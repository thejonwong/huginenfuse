--[[----------------------------------------------------------------------------

Copyright (c) 2014, 2015, Jonathan Wong
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

HuginEnfuse Plugin
------------------------------------------------------------------------------]]

require "settings"
require "gui.browse"
require "gui.hugin"
require "gui.enfuse"
require "gui.config"
-- Access the Lightroom SDK namespaces.

local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrView = import 'LrView'
local LrLogger = import 'LrLogger'
local LrFileUtils = import 'LrFileUtils'
local LrApplication = import 'LrApplication'
local LrExportSession = import 'LrExportSession'
local LrTasks = import 'LrTasks'
local LrProgressScope = import 'LrProgressScope'

local myLogger = LrLogger( 'exportLogger' )
myLogger:enable( "print" ) -- Pass either a string or a table of actions.

--[[
	Main Logic for the HuginEnfuse Plugin
]]

-- Start pre-initialization

-- spawns with each new call - different panos sets will operate individually on their own taskProperties
local taskProperties = {} 

-- Get Active Catalog
local catalog = LrApplication.activeCatalog()
-- Get Selected Photos
taskProperties.selectedPhotos = catalog:getTargetPhotos()
taskProperties.renditionPaths = {}

-- edge case where entire film strip is "accidentally" selected
if catalog:getTargetPhoto() == nil then
	taskProperties.selectedPhotos = nil
end

local HuginEnfuseOptions = import 'LrPrefs'.prefsForPlugin()

-- Determine OS and get Default Settings for plugin
setDefaultSettings(HuginEnfuseOptions)

-- End pre-initialization

local function showMainDialog()
   
	taskProperties.status = "INITIALIZING"

	-- create main gui - assemble the different forms into panels
	local result = LrFunctionContext.callWithContext( "showDialog", function( context )

		local formWidth = 600		
		local catalog = LrApplication.activeCatalog()
		myLogger:trace( string.format("targetphotos %s", catalog:getTargetPhotos()))

		local f = LrView.osFactory()

		local pConfig = f:tab_view_item {
			title = "Configuration",
			identifier = "Configuration",
			getConfigForm(HuginEnfuseOptions, taskProperties)
		}

		local pHugin = f:tab_view_item {
			title = "Hugin",
			identifier = "Hugin",
			getHuginForm(HuginEnfuseOptions, taskProperties)
		}

		local pEnfuse = f:tab_view_item {
			title = "Enfuse",
			identifier = "Enfuse",
			getEnfuseForm(HuginEnfuseOptions, taskProperties)
		}

		local tabs = f:tab_view {
			view = "Configuration",
			pConfig,
			pHugin,
			pEnfuse,
		}

		return LrDialogs.presentModalDialog {
			title = "Lightroom Enfuse plug-in",
			-- actionBind = 
			contents = tabs
		}
		
	end )

    -- cancel the job
	if result == "cancel" then
    	taskProperties.status = "CANCELLED"
	end

end


-- main thread responsible for sending the tasks out
LrTasks.startAsyncTask( function ()

	-- get parent folder of first image
	HuginEnfuseOptions.parentFolder = taskProperties.selectedPhotos[1]:getRawMetadata("path")
	HuginEnfuseOptions.parentFolder = HuginEnfuseOptions.parentFolder:sub(1, string.find(HuginEnfuseOptions.parentFolder, "\\[^\\]*$"))

	-- get leaf path names of all selectedPhotos
	taskProperties.selectedPhotoNames = {}
	taskProperties.selectedPhotoPaths = {}
	for i, p in ipairs(taskProperties.selectedPhotos) do
		taskProperties.selectedPhotoNames[i] = p:getFormattedMetadata("fileName")
		taskProperties.selectedPhotoPaths[i] = p:getRawMetadata("path")
	end

	-- create progressbar first
	local taskProgress = LrProgressScope({
			title = "HuginEnfuse",
		})

	-- allow this task to be cancelled
	taskProgress:setCancelable(true)

	-- wait for possible export or exit
	local checkStatus = function ()
		-- body
		if --taskProperties.status == "CANCELLED" or 
			taskProperties.status == "RENDERED" or 
			taskProgress:isCanceled() then
			return false
		end
		return true
	end

	taskProperties.status = "INITIALIZED"

	-- check to see if task is done rendering or has been cancelled
	while checkStatus() do
		LrTasks.sleep(1)
	end

	if taskProgress:isCanceled() then
		taskProperties.status = "CANCELLED"
		taskProgress:cancel()
		return
	end

	-- Change Task name
	taskProgress:setCaption( string.format("HuginEnfuse : %s", taskProperties.project ))

	-- get folderName for first rendered image
	local photoPath = taskProperties.renditionPaths[1]
	taskProperties.projectFolder = photoPath:sub(1, string.find(photoPath, "\\[^\\]*$"))
	myLogger:trace(string.format("folderName = %s", taskProperties.projectFolder))

	-- rendered now call hugin commands
	local prepareCommands = {}
	if taskProperties.task == "Hugin" then
		prepareCommands = prepareHuginSimpleBatchCommands(HuginEnfuseOptions, HuginEnfuseOptions.path, taskProperties.project, taskProperties.renditionPaths, taskProperties)
	else
		prepareCommands = prepareEnfuseSimpleCommands(HuginEnfuseOptions, HuginEnfuseOptions.path, taskProperties.project, taskProperties.renditionPaths, taskProperties)
		-- write Enfuse commands to the same folder
		file = io.open (constructPath(HuginEnfuseOptions, taskProperties.projectFolder, "enfuse_cmd"), "w")
		myLogger:trace(constructPath(HuginEnfuseOptions, taskProperties.projectFolder, "enfuse_cmd"))
		myLogger:trace(file)
		for i, cmd in ipairs(prepareCommands) do
			file:write(cmd)
		end
		file:close()
	end

	-- create directories (TODO allow user to specify this later)
	local temporaryOutputFolder = string.format("%stemp%s", taskProperties.projectFolder, HuginEnfuseOptions.dirSeparator)

	LrFileUtils.delete(temporaryOutputFolder)
	LrFileUtils.createDirectory(temporaryOutputFolder)

	local totalSubTasks = #prepareCommands + 1
	taskProgress:setPortionComplete(1, totalSubTasks)

	-- execute commands
	for i, cmd in ipairs(prepareCommands) do
		myLogger:trace(string.format("cmd: %s", cmd))
		local status = LrTasks.execute("\""..cmd.."\"")
		taskProgress:setPortionComplete(i+1, totalSubTasks)

		if taskProgress:isCanceled() then
			return
		end

		myLogger:trace(string.format("status %s", status))
	end

	-- automatically reimport finished product
	local finalOutput = string.format("%s%s.TIF", taskProperties.projectFolder, taskProperties.project)
	myLogger:trace(string.format("finaloutput = %s", finalOutput))

	-- check if resulting photo is already in catalog
	catalog:withWriteAccessDo("HuginEnfuseAddResult", function (context)
		
		local result = catalog:findPhotoByPath(finalOutput)
		if result == nil then
			-- photo not found in catalog, add to catalog
			myLogger:trace(string.format("addPhoto", finalOutput))
			result = catalog:addPhoto(finalOutput)
		end
	end)

	taskProgress:done()	

end, "orchestration")

-- Now display the MainDialog.
showMainDialog()

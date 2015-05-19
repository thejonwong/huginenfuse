--[[----------------------------------------------------------------------------

Copyright (c) 2014, 2015, Jonathan Wong
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


------------------------------------------------------------------------------]]
require "helper"

--- Hugin Form
local LrView = import 'LrView'
local LrApplication = import 'LrApplication'
local LrExportSession = import 'LrExportSession'
local LrTasks = import 'LrTasks'
local LrLogger = import 'LrLogger'
local LrDialogs = import 'LrDialogs'
local LrFileUtils = import 'LrFileUtils'
local LrPathUtils = import 'LrPathUtils'

local f = LrView.osFactory()
local catalog = LrApplication.activeCatalog()
local formWidth = 600

local myLogger = LrLogger( 'exportLogger' )

function getHuginForm(HuginEnfuseOptions, taskProperties) 
	return f:column {

		spacing = f:control_spacing(),
		width = formWidth,
		bind_to_object = HuginEnfuseOptions,
		label_spacing = f:label_spacing(),
		spacing = f:control_spacing(),

		f:group_box {
			fill_horizontal = 1,
			title = "Options",

			f:static_text {
				title = "Hugin Project Name"
			},

			f:edit_field {
				bind_to_object = HuginEnfuseOptions,
				value = LrView.bind("suggestedProject"),
				width_in_chars = 50,
			},
		},
		
		f:push_button {
			title = "Export + Auto-Stitch",
			width = label_spacing,
			action = function () 
			-- start automatic stitching process
			-- execute task here since it is "okay to proceed"
			-- where the selected photos reside
	 
			taskProperties.task = "Hugin"

			-- in case of cancel and restart
			if taskProperties.status == "CANCELLED" then
				taskProperties.status = "INITIALIZING"
			end

			-- make sure MainDialog is initialized
			while taskProperties.status ~= "INITIALIZED" do
				LrTasks.sleep(1)
			end

			local projectFolderName = checkResultingFolder(HuginEnfuseOptions, HuginEnfuseOptions.suggestedProject, nil)
			if projectFolderName == "" then
				taskProperties.status = "CANCELLED"
				return
			end

			taskProperties.project = projectFolderName

			myLogger:trace(string.format("ok hugin.status = %s", taskProperties.status))

			LrTasks.startAsyncTask( function()

				local exportParams = {
					photosToExport = taskProperties.selectedPhotos,
					exportSettings = {
						LR_export_destinationType = "sourceFolder",
						LR_export_useSubFolder = true,
						LR_export_destinationPathSuffix = taskProperties.project,
						LR_reimportExportedPhoto = false,
						LR_collisionHandling = "ask",
						LR_format = "TIFF",
						LR_export_bitDepth = 16,
						LRtiff_compressionMethod = "compressionMethod_LZW",
						LR_removeLocationMetadata = true
					}
				}
				exportSession = LrExportSession(exportParams)
				exportSession:doExportOnCurrentTask()

				-- get the paths for all the exported photos after rendering has completed
				if exportSession:countRenditions() == 0 then
					myLogger:trace("export cancelled")
					taskProperties.status = "CANCELLED"
				else
					for i, rendition in exportSession:renditions() do
						taskProperties.renditionPaths[i] = rendition.destinationPath
						myLogger:trace(string.format("renditionPaths = %s", taskProperties.renditionPaths[i]))
					end

			        taskProperties.status = "RENDERED"
		    	end
			end
			)					

			end
	    },

	    f:push_button {
			title = "Launch Hugin (default)",
			width = label_spacing,
			action = function () 
				-- Launch Hugin (non-optimized)

				-- make sure MainDialog is initialized
				while taskProperties.status ~= "INITIALIZED" do
					LrTasks.sleep(1)
				end

				-- first check if #taskProperties.selectedPhotos is 1 and tiff
				launch = ""
				if #(taskProperties.selectedPhotoPaths) == 1 and 
					LrPathUtils.extension(taskProperties.selectedPhotoPaths[1]) == "TIF" then
					myLogger:trace("only1")
					-- launch project corresponding to the name of the TIF
					local photopath = taskProperties.selectedPhotoPaths[1]
					myLogger:trace(photopath)
					local huginPTOPath = LrPathUtils.replaceExtension(photopath, "pto")
					myLogger:trace(huginPTOPath)
					
					-- check if PTO file exists
					if LrFileUtils.exists(huginPTOPath) then
						launch = execString(HuginEnfuseOptions, HuginEnfuseOptions.path, "hugin", huginPTOPath)
					end

				else
					-- more than one file has been selected
					-- 1. look at the photos selected and determine parentFolder based on selectedPhoto[1]
					-- 2. get the subfolder corresponding to the prefix project name if it exists
					-- 3. take the prefix project name and look to see if the pto file corresponding exists

				end
				-- launch the resulting pto file
				if launch ~= "" then
					LrTasks.startAsyncTask( function()
						LrTasks.execute("\""..launch.."\"")
					end)
				end
			end
		},
	}
end

-- script hugin to prepare commands to execute
function prepareHuginSimpleBatchCommands(HuginEnfuseOptions, huginPath, prefixName, photoPaths, taskProperties)

	-- first flatten photoPaths and escape with quotes for windows
	local photoPathsFlattened = ""
	for _, photoPath in ipairs(photoPaths) do
		photoPathsFlattened = photoPathsFlattened .. " " .. string.format("%s",photoPath)
	end

	local optimizedProjectName = string.format("\"%s%s-optimized.pto\"", taskProperties.projectFolder, prefixName)
	local projectName = string.format("\"%s%s.pto\"", taskProperties.projectFolder, prefixName)
	local temporaryOutput = string.format("\"%stemp%s%s\"", taskProperties.projectFolder, HuginEnfuseOptions.dirSeparator, prefixName)

	return {
		execString(HuginEnfuseOptions, huginPath, "pto_gen", string.format("-o %s %s", projectName, photoPathsFlattened)),
		execString(HuginEnfuseOptions, huginPath, "cpfind", string.format("--multirow -o %s %s", projectName, projectName)),
		execString(HuginEnfuseOptions, huginPath, "celeste_standalone", string.format("-i %s -o %s", projectName, projectName)),
		execString(HuginEnfuseOptions, huginPath, "ptoclean", string.format("-v --output %s %s", projectName, projectName)),
		execString(HuginEnfuseOptions, huginPath, "autooptimiser", string.format("-a -s -l -m -o %s %s", optimizedProjectName, projectName)),
		execString(HuginEnfuseOptions, huginPath, "pano_modify", string.format("-o %s --center --canvas=AUTO %s", optimizedProjectName, optimizedProjectName)),
		execString(HuginEnfuseOptions, huginPath, "nona", string.format("-m TIFF_m -o %s %s", temporaryOutput  ,optimizedProjectName)),
		execString(HuginEnfuseOptions, huginPath, "enblend", string.format("-o %s.TIF %s*.tif", taskProperties.projectFolder .. prefixName, temporaryOutput)),
	}
end

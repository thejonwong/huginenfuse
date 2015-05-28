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

-- Enfuse form	
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

function generateSlider(title, bindStr)
	return	f:row {
		fill_horizonal = 1,

		f:static_text {
			title = title,
			alignment = "right",
			width = LrView.share "label_width",
		},

		f:slider {
			width = 300,
			value = LrView.bind(bindStr),
			min = 0.0,
			max = 1.0,
		},

		f: edit_field {
			value = LrView.bind(bindStr),
			width_in_chars = 4,
		},
	}
end

function getEnfuseForm(HuginEnfuseOptions, taskProperties) 

	function exportEnfuse (bExport) 
			-- start enfuse! process
		taskProperties.task = "Enfuse"

		-- in case of cancel and restart
		if taskProperties.status == "CANCELLED" then
			taskProperties.status = "INITIALIZED"
		end

		-- make sure MainDialog is initialized
		while taskProperties.status == "INITIALIZING" do
			LrTasks.sleep(1)
		end

		if bExport then

			local projectFolderName = checkResultingFolder(HuginEnfuseOptions, HuginEnfuseOptions.suggestedEnfuse, nil)
			if projectFolderName == "" then
				taskProperties.status = "CANCELLED"
				return
			end

			taskProperties.project = projectFolderName

			myLogger:trace(string.format("ok enfuse.status = %s", taskProperties.status))

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
					myLogger:trace(exportSession)
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
		else
	
			-- here we assume that files have already been rendered to suggestedEnfuse, if they haven't throw an error
			local projectFolderName = checkForProjectFolder(HuginEnfuseOptions, HuginEnfuseOptions.suggestedEnfuse, nil)
	
			if projectFolderName == "" then
				taskProperties.status = "CANCELLED"
				return
			end

			taskProperties.project = projectFolderName
	
			-- how do we set the renditionPaths? (currently look for TIFF corresponding to images)
			for i, path in ipairs(taskProperties.selectedPhotoNames) do
				-- check if each photo in selected Photos exists in the subFolder		
				possibleRenderedPath = constructPath(HuginEnfuseOptions, 
											constructPath(HuginEnfuseOptions, HuginEnfuseOptions.parentFolder, projectFolderName),
											LrPathUtils.leafName(
												LrPathUtils.replaceExtension(path, "tif")))
				myLogger:trace( possibleRenderedPath )
				if LrFileUtils.exists(possibleRenderedPath) == false then
					taskProperties.status = "CANCELLED"
					return
				else
					taskProperties.renditionPaths[i] = possibleRenderedPath
				end
			end

			-- a little messy, but we'll claim we're in the rendered state (techincally true)
			taskProperties.status = "RENDERED"
		end
	end

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
				title = "Enfuse Prefix Name (subfolder)"
			},

			f:edit_field {
				bind_to_object = HuginEnfuseOptions,
				value = LrView.bind("suggestedEnfuse"),
				width_in_chars = 50,
			},
		},

		f:group_box {
			bind_to_object = HuginEnfuseOptions,
			fill_horizontal = 1,
			title = "Enfuse Settings",

			generateSlider("Exposure", "enfuseExp"),
			generateSlider("Saturation", "enfuseSat"),			
			generateSlider("Contrast", "enfuseCon"),						
			generateSlider("Mu", "enfuseMu"),
			generateSlider("Sigma", "enfuseSigma"),
		},

		f:push_button {
			title = "Export + Enfuse",
			width = label_spacing,
			action = function () 
				exportEnfuse(true) 
			end,
		},


		f:push_button {
			title = "Enfuse",
			width = label_spacing,
			action = function ()
				-- exportEnfuse will go through the motions of exporting and get the proper paths
				exportEnfuse(false) 
			end,
		},

--[[ TODO: Fix the action of these buttons
		f:push_button {
			title = "Clean Up",
			width = label_spacing,
			action = function () 
				-- finished stitching clean up temporary nona files
				-- create directories (TODO allow user to specify this later)
				local temporaryOutputFolder = string.format("%stemp%s", taskProperties.projectFolder, HuginEnfuseOptions.dirSeparator)
				LrFileUtils.delete(temporaryOutputFolder)
			end
		}
		--]]

	}
end

-- script enfuse to prepare commands to execute
function prepareEnfuseSimpleCommands(HuginEnfuseOptions, EnfusePath, prefixName, photoPaths, taskProperties)
	-- first flatten photoPaths and escape with quotes for windows
	local photoPathsFlattened = ""
	for _, photoPath in ipairs(photoPaths) do
		photoPathsFlattened = photoPathsFlattened .. " " .. string.format("\"%s\"",photoPath)
	end

	local temporaryOutputFolder = string.format("\"%stemp%s*.tif\"", taskProperties.projectFolder, HuginEnfuseOptions.dirSeparator)
	local temporaryOutput = string.format("\"%stemp%s%s\"", taskProperties.projectFolder, HuginEnfuseOptions.dirSeparator, prefixName)

	-- Enfuse options
	exp = HuginEnfuseOptions.enfuseExp
	sat = HuginEnfuseOptions.enfuseSat
	con = HuginEnfuseOptions.enfuseCon
	mu = HuginEnfuseOptions.enfuseMu
	sigma = HuginEnfuseOptions.enfuseSigma

	return {
		execString(HuginEnfuseOptions, EnfusePath, "align_image_stack", string.format("-m -a %s %s", temporaryOutput, photoPathsFlattened)),
		execString(HuginEnfuseOptions, EnfusePath, "enfuse", string.format("-o %s.TIF --hard-mask --compression=LZW --exposure-weight=%1.2f --saturation-weight=%1.2f --contrast-weight=%1.2f --exposure-mu=%1.2f --exposure-sigma=%1.2f %s", taskProperties.projectFolder .. prefixName, exp, sat, con, mu, sigma, temporaryOutputFolder))
	}
end
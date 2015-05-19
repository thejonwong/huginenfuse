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

-- Config form	
local LrView = import 'LrView'
local LrApplication = import 'LrApplication'
local LrExportSession = import 'LrExportSession'
local LrTasks = import 'LrTasks'
local LrLogger = import 'LrLogger'
local LrDialogs = import 'LrDialogs'
local LrFileUtils = import 'LrFileUtils'

local f = LrView.osFactory()
local catalog = LrApplication.activeCatalog()
local formWidth = 600

local myLogger = LrLogger( 'exportLogger' )

-- Define Configuration Panel
function getConfigForm(HuginEnfuseOptions, taskProperties)
	return f:column {

		spacing = f:control_spacing(),
		width = formWidth,
		bind_to_object = HuginEnfuseOptions,
		label_spacing = f:label_spacing(),
		spacing = f:control_spacing(),

		f:group_box {
			fill_horizontal = 1,
			title = "Hugin Configuration",

			f:static_text {
				title = "Path to the Hugin Folder"
			},

			browseableLocation {
				title = "Path to the Hugin Folder",
				object = HuginEnfuseOptions,
				value = "path",
				name = "Browse...",
				button_width = label_spacing,
				check = function ( path )
					-- check to make sure hugin, enfuse, and align are in that directory
					if LrFileUtils.exists(HuginEnfuseOptions.execString(path, "align_image_stack", "")) and
					   LrFileUtils.exists(HuginEnfuseOptions.execString(path, "enfuse", "")) and
					   LrFileUtils.exists(HuginEnfuseOptions.execString(path, "hugin", "")) then
					   return true
					end
					LrDialogs.message("One of the following could not be found at the specified path:\n align_image_stack, enfuse, hugin")
					return false
				end,
			},
		}			
	}
end
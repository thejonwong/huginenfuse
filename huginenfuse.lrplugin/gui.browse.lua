--[[----------------------------------------------------------------------------

Copyright (c) 2014, 2015, Jonathan Wong
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


------------------------------------------------------------------------------]]

--- Browse locations

local LrDialogs = import 'LrDialogs'
local LrView = import 'LrView'

local function showBrowseableLocation(properties)

	return function ()
		local results = LrDialogs.runOpenPanel {
			title = properties.title,
			prompt = "Select Folder",
			canChooseDirectories = true,
			canChooseFiles = false,
		}

		myLogger:trace( string.format("showBrowseableLocation %s", results[1] or nil ))
		if results then
			if properties.check == nil or properties.check(results[1]) then
				(properties.object)[(properties.value)] = results[1]
			end
		end
	end
end

-- helper function for creating path boxes
function browseableLocation(properties)

	local f = LrView.osFactory()

	return	f:row {
		bind_to_object = properties.object,

		f:edit_field {
			value = LrView.bind(properties.value),
			width_in_chars = 50,
		},

		f:push_button {
			title = properties.name,
			width = properties.button_width,
			action = showBrowseableLocation(properties)
	    }
	}
end
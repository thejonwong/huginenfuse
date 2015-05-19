--[[----------------------------------------------------------------------------

Copyright (c) 2015, Jonathan Wong
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
------------------------------------------------------------------------------]]

--- Helper Functions

local LrDialogs = import 'LrDialogs'
local LrFileUtils = import 'LrFileUtils'

-- check if the folder exists already - if it does suggest an alternate
function checkResultingFolder (HuginEnfuseOptions, value, fromModel)
	local suggestedPath = string.format("%s%s",
		HuginEnfuseOptions.parentFolder,value)

	if LrFileUtils.exists(suggestedPath) then
	--[[ check if path exists 
	-if it does, create a yes-no-dialog to ask if the person wants to keep the same name
	 or create a new folder 
	-if no, use uniquePath to propose one ]]
		local result = LrDialogs.confirm(string.format("The path %s already exists. Do you want to build this panorama in the same location?", suggestedPath),
				"Alternatively, you can select to have an auto-generated unique path by selecting \"Generate Unique\"",
				"Yes",
				"No",
				"Generate Unique")

		if result == "ok" then
			return value
		elseif result == "cancel" then
			return ""
		else
			local uniquePath = LrFileUtils.chooseUniqueFileName(suggestedPath)
			local uniqueFolder = uniquePath:sub(string.find(uniquePath, "\\[^\\]*$")+1)
			return uniqueFolder
		end
	else
		return value
	end
end

-- check for folder - if it doesn't exist produce an error
function checkForProjectFolder (HuginEnfuseOptions, value, fromModel)
	local suggestedPath = string.format("%s%s",
		HuginEnfuseOptions.parentFolder,value)

	if LrFileUtils.exists(suggestedPath) then
		return value
	else
		LrDialogs.message(string.format("The directory %s does not exist. Please set the prefix name pointing to the subfolder properly", 
			suggestedPath))
		return ""
	end
end

-- helper function to generate shell commands
function execString(HuginEnfuseOptions, Path, executable, options)
	return string.format("\"%s%s%s%s\" %s", Path, HuginEnfuseOptions.dirSeparator, executable, HuginEnfuseOptions.exe, options)
end

function constructPath(HuginEnfuseOptions, Path, file)
	return string.format("%s%s%s", Path, HuginEnfuseOptions.dirSeparator, file)
end
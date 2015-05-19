--[[----------------------------------------------------------------------------

Copyright (c) 2014, 2015, Jonathan Wong
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


------------------------------------------------------------------------------]]

--- Global Settings

local LrTasks = import 'LrTasks'
local LrLogger = import 'LrLogger'
local LrFileUtils = import 'LrFileUtils'

local myLogger = LrLogger( 'exportLogger' )
myLogger:enable( "print" ) -- Pass either a string or a table of actions.

-- set default setting if it hasn't been set yet with the given value
function setDefaultSetting(settings, name, value)
	if settings[name] == nil then
		settings[name] = value
	end
end


-- make sure to execute setDefaultSettings from within the main task thread
function setDefaultSettings(HuginEnfuseOptions)

	-- detect Operating System
	if LrFileUtils.exists("C:\\Windows") then
		HuginEnfuseOptions.OS = "Windows"
	elseif LrFileUtils.exists("/Applications") then
		HuginEnfuseOptions.OS = "Mac"
	end

	myLogger:trace(string.format("Operating System = %s", HuginEnfuseOptions.OS))

	-- see if values have been already set, if not pre-initialize
	-- OS specific
	if HuginEnfuseOptions.OS == "Windows" then
		setDefaultSetting(HuginEnfuseOptions, "path", "C:\\Program Files\\Hugin\\bin\\")
		setDefaultSetting(HuginEnfuseOptions, "dirSeparator", "\\")
		setDefaultSetting(HuginEnfuseOptions, "exe", ".exe")

	elseif HuginEnfuseOptions == "Mac" then
		setDefaultSetting(HuginEnfuseOptions, "dirSeparator", "/")
	end

	-- Hugin specific names
	setDefaultSetting(HuginEnfuseOptions, "suggestedProject", "pano")
	setDefaultSetting(HuginEnfuseOptions, "suggestedEnfuse", "fuse")

	-- Enfuse Settings
	setDefaultSetting(HuginEnfuseOptions, "enfuseExp", 1.0)
	setDefaultSetting(HuginEnfuseOptions, "enfuseSat", 0.2)
	setDefaultSetting(HuginEnfuseOptions, "enfuseCon", 0.0)
	setDefaultSetting(HuginEnfuseOptions, "enfuseMu", 0.5)
	setDefaultSetting(HuginEnfuseOptions, "enfuseSigma", 0.2)

end


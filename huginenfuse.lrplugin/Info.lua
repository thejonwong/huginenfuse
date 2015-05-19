--[[----------------------------------------------------------------------------

Copyright (c) 2014, 2015, Jonathan Wong
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


--------------------------------------------------------------------------------

Info.lua
Provides Lightroom with quick scripted access for making panoramas and retains the 
Hugin and Enfuse project files for later use

------------------------------------------------------------------------------]]

return {
	
	LrSdkVersion = 5.0,
	LrSdkMinimumVersion = 4.0, -- minimum SDK version required by this plug-in

	LrToolkitIdentifier = 'com.jonjwong.lightroom.HuginEnfuse',

	LrPluginName = LOC "$$$/HuginEnfuse/PluginName=HuginEnfuse",
	
	-- Add the menu item to the File menu.
	
	LrExportMenuItems = {
		title = "Hugin/Enfuse photos",
		file = "MainDialog.lua",
	},

	VERSION = { major=0, minor=1, revision=0, build=101514, },

	LrPluginInfoUrl = 'http://www.jonjwong.com/lrhuginenfuse.html',

}


	
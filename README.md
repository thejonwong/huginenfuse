# huginenfuse
A lua plugin to access basic panorama (hugin) and exposure fusion (enfuse) capabilities directly from Lightroom.

Goals
=====
This project uses the Hugin Panoramic tools both for automatically stitching panoramas and for basic exposure fusion using enfuse. The code is licensed under the BSD 3-Clause license to encourage developement of this plugin and to act as a starting point to enable others to create similar plugins for other photography related open-source applications.

Plugin Features:

* Export and automatically stitch panoramas using hugin with selected images
* Create exposure fusion of selected images using enfuse
* Stitch and enfuse different projects at the same time
* Save Hugin project files and commands for enfuse in case the panorama or exposure fusion needs to be adjusted
* Quick access buttons to automate different tasks (i.e., Launch Hugin projects from LR, redo exposure fusion without export, etc..)
* Basic OS detection
* Hugin project can be launch when a TIF panorama is selected (pto must be in the same folder)
* Basic setting selection

Planned Features:

* enable users to specify a temporary folder (case for SSD/ramdisk)
* project cleanup information

Installation
============
1. Download [Hugin Tools] (http://hugin.sourceforge.net/) and Install
2. Save the huginenfuse.lrplugin directory to a suitable permanent location
3. Import the plugin using Lightroom
4. Specify the path to hugin tools folder (where hugin, enfuse, align_image_stack binaries reside)
5. Select "Hugin" or "Enfuse" tabs to perform a specific action.

Tested Platforms
================

* Windows 8.1 64-bit: Hugin and Enfuse


Background
==========
HuginEnfuse was written as an excuse to learn Lua and because I simply got tired of having to export pictures from Lightroom, setup Hugin options and run the optimizations, then wait for the stitch to finish, and then reimport into Lightroom. Although an exposure fusion plugin for lightroom already exists, as Hugin and Enfuse are open source tools, I believe it would be appropriate to create an alternative open source plugin that would allow other photographers to freely create exposure fusion images or stich panoramas quickly from Lightroom.

The process has been rewarding so far and I hope to continue to work on adding additional features and resolving bugs that I run into along the way. So far I've been using the plugin for awhile and I feel it's at a good enough state in which I can now share with the community. I hope that many nifty panoramas and exposure fusions can be created from this plugin.

"For his invisible attributes, namely, his eternal power and divine nature, have been clearly perceived, ever since the creation of the world, in the things that have been made..."
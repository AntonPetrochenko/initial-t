--[[
-------------------------------------------------------------------------------
-- @author Colby Klein
-- @author Landon Manning
-- @copyright 2016
-- @license MIT/X11
-------------------------------------------------------------------------------
                  .'@@@@@@@@@@@@@@#:
              ,@@@@#;            .'@@@@+
           ,@@@'                      .@@@#
         +@@+            ....            .@@@
       ;@@;         '@@@@@@@@@@@@.          @@@
      @@#         @@@@@@@@++@@@@@@@;         `@@;
    .@@`         @@@@@#        #@@@@@          @@@
   `@@          @@@@@` Cirno's  `@@@@#          +@@
   @@          `@@@@@  Perfect   @@@@@           @@+
  @@+          ;@@@@+   Math     +@@@@+           @@
  @@           `@@@@@  Library   @@@@@@           #@'
 `@@            @@@@@@          @@@@@@@           `@@
 :@@             #@@@@@@.    .@@@@@@@@@            @@
 .@@               #@@@@@@@@@@@@;;@@@@@            @@
  @@                  .;+@@#'.   ;@@@@@           :@@
  @@`                            +@@@@+           @@.
  ,@@                            @@@@@           .@@
   @@#          ;;;;;.          `@@@@@           @@
    @@+         .@@@@@          @@@@@           @@`
     #@@         '@@@@@#`    ;@@@@@@          ;@@
      .@@'         @@@@@@@@@@@@@@@           @@#
        +@@'          '@@@@@@@;            @@@
          '@@@`                         '@@@
             #@@@;                  .@@@@:
                :@@@@@@@++;;;+#@@@@@@+`
                      .;'+++++;.
--]]
local modules = (...) and (...):gsub('%.init$', '') .. ".modules." or ""

local cpml = {
	_LICENSE = "CPML is distributed under the terms of the MIT license. See LICENSE.md.",
	_URL = "https://github.com/excessive/cpml",
	_VERSION = "1.2.9",
	_DESCRIPTION = "Cirno's Perfect Math Library: Just about everything you need for 3D games. Hopefully."
}

local files = {
	"bvh",
	"color",
	"constants",
	"intersect",
	"mat4",
	"mesh",
	"octree",
	"quat",
	"simplex",
	"utils",
	"vec2",
	"vec3",
	"bound2",
	"bound3",
}


cpml.bvh        =  require('cpml.modules.bvh')
cpml.color      =  require('cpml.modules.color')
cpml.constants  =     require('cpml.modules.constants')
cpml.intersect  =     require('cpml.modules.intersect')
cpml.mat4       =      require('cpml.modules.mat4')
cpml.mesh       =      require('cpml.modules.mesh')
cpml.octree     =      require('cpml.modules.octree')
cpml.quat       =      require('cpml.modules.quat')
cpml.simplex    =      require('cpml.modules.simplex')
cpml.utils      =      require('cpml.modules.utils')
cpml.vec2       =      require('cpml.modules.vec2')
cpml.vec3       =      require('cpml.modules.vec3')
cpml.bound2     =      require('cpml.modules.bound2')
cpml.bound3     =      require('cpml.modules.bound3')
return cpml

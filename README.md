# aapi2
AceAPIv2 is a module for FlyWithLUA for X-Plane 11.
https://forums.x-plane.org/index.php?/files/file/38445-flywithlua-ng-next-generation-edition-for-x-plane-11-win-lin-mac/

Using this module you can create custom windows environment for your plugins.
This software is released under GNU GPLv3 license.
This software comes with no warranty - use at your own risk!

Installation:
Copy "aapi2.lua" file into "[X-Plane 11]\Resources\plugins\FlyWithLua\Modules\"

*v2.03:
  - Added "table" object
  - Added "editbox" object
  - Added events for windows (mandatory property)
  - Added basic window focus control
  - Fixed minor graphical bugs introduced FLWNG

---------------------------------------------------------------------------------------------------------------------------
Object prototypes:
---------------------------------------------------------------------------------------------------------------------------
- window:
  ["name"] = "Window1",
  ["show"] = true,
  ["x"] = 100,
  ["y"] = 100,
  ["w"] = 800,
  ["h"] = 600,
  ["limits"] = { ["min_x"]=200, ["min_y"]=100, ["max_x"]=1000, ["max_y"]=1000 },
  ["header"] = {
    ["enabled"] = true,
    ["title"] = "Window1",
    ["h"] = 20,
    ["movable"] = true,
    ["close"] = true,
    ["border"] = 1,
    ["color"] = { ["br"]=0.1, ["bg"]=0.2, ["bb"]=0.4, ["ba"]=0.9, ["fr"]=1, ["fg"]=1, ["fb"]=1, ["fa"]=0.9 },
    ["components"] =  {},
  },
  ["body"] = { 
    ["border"] = 1,
    ["color"] = { ["br"]=0.0, ["bg"]=0.0, ["bb"]=0.1, ["ba"]=0.9, ["fr"]=1, ["fg"]=1, ["fb"]=1, ["fa"]=0.9 },
    ["components"] =  {},
  },
  ["events"] = {
    ["on_click"] = "",
    ["on_wheel"] = "",
    ["on_drag"] = "",
    ["on_close"] = ""
  }	
---------------------------------------------------------------------------------------------------------------------------
- label:
  ["type"] = "label",
  ["name"] = "Label1",
  ["x"] = 10, ["y"] = 10,
  ["color"] = { ["r"]=1, ["g"]=1, ["b"]=1 },
  ["text"] = "Label1"
---------------------------------------------------------------------------------------------------------------------------
- box:
  ["type"] = "box",
  ["name"] = "Box1",	
  ["x"] = 10,	["y"] = 10,
  ["w"] = 100,	["h"] = 100,
  ["color"] = { ["r"]=0.0, ["g"]=0.1, ["b"]=0.1, ["a"]=0.5 },
  ["border"] = {
    ["size"] = 2,
    ["color"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=0.6 }
  }
---------------------------------------------------------------------------------------------------------------------------  
- line:
  ["type"] = "line",
  ["name"] = ":ine1",
  ["x"] = 10, ["y"] = 10,
  ["x2"] = 100, ["y2"] = 100,
  ["width"] = 1,
  ["color"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=0.5 } 
---------------------------------------------------------------------------------------------------------------------------
- led:
  ["type"] = "led",
  ["name"] = "Led1",
  ["x"] = 10, ["y"] = 10,
  ["w"] = 10, ["h"] = 10,
  ["color"] = { 
    ["off"] = { ["r"]=0.0, ["g"]=0.0, ["b"]=0.4, ["a"]=0.9 },
    ["on"] = { ["r"]=0.1, ["g"]=0.9, ["b"]=0.7, ["a"]=0.9 }
  },
  ["border"] = {
    ["size"] = 1,
    ["color"] = { ["r"]=1, ["g"]=1, ["b"]=1, ["a"]=0.9 }
  },
  ["control"] = {
    ["enabled"] = true,
  },	
  ["state"] = "off",
  ["events"] = {
    ["on_click"] = "",
    ["on_wheel"] = "",
    ["on_drag"] = ""
  }				
---------------------------------------------------------------------------------------------------------------------------
- progress_bar:
  ["type"] = "progress_bar",
  ["name"] = "ProgressBar1",	
  ["x"] = 10, ["y"] = 10,
  ["w"] = 150, ["h"] = 20,
  ["color"] = { 
    ["bg"] = { ["r"]=0.0, ["g"]=0.0, ["b"]=0.1, ["a"]=0.9 },
    ["fg"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=0.9 },
    ["pb"] = { ["r"]=0.7, ["g"]=0.7, ["b"]=1.0, ["a"]=0.9 }
  },
  ["border"] = {
    ["size"] = 1,
  },
  ["bar"] = { 
    ["min"] = 0,
    ["max"] = 100,
    ["pos"] = 0,
    ["dir"] = "right",
    ["border"] = {
      ["size"] = 0,
    }
  },
  ["control"] = {
    ["enabled"] = true,
    ["delta_small"] = 1,
    ["delta_big"] = 10,
    ["delta_wheel"] = 1,
  },
  ["label"] = {
    ["enabled"] = true,
    ["units"] = ""
  },
  ["events"] = {
    ["on_click"] = "",
    ["on_wheel"] = "",
    ["on_drag"] = ""
  }			
---------------------------------------------------------------------------------------------------------------------------  
- slider:
	["type"] = "slider",
	["name"] = "Slider1",	
	["x"] = 10, ["y"] = 10,
	["w"] = 200, ["h"] = 20,
	["color"] = { 
		["bg"] = { ["r"]=0.0, ["g"]=0.0, ["b"]=0.1, ["a"]=0.9 },
		["fg"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=0.9 },
		["pb"] = { ["r"]=0.5, ["g"]=0.5, ["b"]=1.0, ["a"]=0.5 }
	},
	["border"] = {
		["size"] = 1,
	},
	["bar"] = { 
		["min"] = 0,
		["max"] = 100,
		["pos"] = 0,
		["dir"] = "right",
		["border"] = {
			["size"] = 15,
		}
	},
	["control"] = {
		["enabled"] = true,
		["delta_small"] = 1,
		["delta_big"] = 10,
		["delta_wheel"] = 1,
		["buttons"] = {
			["enabled"] = true,
			["size"] = 10,
			["thickness"] = 2,
		},
	},
	["label"] = {
		["enabled"] = true,
		["units"] = ""
	},
	["events"] = {
		["on_click"] = "",
		["on_wheel"] = "",
		["on_drag"] = ""
	}	
---------------------------------------------------------------------------------------------------------------------------  
- textbox:
  ["type"] = "textbox",
  ["name"] = "TextBox1",
  ["x"] = 10, ["y"] = 10,
  ["w"] = 85, ["h"] = 20,
  ["color"] = { 
    ["bg"] = { ["r"]=0.0, ["g"]=0.0, ["b"]=0.1, ["a"]=0.9 },
    ["fg"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=0.9 },
  },
  ["border"] = {
    ["size"] = 1,
    ["color"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=0.9 }
  },
  ["label"] = "TextBox1",
  ["text"] = "TextBox1"
  
- button:
  ["type"] = "button",
  ["mode"] = "button", --"button" or "switch"
  ["name"] = "Button1",
  ["x"] = 10, ["y"] = 10,
  ["w"] = 60, ["h"] = 20,
  ["color"] = { 
    ["off"] = { ["r"]=0.3, ["g"]=0.3, ["b"]=0.5, ["a"]=0.9 },
    ["on"] = { ["r"]=0.1, ["g"]=0.9, ["b"]=0.7, ["a"]=0.9 },
    ["fg"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=0.9 },
  },
  ["border"] = {
    ["size"] = 1,
    ["color"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=0.9 }
  },
  ["text"] = {
    ["off"] = "Off",
    ["on"] = "On",
  },
  ["state"] = "off",
  ["events"] = {
    ["on_click"] = "",
    ["on_wheel"] = "",
    ["on_drag"] = ""
  }
---------------------------------------------------------------------------------------------------------------------------      
- editbox:
	["type"] = "editbox",
	["name"] = "EditBox1",
	["x"] = 10, ["y"] = 10,
	["w"] = 120, ["h"] = 20,
	["color"] = { 
		["normal"] = { ["r"]=0.1, ["g"]=0.1, ["b"]=0.2, ["a"]=0.9 },
		["focus"] = { ["r"]=0.25, ["g"]=0.35, ["b"]=0.45, ["a"]=0.9 },
		["fg"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=0.9 },
	},
	["border"] = {
		["size"] = 1,
		["color"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=0.9 }
	},
	["text"] = "EditBox1",
	["filters"] = { "%w", "%p", "%s" },
	["max_len"] = 20,
	["events"] = {
		["on_click"] = "",
		["on_wheel"] = "",
		["on_drag"] = "",
		["on_enter"] = ""
	}
---------------------------------------------------------------------------------------------------------------------------  
- table:
  ["type"] = "table",
  ["name"] = "Table1",
  ["x"] = 10, ["y"] = 10,
  ["w"] = 400, ["h"] = 300,
  ["color"] = { 
    ["bg"] = { ["r"]=0.1, ["g"]=0.1, ["b"]=0.2, ["a"]=0.5 },
    ["fg"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=0.9 },
  },
  ["border"] = {
    ["size"] = 0,
    ["color"] = { ["r"]=0.98, ["g"]=0.99, ["b"]=1.0, ["a"]=0.9 }
  },
  ["events"] = {
    ["on_click"] = "",
    ["on_wheel"] = "",
    ["on_drag"] = ""
  },
  ["table"] = {
    ["row_colors"] = {
      { ["r"]=0.8, ["g"]=0.9, ["b"]=1.0, ["a"]=0.1 },
      { ["r"]=0.8, ["g"]=0.9, ["b"]=1.0, ["a"]=0.125 },
    },
    ["columns"] = {	
      { ["name"] = "Column 1",	["width"] = 125,	["align"] = "left" },
      { ["name"] = "Column 2",	["width"] = 125,	["align"] = "left" },
      { ["name"] = "Column 3", 	["width"] = 125,	["align"] = "left" },
    },
    ["header"] = {
      ["enabled"] = true,
      ["height"] = 20,
    },
    ["scrollbar"] = {
      ["enabled"] = true,
      ["size"] = 15,
      ["pos"] = 1,
    },
    ["row_height"] = 20,
    ["selection"] = {
      ["row"] = 0,
      ["color"] = { ["r"]=0.8, ["g"]=0.9, ["b"]=1.0, ["a"]=0.5 },
    },
    ["display"] = {
      ["start"] = 1
    },
    ["rows"] = {
      { "R1C1", "R1C2", "R1C3" },
    },
  },
---------------------------------------------------------------------------------------------------------------------------  

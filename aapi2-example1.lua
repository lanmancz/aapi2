require("aapi2")
local i = nil	-- Instance handle
local w = nil	-- Window handle

-- Create AceAPI instance
i = aapi2.CreateInstance("ExampleInstance")

local _ex_win_width = 800	-- Example window width
local _ex_win_height = 600	-- Example window height
-- ------------------------------------------------------------------------------------------------
-- Create a window
local _p = {
	["name"] = "ExampleWindow1",
	["show"] = true,
	["x"] = (SCREEN_WIDTH/2) - math.floor(_ex_win_width/2),
	["y"] = (SCREEN_HIGHT/2) - math.floor(_ex_win_height/2),
	["w"] = _ex_win_width,
	["h"] = _ex_win_height,
	["limits"] = { ["min_x"]=200, ["min_y"]=100, ["max_x"]=1000, ["max_y"]=1000 },
	["header"] = {
		["enabled"] = true,
		["title"] = "ExampleWindow1",
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
	["events"] = {		-- Call a function from globalspace on event
		["on_click"] = "",
		["on_wheel"] = "",
		["on_drag"] = "",
		["on_close"] = ""
	}		
}
-- Register new window in our aapi2 instance (i) and grab the handle (w)
w = aapi2.CreateWindow(i, _p)
-- ------------------------------------------------------------------------------------------------
-- Create label object
local _p = {
	["type"] = "label",
	["name"] = "Label1",
	["x"] = 10, ["y"] = 15,
	["color"] = { ["r"]=1, ["g"]=1, ["b"]=1 },
	["text"] = "Label1 - this is a simple text label",
	["font"] = "std",	-- std, h10, h12, h18
}
-- Register new component in aapi2
aapi2.CreateComponent(i, w, _p)
-- ------------------------------------------------------------------------------------------------
-- Create editbox object
local _p = {
	["type"] = "editbox",
	["name"] = "EditBox1",
	["x"] = 10, ["y"] = 30,
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
	["text"] = "some text",
	["filters"] = { "%w", "%p", "%s" },
	["max_len"] = 20,
	["events"] = {
		["on_click"] = "",
		["on_wheel"] = "",
		["on_drag"] = "",
		["on_enter"] = ""
	}
}
aapi2.CreateComponent(i, w, _p)
-- ------------------------------------------------------------------------------------------------
-- Create button object
local _p = {
	["type"] = "button",
	["mode"] = "switch", -- "button" or "switch"
	["name"] = "Switch1",
	["x"] = 150, ["y"] = 30,
	["w"] = 80, ["h"] = 20,
	["color"] = { 
		["off"] = { ["r"]=0.3, ["g"]=0.3, ["b"]=0.5, ["a"]=0.9 },
		["on"] = { ["r"]=1.0, ["g"]=0.9, ["b"]=0.5, ["a"]=0.7 },
		["fg"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=0.9 },
	},
	["border"] = {
		["size"] = 1,
		["color"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=0.9 }
	},
	["text"] = {
		["off"] = "Off",
		["on"] = "ON",
	},
	["state"] = "off",
	["events"] = {
		["on_click"] = "",
		["on_wheel"] = "",
		["on_drag"] = ""
	}
}
aapi2.CreateComponent(i, w, _p)	
-- ------------------------------------------------------------------------------------------------
-- Create textbox object
local _p = {
	["type"] = "textbox",
	["name"] = "TextBox1",
	["x"] = 10, ["y"] = 60,
	["w"] = 120, ["h"] = 20,
	["color"] = { 
		["bg"] = { ["r"]=0.0, ["g"]=0.0, ["b"]=0.1, ["a"]=0.9 },
		["fg"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=0.9 },
	},
	["border"] = {
		["size"] = 1,
		["color"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=0.9 }
	},
	["label"] = "",
	["text"] = "text here"
}
aapi2.CreateComponent(i, w, _p)
-- ------------------------------------------------------------------------------------------------
-- Create button object
local _p = {
	["type"] = "button",
	["mode"] = "button", -- "button" or "switch"
	["name"] = "Button1",
	["x"] = 150, ["y"] = 60,
	["w"] = 80, ["h"] = 20,
	["color"] = { 
		["off"] = { ["r"]=0.3, ["g"]=0.3, ["b"]=0.5, ["a"]=0.9 },
		["on"] = { ["r"]=1.0, ["g"]=0.9, ["b"]=0.5, ["a"]=0.7 },
		["fg"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=0.9 },
	},
	["border"] = {
		["size"] = 1,
		["color"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=0.9 }
	},
	["text"] = {
		["off"] = "Button",
		["on"] = "Button",
	},
	["state"] = "off",
	["events"] = {
		["on_click"] = "ExampleButtonCallback",
		["on_wheel"] = "",
		["on_drag"] = ""
	}
}
aapi2.CreateComponent(i, w, _p)	
-- ------------------------------------------------------------------------------------------------
-- Create another label object in front of a led (next component)
local _p = {
	["type"] = "label",
	["name"] = "Label2",
	["x"] = 30, ["y"] = 96,
	["color"] = { ["r"]=1, ["g"]=1, ["b"]=1 },
	["text"] = "<<-- This is a led component",
	["font"] = "std",	-- std, h10, h12, h18
}
-- Register new component in aapi2
aapi2.CreateComponent(i, w, _p)
-- ------------------------------------------------------------------------------------------------
-- Create label object
local _p = {
	["type"] = "led",
	["name"] = "Led1",
	["x"] = 10, ["y"] = 90,
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
}
aapi2.CreateComponent(i, w, _p)
-- ------------------------------------------------------------------------------------------------
-- Create progress_bar object
local _p = {
	["type"] = "progress_bar",
	["name"] = "ProgressBar1",	
	["x"] = 10, ["y"] = 110,
	["w"] = 200, ["h"] = 20,
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
		["pos"] = 50,
		["dir"] = "right", -- "right" or "top"
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
		["units"] = "%"
	},
	["events"] = {
		["on_click"] = "",
		["on_wheel"] = "",
		["on_drag"] = ""
	}					
}
aapi2.CreateComponent(i, w, _p)	
-- ------------------------------------------------------------------------------------------------
-- Create slider object
local _p = {
	["type"] = "slider",
	["name"] = "Slider1",	
	["x"] = 20, ["y"] = 140,
	["w"] = 180, ["h"] = 20,
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
		["pos"] = 50,
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
		["units"] = "%"
	},
	["events"] = {
		["on_click"] = "ExampleSliderCallback",
		["on_wheel"] = "ExampleSliderCallback",
		["on_drag"] = "ExampleSliderCallback"
	}				
}
aapi2.CreateComponent(i, w, _p)
-- ------------------------------------------------------------------------------------------------
-- Create another label object in front of a led (next component)
local _p = {
	["type"] = "label",
	["name"] = "Label4",
	["x"] = 10, ["y"] = 185,
	["color"] = { ["r"]=1, ["g"]=1, ["b"]=1 },
	["text"] = "We also got lines :",
	["font"] = "std",	-- std, h10, h12, h18
}
-- Register new component in aapi2
aapi2.CreateComponent(i, w, _p)
-- ------------------------------------------------------------------------------------------------
-- Create line object
local _p = {
	["type"] = "line",
	["name"] = "Line1",
	["x"] = 10, ["y"] = 200,
	["x2"] = 200, ["y2"] = 200,
	["width"] = 1,
	["color"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=0.5 } 
}
aapi2.CreateComponent(i, w, _p)
-- ------------------------------------------------------------------------------------------------
-- Create another label object
local _p = {
	["type"] = "label",
	["name"] = "Label5",
	["x"] = 10, ["y"] = 220,
	["color"] = { ["r"]=1, ["g"]=1, ["b"]=1 },
	["text"] = "And we also got boxes :",
	["font"] = "std",	-- std, h10, h12, h18
}
-- Register new component in aapi2
aapi2.CreateComponent(i, w, _p)
-- ------------------------------------------------------------------------------------------------
-- Create box object
local _p = {
	["type"] = "box",
	["name"] = "Box1",	
	["x"] = 10,	["y"] = 230,
	["w"] = 200,	["h"] = 100,
	["color"] = { ["r"]=0.0, ["g"]=0.1, ["b"]=0.1, ["a"]=0.5 },
	["border"] = {
		["size"] = 1,
		["color"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=0.6 }
	}
}
aapi2.CreateComponent(i, w, _p)
-- ------------------------------------------------------------------------------------------------
-- Create label object
local _p = {
	["type"] = "label",
	["name"] = "Label3",
	["x"] = 270, ["y"] = 15,
	["color"] = { ["r"]=1, ["g"]=1, ["b"]=1 },
	["text"] = "Look, a table:",
	["font"] = "std",	-- std, h10, h12, h18
}
-- Register new component in aapi2
aapi2.CreateComponent(i, w, _p)
-- ------------------------------------------------------------------------------------------------
-- Create table component
local _p = {
	["type"] = "table",
	["name"] = "Table1",
	["x"] = 270, ["y"] = 30,
	["w"] = 350, ["h"] = 300,
	["color"] = { 
		["bg"] = { ["r"]=0.1, ["g"]=0.1, ["b"]=0.2, ["a"]=0.5 },
		["fg"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=0.9 },
	},
	["border"] = {
		["size"] = 1,
		["color"] = { ["r"]=0.98, ["g"]=0.99, ["b"]=1.0, ["a"]=0.9 }
	},
	["events"] = {
		["on_click"] = "ExampleTableCallback",
		["on_wheel"] = "",
		["on_drag"] = ""
	},
	["table"] = {
		["row_colors"] = {
			{ ["r"]=0.8, ["g"]=0.9, ["b"]=1.0, ["a"]=0.1 },
			{ ["r"]=0.8, ["g"]=0.9, ["b"]=1.0, ["a"]=0.125 },
		},
		["columns"] = {	
			{ ["name"] = "Column 1",	["width"] = 100,	["align"] = "left" },
			{ ["name"] = "Column 2",	["width"] = 100,	["align"] = "left" },
			{ ["name"] = "Column 3", 	["width"] = 100,	["align"] = "left" },
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
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
			{ "Item here", "Item there", "Items everywhere" },
		},
	},
}
aapi2.CreateComponent(i, w, _p)
-- ------------------------------------------------------------------------------------------------
-- Create label object
local _p = {
	["type"] = "label",
	["name"] = "Label6",
	["x"] = 270, ["y"] = 345,
	["color"] = { ["r"]=1, ["g"]=1, ["b"]=1 },
	["text"] = "Selected row: ",
	["font"] = "std",	-- std, h10, h12, h18
}
-- Register new component in aapi2
aapi2.CreateComponent(i, w, _p)
-- ------------------------------------------------------------------------------------------------
-- Example of an event callback function
function ExampleButtonCallback(i, w, c)
	-- First we need to find handles of components we want to interact with
	local _th = aapi2.GetComponentHandle(i, w, "TextBox1")
	local _eh = aapi2.GetComponentHandle(i, w, "EditBox1")
	
	-- Next we need to grab their properties
	local _tp = aapi2.GetComponentProperties(i, w, _th)
	local _ep = aapi2.GetComponentProperties(i, w, _eh)
	
	-- Now we can use property of one to affect property of the other
	_tp["text"] = _ep["text"]
	
	-- And that's it
	return
end
-- ------------------------------------------------------------------------------------------------
-- Another example of an event callback function
function ExampleSliderCallback(i, w, c)
	-- First we need to find handles of components we want to interact with
	local _ph = aapi2.GetComponentHandle(i, w, "ProgressBar1")
	local _sh = aapi2.GetComponentHandle(i, w, "Slider1")
	
	-- Next we need to grab their properties
	local _pp = aapi2.GetComponentProperties(i, w, _ph)
	local _sp = aapi2.GetComponentProperties(i, w, _sh)
	
	-- Now we can use property of one to affect property of the other
	_pp["bar"]["pos"] = _sp["bar"]["pos"]
	
	-- And that's it
	return
end
-- ------------------------------------------------------------------------------------------------
-- Another example of an event callback function
function ExampleTableCallback(i, w, c)
	-- First we need to find handles of components we want to interact with
	local _th = aapi2.GetComponentHandle(i, w, "Table1")
	local _lh = aapi2.GetComponentHandle(i, w, "Label6")
	
	-- Next we need to grab their properties
	local _tp = aapi2.GetComponentProperties(i, w, _th)
	local _lp = aapi2.GetComponentProperties(i, w, _lh)
	
	-- Now we can use property of one to affect property of the other
	_lp["text"] = "Selected row: ".._tp["table"]["selection"]["row"]
	
	-- And that's it
	return
end

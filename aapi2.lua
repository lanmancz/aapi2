-- ************************************************************************************************************************************************************************************************
-- AceAPIv2
--[[
	AceAPIv2 is a module for FlyWithLUA for X-Plane 11.
	https://forums.x-plane.org/index.php?/files/file/38445-flywithlua-ng-next-generation-edition-for-x-plane-11-win-lin-mac/

	Using this module you can create custom windows environment for your plugins.
	This software is released under GNU GPLv3 license.
	This software comes with no warranty - use at your own risk!
	More information in documentation.

	*v2.03:
		- Added "table" object
		- Added "editbox" object
		- Added events for windows (mandatory property)
		- Added basic window focus control
		- Fixed minor graphical bugs introduced FLWNG
	*v2.04:
		- Added "font" property for labels (std, h10, h12, h18)
	*v2.05:
		- Fixed window focus bug
--]]
-- ************************************************************************************************************************************************************************************************
-- GLOBAL INIT

module(..., package.seeall)
require("graphics")

-- ************************************************************************************************************************************************************************************************
-- LOCAL VARIABLES
local AceAPI = {}
AceAPI = {
	["version"] = "2.05",
	["config"] = {
		["debug"] = false,
	},
	["inst"] = {},
	["focus"] = {
		["instance"] = nil,
		["window"] = nil,
		["component"] = nil,
	},
}

-- ************************************************************************************************************************************************************************************************
-- GLOBAL FUNCTIONS
-- Create new instance
function CreateInstance(name)
	local _name = name or "Instance"
	local _handle = #AceAPI["inst"] + 1
	AceAPI["inst"][_handle] = {
		["name"] = _name,
		["win"] = {},
		["dialog"] = {},
		["runtime"] = {},
	}
	return _handle
end

-- ------------------------------------------------------------------------------------------------
-- Public functions
function Dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. Dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end 
function Round(n, d)
  local m = 10^(d or 0)
  return math.floor(n * m + 0.5) / m
end

-- ************************************************************************************************************************************************************************************************
-- LOCAL FUNCTIONS
-- Output a text message into main X-Plane log
local function Log(text) logMsg("AceAPI: "..text) end
-- Output a debug text message into main X-Plane log if debug mode is on
local function DebugLog(text) if AceAPI["config"]["debug"] == true then logMsg("AceAPI DEBUG: "..text) end end
-- Return inverted Y coordinate - X-Plane is addressing the Y coordinates from bottom of the screen
local function Ay2Oy(ay) return (SCREEN_HIGHT - ay) end
-- Return true if pattern is found in the string
local function TestPat(s,p) if s:find(p) ~= nil then return true else return false end end

-- ************************************************************************************************************************************************************************************************
-- GLOBAL WINDOW FUNCTIONS
function CreateWindow(instance, properties)
	local _properties = properties or {
		["name"] = "Window1",
		["show"] = true,
		["x"] = 200,
		["y"] = 200,
		["w"] = 600,
		["h"] = 400,
		["limits"] = { ["min_x"]=200, ["min_y"]=100, ["max_x"]=1000, ["max_y"]=1000 },
		["header"] = {
			["enabled"] = true,
			["title"] = "Window 1",
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
		}		
	}
	
	local _handle = #AceAPI["inst"][instance]["win"] + 1
	AceAPI["inst"][instance]["win"][_handle] = _properties
	DebugLog("Created new window. Instance: "..instance..", Window: ".._handle..", Name: ".._properties["name"])
	
	SetFocus(instance, _handle)
	return _handle
end

-- ------------------------------------------------------------------------------------------------

function ShowHideWindow(instance, window, position, state)
	if AceAPI["inst"][instance]["win"][window] ~= nil then
		if state ~= nil then
			AceAPI["inst"][instance]["win"][window]["show"] = state
		else
			AceAPI["inst"][instance]["win"][window]["show"] = not AceAPI["inst"][instance]["win"][window]["show"]
		end
		if (position == "center") then
			AceAPI["inst"][instance]["win"][window]["x"] = (SCREEN_WIDTH/2) - math.floor(AceAPI["inst"][instance]["win"][window]["w"]/2)
			AceAPI["inst"][instance]["win"][window]["y"] = (SCREEN_HIGHT/2) - math.floor(AceAPI["inst"][instance]["win"][window]["h"]/2)
		end
		if AceAPI["inst"][instance]["win"][window]["show"] == true then
			SetFocus(instance, window)
		end
	end
	--DebugLog("Show/hide window: Instance: "..instance..", Window: "..window..", Name: "..AceAPI["inst"][instance]["win"][window]["name"]..", State: "..AceAPI["inst"][instance]["win"][window]["show"])
	return
end

-- ------------------------------------------------------------------------------------------------

function GetWindowProperties(instance, window)
	_properties = AceAPI["inst"][instance]["win"][window] or nil
	return _properties
end

-- ------------------------------------------------------------------------------------------------

function SetWindowProperties(instance, window, properties)
	_properties = properties or nil
	AceAPI["inst"][instance]["win"][window] = _properties
	return
end

-- ------------------------------------------------------------------------------------------------

function CreateComponent(instance, window, properties)
	local _properties = properties or {
		["type"] = "led",
		["x"] = 20,	["y"] = 20,
		["w"] = 10,	["h"] = 10,
		["color"] = { 
	 		["off"] = { ["r"]=0.0, ["g"]=0.0, ["b"]=0.4, ["a"]=0.9 },
			["on"] = { ["r"]=0.1, ["g"]=1, ["b"]=0.1, ["a"]=0.9 }
		},
		["border"] = {
			["size"] = 1,
			["color"] = { ["r"]=0.1, ["g"]=1, ["b"]=0.1, ["a"]=0.9 }
		},
		["state"] = "off"
	}

	local _handle = #AceAPI["inst"][instance]["win"][window]["body"]["components"] + 1
	AceAPI["inst"][instance]["win"][window]["body"]["components"][_handle] = _properties
	DebugLog("Created new component. Instance: "..instance..", Window: "..window..", Component: ".._handle..", Type: ".._properties["type"]..", Name: ".._properties["name"])
	return _handle
end

-- ------------------------------------------------------------------------------------------------

function GetComponentHandle(instance, window, name)
	for c = 1,#AceAPI["inst"][instance]["win"][window]["body"]["components"] do
		if AceAPI["inst"][instance]["win"][window]["body"]["components"][c]["name"] == name then return c end
	end
	return nil
end

-- ------------------------------------------------------------------------------------------------

function GetComponentProperties(instance, window, component)
	_properties = AceAPI["inst"][instance]["win"][window]["body"]["components"][component] or nil
	return _properties
end

-- ------------------------------------------------------------------------------------------------

function SetComponentProperties(instance, window, component, properties)
	_properties = properties or nil
	AceAPI["inst"][instance]["win"][window]["body"]["components"][component] = _properties
	return
end

-- ------------------------------------------------------------------------------------------------


-- ************************************************************************************************************************************************************************************************
-- LOCAL DRAW FUNCTIONS
-- Low level draw rectangle function
local function llDrawRec(x, y, w, h, r, g, b, a)
	graphics.set_color(r, g, b, a)	
	graphics.draw_rectangle(x, Ay2Oy(y), x + w, Ay2Oy(y + h))
end 
-- ------------------------------------------------------------------------------------------------
-- Low level draw line function
local function llDrawLine(x1, y1, x2, y2, w, r, g, b, a)
	graphics.set_color(r, g, b, a)	
	graphics.set_width(w)
	graphics.draw_line(x1, Ay2Oy(y1), x2, Ay2Oy(y2))
end 
-- ------------------------------------------------------------------------------------------------
-- Low level draw text function
local function llDrawText(x, y, r, g, b, text, font)
	if text == nil then return end
	if font == nil then font = "std" end
	
	if (font == "std") then
		draw_string(x, Ay2Oy(y), tostring(text), r, g, b)
	elseif (font == "h10") then
		glColor4f(r, g, b, 1)
		draw_string_Helvetica_10(x, Ay2Oy(y), tostring(text))
	elseif (font == "h12") then
		glColor4f(r, g, b, 1)
		draw_string_Helvetica_12(x, Ay2Oy(y), tostring(text))
	elseif (font == "h18") then
		glColor4f(r, g, b, 1)
		draw_string_Helvetica_18(x, Ay2Oy(y), tostring(text))
	end

end
-- ------------------------------------------------------------------------------------------------
-- Low level draw box function (rectangle with line borders)
local function llDrawBox(x, y, w, h, br, bg, bb, ba, fr, fg, fb, fa, bw)
	_bw = bw or 0
	llDrawRec(x, y, w, h, br, bg, bb, ba)
	if (_bw > 0) then
		llDrawLine(x, y, x+w, y, _bw, fr, fg, fb, fa)
		llDrawLine(x, y+h, x+w, y+h, _bw, fr, fg, fb, fa)
		llDrawLine(x, y, x, y+h, _bw, fr, fg, fb, fa)
		llDrawLine(x+w, y, x+w, y+h, _bw, fr, fg, fb, fa)
	end
end

-- ************************************************************************************************************************************************************************************************
-- DRAW COMPONENTS SECTION
local function DrawComponent(i, w, c)
	-- Set initial window reference frame
	local _rx = AceAPI["inst"][i]["win"][w]["x"]
	local _ry = AceAPI["inst"][i]["win"][w]["y"]
	
	-- textbox
	if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["type"] == "textbox") then	
		local _t = {
			["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"],
			["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"],
			["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"],
			["h"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"],
			["bw"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["size"],
			["br"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["r"],
			["bg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["g"],
			["bb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["b"],
			["ba"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["a"],
			["fr"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["r"],
			["fg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["g"],
			["fb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["b"],
			["fa"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["a"],
		}
		llDrawBox(_t["x"], _t["y"], _t["w"], _t["h"], _t["br"], _t["bg"], _t["bb"], _t["ba"], _t["fr"], _t["fg"], _t["fb"], _t["fa"], _t["bw"])	
		-- Draw text
		local _w = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"]
		local _h = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"]
		local _tw = measure_string(AceAPI["inst"][i]["win"][w]["body"]["components"][c]["text"])
		local _t = {
			["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + (_w/2) - (_tw/2),
			["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + (_h/2) + 3,
			["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["r"],
			["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["g"],
			["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["b"],
			["t"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["text"]
		}
		llDrawText(_t["x"], _t["y"], _t["r"], _t["g"], _t["b"], _t["t"])		
		-- Draw label
		if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["label"] ~= nil) and (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["label"] ~= "") then
			local _w = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"]
			local _h = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"]
			local _tw = measure_string(AceAPI["inst"][i]["win"][w]["body"]["components"][c]["label"])
			local _t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] - _tw - 10,
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + (_h/2) + 3,
				["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["r"],
				["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["g"],
				["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["b"],
				["t"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["label"]
			}
			llDrawText(_t["x"], _t["y"], _t["r"], _t["g"], _t["b"], _t["t"])		
		end
	-- button
	elseif (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["type"] == "button") then	
		local _s = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["state"]	
		local _t = {
			["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"],
			["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"],
			["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"],
			["h"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"],
			["bw"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["size"],
			["br"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"][_s]["r"],
			["bg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"][_s]["g"],
			["bb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"][_s]["b"],
			["ba"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"][_s]["a"],
			["fr"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["r"],
			["fg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["g"],
			["fb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["b"],
			["fa"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["a"],
		}
		llDrawBox(_t["x"], _t["y"], _t["w"], _t["h"], _t["br"], _t["bg"], _t["bb"], _t["ba"], _t["fr"], _t["fg"], _t["fb"], _t["fa"], _t["bw"])	
		-- Draw text
		local _w = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"]
		local _h = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"]
		local _tw = measure_string(AceAPI["inst"][i]["win"][w]["body"]["components"][c]["text"][_s])
		local _t = {
			["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + (_w/2) - (_tw/2),
			["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + (_h/2) + 3,
			["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["r"],
			["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["g"],
			["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["b"],
			["t"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["text"][_s]
		}
		llDrawText(_t["x"], _t["y"], _t["r"], _t["g"], _t["b"], _t["t"])		
	-- editbox
	elseif (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["type"] == "editbox") then
		local _s = "normal"
		if (AceAPI["focus"]["instance"] == i) and (AceAPI["focus"]["window"] == w) and (AceAPI["focus"]["component"] == c) then
		 _s = "focus"
		end
		local _t = {
			["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"],
			["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"],
			["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"],
			["h"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"],
			["bw"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["size"],
			["br"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"][_s]["r"],
			["bg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"][_s]["g"],
			["bb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"][_s]["b"],
			["ba"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"][_s]["a"],
			["fr"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["r"],
			["fg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["g"],
			["fb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["b"],
			["fa"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["a"],
		}
		llDrawBox(_t["x"], _t["y"], _t["w"], _t["h"], _t["br"], _t["bg"], _t["bb"], _t["ba"], _t["fr"], _t["fg"], _t["fb"], _t["fa"], _t["bw"])	
		-- Draw text
		local _w = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"]
		local _h = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"]
		local _txt = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["text"]
		local _tw = measure_string(_txt)
		local _aw = measure_string(_txt) / string.len(_txt)
		local _sw = 10
		local _cw = _w - (_h/2)

		if (_s == "normal") and (_tw > (_cw - _sw)) then
			local _te = math.floor(_cw/_aw) - 1
			_txt = string.sub(_txt, 1, _te)..".."
		elseif (_s == "focus") and (_tw > (_cw - _sw)) then
			local _ts = 1+math.ceil((_tw-_cw)/_aw)
			_txt = string.sub(_txt, _ts)
			if (_ts > 1) then 
				_txt = string.sub(_txt, 3)
				_txt = "..".._txt
			end
		end
		
		local _t = {
			["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + (_h/3),
			["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + (_h/2) + 2,
			["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["r"],
			["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["g"],
			["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["b"],
			["t"] = _txt
		}
		llDrawText(_t["x"], _t["y"], _t["r"], _t["g"], _t["b"], _t["t"])	

		-- Draw cursor line
		if (_s == "focus") then
			local _tx = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + (_h/3) + measure_string(_txt)

			local _t = {
				["x"] = _tx,
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + (_h/4) - 2,
				["w"] = 2,
				["h"] = (_h/2) + 2,
				["bw"] = 0,
				["br"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["r"],
				["bg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["g"],
				["bb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["b"],
				["ba"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["a"],
				["fr"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["r"],
				["fg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["g"],
				["fb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["b"],
				["fa"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["a"],
			}
			llDrawBox(_t["x"], _t["y"], _t["w"], _t["h"], _t["br"], _t["bg"], _t["bb"], _t["ba"], _t["fr"], _t["fg"], _t["fb"], _t["fa"], _t["bw"])	
			
		end
	-- line
	elseif (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["type"] == "line") then	
		local _t = {
			["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"],
			["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"],
			["x2"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x2"],
			["y2"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y2"],
			["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["width"],
			["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["r"],
			["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["g"],
			["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["b"],
			["a"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["a"],
		}
		llDrawLine(_t["x"], _t["y"], _t["x2"], _t["y2"], _t["w"], _t["r"], _t["g"], _t["b"], _t["a"])
	-- led
	elseif (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["type"] == "led") then	
		local _s = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["state"]
		local _t = {
			["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"],
			["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"],
			["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"],
			["h"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"],
			["bw"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["size"],
			["br"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"][_s]["r"],
			["bg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"][_s]["g"],
			["bb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"][_s]["b"],
			["ba"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"][_s]["a"],
			["fr"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["r"],
			["fg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["g"],
			["fb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["b"],
			["fa"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["a"],
		}
		llDrawBox(_t["x"], _t["y"], _t["w"], _t["h"], _t["br"], _t["bg"], _t["bb"], _t["ba"], _t["fr"], _t["fg"], _t["fb"], _t["fa"], _t["bw"])
	-- label
	elseif (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["type"] == "label") then
		if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["font"] == nil) or (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["font"] == "std") then
			local _t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"],
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"],
				["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["r"],
				["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["g"],
				["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["b"],
				["t"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["text"]
			}
			llDrawText(_t["x"], _t["y"], _t["r"], _t["g"], _t["b"], _t["t"])
		elseif (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["font"] == nil) or (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["font"] ~= "std") then	
			local _t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"],
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"],
				["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["r"],
				["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["g"],
				["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["b"],
				["t"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["text"],
				["f"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["font"]
			}
			llDrawText(_t["x"], _t["y"], _t["r"], _t["g"], _t["b"], _t["t"], _t["f"])
		end
	-- box
	elseif (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["type"] == "box") then	
		local _s = "bg"
		local _t = {
			["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"],
			["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"],
			["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"],
			["h"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"],
			["bw"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["size"],
			["br"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["r"],
			["bg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["g"],
			["bb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["b"],
			["ba"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["a"],
			["fr"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["r"],
			["fg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["g"],
			["fb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["b"],
			["fa"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["a"],
		}
		llDrawBox(_t["x"], _t["y"], _t["w"], _t["h"], _t["br"], _t["bg"], _t["bb"], _t["ba"], _t["fr"], _t["fg"], _t["fb"], _t["fa"], _t["bw"])
	-- progress_bar
	elseif (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["type"] == "progress_bar") then	
		-- Background
		local _t = {
			["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"],
			["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"],
			["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"],
			["h"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"],
			["br"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["r"],
			["bg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["g"],
			["bb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["b"],
			["ba"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["a"],
			["fr"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["r"],
			["fg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["g"],
			["fb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["b"],
			["fa"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["a"],
			["bw"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["size"],
		}
		llDrawBox(_t["x"], _t["y"], _t["w"], _t["h"], _t["br"], _t["bg"], _t["bb"], _t["ba"], _t["fr"], _t["fg"], _t["fb"], _t["fa"], _t["bw"])

		-- Progress bar
		local _min = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["min"]
		local _max = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["max"]
		local _pos = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] - _min
		local _dir = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["dir"]
		
		local _t = {}
		if (_dir == "right") then
			local _b = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["border"]["size"]
			local _w = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"]
			local _o = (_w/(_max-_min))*_pos
			_t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + _b,
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + _b + 1,
				["w"] = _o - (_b*2)-1,
				["h"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"] - (_b*2) - 1,
				["br"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["pb"]["r"],
				["bg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["pb"]["g"],
				["bb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["pb"]["b"],
				["ba"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["pb"]["a"],
				["fr"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["r"],
				["fg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["g"],
				["fb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["b"],
				["fa"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["a"],
				["bw"] = _b,
			}
		elseif (_dir == "top") then
			local _b = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["border"]["size"]
			local _h = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"]
			local _o = (_h/(_max-_min))*_pos
			_t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + _b,
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + _h -_b - 1,
				["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"] - (_b*2) - 1,
				["h"] = 0 - (_o - (_b*2)-1),
				["br"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["pb"]["r"],
				["bg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["pb"]["g"],
				["bb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["pb"]["b"],
				["ba"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["pb"]["a"],
				["fr"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["r"],
				["fg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["g"],
				["fb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["b"],
				["fa"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["a"],
				["bw"] = _b,
			}		
		end
		llDrawBox(_t["x"], _t["y"], _t["w"], _t["h"], _t["br"], _t["bg"], _t["bb"], _t["ba"], _t["fr"], _t["fg"], _t["fb"], _t["fa"], _t["bw"])		
		
		-- Label
		if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["label"]["enabled"] == true) then
			local _l = ""
			if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["label"]["units"] ~= nil) and (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["label"]["units"] ~= "") then
				_l = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"].." "..AceAPI["inst"][i]["win"][w]["body"]["components"][c]["label"]["units"]
			else
				_l = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"]
			end
			local _lw = measure_string(_l)
			local _w = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"]
			local _h = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"]
			
			local _t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + (_w/2) - (_lw/2),
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + (_h/2) + 4,
				["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["r"],
				["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["g"],
				["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["b"],
				["t"] = _l
			}
			llDrawText(_t["x"], _t["y"], _t["r"], _t["g"], _t["b"], _t["t"])
		end
	-- table
	elseif (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["type"] == "table") then	
		-- Background
		local _t = {
			["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"],
			["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"],
			["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"],
			["h"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"],
			["br"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["r"],
			["bg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["g"],
			["bb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["b"],
			["ba"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["a"],
			["fr"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["r"],
			["fg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["g"],
			["fb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["b"],
			["fa"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["a"],
			["bw"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["size"],
		}
		llDrawBox(_t["x"], _t["y"], _t["w"], _t["h"], _t["br"], _t["bg"], _t["bb"], _t["ba"], _t["fr"], _t["fg"], _t["fb"], _t["fa"], _t["bw"])
		-- Header
		if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["header"]["enabled"] == true) then
			-- border line
			local _t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"],
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["header"]["height"],
				["x2"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"] - 1,
				["y2"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["header"]["height"],
				["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["size"],
				["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["r"],
				["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["g"],
				["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["b"],
				["a"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["a"],
			}
			llDrawLine(_t["x"], _t["y"], _t["x2"], _t["y2"], _t["w"], _t["r"], _t["g"], _t["b"], _t["a"])
			
			local _colx = 0
			for col = 1, #AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["columns"] do
				local _tx = 0
				if AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["columns"][col]["align"] == "center" then
					_tx = _colx + ((AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["columns"][col]["width"]/2) - (measure_string(AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["columns"][col]["name"])/2))
				elseif AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["columns"][col]["align"] == "left" then
					_tx = _colx + (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_height"]/2)
				elseif AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["columns"][col]["align"] == "right" then
					_tx = _colx + ((AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["columns"][col]["width"]) - (measure_string(AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["columns"][col]["name"])) - (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_height"]/2))
				end
					
				local _t = {
					["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + _tx,
					["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["header"]["height"]/2) + 3,
					["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fr"],
					["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"],
					["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fb"],
					["t"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["columns"][col]["name"]
				}
				llDrawText(_t["x"], _t["y"], _t["r"], _t["g"], _t["b"], _t["t"])				
				_colx = _colx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["columns"][col]["width"]
			end
		end
		-- Scrollbar
		if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["enabled"] == true) then
			local _hy = 0
			if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["header"]["enabled"] == true) then
				_hy = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["header"]["height"]
			end
			-- border line
			local _t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"] - AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"],
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + _hy + 1,
				["x2"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"] - AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"],
				["y2"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"],
				["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["size"],
				["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["r"],
				["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["g"],
				["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["b"],
				["a"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["a"],
			}
			llDrawLine(_t["x"], _t["y"], _t["x2"], _t["y2"], _t["w"], _t["r"], _t["g"], _t["b"], _t["a"])
			
			-- scroll up line
			local _t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"] - AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"],
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + _hy + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"],
				["x2"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"] - 1,
				["y2"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + _hy + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"],
				["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["size"],
				["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["r"],
				["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["g"],
				["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["b"],
				["a"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["a"],
			}
			llDrawLine(_t["x"], _t["y"], _t["x2"], _t["y2"], _t["w"], _t["r"], _t["g"], _t["b"], _t["a"])

			-- scroll up icon
			local _t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"] - AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"] + (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"]/4),
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + _hy + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"] - (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"]/4),
				["x2"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"] - AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"] + (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"]/2),
				["y2"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + _hy + (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"]/4),
				["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["size"],
				["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["r"],
				["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["g"],
				["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["b"],
				["a"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["a"],
			}
			llDrawLine(_t["x"], _t["y"], _t["x2"], _t["y2"], _t["w"], _t["r"], _t["g"], _t["b"], _t["a"])
			local _t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"] - (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"]/4) - 1,
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + _hy + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"] - (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"]/4),
				["x2"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"] - AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"] + (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"]/2) - 1,
				["y2"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + _hy + (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"]/4),
				["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["size"],
				["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["r"],
				["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["g"],
				["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["b"],
				["a"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["a"],
			}
			llDrawLine(_t["x"], _t["y"], _t["x2"], _t["y2"], _t["w"], _t["r"], _t["g"], _t["b"], _t["a"])

			-- scroll down line
			local _t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"] - AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"],
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"] - AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"],
				["x2"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"] - 1,
				["y2"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"] - AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"],
				["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["size"],
				["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["r"],
				["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["g"],
				["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["b"],
				["a"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["a"],
			}
			llDrawLine(_t["x"], _t["y"], _t["x2"], _t["y2"], _t["w"], _t["r"], _t["g"], _t["b"], _t["a"])

			-- scroll down icon
			local _t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"] - AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"] + (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"]/4),
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"] - AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"] + (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"]/4),
				["x2"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"] - AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"] + (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"]/2),
				["y2"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"] - (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"]/4),
				["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["size"],
				["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["r"],
				["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["g"],
				["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["b"],
				["a"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["a"],
			}
			llDrawLine(_t["x"], _t["y"], _t["x2"], _t["y2"], _t["w"], _t["r"], _t["g"], _t["b"], _t["a"])
			local _t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"] - (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"]/4) - 1,
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"] - AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"] + (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"]/4),
				["x2"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"] - AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"] + (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"]/2) - 1,
				["y2"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"] - (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"]/4),
				["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["size"],
				["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["r"],
				["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["g"],
				["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["b"],
				["a"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["a"],
			}
			llDrawLine(_t["x"], _t["y"], _t["x2"], _t["y2"], _t["w"], _t["r"], _t["g"], _t["b"], _t["a"])
			
			-- Scrollbox
			local _row_start = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"]
			local _row_height = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_height"]
			--local _row_display = Round(((AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"] - _hy) / _row_height), 0)
			local _row_count = #AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["rows"]
			local _dh = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"] - _hy
			local _sh = _dh - (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"] * 3)
			local _start_max = (_row_count - math.floor(_dh / _row_height))
			local _ss = (_sh / _start_max)
			local _spy = _ss * (_row_start-1)
			
			local _t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"] - AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"] + 1,
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + _hy + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"] + _spy + 1,
				["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"] - 2,
				["h"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"] - 3,
				["br"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["r"],
				["bg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["g"],
				["bb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["b"],
				["ba"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["a"],
				["fr"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["r"],
				["fg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["g"],
				["fb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["b"],
				["fa"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["color"]["a"],
				["bw"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["size"],
			}
			llDrawBox(_t["x"], _t["y"], _t["w"], _t["h"], _t["br"], _t["bg"], _t["bb"], _t["ba"], _t["fr"], _t["fg"], _t["fb"], _t["fa"], _t["bw"])		
		end
		-- Body
		local _ty = 0
		local _sx = 0
		local _hy = 0
		if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["header"]["enabled"] == true) then
			_hy = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["header"]["height"]
		end
		if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["header"]["enabled"] == true) then
			_ty = _ty + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["header"]["height"]
		end
		if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["enabled"] == true) then
			_sx = _sx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"]
		end
		local _rds = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"]
		local _rde = _rds + #AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["rows"] - 1
		if _rde >= Round((AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"]/AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_height"]),0) then
			_rde = _rds + Round(((AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"] - _hy)/AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_height"]),0) - 1
		end
		
		for row = _rds, _rde do
			-- Row background
			local _t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + 1,
				["y"] = _ry + _ty + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + 1,
				["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"] - 2 - _sx - 1,
				["h"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_height"] - 1,
				["bw"] = 0,
				["br"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_colors"][math.mod(row, #AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_colors"])+1]["r"],
				["bg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_colors"][math.mod(row, #AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_colors"])+1]["g"],
				["bb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_colors"][math.mod(row, #AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_colors"])+1]["b"],
				["ba"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_colors"][math.mod(row, #AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_colors"])+1]["a"],
				["fr"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_colors"][math.mod(row, #AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_colors"])+1]["r"],
				["fg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_colors"][math.mod(row, #AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_colors"])+1]["g"],
				["fb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_colors"][math.mod(row, #AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_colors"])+1]["b"],
				["fa"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_colors"][math.mod(row, #AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_colors"])+1]["a"],
			}
			if row == AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["selection"]["row"] then
				_t["br"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["selection"]["color"]["r"]
				_t["bg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["selection"]["color"]["g"]
				_t["bb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["selection"]["color"]["b"]
				_t["ba"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["selection"]["color"]["a"]
				_t["fr"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["selection"]["color"]["r"]
				_t["fg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["selection"]["color"]["g"]
				_t["fb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["selection"]["color"]["b"]
				_t["fa"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["selection"]["color"]["a"]
				llDrawBox(_t["x"], _t["y"], _t["w"], _t["h"], _t["br"], _t["bg"], _t["bb"], _t["ba"], _t["fr"], _t["fg"], _t["fb"], _t["fa"], _t["bw"])
			else
				llDrawBox(_t["x"], _t["y"], _t["w"], _t["h"], _t["br"], _t["bg"], _t["bb"], _t["ba"], _t["fr"], _t["fg"], _t["fb"], _t["fa"], _t["bw"])
			end

			-- Rows text
			local _colx = 0
			for col = 1, #AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["columns"] do
				local _tx = 0
				_tx = _colx + (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_height"]/2)
				local _txt = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["rows"][row][col]	
				if (measure_string(_txt) > AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["columns"][col]["width"]) then
					_txt = string.sub(_txt, 1, math.floor(AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["columns"][col]["width"]/6.5))..".."
				end
				
				local _t = {
					["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + _tx,
					["y"] = _ry + _ty + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_height"]/2) + 3,
					["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fr"],
					["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"],
					["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fb"],
					["t"] = _txt
				}
				llDrawText(_t["x"], _t["y"], _t["r"], _t["g"], _t["b"], _t["t"])				
				_colx = _colx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["columns"][col]["width"]
				
			end
			_ty = _ty + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_height"]
		end

		
	-- Slider
	elseif (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["type"] == "slider") then	
		-- Background
		local _t = {
			["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"],
			["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"],
			["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"],
			["h"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"],
			["br"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["r"],
			["bg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["g"],
			["bb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["b"],
			["ba"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["a"],
			["fr"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["r"],
			["fg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["g"],
			["fb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["b"],
			["fa"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["a"],
			["bw"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["size"],
		}
		llDrawBox(_t["x"], _t["y"], _t["w"], _t["h"], _t["br"], _t["bg"], _t["bb"], _t["ba"], _t["fr"], _t["fg"], _t["fb"], _t["fa"], _t["bw"])

		-- Bar
		local _h = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"]
		local _s = 4
		local _t = {
			["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"],
			["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + ((_h/2) - ((_h/_s)/2)),
			["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"] - 1,
			["h"] = (_h/_s),
			["br"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["pb"]["r"],
			["bg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["pb"]["g"],
			["bb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["pb"]["b"],
			["ba"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["pb"]["a"],
			["fr"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["r"],
			["fg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["g"],
			["fb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["b"],
			["fa"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["a"],
			["bw"] = 0,
		}
		llDrawBox(_t["x"], _t["y"], _t["w"], _t["h"], _t["br"], _t["bg"], _t["bb"], _t["ba"], _t["fr"], _t["fg"], _t["fb"], _t["fa"], _t["bw"])
		
		-- Slider position
		local _min = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["min"]
		local _max = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["max"]
		local _pos = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] - _min
		local _dir = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["dir"]
		
		local _b = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["border"]["size"]
		local _w = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"]
		local _o = ((_w-_b)/(_max-_min))*_pos
		local _t = {
			["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + _o,
			["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + 1,
			["w"] = _b,
			["h"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"] - 3,
			["br"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["r"],
			["bg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["g"],
			["bb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["b"],
			["ba"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["a"],
			["fr"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["r"],
			["fg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["g"],
			["fb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["b"],
			["fa"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["a"],
			["bw"] = 0,
		}
		llDrawBox(_t["x"], _t["y"], _t["w"], _t["h"], _t["br"], _t["bg"], _t["bb"], _t["ba"], _t["fr"], _t["fg"], _t["fb"], _t["fa"], 0)	
		-- Draw buttons
		if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["control"]["buttons"]["enabled"] == true) then
			local _bs = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["control"]["buttons"]["size"]
			local _w = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"]
			local _h = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"]
			-- Button Left
			local _t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] - _bs,
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"],
				["w"] = _bs,
				["h"] = _h,
				["br"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["r"],
				["bg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["g"],
				["bb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["b"],
				["ba"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["a"],
				["fr"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["r"],
				["fg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["g"],
				["fb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["b"],
				["fa"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["a"],
				["bw"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["size"],
			}
			llDrawBox(_t["x"], _t["y"], _t["w"], _t["h"], _t["br"], _t["bg"], _t["bb"], _t["ba"], _t["fr"], _t["fg"], _t["fb"], _t["fa"], _t["bw"])
			local _t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] - (_bs/3) - 1,
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + (_bs/3),
				["x2"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] - _bs + (_bs/3) - 1,
				["y2"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + (_h/2),
				["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["r"],
				["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["g"],
				["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["b"],
				["a"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["a"],
				["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["control"]["buttons"]["thickness"],
			}
			llDrawLine(_t["x"], _t["y"], _t["x2"], _t["y2"], _t["w"], _t["r"], _t["g"], _t["b"], _t["a"])
			local _t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] - (_bs/3) - 1,
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + _h - (_bs/3),
				["x2"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] - _bs + (_bs/3) - 1,
				["y2"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + (_h/2) - 1,
				["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["r"],
				["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["g"],
				["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["b"],
				["a"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["a"],
				["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["control"]["buttons"]["thickness"],
			}
			llDrawLine(_t["x"], _t["y"], _t["x2"], _t["y2"], _t["w"], _t["r"], _t["g"], _t["b"], _t["a"])
			-- Button Right
			local _t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + _w,
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"],
				["w"] = _bs,
				["h"] = _h,
				["br"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["r"],
				["bg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["g"],
				["bb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["b"],
				["ba"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["bg"]["a"],
				["fr"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["r"],
				["fg"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["g"],
				["fb"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["b"],
				["fa"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["a"],
				["bw"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["border"]["size"],
			}
			llDrawBox(_t["x"], _t["y"], _t["w"], _t["h"], _t["br"], _t["bg"], _t["bb"], _t["ba"], _t["fr"], _t["fg"], _t["fb"], _t["fa"], _t["bw"])
			local _t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + _w + (_bs/3),
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + (_bs/3),
				["x2"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + _w + _bs - (_bs/3),
				["y2"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + (_h/2),
				["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["r"],
				["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["g"],
				["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["b"],
				["a"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["a"],
				["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["control"]["buttons"]["thickness"],
			}
			llDrawLine(_t["x"], _t["y"], _t["x2"], _t["y2"], _t["w"], _t["r"], _t["g"], _t["b"], _t["a"])
			local _t = {
				["x"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + _w + (_bs/3),
				["y"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + _h - (_bs/3),
				["x2"] = _rx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"] + _w + _bs - (_bs/3),
				["y2"] = _ry + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"] + (_h/2) - 1,
				["r"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["r"],
				["g"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["g"],
				["b"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["b"],
				["a"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["color"]["fg"]["a"],
				["w"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["control"]["buttons"]["thickness"],
			}
			llDrawLine(_t["x"], _t["y"], _t["x2"], _t["y2"], _t["w"], _t["r"], _t["g"], _t["b"], _t["a"])
		end
	end
	return
end
-- ------------------------------------------------------------------------------------------------
local function DrawWindow(i, w)
	if i == nil then return end
	if w == nil then return end
	
	if (AceAPI["inst"][i]["win"][w]["show"] == true) then
		-- Draw window main box
		local _t = {
			["x"] = AceAPI["inst"][i]["win"][w]["x"],
			["y"] = AceAPI["inst"][i]["win"][w]["y"],
			["w"] = AceAPI["inst"][i]["win"][w]["w"],
			["h"] = AceAPI["inst"][i]["win"][w]["h"],
			["bw"] = AceAPI["inst"][i]["win"][w]["body"]["border"],
			["br"] = AceAPI["inst"][i]["win"][w]["body"]["color"]["br"],
			["bg"] = AceAPI["inst"][i]["win"][w]["body"]["color"]["bg"],
			["bb"] = AceAPI["inst"][i]["win"][w]["body"]["color"]["bb"],
			["ba"] = AceAPI["inst"][i]["win"][w]["body"]["color"]["ba"],
			["fr"] = AceAPI["inst"][i]["win"][w]["body"]["color"]["fr"],
			["fg"] = AceAPI["inst"][i]["win"][w]["body"]["color"]["fg"],
			["fb"] = AceAPI["inst"][i]["win"][w]["body"]["color"]["fb"],
			["fa"] = AceAPI["inst"][i]["win"][w]["body"]["color"]["fa"],
		}
		llDrawBox(_t["x"], _t["y"], _t["w"], _t["h"], _t["br"], _t["bg"], _t["bb"], _t["ba"], _t["fr"], _t["fg"], _t["fb"], _t["fa"], _t["bw"])
		
		-- Draw header
		if (AceAPI["inst"][i]["win"][w]["header"]["enabled"] == true) then
			local _t = {
				["x"] = AceAPI["inst"][i]["win"][w]["x"],
				["y"] = AceAPI["inst"][i]["win"][w]["y"] - AceAPI["inst"][i]["win"][w]["header"]["h"],
				["w"] = AceAPI["inst"][i]["win"][w]["w"],
				["h"] = AceAPI["inst"][i]["win"][w]["header"]["h"],
				["bw"] = AceAPI["inst"][i]["win"][w]["header"]["border"],
				["br"] = AceAPI["inst"][i]["win"][w]["header"]["color"]["br"],
				["bg"] = AceAPI["inst"][i]["win"][w]["header"]["color"]["bg"],
				["bb"] = AceAPI["inst"][i]["win"][w]["header"]["color"]["bb"],
				["ba"] = AceAPI["inst"][i]["win"][w]["header"]["color"]["ba"],
				["fr"] = AceAPI["inst"][i]["win"][w]["header"]["color"]["fr"],
				["fg"] = AceAPI["inst"][i]["win"][w]["header"]["color"]["fg"],
				["fb"] = AceAPI["inst"][i]["win"][w]["header"]["color"]["fb"],
				["fa"] = AceAPI["inst"][i]["win"][w]["header"]["color"]["fa"],
			}
			llDrawBox(_t["x"], _t["y"], _t["w"], _t["h"], _t["br"], _t["bg"], _t["bb"], _t["ba"], _t["fr"], _t["fg"], _t["fb"], _t["fa"], _t["bw"])

			-- Draw title
			if (AceAPI["inst"][i]["win"][w]["header"]["title"] ~= "") and (AceAPI["inst"][i]["win"][w]["header"]["title"] ~= nil)then
				local _t = {
					["x"] = AceAPI["inst"][i]["win"][w]["x"] + 10,
					["y"] = AceAPI["inst"][i]["win"][w]["y"] - (AceAPI["inst"][i]["win"][w]["header"]["h"]/2)+3,
					["r"] = AceAPI["inst"][i]["win"][w]["header"]["color"]["fr"],
					["g"] = AceAPI["inst"][i]["win"][w]["header"]["color"]["fg"],
					["b"] = AceAPI["inst"][i]["win"][w]["header"]["color"]["fb"],
					["t"] = AceAPI["inst"][i]["win"][w]["header"]["title"],
				}
				llDrawText(_t["x"], _t["y"], _t["r"], _t["g"], _t["b"], _t["t"])		
			end
			
			-- Draw close button
			if (AceAPI["inst"][i]["win"][w]["header"]["close"] == true) then
				local _t = {
					["x"] = AceAPI["inst"][i]["win"][w]["x"],
					["y"] = AceAPI["inst"][i]["win"][w]["y"] - AceAPI["inst"][i]["win"][w]["header"]["h"],
					["w"] = AceAPI["inst"][i]["win"][w]["w"],
					["h"] = AceAPI["inst"][i]["win"][w]["header"]["h"],
					["bw"] = AceAPI["inst"][i]["win"][w]["header"]["border"],
					["br"] = AceAPI["inst"][i]["win"][w]["header"]["color"]["br"],
					["bg"] = AceAPI["inst"][i]["win"][w]["header"]["color"]["bg"],
					["bb"] = AceAPI["inst"][i]["win"][w]["header"]["color"]["bb"],
					["ba"] = AceAPI["inst"][i]["win"][w]["header"]["color"]["ba"],
					["fr"] = AceAPI["inst"][i]["win"][w]["header"]["color"]["fr"],
					["fg"] = AceAPI["inst"][i]["win"][w]["header"]["color"]["fg"],
					["fb"] = AceAPI["inst"][i]["win"][w]["header"]["color"]["fb"],
					["fa"] = AceAPI["inst"][i]["win"][w]["header"]["color"]["fa"],
				}
				llDrawLine((_t["x"]+_t["w"])-_t["h"], _t["y"], (_t["x"]+_t["w"])-_t["h"], _t["y"]+_t["h"], _t["bw"], _t["fr"], _t["fg"], _t["fb"], _t["fa"])
				llDrawLine((_t["x"]+_t["w"])-_t["h"]+4, _t["y"]+4, (_t["x"]+_t["w"])-5, _t["y"]+_t["h"]-5, _t["bw"], _t["fr"], _t["fg"], _t["fb"], _t["fa"])
				llDrawLine((_t["x"]+_t["w"])-_t["h"]+4, _t["y"]+_t["h"]-5, (_t["x"]+_t["w"])-5, _t["y"]+4, _t["bw"], _t["fr"], _t["fg"], _t["fb"], _t["fa"])
			end
		end
		
		-- Draw components
		for c = 1,#AceAPI["inst"][i]["win"][w]["body"]["components"] do
			DrawComponent(i, w, c)
		end
	end
	return
end
-- ************************************************************************************************************************************************************************************************
-- DRAW SECTION
local function Redraw()
	for i = 1,#AceAPI["inst"] do
		if (AceAPI["focus"]["instance"] == i) then
			-- do nothing, skip focus
		else
			for w = 1,#AceAPI["inst"][i]["win"] do
				DrawWindow(i, w)
			end
		end
	end
	
	-- Draw focus instance
	for w = 1,#AceAPI["inst"][AceAPI["focus"]["instance"]]["win"] do
		if (AceAPI["focus"]["window"] == w) then
			-- do nothing, skip focus
		else
			DrawWindow(AceAPI["focus"]["instance"], w)
		end
	end
	-- Draw focus window
	DrawWindow(AceAPI["focus"]["instance"], AceAPI["focus"]["window"])
	return
end

-- ************************************************************************************************************************************************************************************************
-- MOUSE INTERACTION SECTION

function SetFocus(i, w, c)
	local _li = AceAPI["focus"]["instance"]
	local _lw = AceAPI["focus"]["window"]
	local _lc = AceAPI["focus"]["component"]
	
	-- Call the editbox "on_enter" function on loss of focus
	if (_li ~= nil) and (_lw ~= nil) and (_lc ~= nil) then
		if (AceAPI["inst"][_li]["win"][_lw]["body"]["components"][_lc]["type"] == "editbox") and (c == nil) then
			-- Call the events
			if (AceAPI["inst"][_li]["win"][_lw]["body"]["components"][_lc]["events"]["on_enter"] ~= nil) and (AceAPI["inst"][_li]["win"][_lw]["body"]["components"][_lc]["events"]["on_enter"] ~= "") then
				_G[AceAPI["inst"][_li]["win"][_lw]["body"]["components"][_lc]["events"]["on_enter"]](_li,_lw,_lc)
			end			
		end
	end
	
	if (i ~= "keep") then AceAPI["focus"]["instance"] = i or nil end
	if (w ~= "keep") then AceAPI["focus"]["window"] = w or nil end
	if (c ~= "keep") then AceAPI["focus"]["component"] = c or nil end
	DebugLog("Set focus. Instance: "..tostring(i)..", Window: "..tostring(w)..", Component: "..tostring(c))
end

-- ------------------------------------------------------------------------------------------------
-- Detect click in an area
local function TestClick(mx, my, x, y, w ,h)
	local _result = false
	if (mx > x) and (mx < (x + w)) and
	(Ay2Oy(my) > y) and (Ay2Oy(my) < (y + h)) then
		_result = true
	end	
	return _result
end
-- ------------------------------------------------------------------------------------------------
-- Mouse click handler
local function WindowClick(i,w)
	-- Get mouse click coordinates
	local _mx = MOUSE_X
	local _my = Ay2Oy(MOUSE_Y)	-- Get normal Y coordinates
	local _ms = MOUSE_STATUS

	if AceAPI["inst"][i]["win"][w]["show"] == true then
		-- Get window coordinates and dimensions
		local _x = AceAPI["inst"][i]["win"][w]["x"]
		local _y = AceAPI["inst"][i]["win"][w]["y"]
		local _w = AceAPI["inst"][i]["win"][w]["w"]
		local _h = AceAPI["inst"][i]["win"][w]["h"]
		local _hh = AceAPI["inst"][i]["win"][w]["header"]["h"]
		local _hb = AceAPI["inst"][i]["win"][w]["header"]["border"]
		local _b = AceAPI["inst"][i]["win"][w]["body"]["border"]
	
	
		-- Window body
		if (_mx >= _x) and (_my >= _y) and (_mx <= (_x + _w)) and (_my <= (_y + _h)) then
			-- Iterate through all components in window body
			for c = 1,#AceAPI["inst"][i]["win"][w]["body"]["components"] do
				-- Get common component variables
				local _cx = _x + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"]
				local _cy = _y + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"]
			
				if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["type"] == "button") then
					local _cw = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"]
					local _ch = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"]
					-- Click inside component
					if (_mx >= _cx) and (_my >= _cy) and (_mx <= (_cx+_cw)) and (_my <= (_cy+_ch)) then
						if (_ms == "down") then
							if (_ms == "down") then SetFocus(i, w, c) end
							-- Flip the switch
							if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["mode"] == "switch") then
								if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["state"] == "off") then
									AceAPI["inst"][i]["win"][w]["body"]["components"][c]["state"] = "on"
								else
									AceAPI["inst"][i]["win"][w]["body"]["components"][c]["state"] = "off"
								end
							end
							
							-- Call the events
							if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"] ~= nil) and (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"] ~= "") then
								_G[AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"]](i,w,c)
							end
							
							DebugLog("MouseClick (COMPONENT): Instance: "..i..", Window: "..w..", Component: "..c..", Name: "..AceAPI["inst"][i]["win"][w]["body"]["components"][c]["name"]..", State: "..AceAPI["inst"][i]["win"][w]["body"]["components"][c]["state"])
							return true
						end
					end
				elseif (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["type"] == "editbox") then
					local _cw = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"]
					local _ch = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"]
					-- Click inside component
					if (_mx >= _cx) and (_my >= _cy) and (_mx <= (_cx+_cw)) and (_my <= (_cy+_ch)) then
						if (_ms == "down") then
							if (_ms == "down") then SetFocus(i, w, c) end						
							-- Call the events
							if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"] ~= nil) and (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"] ~= "") then
								_G[AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"]](i,w,c)
							end
							
							DebugLog("MouseClick (COMPONENT): Instance: "..i..", Window: "..w..", Component: "..c..", Name: "..AceAPI["inst"][i]["win"][w]["body"]["components"][c]["name"])
							return true
						end
					end
				elseif (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["type"] == "led") then
					local _cw = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"]
					local _ch = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"]
					-- Click inside component
					if (_mx >= _cx) and (_my >= _cy) and (_mx <= (_cx+_cw)) and (_my <= (_cy+_ch)) then
						if (_ms == "down") then
							if (_ms == "down") then SetFocus(i, w, c) end					
							-- Flip the led
							if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["control"]["enabled"] == true) then
								if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["state"] == "off") then
									AceAPI["inst"][i]["win"][w]["body"]["components"][c]["state"] = "on"
								else
									AceAPI["inst"][i]["win"][w]["body"]["components"][c]["state"] = "off"
								end
							end
							
							-- Call the events
							if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"] ~= nil) and (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"] ~= "") then
								_G[AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"]](i,w,c)
							end

							DebugLog("MouseClick (COMPONENT): Instance: "..i..", Window: "..w..", Component: "..c..", Name: "..AceAPI["inst"][i]["win"][w]["body"]["components"][c]["name"]..", State: "..AceAPI["inst"][i]["win"][w]["body"]["components"][c]["state"])
							return true
						end
					end
				elseif (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["type"] == "table") then
					local _cw = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"]
					local _ch = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"]
					-- Click inside component
					if (_mx >= _cx) and (_my >= _cy) and (_mx <= (_cx+_cw)) and (_my <= (_cy+_ch)) then
						if (_ms == "down") then SetFocus(i, w, c) end
						-- Select row
						local _hy = 0
						if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["header"]["enabled"] == true) then
							_hy = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["header"]["height"]
						end
						local _sx = 0
						if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["enabled"] == true) then
							_sx = _sx + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"]
						end

						local _row_start = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"]
						local _row_height = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_height"]
						local _row_display = Round(((AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"] - _hy) / _row_height), 0)
						local _row_count = #AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["rows"]
						local _dh = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"] - _hy
						local _sh = _dh - (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["scrollbar"]["size"] * 3)
						local _start_max = (_row_count - math.floor(_dh / _row_height))
						local _ss = (_sh / _start_max)
						local _spy = _ss * (_row_start-1)
						
						-- Click on header
						if (_mx >= (_cx+1)) and (_my >= (_cy)) and (_mx <= (_cx+_cw-1)) and (_my <= (_cy+_hy-1)) then
							if (_ms == "down") then
								--Log("Table: Click on header.")
							end
						end
						-- Click on row
						if (_mx >= (_cx+1)) and (_my >= (_cy+_hy+1)) and (_mx <= (_cx+_cw-_sx-1)) and (_my <= (_cy+_ch)) then
							if (_ms == "down") then
								local _last = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["selection"]["row"]
								AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["selection"]["row"] = _row_start + math.ceil(((_my - (_cy+_hy))/_row_height)) - 1
								if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["selection"]["row"] < 1) or (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["selection"]["row"] > _row_count) then
									AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["selection"]["row"] = _last
								end
							end
						end
						if _row_count > _row_display then
							-- Click on scrollbar button up
							if (_mx >= (_cx+_cw-_sx+1)) and (_my >= (_cy+_hy+1)) and (_mx <= (_cx+_cw-1)) and (_my <= (_cy+_hy+_sx-1)) then
								if (_ms == "down") then
									AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] - 1
									if AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] < 1 then
										AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] = 1
									end
								end
							end
							-- Click on scrollbar page up
							if (_mx >= (_cx+_cw-_sx+1)) and (_my >= (_cy+_hy+_sx+1)) and (_mx <= (_cx+_cw-1)) and (_my <= (_cy+_hy+_sx+_spy-1)) then
								if (_ms == "down") then
									AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] - _row_display
									if AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] < 1 then
										AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] = 1
									end
								end
							end
							-- Click on scrollbar box
							if (_mx >= (_cx+_cw-_sx+1)) and (_my >= (_cy+_hy+_sx+_spy+1)) and (_mx <= (_cx+_cw-1)) and (_my <= (_cy+_hy+_sx+_spy+_sx-1)) then
								if (_ms == "down") then
									--logMsg("DRAG")
									return true
								elseif (_ms == "drag") then
									AceAPI["inst"][i]["runtime"]["drag"] = "table"
									AceAPI["inst"][i]["runtime"]["window"] = w
									AceAPI["inst"][i]["runtime"]["component"] = c
									--AceAPI["inst"][i]["runtime"]["delta_x"] = (_cx + _o)
									--AceAPI["inst"][i]["runtime"]["delta_y"] = _cy - _my
									-- Call the events
									if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_drag"] ~= nil) and (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_drag"] ~= "") then
										_G[AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_drag"]](i,w,c)
									end																			
									return true
								elseif (_ms == "up") then
									AceAPI["inst"][i]["runtime"]["drag"] = "none"
									AceAPI["inst"][i]["runtime"]["window"] = nil
									AceAPI["inst"][i]["runtime"]["component"] = nil
									return true
								end
							end									
							-- Click on scrollbar page down
							if (_mx >= (_cx+_cw-_sx+1)) and (_my >= (_cy+_hy+_sx+_spy+_sx+1)) and (_mx <= (_cx+_cw-1)) and (_my <= (_cy+_ch-_sx-1)) then
								if (_ms == "down") then
									AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] + _row_display
									local _row_height = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_height"]
									local _row_count = #AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["rows"]
									local _dh = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"] - _hy
									local _start_max = (_row_count - Round((_dh / _row_height), 0)) + 1
									if AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] > _start_max then
										AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] = _start_max
									end
								end
							end
							-- Click on scrollbar button down
							if (_mx >= (_cx+_cw-_sx+1)) and (_my >= (_cy+_ch-_sx-1)) and (_mx <= (_cx+_cw-1)) and (_my <= (_cy+_ch-1)) then
								if (_ms == "down") then
									AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] + 1
									local _row_height = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_height"]
									local _row_count = #AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["rows"]
									local _dh = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"] - _hy
									local _start_max = (_row_count - Round((_dh / _row_height), 0)) + 1
									if AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] > _start_max then
										AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] = _start_max
									end
								end
							end
						end
						
						-- Call the events
						if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"] ~= nil) and (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"] ~= "") then
							_G[AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"]](i,w,c)
						end

						DebugLog("MouseClick (COMPONENT): Instance: "..i..", Window: "..w..", Component: "..c..", Name: "..AceAPI["inst"][i]["win"][w]["body"]["components"][c]["name"])
						return true								
					end
				elseif (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["type"] == "slider") then
					local _cw = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"]
					local _ch = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"]
					local _bs = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["control"]["buttons"]["size"]
					-- Click inside component
					if (_mx >= _cx) and (_my >= _cy) and (_mx <= (_cx+_cw)) and (_my <= (_cy+_ch)) then
						if (_ms == "down") then SetFocus(i, w, c) end
						-- Slider position
						local _min = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["min"]
						local _max = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["max"]
						local _pos = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"]
						local _dir = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["dir"]								
						local _cb = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["border"]["size"]
						local _o = ((_cw-_cb)/(_max-_min))*(_pos-_min)
							
						-- Click on left side of the bar
						if (_mx < (_cx + _o)) then
							if (_ms == "down") then
								AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] - AceAPI["inst"][i]["win"][w]["body"]["components"][c]["control"]["delta_big"]
								-- Don't go below min
								if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] < AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["min"]) then
									AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["min"]
								end	

								-- Call the events
								if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"] ~= nil) and (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"] ~= "") then
									_G[AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"]](i,w,c)
								end
								
								DebugLog("MouseClick (COMPONENT): Instance: "..i..", Window: "..w..", Component: "..c..", Name: "..AceAPI["inst"][i]["win"][w]["body"]["components"][c]["name"]..", Side: Left")
								return true
							end
						-- Click on right side of the bar
						elseif (_mx > ((_cx + _o)+_cb)) then
							if (_ms == "down") then
								AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["control"]["delta_big"]
								-- Don't go above max
								if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] > AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["max"]) then
									AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["max"]
								end
								
								-- Call the events
								if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"] ~= nil) and (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"] ~= "") then
									_G[AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"]](i,w,c)
								end
								
								DebugLog("MouseClick (COMPONENT): Instance: "..i..", Window: "..w..", Component: "..c..", Name: "..AceAPI["inst"][i]["win"][w]["body"]["components"][c]["name"]..", Side: Right")
								return true
							end
						-- Click on the slider
						elseif (_mx > (_cx + _o)) and (_mx < ((_cx + _o)+_cb)) then
							if (_ms == "down") then
								-- Call the events
								if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"] ~= nil) and (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"] ~= "") then
									_G[AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"]](i,w,c)
								end									
								DebugLog("MouseClick (COMPONENT): Instance: "..i..", Window: "..w..", Component: "..c..", Name: "..AceAPI["inst"][i]["win"][w]["body"]["components"][c]["name"]..", Side: Knob")										
								return true
							elseif (_ms == "drag") then
								AceAPI["inst"][i]["runtime"]["drag"] = "slider"
								AceAPI["inst"][i]["runtime"]["window"] = w
								AceAPI["inst"][i]["runtime"]["component"] = c
								--AceAPI["inst"][i]["runtime"]["delta_x"] = (_cx + _o)
								--AceAPI["inst"][i]["runtime"]["delta_y"] = _cy - _my
								-- Call the events
								if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_drag"] ~= nil) and (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_drag"] ~= "") then
									_G[AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_drag"]](i,w,c)
								end																			
								return true
							elseif (_ms == "up") then
								AceAPI["inst"][i]["runtime"]["drag"] = "none"
								AceAPI["inst"][i]["runtime"]["window"] = nil
								AceAPI["inst"][i]["runtime"]["component"] = nil
								return true
							end
						end	
					-- Click on left button
					elseif (_mx >= (_cx - _bs)) and (_my >= _cy) and (_mx <= _cx) and (_my <= (_cy+_ch)) then
						if (_ms == "down") then
							if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] > AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["min"]) then
								AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] - AceAPI["inst"][i]["win"][w]["body"]["components"][c]["control"]["delta_small"]
								-- Don't go below min
								if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] < AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["min"]) then
									AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["min"]
								end
							end
							
							-- Call the events
							if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"] ~= nil) and (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"] ~= "") then
								_G[AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"]](i,w,c)
							end									
							
							DebugLog("MouseClick (COMPONENT): Instance: "..i..", Window: "..w..", Component: "..c..", Name: "..AceAPI["inst"][i]["win"][w]["body"]["components"][c]["name"]..", Value: "..AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"])
							return true
						end
					-- Click on right button
					elseif (_mx >= (_cx + _cw)) and (_my >= _cy) and (_mx <= (_cx + _cw + _bs)) and (_my <= (_cy+_ch)) then
						if (_ms == "down") then
							if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] < AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["max"]) then
								AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["control"]["delta_small"]
								-- Don't go above max
								if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] > AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["max"]) then
									AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["max"]
								end
							end

							-- Call the events
							if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"] ~= nil) and (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"] ~= "") then
								_G[AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_click"]](i,w,c)
							end									
							
							DebugLog("MouseClick (COMPONENT): Instance: "..i..", Window: "..w..", Component: "..c..", Name: "..AceAPI["inst"][i]["win"][w]["body"]["components"][c]["name"]..", Value: "..AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"])
							return true
						end
					end
				end
			end
			
			if (_ms == "down") then	SetFocus(i, w) end
			-- If we don't hit any component but we're inside the window
			-- we still want to catch the mouse press. Furthermore if
			-- the mouse is released then reset the drag runtime.
			if (_ms ~= "drag") then
				AceAPI["inst"][i]["runtime"]["drag"] = "none"
				AceAPI["inst"][i]["runtime"]["window"] = nil
				AceAPI["inst"][i]["runtime"]["component"] = nil
			end
			return true

		-- Window close button
		elseif (_mx >= ((_x+_w)-_hh)) and (_my >= (_y-_hh)) and (_mx <= (_x + _w)) and (_my <= _y) then
			if (_ms == "down") then SetFocus(i, w, c) end
			if (AceAPI["inst"][i]["win"][w]["header"]["enabled"] == true) then
				if (_ms == "down") then
					if (AceAPI["inst"][i]["win"][w]["header"]["close"] == true) then
						DebugLog("MouseClick (CLOSE): Instance: "..i..", Window: "..w..", Name: "..AceAPI["inst"][i]["win"][w]["name"])
						ShowHideWindow(i, w, false)
						-- Call the functions
						if (AceAPI["inst"][i]["win"][w]["events"]["on_close"] ~= nil) and (AceAPI["inst"][i]["win"][w]["events"]["on_close"] ~= "") then
							_G[AceAPI["inst"][i]["win"][w]["events"]["on_close"]](i,w)
						end								
					else	-- Header click with no close button
						DebugLog("MouseClick (HEADER): Instance: "..i..", Window: "..w..", Name: "..AceAPI["inst"][i]["win"][w]["name"])						
					end
					return true
				end
			end

		-- Window header
		elseif (_mx >= _x) and (_my >= (_y-_hh)) and (_mx <= (_x + _w)) and (_my <= _y) then
			if (AceAPI["inst"][i]["win"][w]["header"]["enabled"] == true) then					
				if (AceAPI["inst"][i]["win"][w]["header"]["movable"] == true) then
					if (_ms == "up") then
						AceAPI["inst"][i]["runtime"]["drag"] = "none"
						AceAPI["inst"][i]["runtime"]["window"] = nil
						return false
					elseif (_ms == "down") then
						SetFocus(i, w)
						DebugLog("MouseClick (HEADER): Instance: "..i..", Window: "..w..", Name: "..AceAPI["inst"][i]["win"][w]["name"])
						AceAPI["inst"][i]["runtime"]["drag"] = nil
						return true
					elseif (_ms == "drag") and ((AceAPI["inst"][i]["runtime"]["drag"] == nil) or (AceAPI["inst"][i]["runtime"]["drag"] == "drag")) then
						SetFocus(i, w)
						AceAPI["inst"][i]["runtime"]["drag"] = "drag"
						AceAPI["inst"][i]["runtime"]["window"] = w
						AceAPI["inst"][i]["runtime"]["delta_x"] = _x - _mx
						AceAPI["inst"][i]["runtime"]["delta_y"] = _y - _my
						return true
					end
				end
			end
		end				
	end
	if (_ms == "down") then	SetFocus("keep", "keep", nil) end
	return false
end

function MouseClick()
	-- Check focus first
	if WindowClick(AceAPI["focus"]["instance"], AceAPI["focus"]["window"]) == true then return true end
	for w = #AceAPI["inst"][AceAPI["focus"]["instance"]]["win"],1,-1 do
		if (w == AceAPI["focus"]["window"]) then
			-- Do nothing
		else
			if WindowClick(AceAPI["focus"]["instance"],w) == true then return true end
		end
	end
	
	-- Iterate through all instances and windows
	for i = 1,#AceAPI["inst"] do
		if (i == AceAPI["focus"]["instance"]) then
			-- Do nothing
		else
			for w = #AceAPI["inst"][i]["win"],1,-1 do
				if WindowClick(i,w) == true then return true end
			end
		end
		-- If the click is outside any window of the instance cancel drag
		AceAPI["inst"][i]["runtime"]["drag"] = "none"
	end
	-- We didn't hit anything, don't resume the mouse
	return false
end
-- ------------------------------------------------------------------------------------------------
local function WindowWheel(i,w)
	-- Get mouse wheel coordinates
	local _mx = MOUSE_X
	local _my = Ay2Oy(MOUSE_Y)	-- Get normal Y coordinates
	local _mw = MOUSE_WHEEL_CLICKS
	
	if AceAPI["inst"][i]["win"][w]["show"] == true then
		-- Get window coordinates and dimensions
		local _x = AceAPI["inst"][i]["win"][w]["x"]
		local _y = AceAPI["inst"][i]["win"][w]["y"]
		local _w = AceAPI["inst"][i]["win"][w]["w"]
		local _h = AceAPI["inst"][i]["win"][w]["h"]
		local _hh = AceAPI["inst"][i]["win"][w]["header"]["h"]
		local _hb = AceAPI["inst"][i]["win"][w]["header"]["border"]
		local _b = AceAPI["inst"][i]["win"][w]["body"]["border"]
	
	
		-- Window body
		if (_mx >= _x) and (_my >= _y) and (_mx <= (_x + _w)) and (_my <= (_y + _h)) then	
			-- Iterate through all components in window body
			for c = 1,#AceAPI["inst"][i]["win"][w]["body"]["components"] do
				-- Get common component variables
				local _cx = _x + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["x"]
				local _cy = _y + AceAPI["inst"][i]["win"][w]["body"]["components"][c]["y"]
			
				if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["type"] == "slider") then
					local _cw = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"]
					local _ch = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"]
					-- Click inside component
					if (_mx >= _cx) and (_my >= _cy) and (_mx <= (_cx+_cw)) and (_my <= (_cy+_ch)) then
						SetFocus(i, w, c)
						AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] + (MOUSE_WHEEL_CLICKS * AceAPI["inst"][i]["win"][w]["body"]["components"][c]["control"]["delta_wheel"])
						-- Don't go below min
						if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] < AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["min"]) then
							AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["min"]
						end					
						-- Don't go above max
						if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] > AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["max"]) then
							AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["max"]
						end							

						-- Call the events
						if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_wheel"] ~= nil) and (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_wheel"] ~= "") then
							_G[AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_wheel"]](i,w,c)
						end									

						DebugLog("MouseWheel (COMPONENT): Instance: "..i..", Window: "..w..", Component: "..c..", Name: "..AceAPI["inst"][i]["win"][w]["body"]["components"][c]["name"]..", Value: "..AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"])
						return true
					end
				elseif (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["type"] == "table") then
					local _cw = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"]
					local _ch = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"]
					-- Click inside component
					if (_mx >= _cx) and (_my >= _cy) and (_mx <= (_cx+_cw)) and (_my <= (_cy+_ch)) then
						SetFocus(i, w, c)
						local _hy = 0
						if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["header"]["enabled"] == true) then
							_hy = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["header"]["height"]
						end
						AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] - MOUSE_WHEEL_CLICKS
						if AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] > (#AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["rows"] - Round(((AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"]-_hy)/AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_height"]),0)+1) then
							AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] = (#AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["rows"] - Round(((AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"]-_hy)/AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_height"]),0)+1)
						end
						if AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] < 1 then
							AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"] = 1
						end
						--DebugLog("Start: "..AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["display"]["start"].." Rows: "..#AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["rows"].." Display: "..Round(((AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"]-_hy)/AceAPI["inst"][i]["win"][w]["body"]["components"][c]["table"]["row_height"]),0))
					end
				elseif (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["type"] == "progress_bar") then
					local _cw = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["w"]
					local _ch = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["h"]
					-- Click inside component
					if (_mx >= _cx) and (_my >= _cy) and (_mx <= (_cx+_cw)) and (_my <= (_cy+_ch)) then
						SetFocus(i, w, c)
						AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] + (MOUSE_WHEEL_CLICKS * AceAPI["inst"][i]["win"][w]["body"]["components"][c]["control"]["delta_wheel"])
						-- Don't go below min
						if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] < AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["min"]) then
							AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["min"]
						end					
						-- Don't go above max
						if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] > AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["max"]) then
							AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["max"]
						end							

						-- Call the events
						if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_wheel"] ~= nil) and (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_wheel"] ~= "") then
							_G[AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_wheel"]](i,w,c)
						end									

						DebugLog("MouseWheel (COMPONENT): Instance: "..i..", Window: "..w..", Component: "..c..", Name: "..AceAPI["inst"][i]["win"][w]["body"]["components"][c]["name"]..", Value: "..AceAPI["inst"][i]["win"][w]["body"]["components"][c]["bar"]["pos"])
						return true
					end
				end
			end
			-- We hit inside a window but not on a component, resume mouse wheel
			SetFocus(i, w, nil)
			return true
		end			
	end
	return false
end

-- Mouse wheel handler
function MouseWheel()
	-- Check focus first
	if WindowWheel(AceAPI["focus"]["instance"], AceAPI["focus"]["window"]) == true then return true end
	for w = #AceAPI["inst"][AceAPI["focus"]["instance"]]["win"],1,-1 do
		if (w == AceAPI["focus"]["window"]) then
			-- Do nothing
		else
			if WindowWheel(AceAPI["focus"]["instance"],w) == true then return true end
		end
	end
	
	-- Iterate through all instances and windows
	for i = 1,#AceAPI["inst"] do
		if (i == AceAPI["focus"]["instance"]) then
			-- Do nothing
		else
			for w = #AceAPI["inst"][i]["win"],1,-1 do
				if WindowWheel(i,w) == true then return true end
			end
		end
		-- If the click is outside any window of the instance cancel drag
		AceAPI["inst"][i]["runtime"]["drag"] = "none"
	end
	-- We didn't hit anything, don't resume the mouse
	return false
end

-- KeyPress handler
function KeyPress()
	local i = AceAPI["focus"]["instance"]
	local w = AceAPI["focus"]["window"]
	local c = AceAPI["focus"]["component"]
	
	if (c ~= nil) then
		if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["type"] == "editbox") then
			if (KEY_ACTION == "pressed") then
				if  (VKEY == 8) then
					AceAPI["inst"][i]["win"][w]["body"]["components"][c]["text"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["text"]:sub(1, -2)
				elseif (VKEY == 13) or (VKEY == 27) then
					AceAPI["focus"]["component"] = nil
					-- Call the events
					if (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_enter"] ~= nil) and (AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_enter"] ~= "") then
						_G[AceAPI["inst"][i]["win"][w]["body"]["components"][c]["events"]["on_enter"]](i,w,c)
					end									
				else
					if (string.len(AceAPI["inst"][i]["win"][w]["body"]["components"][c]["text"]) < AceAPI["inst"][i]["win"][w]["body"]["components"][c]["max_len"]) then
						for p = 1, #AceAPI["inst"][i]["win"][w]["body"]["components"][c]["filters"] do
							if TestPat(CKEY, AceAPI["inst"][i]["win"][w]["body"]["components"][c]["filters"][p]) == true then
								AceAPI["inst"][i]["win"][w]["body"]["components"][c]["text"] = AceAPI["inst"][i]["win"][w]["body"]["components"][c]["text"]..CKEY
							end
						end
					end
				end
				DebugLog("KeyPress (COMPONENT): Instance: "..i..", Window: "..w..", Component: "..c..", Name: "..AceAPI["inst"][i]["win"][w]["body"]["components"][c]["name"]..", VKEY: "..VKEY..", CKEY: "..CKEY)
				return true
			end
		end
	end	
	return false
end
-- ------------------------------------------------------------------------------------------------
-- Register mouse & keyboard handlers
do_on_mouse_click("if aapi2.MouseClick() then RESUME_MOUSE_CLICK = true else RESUME_MOUSE_CLICK = false end")
do_on_mouse_wheel("if aapi2.MouseWheel() then RESUME_MOUSE_WHEEL = true else RESUME_MOUSE_WHEEL = false end")
do_on_keystroke("if aapi2.KeyPress() then RESUME_KEY = true else RESUME_KEY = false end")
-- ------------------------------------------------------------------------------------------------
local function Update()
	for i = 1,#AceAPI["inst"] do
		-- Update dragged window position
		if (AceAPI["inst"][i]["runtime"]["drag"] == "drag") then
			local _w = AceAPI["inst"][i]["runtime"]["window"]		
			AceAPI["inst"][i]["win"][_w]["x"] = MOUSE_X + AceAPI["inst"][i]["runtime"]["delta_x"]
			AceAPI["inst"][i]["win"][_w]["y"] = (Ay2Oy(MOUSE_Y)) + AceAPI["inst"][i]["runtime"]["delta_y"]
			-- Call the functions
			if (AceAPI["inst"][i]["win"][_w]["events"]["on_drag"] ~= nil) and (AceAPI["inst"][i]["win"][_w]["events"]["on_drag"] ~= "") then
				_G[AceAPI["inst"][i]["win"][_w]["events"]["on_drag"]](i,_w,_c)
			end	
		-- Update dragged slider
		elseif (AceAPI["inst"][i]["runtime"]["drag"] == "slider") then
			local _w = AceAPI["inst"][i]["runtime"]["window"]		
			local _c = AceAPI["inst"][i]["runtime"]["component"]		
			local _min = AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["bar"]["min"]
			local _max = AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["bar"]["max"]
			local _cx = AceAPI["inst"][i]["win"][_w]["x"] + AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["x"]
			local _cw = AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["w"]
			local _gs = _cw / (_max - _min)
			AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["bar"]["pos"] = math.floor((MOUSE_X-_cx)/_gs)
			-- Don't go below min
			if (AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["bar"]["pos"] < AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["bar"]["min"]) then
				AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["bar"]["pos"] = AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["bar"]["min"]
			end										
			-- Don't go above max
			if (AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["bar"]["pos"] > AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["bar"]["max"]) then
				AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["bar"]["pos"] = AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["bar"]["max"]
			end
			-- Call the functions
			if (AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["events"]["on_drag"] ~= nil) and (AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["events"]["on_drag"] ~= "") then
				_G[AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["events"]["on_drag"]](i,_w,_c)
			end	
		elseif (AceAPI["inst"][i]["runtime"]["drag"] == "table") then
			local _w = AceAPI["inst"][i]["runtime"]["window"]		
			local _c = AceAPI["inst"][i]["runtime"]["component"]
			local _hy = 0
			
			if (AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["table"]["header"]["enabled"] == true) then
				_hy = AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["table"]["header"]["height"]
			end
			local _sx = 0
			if (AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["table"]["scrollbar"]["enabled"] == true) then
				_sx = _sx + AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["table"]["scrollbar"]["size"]
			end
			
			local _row_start = AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["table"]["display"]["start"]
			local _row_height = AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["table"]["row_height"]
			--local _row_display = Round(((AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["h"] - _hy) / _row_height), 0)
			local _row_count = #AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["table"]["rows"]
			local _dh = AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["h"] - _hy
			local _sh = _dh - (AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["table"]["scrollbar"]["size"] * 3)
			local _start_max = (_row_count - math.floor(_dh / _row_height)) + 1
			local _ss = (_sh / _start_max)
			
			local _cy = AceAPI["inst"][i]["win"][_w]["y"] + AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["y"]

			local _mcy = (Ay2Oy(MOUSE_Y) - _cy - _hy - _sx - (_sx/2))
			local _pos = math.floor(_mcy / _ss)
			
			if _pos < 1 then _pos = 1
			elseif _pos > _start_max then _pos = _start_max end
			
			AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["table"]["display"]["start"] = _pos
			
			-- Call the functions
			if (AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["events"]["on_drag"] ~= nil) and (AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["events"]["on_drag"] ~= "") then
				_G[AceAPI["inst"][i]["win"][_w]["body"]["components"][_c]["events"]["on_drag"]](i,_w,_c)
			end	
		end
		if MOUSE_STATUS == "up" then
			AceAPI["inst"][i]["runtime"]["drag"] = "none"
			AceAPI["inst"][i]["runtime"]["window"] = nil
			AceAPI["inst"][i]["runtime"]["component"] = nil			
		end
	end
end


-- ************************************************************************************************************************************************************************************************
-- MAIN LOOP SECTION
function Main()
	Update()
	Redraw()
	return
end
do_every_draw("aapi2.Main()")


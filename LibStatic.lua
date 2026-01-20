--[[------------------------------------------------------------------------------------------------
Title:					LibStatic
Author:					Static_Recharge
Version:				0.0.1
Description:		Static_Recharge common utility functions.
------------------------------------------------------------------------------------------------]]--


--[[------------------------------------------------------------------------------------------------
Libraries and Aliases
------------------------------------------------------------------------------------------------]]--
local CS = CHAT_SYSTEM
local EM = EVENT_MANAGER
local CR = CHAT_ROUTER
local CSA = CENTER_SCREEN_ANNOUNCE


--[[------------------------------------------------------------------------------------------------
Globals
------------------------------------------------------------------------------------------------]]--
LIBSTATIC_BOOL_TYPE_MIN = 1
LIBSTATIC_BOOL_TYPE_MAX = 7
LIBSTATIC_BOOL_TYPE_TRUE_FALSE = 1
LIBSTATIC_BOOL_TYPE_POSITIVE_NEGATIVE = 2
LIBSTATIC_BOOL_TYPE_YES_NO = 3
LIBSTATIC_BOOL_TYPE_ON_OFF = 4
LIBSTATIC_BOOL_TYPE_ENABLED_DISABLED = 5
LIBSTATIC_BOOL_TYPE_PLUS_MINUS = 6
LIBSTATIC_BOOL_TYPE_ACTIVE_INACTIVE = 7


--[[------------------------------------------------------------------------------------------------
LS Class Initialization
LS    - Parent object containing all functions, tables, variables, constants and other data managers.
------------------------------------------------------------------------------------------------]]--
local LS = ZO_InitializingObject:Subclass()


--[[------------------------------------------------------------------------------------------------
LS:Initialize()
Inputs:				None
Outputs:			None
Description:	Initializes all of the variables, object managers, slash commands and main event
							callbacks.
------------------------------------------------------------------------------------------------]]--
function LS:Initialize()
	-- Static definitions
	self.addonName = "LibStatic"
	self.addonVersion = "0.0.1"
	self.author = "|cFF0000Static_Recharge|r"
  self.chatPrefix = "|cFFFFFF[LibStatic]:|r "
	self.chatTextColor = "|cFFFFFF"
	self.chatSuffix = "|r"

  SLASH_COMMANDS["/lstest"] = function(...) self:Test(...) end

  self.initialized = true
end


--[[------------------------------------------------------------------------------------------------
LS:Convert(input, returnType)
Inputs:				input 						                  - input to convert
              returnType                          - (optional) determines the pair of possible return values for bool inputs
Outputs:			string 					                    - string containing the converted input, or the input if no change needed
Description:	Returns a string friendly converted input or the input if no change needed.
------------------------------------------------------------------------------------------------]]--
function LS:Convert(input, returnType)
  -- exit right away if nil with 'nil' text
  if input == nil then return "nil" end
  -- exit right away if empty string with 'empty_string' text
  if input == "" then return "empty_string" end
  -- exit right away if not a bool, return the original value
	if type(input) ~= "boolean" then return input end

  -- list of possible responses
  local Responses = {
    {"true", "false"},
    {"positive", "negative"},
    {"yes", "no"},
    {"on", "off"},
    {"enabled", "disabled"},
    {"+", "-"},
    {"active", "inactive"},
  }

  -- set default if no return type specified
  if not returnType or returnType < LIBSTATIC_BOOL_TYPE_MIN or returnType > LIBSTATIC_BOOL_TYPE_MAX then
    returnType = LIBSTATIC_BOOL_TYPE_TRUE_FALSE
  end

  -- if true
  if input then
    return Responses[returnType][1]
  -- if false
  else
    return Responses[returnType][2]
  end
end


--[[------------------------------------------------------------------------------------------------
LS:PairedListNew(Choices, Values)
Inputs:				Choices                             - Table of choices (enums)
              Values                              - (optional) Table of values
Outputs:			PairedList                          - The new object created.
Description:	Returns a new PairedList object.
------------------------------------------------------------------------------------------------]]--
function LS:PairedListNew(Choices, Values)
  return LibStaticPairedListInitialize(Choices, Values)
end


--[[------------------------------------------------------------------------------------------------
LS:Test(...)
Inputs:				...							                    - Various test inputs
Outputs:			...                                 - Various test outputs
Description:	For internal add-on testing only.
------------------------------------------------------------------------------------------------]]--
function LS:Test(...)
	local pl = self:PairedListNew({"A", "B", "C"}, {8, 9, 3})
  d(pl:GetChoices(), pl:GetValues())
  pl:Sort(LIBSTATIC_LIST_SORT_VALUE_ASCENDING)
  d(pl:GetChoices(), pl:GetValues())
end


--[[------------------------------------------------------------------------------------------------
Main add-on event registration. Creates the global object, LibStatic, of the LS class.
------------------------------------------------------------------------------------------------]]--
EM:RegisterForEvent("LibStatic", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
	if addonName ~= "LibStatic" then return end
	EM:UnregisterForEvent("LibStatic", EVENT_ADD_ON_LOADED)
	LibStatic = LS:New()
end)
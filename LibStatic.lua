--[[------------------------------------------------------------------------------------------------
Title:					LibStatic
Author:					Static_Recharge
Version:				0.0.3
Description:		Static_Recharge common utility functions.

LS                                                - Object containing all functions, tables, variables, constants and other data managers.
├─ :IsInitialized()                               - Returns true if the object has been successfully initialized.
├─ :StringConvert(input, returnType)              - Returns a string friendly converted input or the input if no change needed.
├─ :PairedListNew(Choices, Values)                - Returns a new PairedList object.
├─ :ChatNew(Options)                              - Returns a new Chat object.
├─ :TimerNew(Options)                             - Returns a new Timer object.
└─ :Test(...)                                     - For internal add-on testing only.
------------------------------------------------------------------------------------------------]]--


--[[------------------------------------------------------------------------------------------------
Libraries and Aliases
------------------------------------------------------------------------------------------------]]--
local CS = CHAT_SYSTEM
local EM = EVENT_MANAGER


--[[------------------------------------------------------------------------------------------------
Globals
------------------------------------------------------------------------------------------------]]--
-- for use with LS:StringConvert
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
	self.addonVersion = "0.0.3"
	self.author = "|cFF0000Static_Recharge|r"
  self.chatPrefix = "|cFFFFFF[LibStatic]:|r "
	self.chatTextColor = "|cFFFFFF"
	self.chatSuffix = "|r"

  SLASH_COMMANDS["/lstest"] = function(...) self:Test(...) end

  self.initialized = true
end


--[[------------------------------------------------------------------------------------------------
LS:IsInitialized()
Inputs:				None
Outputs:			initialized                         - bool for object initialized state
Description:	Returns true if the object has been successfully initialized.
------------------------------------------------------------------------------------------------]]--
function LS:IsInitialized()
  return self.initialized
end


--[[------------------------------------------------------------------------------------------------
LS:StringConvert(input, returnType)
Inputs:				input 						                  - input to convert
              returnType                          - (optional) determines the pair of possible return values for bool inputs
Outputs:			string 					                    - string containing the converted input, or the input if no change needed
Description:	Returns a string friendly converted input or the input if no change needed.
------------------------------------------------------------------------------------------------]]--
function LS:StringConvert(input, returnType)
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
LS:ChatNew(Options)
Inputs:				Options                             - Table containing parameters
                                                    - (optional) addonIdentifier
                                                    - (optional) Hexcode color
                                                    - (optional) Hexcode color
                                                    - (optional) bool that enables chat
                                                    - (optional) bool that enables debug
Outputs:			None
Description:	Returns a new Chat object.
------------------------------------------------------------------------------------------------]]--
function LS:ChatNew(Options)
  return LibStaticChatInitialize(Options)
end


--[[------------------------------------------------------------------------------------------------
LS:TimerNew(Options)
Inputs:				Options                             - Table containing all of the options
                                                    - uniqueName
                                                    - (optional) timerType
                                                    - (optional) updateInterval (global)
                                                    - duration (ms)
                                                    - (optional) updateCallback(uniqueName, accumulator)
                                                    - (optional) finishedCallback(uniqueName)
Outputs:			None
Description:	Returns a new Timer object.
------------------------------------------------------------------------------------------------]]--
function LS:TimerNew(Options)
  return LibStaticTimerInitialize(Options)
end


--[[------------------------------------------------------------------------------------------------
LS:Test(...)
Inputs:				...							                    - Various test inputs
Outputs:			...                                 - Various test outputs
Description:	For internal add-on testing only.
------------------------------------------------------------------------------------------------]]--
function LS:Test(...)
  self.chat = self:ChatNew()

  local Options = {
    uniqueName = "LibStaticTimer",
    duration = 30000,
    timerType = LIBSTATIC_TIMER_TYPE_COUNT_DOWN,
    updateInterval = LIBSTATIC_TIMER_UPDATE_INTERVAL_1000,
    updateCallback = function(uniqueName, accumulator) self.chat:Msg(accumulator) end,
    finishedCallback = function(uniqueName) self.chat:Msg(uniqueName) end,
  }

  self.timer = self:TimerNew(Options)
  self.timer:Start()
end

-- /script LibStatic.timer:Pause()


--[[------------------------------------------------------------------------------------------------
Main add-on event registration. Creates the global object, LibStatic, of the LS class.
------------------------------------------------------------------------------------------------]]--
EM:RegisterForEvent("LibStatic", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
	if addonName ~= "LibStatic" then return end
	EM:UnregisterForEvent("LibStatic", EVENT_ADD_ON_LOADED)
	LibStatic = LS:New()
end)
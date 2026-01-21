--[[------------------------------------------------------------------------------------------------
Title:					Chat
Author:					Static_Recharge
Description:		Object to manage sending messages to chat with proper wrappers.

CHAT                                              - Object containing all functions, tables, variables, constants and other data managers.
├─ :IsInitialized()                               - Returns true if the object has been successfully initialized.
├─ :SetChatEnabled(state)                         - Sets the chat enabled state for the object.
├─ :SetDebugEnabled(state)                        - Sets the debug enabled state for the object.
├─ :Msg(...)                                      - Formats text to be sent to the chat box for the user. Bools, nil and empty strings will be converted to 
│                                                   text formats. All inputs after the first will be placed on a new line within the message.
│                                                   Only the first line gets the add-on prefix.
└─ :Debug(...)                                    - Routes the debug info to the chat method if debugging is on.
------------------------------------------------------------------------------------------------]]--


--[[------------------------------------------------------------------------------------------------
Libraries and Aliases
------------------------------------------------------------------------------------------------]]--
local CS = CHAT_SYSTEM


--[[------------------------------------------------------------------------------------------------
CHAT Class Initialization
------------------------------------------------------------------------------------------------]]--
local CHAT = ZO_InitializingObject:Subclass()


--[[------------------------------------------------------------------------------------------------
CHAT:Initialize(Options)
Inputs:				Options                             - Table containing parameters
                                                    - (optional) addonIdentifier
                                                    - (optional) Hexcode color
                                                    - (optional) Hexcode color
                                                    - (optional) bool that enables chat
                                                    - (optional) bool that enables debug
Outputs:			None
Description:	Initializes the object with given inputs.
<<prefixColor>>[<<addonIdentifier>>]: <<textColor>><<message>>
------------------------------------------------------------------------------------------------]]--
function CHAT:Initialize(Options)
  if not Options then Options = {} end
  self.prefix = "|c"
  self.suffix = "|r"
  self.prefixColor = Options.prefixColor or "FFFFFF"
  self.addonIdentifier = Options.addonIdentifier or "LibStatic"
  self.textColor = Options.textColor or "FFFFFF"
  self.chatEnabled = Options.chatEnabled or true
  self.debugEnabled = Options.debugEnabled or false

  self.initialized = true
end


--[[------------------------------------------------------------------------------------------------
CHAT:IsInitialized()
Inputs:				None
Outputs:			initialized                         - bool for object initialized state
Description:	Returns true if the object has been successfully initialized.
------------------------------------------------------------------------------------------------]]--
function CHAT:IsInitialized()
  return self.initialized
end


--[[------------------------------------------------------------------------------------------------
CHAT:SetChatEnabled(state)
Inputs:				state                               - bool, true to enable chat.
Outputs:			None
Description:	Sets the chat enabled state for the object.
------------------------------------------------------------------------------------------------]]--
function CHAT:SetChatEnabled(state)
  self.chatEnabled = state
end


--[[------------------------------------------------------------------------------------------------
CHAT:SetDebugEnabled(state)
Inputs:				state                               - bool, true to enable debug.
Outputs:			None
Description:	Sets the debug enabled state for the object.
------------------------------------------------------------------------------------------------]]--
function CHAT:SetDebugEnabled(state)
  self.debugEnabled = state
end


--[[------------------------------------------------------------------------------------------------
CHAT:Msg(...)
Inputs:				...                                 - Any number of arguments that are strings, numbers or bools to post to chat. Will accept tables of strings
Outputs:			None
Description:	Formats text to be sent to the chat box for the user. Bools, nil and empty strings will be converted to 
							text formats. All inputs after the first will be placed on a new line within the message.
              Only the first line gets the add-on prefix.
------------------------------------------------------------------------------------------------]]--
function CHAT:Msg(...)
  -- exit if not enabled
  if not self.chatEnabled then return end

	local Args = {...}
  local first = true

  -- check for first line and format output
  local function sendMsg(input)
    if first then
      CS:AddMessage(zo_strformat("<<1>><<2>>[<<3>>]:<<4>> <<5>><<6>><<7>><<8>>", self.prefix, self.prefixColor, self.addonIdentifier, self.suffix, self.prefix, self.textColor, input, self.suffix))
      first = false
    else
      CS:AddMessage(zo_strformat("<<1>><<2>><<3>><<4>>", self.prefix, self.textColor, input, self.suffix))
    end
  end

  -- cycle through the inputs and send them to chat
  for i, v in ipairs(Args) do
    if type(v) == "table" then
      for j, k in ipairs(v) do
        sendMsg(LibStatic:StringConvert(k))
      end
    else
      sendMsg(LibStatic:StringConvert(v))
    end
  end
end


--[[------------------------------------------------------------------------------------------------
CHAT:Debug(...)
Inputs:				...                                 - Any number of arguments that are strings, numbers or bools to post to chat. Will accept tables of strings
Outputs:			None
Description:	Routes the debug info to the chat method if debugging is on.
------------------------------------------------------------------------------------------------]]--
function CHAT:Debug(...)
  -- exit if not enabled
  if not self.debugEnabled then return end

	self:Msg(...)
end


--[[------------------------------------------------------------------------------------------------
LibStaticChatInitialize()
Inputs:				Options                             - Table containing parameters
                                                    - (optional) addonIdentifier
                                                    - (optional) Hexcode color
                                                    - (optional) Hexcode color
                                                    - (optional) bool that enables chat
                                                    - (optional) bool that enables debug
Outputs:			CHAT                                - The new object created.
Description:	Global function to create a new instance of this object.
------------------------------------------------------------------------------------------------]]--
function LibStaticChatInitialize(Options)
	return CHAT:New(Options)
end
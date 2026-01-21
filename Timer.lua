--[[------------------------------------------------------------------------------------------------
Title:					Timer
Author:					Static_Recharge
Description:		Object to manage a timer

TIMER                                             - Object containing all functions, tables, variables, constants and other data managers.
├─ :IsInitialized()                               - Returns true if the object has been successfully initialized.
├─ :IsRunning()                                   - Returns true if the timer is running.
├─ :IsPaused()                                    - Returns true if the timer is paused.
├─ :IsFinished()                                  - Returns true if the timer is finished.
├─ :SetDuration(duration)                         - Sets a new duration value rounded down. This cannot be done if the timer is running or paused. Stop the timer first.
├─ :SetAccumulator(accumulator)                   - Sets a new accumulator value. This cannot be done if the timer is running or paused. Stop the timer first.
├─ :Start()                                       - Starts the timer with the current object settings. Timer must not be running or paused.
├─ :TimerUpdate()                                 - Updates the accumulator and checks for the finished condition. Calls proper callbacks.
├─ :Stop()                                        - Stops and resets the timer to pre-provided parameters. Will override running and paused.
└─ :Pause(state)                                  - Pauses/unpauses the timer. If no state is specified then it will be toggled. Only works if currently running or paused.
------------------------------------------------------------------------------------------------]]--

--[[------------------------------------------------------------------------------------------------
Libraries and Aliases
------------------------------------------------------------------------------------------------]]--
local EM = EVENT_MANAGER


--[[------------------------------------------------------------------------------------------------
Globals
------------------------------------------------------------------------------------------------]]--
-- timer types
LIBSTATIC_TIMER_TYPE_MIN = 1
LIBSTATIC_TIMER_TYPE_MAX = 2
LIBSTATIC_TIMER_TYPE_COUNT_UP = 1
LIBSTATIC_TIMER_TYPE_COUNT_DOWN = 2

-- timer update intervals (ms)
LIBSTATIC_TIMER_UPDATE_INTERVAL_100 = 100
LIBSTATIC_TIMER_UPDATE_INTERVAL_200 = 200
LIBSTATIC_TIMER_UPDATE_INTERVAL_500 = 500
LIBSTATIC_TIMER_UPDATE_INTERVAL_1000 = 1000


--[[------------------------------------------------------------------------------------------------
TIMER Class Initialization
------------------------------------------------------------------------------------------------]]--
local TIMER = ZO_InitializingObject:Subclass()


--[[------------------------------------------------------------------------------------------------
TIMER:Initialize()
Inputs:				Options                             - Table containing all of the options
                                                    - uniqueName
                                                    - (optional) timerType
                                                    - (optional) updateInterval (global)
                                                    - duration (ms)
                                                    - (optional) updateCallback(uniqueName, accumulator)
                                                    - (optional) finishedCallback(uniqueName)
Outputs:			None
Description:	Initializes the object.
------------------------------------------------------------------------------------------------]]--
function TIMER:Initialize(Options)
  self.uniqueName = Options.uniqueName
  self.timerType = Options.timerType or LIBSTATIC_TIMER_TYPE_COUNT_UP
  self.updateInterval = Options.updateInterval or LIBSTATIC_TIMER_UPDATE_INTERVAL_200
  self.duration = Options.duration
  self.updateCallback = Options.updateCallback or function() end
  self.finishedCallback = Options.finishedCallback or function() end
  self.running = false
  self.paused = false
  self.finished = false
  
  self.initialized = true
end


--[[------------------------------------------------------------------------------------------------
TIMER:IsInitialized()
Inputs:				None
Outputs:			initialized                         - bool for timer initialized state
Description:	Returns true if the timer has been successfully initialized.
------------------------------------------------------------------------------------------------]]--
function TIMER:IsInitialized()
  return self.initialized
end


--[[------------------------------------------------------------------------------------------------
TIMER:IsRunning()
Inputs:				None
Outputs:			initialized                         - bool for timer running state
Description:	Returns true if the timer is running.
------------------------------------------------------------------------------------------------]]--
function TIMER:IsRunning()
  return self.running
end


--[[------------------------------------------------------------------------------------------------
TIMER:IsPaused()
Inputs:				None
Outputs:			initialized                         - bool for timer paused state
Description:	Returns true if the timer is paused.
------------------------------------------------------------------------------------------------]]--
function TIMER:IsPaused()
  return self.paused
end


--[[------------------------------------------------------------------------------------------------
TIMER:IsFinished()
Inputs:				None
Outputs:			initialized                         - bool for timer finished state
Description:	Returns true if the timer is finished.
------------------------------------------------------------------------------------------------]]--
function TIMER:IsFinished()
  return self.finished
end


--[[------------------------------------------------------------------------------------------------
TIMER:SetDuration(duration)
Inputs:				duration                            - duration to set (ms)
Outputs:			None
Description:	Sets a new duration value rounded down. This cannot be done if the timer is running or paused. Stop the timer first.
------------------------------------------------------------------------------------------------]]--
function TIMER:SetDuration(duration)
  if duration < 0 or self.running or self.paused then return end

  self.duration = math.floor(duration)
end


--[[------------------------------------------------------------------------------------------------
TIMER:SetAccumulator(accumulator)
Inputs:				accumulator                         - accumulator to set (ms)
Outputs:			None
Description:	Sets a new accumulator value. This cannot be done if the timer is running or paused. Stop the timer first.
------------------------------------------------------------------------------------------------]]--
function TIMER:SetAccumulator(accumulator)
  if accumulator < 0 or self.running or self.paused then return end

  self.accumulator = accumulator
end


--[[------------------------------------------------------------------------------------------------
TIMER:Start()
Inputs:				None
Outputs:			None
Description:	Starts the timer with the current object settings. Timer must not be running or paused.
------------------------------------------------------------------------------------------------]]--
function TIMER:Start()
  if self.running or self.paused then return end

  self.startTime = GetFrameTimeMilliseconds()
  self.endTime = self.startTime + self.duration
  self.running = true

  if self.timerType == LIBSTATIC_TIMER_TYPE_COUNT_UP then
    self.accumulator = 0
  else
    self.accumulator = self.duration
  end

  EM:RegisterForUpdate(self.uniqueName, self.updateInterval, function(...) self:TimerUpdate(...) end)
end


--[[------------------------------------------------------------------------------------------------
TIMER:TimerUpdate()
Inputs:				None
Outputs:			None
Description:	Updates the accumulator and checks for the finished condition. Calls proper callbacks.
------------------------------------------------------------------------------------------------]]--
function TIMER:TimerUpdate()
  local now = GetFrameTimeMilliseconds()

  if now >= self.endTime then
    self.finished = true
    self.running = false
    EM:UnregisterForUpdate(self.uniqueName)
    self.finishedCallback(self.uniqueName)
  else
    if self.timerType == LIBSTATIC_TIMER_TYPE_COUNT_UP then
      self.accumulator = now - self.startTime
    else
      self.accumulator = self.endTime - now
    end
    self.updateCallback(self.uniqueName, self.accumulator)
  end
end


--[[------------------------------------------------------------------------------------------------
TIMER:Stop()
Inputs:				None
Outputs:			None
Description:	Stops and resets the timer to pre-provided parameters. Will override running and paused.
------------------------------------------------------------------------------------------------]]--
function TIMER:Stop()
  self.running = false
  self.paused = false
  self.accumulator = nil
  self.startTime = nil
  self.endTime = nil
  self.finished = false
  self.pauseTimeLeft = nil
  self.pauseTimePassed = nil

  EM:UnregisterForUpdate(self.uniqueName)
end


--[[------------------------------------------------------------------------------------------------
TIMER:Pause(state)
Inputs:				State                               - (optional) bool to force paused state
Outputs:			None
Description:	Pauses/unpauses the timer. If no state is specified then it will be toggled. Only works if currently running or paused.
------------------------------------------------------------------------------------------------]]--
function TIMER:Pause(state)
  local now = GetFrameTimeMilliseconds()
  if not state then
    self.paused = not self.paused
  elseif state ~= self.paused then
    self.paused = state
  else
    return
  end

  -- self.paused is the 'new' paused state
  if self.paused and self.running then
    self.pauseTimeLeft = self.endTime - now
    self.pauseTimePassed = now - self.startTime
    self.running = false
    EM:UnregisterForUpdate(self.uniqueName)
  elseif not self.paused and not self.running then
    self.endTime = now + self.pauseTimeLeft
    self.startTime = now - self.pauseTimePassed
    self.running = true
    EM:RegisterForUpdate(self.uniqueName, self.updateInterval, function(...) self:TimerUpdate(...) end)
  end
end


--[[------------------------------------------------------------------------------------------------
LibStaticTimerInitialize()
Inputs:				Options                             - Table containing all of the options
                                                    - uniqueName
                                                    - (optional) timerType
                                                    - (optional) updateInterval (global)
                                                    - duration (ms)
                                                    - (optional) updateCallback(uniqueName, accumulator)
                                                    - (optional) finishedCallback(uniqueName)
Outputs:			TIMER                               - The new object created.
Description:	Global function to create a new instance of this object.
------------------------------------------------------------------------------------------------]]--
function LibStaticTimerInitialize(Options)
	return TIMER:New(Options)
end
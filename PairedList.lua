--[[------------------------------------------------------------------------------------------------
Title:					Paired List
Author:					Static_Recharge
Description:		Object to manage a paired list of choices and values. Mainly for settings menus.
                If no Values table is passed in the object will become an enumerated list instead.

PL                                                - Object containing all functions, tables, variables, constants and other data managers.
├─ :IsEnum()                                      - Returns true if the object is an enum list.
├─ :IsInitialized()                               - Returns true if the object has been successfully initialized.
├─ :GetChoices()                                  - Returns the Choices table.
├─ :GetValues()                                   - Returns the Values table.
├─ :GetChoiceByValue(value)                       - Returns the matching choice from the paired list.
├─ :UpdateData(Choices, Values)                   - Updates the Choices and Values tables.
├─ :Sort(sortType)                                - Sorts the paired list by the specified sortType (use globals).
├─ .choice_1 ┐
¦      ¦     ├─                                   - Allows choices to be used directly, good for enums. Ex: PL.choice_2
└─ .choice_n ┘
------------------------------------------------------------------------------------------------]]--


--[[------------------------------------------------------------------------------------------------
Globals
------------------------------------------------------------------------------------------------]]--
-- for use with PL:Sort
LIBSTATIC_LIST_SORT_MIN = 1
LIBSTATIC_LIST_SORT_MAX = 4
LIBSTATIC_LIST_SORT_CHOICES_ASCENDING = 1
LIBSTATIC_LIST_SORT_CHOICES_DESCENDING = 2
LIBSTATIC_LIST_SORT_VALUE_ASCENDING = 3
LIBSTATIC_LIST_SORT_VALUE_DESCENDING = 4

--[[------------------------------------------------------------------------------------------------
PL Class Initialization
------------------------------------------------------------------------------------------------]]--
local PL = ZO_InitializingObject:Subclass()


--[[------------------------------------------------------------------------------------------------
PL:Initialize()
Inputs:				Choices                             - Table of choices (enums)
              Values                              - (optional) Table of values
Outputs:			None
Description:	Initializes the object. If Values table is missing the object will be treated as an enumerated list.
              Once created as an enum that shouldn't be changed. It's better to destroy the object and start over.
------------------------------------------------------------------------------------------------]]--
function PL:Initialize(Choices, Values)
  self.Choices = Choices
  self.Values = Values
  self.isEnum = false

  -- if used as enum
  if self.Values == nil then
    self.Values = {}
    for index, choice in ipairs(self.Choices) do
      table.insert(self.Values, index)
      self[choice] = index
    end
    self.isEnum = true

  -- if not enum
  else
    for index, choice in ipairs(self.Choices) do
      self[choice] = self.Values[index]
    end
  end

  self.initialized = true
end


--[[------------------------------------------------------------------------------------------------
PL:IsEnum()
Inputs:				None
Outputs:			isEnum                              - bool for object enum state
Description:	Returns true if the object is an enum list.
------------------------------------------------------------------------------------------------]]--
function PL:IsEnum()
  return self.isEnum
end


--[[------------------------------------------------------------------------------------------------
PL:IsInitialized()
Inputs:				None
Outputs:			initialized                         - bool for object initialized state
Description:	Returns true if the object has been successfully initialized.
------------------------------------------------------------------------------------------------]]--
function PL:IsInitialized()
  return self.initialized
end


--[[------------------------------------------------------------------------------------------------
PL:GetChoices()
Inputs:				None
Outputs:			Choices                             - Table of indexed Choices
Description:	Returns the Choices table.
------------------------------------------------------------------------------------------------]]--
function PL:GetChoices()
  return self.Choices
end


--[[------------------------------------------------------------------------------------------------
PL:GetValues()
Inputs:				None
Outputs:			Values                              - Table of indexed values
Description:	Returns the Values table.
------------------------------------------------------------------------------------------------]]--
function PL:GetValues()
  return self.Values
end


--[[------------------------------------------------------------------------------------------------
PL:GetChoiceByValue(value)
Inputs:				value                               - Value to look up
Outputs:			choice                              - Choice found by value
Description:	Returns the matching choice from the paired list.
------------------------------------------------------------------------------------------------]]--
function PL:GetChoiceByValue(value)
  local index
  for i, v in ipairs(self.Values) do
    if v == value then
      index = i
      break
    end
  end
  return self.Choices[index]
end


--[[------------------------------------------------------------------------------------------------
PL:UpdateData(Choices, Values)
Inputs:				Choices                             - Table of choices (enums)
              Values                              - (optional) Table of values
Outputs:			None
Description:	Updates the Choices and Values tables.
------------------------------------------------------------------------------------------------]]--
function PL:UpdateData(Choices, Values)
  -- clear old info
  if Choices ~= nil then
    for index, choice in ipairs(self.Choices) do
      self[choice] = nil
    end
    self.Choices = Choices
  end

  if self.isEnum then
    self.Values = {}
    for index, choice in ipairs(self.Choices) do
      table.insert(self.Values, index)
      self[choice] = index
    end
  else
    if Values ~= nil then
      self.Values = Values
    end
    for index, choice in ipairs(self.Choices) do
      self[choice] = self.Values[index]
    end
  end
end


--[[------------------------------------------------------------------------------------------------
PL:Sort(sortType)
Inputs:				sortType                            - how to sort (globals)
Outputs:			None
Description:	Sorts the paired list by the specified sortType (use globals).
------------------------------------------------------------------------------------------------]]--
function PL:Sort(sortType)
  -- check range
  if sortType < LIBSTATIC_LIST_SORT_MIN or sortType > LIBSTATIC_LIST_SORT_MAX then return end

  -- sort functions
  local Sorts = {
    function(a, b) return a.choice < b.choice end,
    function(a, b) return a.choice > b.choice end,
    function(a, b) return a.value < b.value end,
    function(a, b) return a.value > b.value end,
  }

  -- merge the lists to sort easy
  local Merged = {}
  for index, choice in ipairs(self.Choices) do
    table.insert(Merged, {choice = choice, value = self.Values[index]})
  end

  -- sort the merged list
  table.sort(Merged, Sorts[sortType])

  -- unmerge and update data
  local Choices = {}
  local Values = {}
  for index, data in ipairs(Merged) do
    table.insert(Choices, data.choice)
    table.insert(Values, data.value)
  end
  self:UpdateData(Choices, Values)
end


--[[------------------------------------------------------------------------------------------------
Global template assignment
------------------------------------------------------------------------------------------------]]--
LibStatic.PairedList = PL
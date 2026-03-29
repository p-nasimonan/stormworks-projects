-- Author: <Authorname> (Please change this in user settings, Ctrl+Comma)
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator
    simulator:setScreen(1, "1x1")
    simulator:setProperty("ExampleNumberProperty", 123)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)
        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.width)
        simulator:setInputNumber(2, screenConnection.height)
        simulator:setInputNumber(3, screenConnection.touchX)
        simulator:setInputNumber(4, screenConnection.touchY)

        -- NEW! button/slider options from the UI
        simulator:setInputBool(31, simulator:getIsClicked(1))     -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        simulator:setInputNumber(31, simulator:getSlider(1))      -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2))     -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(32, simulator:getSlider(2) * 50) -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

local GEAR_MIN = 0
local GEAR_MAX = 5

local currentGear = 1
local previousShiftInput = 0

function onTick()
    local shiftInput = input.getNumber(1)

    -- Shift only on edge so holding a key does not keep shifting every tick.
    if shiftInput == 1 and previousShiftInput ~= 1 then
        currentGear = math.min(currentGear + 1, GEAR_MAX)
    elseif shiftInput == -1 and previousShiftInput ~= -1 then
        currentGear = math.max(currentGear - 1, GEAR_MIN)
    end

    previousShiftInput = shiftInput

    output.setNumber(1, currentGear)
    for gear = 1, GEAR_MAX do
        output.setBool(gear, gear == currentGear)
    end
end

function onDraw()
    local w = screen.getWidth()
    local h = screen.getHeight()

    screen.setColor(0, 0, 0)
    screen.drawClear()

    screen.setColor(0, 255, 0)
    screen.drawTextBox(0, 0, w, h * 0.45, "GEAR", 0, 0)
    screen.drawTextBox(0, h * 0.35, w, h * 0.65, tostring(currentGear), 0, 0)
end

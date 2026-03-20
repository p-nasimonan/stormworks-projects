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
    simulator:setScreen(1, "3x1")
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

--
width, height = 96, 32
touchX, touchY, isTouched = 0, 0, false
bat, fuelLvl, fuelCap = 0, 0, 1
rps1, rps2, temp1, temp2 = 0, 0, 0, 0

--
start1, start2 = false, false   -- ON/OFF
prog1, prog2 = 0, 0             --  (0 ~ holdMax)
holdMax = 40                    --  (60=1400.66)
locked1, locked2 = false, false -- 1

function onTick()
    width = input.getNumber(1)
    height = input.getNumber(2)
    touchX = input.getNumber(3)
    touchY = input.getNumber(4)
    isTouched = input.getBool(1)

    bat = input.getNumber(5)
    fuelLvl = input.getNumber(6)
    fuelCap = input.getNumber(7)
    if fuelCap == 0 then fuelCap = 1 end
    rps1 = input.getNumber(8)
    rps2 = input.getNumber(9)
    temp1 = input.getNumber(10)
    temp2 = input.getNumber(11)

    local cx, cy = 76, 16
    local inBox1 = isPointInBox(touchX, touchY, cx - 14, cy - 10, 12, 20)
    local inBox2 = isPointInBox(touchX, touchY, cx + 2, cy - 10, 12, 20)

    -- 1
    if isTouched and inBox1 then
        if not locked1 then
            prog1 = prog1 + 1
            if prog1 >= holdMax then
                start1 = not start1 --
                locked1 = true      --
                prog1 = holdMax     -- MAX
            end
        end
    else
        -- 0
        prog1 = math.max(0, prog1 - 3)
        locked1 = false --
    end

    -- 2
    if isTouched and inBox2 then
        if not locked2 then
            prog2 = prog2 + 1
            if prog2 >= holdMax then
                start2 = not start2
                locked2 = true
                prog2 = holdMax
            end
        end
    else
        prog2 = math.max(0, prog2 - 3)
        locked2 = false
    end

    output.setBool(1, start1)
    output.setBool(2, start2)
end

function isPointInBox(x, y, bx, by, bw, bh)
    return x >= bx and x <= bx + bw and y >= by and y <= by + bh
end

function onDraw()
    screen.setColor(10, 10, 10)
    screen.drawClear()

    drawBattery(2, 2)
    drawFuel(11, 2)
    drawHelicopterTopView(76, 16)
end

function drawBattery(x, y)
    screen.setColor(255, 255, 255)
    screen.drawRect(x, y + 2, 8, 16)
    screen.drawRect(x + 2, y, 4, 2)
    
    local pct = math.min(1, math.max(0, bat))
    local fillH = math.floor(15 * pct)
    
    if pct > 0.2 then 
        screen.setColor(0, 150, 0) 
    else 
        screen.setColor(200, 0, 0) 
    end
    screen.drawRectF(x + 1, y + 18 - fillH, 7, fillH)
    
    screen.setColor(255, 255, 255)
    local val = math.min(99, math.floor(pct * 100))
    screen.drawText(x + 1, y + 13, string.format("%d", val))
    screen.drawText(x + 3, y + 4, "B")
end

function drawFuel(x, y)
    screen.setColor(255, 255, 255)
    screen.drawRect(x, y + 2, 8, 16)
    screen.drawRect(x + 2, y, 4, 2)
    
    local pct = math.min(1, math.max(0, fuelLvl / fuelCap))
    local fillH = math.floor(15 * pct)
    
    screen.setColor(200, 100, 0)
    screen.drawRectF(x + 1, y + 18 - fillH, 7, fillH)
    
    screen.setColor(255, 255, 255)
    local val = math.min(99, math.floor(pct * 100))
    screen.drawText(x + 1, y + 13, string.format("%d", val))
    screen.drawText(x + 3, y + 4, "F")
end

function drawHelicopterTopView(cx, cy)
    screen.setColor(80, 80, 80)
    screen.drawRectF(cx - 4, cy - 12, 8, 24)
    screen.drawRectF(cx - 2, cy + 12, 4, 10)
    drawEngineButton(cx - 11, cy - 7, temp1, rps1, start1, prog1)
    drawEngineButton(cx + 5, cy - 7, temp2, rps2, start2, prog2)
end

function drawEngineButton(ex, ey, temp, rps, isStarted, prog)
    if temp < 50 then
        screen.setColor(0, 200, 0)
    elseif temp < 80 then
        screen.setColor(255, 200, 0)
    else
        screen.setColor(255, 0, 0)
    end
    
    -- エンジン本体を少し大きくして描画（温度色を優先）
    screen.drawRectF(ex, ey, 6, 14)
    
    if isStarted then
        -- 稼働中はオレンジの枠でハイライト（エンジンの「外側」）
        screen.setColor(255, 150, 0)
        screen.drawRect(ex - 1, ey - 1, 7, 15)
    end
    
    if prog > 0 then
        -- ボタン長押しのプログレスはさらにその外側に描画
        screen.setColor(0, 255, 0)
        drawProgressBorder(ex - 2, ey - 2, 9, 17, prog / holdMax)
    end
    
    -- エンジンの下部にRPSを表示
    screen.setColor(255, 255, 255)
    screen.drawText(ex - 1, ey + 17, string.format("%.0f", rps))
end

--
function drawProgressBorder(x, y, w, h, pct)
    if pct <= 0 then return end
    local peri = 2 * w + 2 * h --
    local dist = peri * pct    --

    -- 1.
    local step = math.min(dist, w)
    if step > 0 then
        screen.drawLine(x, y, x + step, y); dist = dist - step
    end

    -- 2.
    step = math.min(dist, h)
    if step > 0 then
        screen.drawLine(x + w, y, x + w, y + step); dist = dist - step
    end

    -- 3.
    step = math.min(dist, w)
    if step > 0 then
        screen.drawLine(x + w, y + h, x + w - step, y + h); dist = dist - step
    end

    -- 4.
    step = math.min(dist, h)
    if step > 0 then
        screen.drawLine(x, y + h, x, y + h - step); dist = dist - step
    end
end

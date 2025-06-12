-- ------------------------------------------
-- Tetris w LÖVE ~ Arkadiusz Adamczyk
-- ------------------------------------------

gridWidth = 10
gridHeight = 16
cellSize = 30
grid = {}

currentPiece = {}
pieceX = nil
pieceY = nil
fallTimer = 0
fallDelay = 0.5
clearedLines = 0
goalLines = 10
gameState = "menu"

flashLines = {}
isFlashing = false
flashTimer = 0
flashInterval = 0.2
flashCount = 0
maxFlashes = 6

shapes = {
    {
        {1,1,1,1}
    },
    {
        {1,1},
        {1,1} 
    },
    {
        {0,1,0},
        {1,1,1}
    },
    {
        {1,0},
        {1,0},
        {1,1}
    },
    {
        {0,1},
        {0,1},
        {1,1}
    },
    {
        {0,1,1},
        {1,1,0}
    }
}

function initGrid()
    for y = 1, gridHeight do
        grid[y] = {}
        for x = 1, gridWidth do
            grid[y][x] = 0
        end
    end
end

function spawnPiece()
    currentPiece = shapes[math.random(#shapes)]
    pieceY = 1
    pieceX = math.floor((gridWidth - #currentPiece[1]) / 2) + 1
    if not canMove(0, 0, currentPiece) then
        gameState = "gameover"
        sounds.lose:play()
    end
end

function lockPiece()
    for y = 1, #currentPiece do
        for x = 1, #currentPiece[y] do
            if currentPiece[y][x] == 1 then
                local gx = pieceX + x - 1
                local gy = pieceY + y - 1
                if gy >= 1 and gx >= 1 and gx <= gridWidth and gy <= gridHeight then
                    grid[gy][gx] = 1
                end
            end
        end
    end

    sounds.lock:play()
    clearLines()
    spawnPiece()
end

function canMove(dx, dy, newPiece)
    newPiece = newPiece or currentPiece
    for y = 1, #newPiece do
        for x = 1, #newPiece[y] do
            if newPiece[y][x] == 1 then
                local newX = pieceX + x - 1 + dx
                local newY = pieceY + y - 1 + dy
                if newX < 1 or newX > gridWidth or newY > gridHeight then
                    return false
                end
                if newY >= 1 and grid[newY][newX] == 1 then
                    return false
                end
            end
        end
    end

    return true
end

function clearLines()
    flashLines = {}
    for y = 1, gridHeight do
        local full = true
        for x = 1, gridWidth do
            if grid[y][x] == 0 then
                full = false
                break
            end
        end
        if full then
            table.insert(flashLines, y)
        end
    end

    if #flashLines > 0 then
        isFlashing = true
        flashTimer = 0
        flashCount = 0
        sounds.score:play()
    else
        spawnPiece()
    end
end

function rotatePiece()
    local new = {}
    for x = 1, #currentPiece[1] do
        new[x] = {}
        for y = #currentPiece, 1, -1 do
            new[x][#currentPiece - y + 1] = currentPiece[y][x]
        end
    end
    if canMove(0, 0, new) then
        currentPiece = new
    end
end

function saveGame()
    local saveData = {
        grid = grid,
        currentPiece = currentPiece,
        pieceX = pieceX,
        pieceY = pieceY,
        clearedLines = clearedLines,
        gameState = gameState
    }

    love.filesystem.write("savegame.lua", "return " .. tableToString(saveData))
end

function tableToString(tbl)
    local function serialize(obj)
        if type(obj) == "number" then
            return tostring(obj)
        elseif type(obj) == "string" then
            return string.format("%q", obj)
        elseif type(obj) == "table" then
            local s = "{"
            for k, v in pairs(obj) do
                s = s .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ","
            end
            return s .. "}"
        else
            return "nil"
        end
    end
    return serialize(tbl)
end

function loadGame()
    if not love.filesystem.getInfo("savegame.lua") then
        return
    end

    local chunk = love.filesystem.load("savegame.lua")
    local saveData = chunk()
    grid = saveData.grid
    currentPiece = saveData.currentPiece
    pieceX = saveData.pieceX
    pieceY = saveData.pieceY
    clearedLines = saveData.clearedLines
    gameState = saveData.gameState
end

function love.load()
    love.window.setTitle("TetrisLÖVE")
    love.window.setMode(gridWidth * cellSize, gridHeight * cellSize)
    font = love.graphics.newFont(18)
    love.graphics.setFont(font)
    math.randomseed(os.time())

    sounds = {
        lock = love.audio.newSource("lock.wav", "static"),
        move = love.audio.newSource("move.wav", "static"),
        score = love.audio.newSource("score.wav", "static"),
        lose = love.audio.newSource("lose.wav", "static")
    }

    initGrid()
    spawnPiece()
end

function love.update(dt)
    if gameState == "playing" and not isFlashing then
        fallTimer = fallTimer + dt
        if fallTimer >= fallDelay then
            fallTimer = 0
            if canMove(0, 1) then
                pieceY = pieceY + 1
                sounds.move:play()
            else
                lockPiece()
            end
        end
    end

    if isFlashing then
        flashTimer = flashTimer + dt
        if flashTimer >= flashInterval then
            flashTimer = 0
            flashCount = flashCount + 1
            if flashCount >= maxFlashes then
                local newGrid = {}
                local lines = 0
                for y = gridHeight, 1, -1 do
                    local isCleared = false
                    for _, fy in ipairs(flashLines) do
                        if y == fy then
                            isCleared = true
                            break
                        end
                    end
                    if not isCleared then
                        table.insert(newGrid, 1, grid[y])
                    else
                        lines = lines + 1
                    end
                end
                for i = 1, lines do
                    local empty = {}
                    for x = 1, gridWidth do
                        table.insert(empty, 0)
                    end
                    table.insert(newGrid, 1, empty)
                end
                grid = newGrid
                clearedLines = clearedLines + lines
                isFlashing = false
                flashLines = {}
                spawnPiece()
            end
        end
    end
end

function love.draw()
    for y = 1, gridHeight do
        for x = 1, gridWidth do
            if grid[y][x] == 1 then
                local flash = false
                if isFlashing then
                    for _, fy in ipairs(flashLines) do
                        if y == fy and flashCount % 2 == 0 then
                            flash = true
                            break
                        end
                    end
                end

                if flash then
                    love.graphics.setColor(1, 0, 0)
                else
                    love.graphics.setColor(1, 1, 1)
                end

                love.graphics.rectangle("fill", (x - 1) * cellSize, (y - 1) * cellSize, cellSize - 1, cellSize - 1)
            end
        end
    end

    if gameState == "playing" and not isFlashing then
        love.graphics.setColor(1, 0.1, 0.8)
        for y = 1, #currentPiece do
            for x = 1, #currentPiece[y] do
                if currentPiece[y][x] == 1 then
                    local drawX = (pieceX + x - 2) * cellSize
                    local drawY = (pieceY + y - 2) * cellSize
                    love.graphics.rectangle("fill", drawX, drawY, cellSize - 1, cellSize - 1)
                end
            end
        end
    end

    if gameState == "playing" then
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("fill", 0, 25, 300, 30)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("SCORE: " .. clearedLines, 0, 30, gridWidth * cellSize, "center")
    elseif gameState == "gameover" then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, 300, 600)
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("GAME OVER!", 0, 200, gridWidth * cellSize, "center")
        love.graphics.printf("PRESS ENTER TO RESTART", 0, 230, gridWidth * cellSize, "center")
    elseif gameState == "menu" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("TETRIS", 0, 100, gridWidth * cellSize, "center")
        love.graphics.printf("Arkadiusz Adamczyk", 0, 130, gridWidth * cellSize, "center")
        love.graphics.printf("ENTER to start", 0, 190, gridWidth * cellSize, "center")
        love.graphics.printf("LEFT/RIGHT/DOWN to move", 0, 220, gridWidth * cellSize, "center")
        love.graphics.printf("UP to rotate piece", 0, 250, gridWidth * cellSize, "center")
        love.graphics.printf("S to save", 0, 300, gridWidth * cellSize, "center")
        love.graphics.printf("L to load save", 0, 330, gridWidth * cellSize, "center")
    end
end

function love.keypressed(key)
    if gameState == "playing" then
        if isFlashing then
            return
        end

        if key == "left" and canMove(-1, 0) then
            pieceX = pieceX - 1
            sounds.move:play()
        elseif key == "right" and canMove(1, 0) then
            pieceX = pieceX + 1
            sounds.move:play()
        elseif key == "down" and canMove(0, 1) then
            pieceY = pieceY + 1
            sounds.move:play()
        elseif key == "up" then
            rotatePiece()
        end

        if key == "s" then
            saveGame()
        elseif key == "l" then
            loadGame()
        end
    end

    if gameState == "gameover" or gameState == "menu" then
        if key == "return" then
            initGrid()
            clearedLines = 0
            gameState = "playing"
            spawnPiece()
        end
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if gameState == "playing" then
        if isFlashing then
            return
        end

        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()

        if x < screenWidth / 3 then
            if canMove(-1, 0) then
                pieceX = pieceX - 1
                sounds.move:play()
            end
        elseif x > 2 * screenWidth / 3 then
            if canMove(1, 0) then
                pieceX = pieceX + 1
                sounds.move:play()
            end
        elseif y > screenHeight * 0.7 then
            if canMove(0, 1) then
                pieceY = pieceY + 1
                sounds.move:play()
            end
        else
            rotatePiece()
        end
    end

    if gameState == "gameover" or gameState == "menu" then
        local screenWidth = love.graphics.getWidth()
        if x > 0 and x < screenWidth then
            initGrid()
            clearedLines = 0
            gameState = "playing"
            spawnPiece()
        end
    end
end
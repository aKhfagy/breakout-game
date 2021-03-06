-- Author : Ahmed A. Khfagy
-- done in CS50 intorduction to game Design course

require 'src/Dependancies'

function love.load()

    love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time())

    love.window.setTitle('My third game <3')

    gFonts = {

        ['small'] = love.graphics.newFont('fonts/font.ttf', 8),

        ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),

        ['large'] = love.graphics.newFont('fonts/font.ttf', 32)

    }

    love.graphics.setFont(gFonts['small'])

    gTextures = {

        ['background'] = love.graphics.newImage('graphics/background.png'),

        ['main'] = love.graphics.newImage('graphics/breakout.png'),

        ['arrows'] = love.graphics.newImage('graphics/arrows.png'),

        ['hearts'] = love.graphics.newImage('graphics/hearts.png'),

        ['particle'] = love.graphics.newImage('graphics/particle.png')

    }

    gFrames = {

        ['paddles'] = GenerateQuadPaddles(gTextures['main']),

        ['balls'] = GenerateQuadBalls(gTextures['main']),

        ['bricks'] = GenerateQuadBricks(gTextures['main']),

        ['hearts'] = GenerateQuad(gTextures['hearts'], 10, 9),

        ['arrows'] = GenerateQuad(gTextures['arrows'], 24, 24),

        ['power-ups'] = GenerateQuadPowerups(gTextures['main'])

    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vysnc = true, 
        fullscreen = false,
        resizable = true, 
        canvas = false
    })

    gSounds = {

        ['paddle-hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),

        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),

        ['wall-hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),

        ['confirm'] = love.audio.newSource('sounds/confirm.wav', 'static'),

        ['select'] = love.audio.newSource('sounds/select.wav', 'static'),

        ['no-select'] = love.audio.newSource('sounds/no-select.wav', 'static'),

        ['brick-hit-1'] = love.audio.newSource('sounds/brick-hit-1.wav', 'static'),

        ['brick-hit-2'] = love.audio.newSource('sounds/brick-hit-2.wav', 'static'),

        ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
        
        ['victory'] = love.audio.newSource('sounds/victory.wav', 'static'),
        
        ['recover'] = love.audio.newSource('sounds/recover.wav', 'static'),
        
        ['high-score'] = love.audio.newSource('sounds/high_score.wav', 'static'),
        
        ['pause'] = love.audio.newSource('sounds/pause.wav', 'static'),

        ['music'] = love.audio.newSource('sounds/music.wav', 'static'),

        ['gain-power-up'] = love.audio.newSource('sounds/gain-power-up.wav', 'static'),

        ['change-ball'] = love.audio.newSource('sounds/change-ball.wav', 'static')
    
    }

    gStateMachine = StateMachine{

        ['start'] = function() return StartState() end, 

        ['play'] = function() return PlayState() end,

        ['serve'] = function() return ServeState() end,

        ['game-over'] = function() return GameOverState() end,

        ['victory'] = function() return VictoryState() end,

        ['high-score'] = function() return HighScoreState() end,

        ['enter-high-score'] = function() return EnterHighScoreState() end,

        ['select-paddle'] = function() return PaddleSelectState() end

    }

    gSounds['music']:play()
    gSounds['music']:setLooping(true)

    gStateMachine:change('start',{
        highscore = loadHighScores()
    })

    love.keyboard.keysPressed = {}

end

function love.resize(w, h)

    push:resize(w, h)

end

function love.update(dt)

    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}

end

function love.keypressed(key)

    love.keyboard.keysPressed[key] = true

end

function love.keyboard.wasPressed(key)

    return love.keyboard.keysPressed[key]

end

function love.draw()

    push:apply('start')

    local backgroundWidth = gTextures['background']:getWidth()
    local backgroundHeight = gTextures['background']:getHeight()

    love.graphics.push()

    love.graphics.scale(VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1))

    love.graphics.draw(gTextures['background'], 0, 0)

    love.graphics.pop()

    gStateMachine:render()

    displayFPS()

    push:apply('end')

end

function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
end

function renderHealth(health)

    local healthX = VIRTUAL_WIDTH - 100

    for i = 1, health do

        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], healthX, 4)

        healthX = healthX + 11

    end

    for i = 1, 3 - health do

        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], healthX, 4)

        healthX = healthX + 11

    end

end

function renderScore(score)

    love.graphics.setFont(gFonts['small'])
    love.graphics.print("Score: ", VIRTUAL_WIDTH - 60, 5)
    love.graphics.printf(tostring(score), VIRTUAL_WIDTH - 50, 5, 40, 'right')

end

function loadHighScores()

    love.filesystem.setIdentity('breakout')

    if not love.filesystem.getInfo('breakout.lst') then

        local scores = ''

        for i = 10, 1, -1 do
            scores = scores .. 'CTO\n'
            scores = scores .. tostring(i * 1000) .. '\n'
        end

        love.filesystem.write('breakout.lst', scores)
    end

    local name = true
    local currentName = nil
    local counter = 1

    local scores = {}

    for i = 1, 10 do

        scores[i] = {
            name = nil,
            score = nil
        }

    end

    for line in love.filesystem.lines('breakout.lst') do

        if name then

            scores[counter].name = string.sub(line, 1, 3)

        else

            scores[counter].score = tonumber(line)
            counter = counter + 1
            
        end

        name = not name

    end

    return scores

end
-- Author : Ahmed A. Khfagy
-- done in CS50 intorduction to game Design course

-- this is the class for the entering high score state

EnterHighScoreState = Class{__includes = BasicState}

local chars = {
    [1] = 65,
    [2] = 65,
    [3] = 65
}

local highlightedChar = 1

function EnterHighScoreState:enter(params)

    self.highscore = params.highscore
    self.score = params.score
    self.scoreIndex = params.scoreIndex

end

function EnterHighScoreState:update(dt)

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then

        local name = string.char(chars[1]) .. string.char(chars[2]) .. string.char(chars[3])

        for i = 10, self.scoreIndex - 1 do

            self.highscore[i + 1] = {
                name = self.highscore[i].name,
                score = self.highscore[i].score
            }

        end

        self.highscore[self.scoreIndex].name = name
        self.highscore[self.scoreIndex].score = self.score

        local scoresStr = ''
        
        for i = 1, 10 do
            scoresStr = scoresStr .. self.highscore[i].name .. '\n'
            scoresStr = scoresStr .. tostring(self.highscore[i].score) .. '\n'
        end

        love.filesystem.write('breakout.lst', scoresStr)

        gStateMachine:change('high-score',{
            highscore = self.highscore
        })

    end

    if love.keyboard.wasPressed('left') and highlightedChar > 1 then

        highlightedChar = highlightedChar - 1
        gSounds['select']:play()

    elseif love.keyboard.wasPressed('right') and highlightedChar < 3 then

        highlightedChar = highlightedChar + 1
        gSounds['select']:play()

    end

    if love.keyboard.wasPressed('up') then

        chars[highlightedChar] = chars[highlightedChar] + 1

        if chars[highlightedChar] > 90 then
            chars[highlightedChar] = 65
        end

    elseif love.keyboard.wasPressed('down') then

        chars[highlightedChar] = chars[highlightedChar] - 1

        if chars[highlightedChar] < 65 then
            chars[highlightedChar] = 90
        end

    end

end

function EnterHighScoreState:render()

    love.graphics.setFont(gFonts['medium'])

    love.graphics.printf('Your score: ' .. tostring(self.score), 0, 30, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['large'])

    if highlightedChar == 1 then

        love.graphics.setColor(103 / 255, 1, 1, 1)

    end

    love.graphics.print(string.char(chars[1]), VIRTUAL_WIDTH / 2 - 28, VIRTUAL_HEIGHT / 2)

    love.graphics.setColor(1, 1, 1, 1)

    if highlightedChar == 2 then

        love.graphics.setColor(103 / 255, 1, 1, 1)

    end

    love.graphics.print(string.char(chars[2]), VIRTUAL_WIDTH / 2 - 6, VIRTUAL_HEIGHT / 2)

    love.graphics.setColor(1, 1, 1, 1)

    if highlightedChar == 3 then

        love.graphics.setColor(103 / 255, 1, 1, 1)

    end

    love.graphics.print(string.char(chars[3]), VIRTUAL_WIDTH / 2 + 20, VIRTUAL_HEIGHT / 2)

    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setFont(gFonts['small'])

    love.graphics.printf('Press Enter to confirm..!', 0, VIRTUAL_HEIGHT - 18, VIRTUAL_WIDTH, 'center')

end

function EnterHighScoreState:exit() end
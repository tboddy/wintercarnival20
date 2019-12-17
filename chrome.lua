local timeLeftStr, images

local function load()
  images = {
    heart = love.graphics.newImage('img/chrome/heart.png'),
    heartShadow = love.graphics.newImage('img/chrome/heart-shadow.png')
  }
	stg.loadImages(images)
  timeLeftStr = '2:00'
end

local function updateTime()
  local timeLeft = math.floor(stg.timeLimit - stg.clock / 60)
  local minutes = '0'; if timeLeft >= 60 then minutes = '1' end
  if timeLeft == 60 * 2 then minutes = '2' end
  local seconds = math.floor(timeLeft % 60)
  if seconds < 10 then seconds = '0' .. seconds end
  timeLeftStr = minutes .. ':' .. seconds
end

local function update()
  updateTime()
end

local function drawLabel(opts)
  -- opts.input = string.upper(opts.input)
  local color = stg.colors.offWhite
	local align = 'left'
	local limit = stg.width
  local x = 0
  if opts.x then x = opts.x end
  if opts.color then color = stg.colors[opts.color] end
	if opts.align then
    align = opts.align.type
    if opts.align.width then limit = opts.align.width end
  end
  if opts.big then love.graphics.setFont(stg.fontBig) end
	love.graphics.setColor(stg.colors.black)
  love.graphics.printf(opts.input, x + 1, opts.y + 1, limit, align)
	love.graphics.setColor(color)
  love.graphics.printf(opts.input, x, opts.y, limit, align)
	love.graphics.setColor(stg.colors.white)
  if opts.big then love.graphics.setFont(stg.font) end
end

local function drawScore()
  drawLabel({input = 'Score', x = 4, y = 4})
  drawLabel({input = stg.processScore(stg.score), x = 4, y = 4 + 10})
end

local function drawTime()
  drawLabel({input = timeLeftStr, x = 4, y = 4 + 10 * 2})
end

local function drawLives()
  love.graphics.setColor(stg.colors.black)
  love.graphics.draw(images.heart, stg.width - 8 * 3 - 4 + 1, stg.height - 4 - 8 + 1)
  love.graphics.setColor(stg.colors.yellow)
  love.graphics.draw(images.heart, stg.width - 8 * 3 - 4, stg.height - 4 - 8)
  love.graphics.setColor(stg.colors.redLight)
  love.graphics.draw(images.heartShadow, stg.width - 8 * 3 - 4, stg.height - 4 - 8)
  love.graphics.setColor(stg.colors.white)
  drawLabel({input = 'x2', y = stg.height - 8 - 4,  align = {type = 'right', width = stg.width - 4}})
end

local function drawBonusOverlay()
  local y = 3
  drawLabel({input = 'BONUS', color = 'yellow', y = y, big = true, align = {type = 'center'}})
  drawLabel({input = '40000', color = 'yellow', y = y + stg.grid, big = true, align = {type = 'center'}})
end

local function draw()
  drawScore()
  drawTime()
  drawLives()
  -- drawBonusOverlay()
end

return {
  load = load,
  draw = draw,
  drawLabel = drawLabel,
  update = update
}

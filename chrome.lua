local images, barOffset, barHeight, evadeMax, evadeWidth, bossMax, bossWidth, bossX, barY

local function load()
  images = {
    heart = love.graphics.newImage('img/chrome/heart.png'),
    heartShadow = love.graphics.newImage('img/chrome/heart-shadow.png'),
    frame = love.graphics.newImage('img/chrome/frame.png')
  }
	stg.loadImages(images)
  barOffset = 4
  barHeight = 7
  evadeMax = 40
  evadeWidth = 12
  bossX = barOffset * 4 + evadeMax + 8 * 5
  bossMax = 100 - barOffset
  bossWidth = bossMax
end

local function update()
  if stage.bossHealth > 0 and stage.bossMaxHealth > 0 then
    bossWidth = math.floor(stage.bossHealth / stage.bossMaxHealth * bossMax)
  end
end

local function drawLabel(opts)
  opts.input = string.upper(opts.input)
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

local function drawBoss()
  love.graphics.setColor(stg.colors.blue)
  stg.mask('half', function() love.graphics.rectangle('fill', bossX, barOffset, bossMax, barHeight) end)
  love.graphics.setColor(stg.colors.blueLight)
  love.graphics.rectangle('fill', bossX, barOffset, bossWidth, barHeight)
  love.graphics.setColor(stg.colors.white)
  drawLabel({input = 'ENEMY', x = bossX + barOffset + bossMax, y = barOffset})
end

local function drawScore()
  -- drawLabel({input = 'Score ' .. stg.processScore(stg.score), x = 4, y = 4})
  local x = stg.width + 8
  local mod = 10
  drawLabel({input = 'Hi-Score', x = x, y = barY})
  barY = barY + mod
  drawLabel({input = stg.processScore(stg.score), x = x, y = barY})
  barY = barY + stg.grid
  drawLabel({input = 'Score', x = x, y = barY})
  barY = barY + mod
  drawLabel({input = stg.processScore(stg.score), x = x, y = barY})
end

local function drawFrame()
  love.graphics.draw(images.frame, stg.width, 0)
  love.graphics.setColor(stg.colors.black)
  stg.mask('half', function() love.graphics.rectangle('fill', stg.width - 1, 0, 1, stg.height) end)
  love.graphics.setColor(stg.colors.purple)
  love.graphics.rectangle('fill', stg.width, 0, 1, stg.height)
  love.graphics.setColor(stg.colors.white)
end

local function drawPlayer()
  local x = stg.width + 8
  local mod = 10
  barY = barY + stg.grid
  drawLabel({input = 'Left  x3', x = x, y = barY})
  barY = barY + mod
  drawLabel({input = 'Graze  0', x = x, y = barY})
  barY = barY + stg.grid
  drawLabel({input = 'Power', x = x, y = barY})
end

local function drawFps()
  local fps = math.floor(love.timer.getFPS() / 60 * 10)
  if fps > 61 or fps < 57 then fps = 60 end
  drawLabel({input = fps .. 'fps', y = stg.height - 8 - 3, align = {type = 'right', width = stg.winWidth - 4}})
end

local function draw()
  barY = stg.grid
  if stage.bossHealth > 0 and stage.bossMaxHealth > 0 then drawBoss() end
  drawFrame()
  drawScore()
  drawPlayer()
  drawFps()
end

return {
  load = load,
  draw = draw,
  drawLabel = drawLabel,
  update = update
}



-- local function drawSidebar()
--   local x = stg.width + barOffset * 2
--   local y = barOffset * 2
--   drawLabel({input = 'Hi Score', x = x, y = y})
--   y = y + 10
--   drawLabel({input = stg.processScore(stg.score), x = x, y = y})
--   y = y + 10 + barOffset
--   drawLabel({input = 'Score', x = x, y = y})
--   y = y + 10
--   drawLabel({input = stg.processScore(stg.score), x = x, y = y})
--   y = y + 10 + barOffset
--   drawLabel({input = 'Left', x = x, y = y})
--   drawLabel({input = player.lives, x = x, y = y, align = {type = 'right', width = 8 * 8}})
--   y = y + 10
--   drawLabel({input = 'Bomb', x = x, y = y})
--   drawLabel({input = 3, x = x, y = y, align = {type = 'right', width = 8 * 8}})
-- end

-- drawSidebar()
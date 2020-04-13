local images, evadeMax, evadeWidth, bossMax, bossHeight, bossY, bossX

local function load()
  images = {
    heart = love.graphics.newImage('img/chrome/heart.png'),
    heartShadow = love.graphics.newImage('img/chrome/heart-shadow.png'),
    bossBar = love.graphics.newImage('img/chrome/bossbar.png')
  }
	stg.loadImages(images)
  evadeMax = 40
  evadeWidth = 12
  bossX = stg.width - 8 - 4
  bossY = stg.grid
  bossMax = stg.height - stg.grid * 1.25
  bossHeight = bossMax
end

local function update()
  if stage.bossHealth > 0 and stage.bossMaxHealth > 0 then
    bossHeight = math.floor(stage.bossHealth / stage.bossMaxHealth * bossMax)
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
  local width = 8
  local yMod = bossMax - bossHeight
  love.graphics.setColor(stg.colors.black)
  love.graphics.rectangle('fill', bossX + 1, bossY + yMod + 1, width, bossHeight)
  love.graphics.setColor(stg.colors.blueLight)
  love.graphics.rectangle('fill', bossX, bossY + yMod, width, bossHeight)
  love.graphics.setColor(stg.colors.blue)
  love.graphics.stencil(function()
    love.graphics.setShader(stg.maskShader)
    love.graphics.draw(images.bossBar, bossX, bossY)
    return love.graphics.setShader()
  end, 'replace', 1)
  love.graphics.setStencilTest('greater', 0)
  love.graphics.rectangle('fill', bossX, bossY + yMod, width, bossHeight)
  love.graphics.setStencilTest()
  love.graphics.setColor(stg.colors.blueLight)
  stg.mask('half', function() love.graphics.rectangle('fill', bossX, bossY + yMod, width, 1) end)
  love.graphics.setColor(stg.colors.white)
end

local function drawPlayer()
  local x = 4
  local y = 4
  -- drawLabel({input = 'Suika', align = {type = 'right', width = x + stg.grid * 4}, y = y})
  drawLabel({input = 'sc ' .. stg.processScore(stg.score), x = x, y = y})
  drawLabel({input = 'hi ' .. stg.processScore(stg.score), y = y, align = {type = 'right', width = stg.width - x}})
  -- x = x + stg.grid * 4 + 4
  y = y + 6
  love.graphics.setFont(stg.fontBig)
  drawLabel({input = 'x2', x = x, y = y})
  love.graphics.setFont(stg.font)
end

local function drawBombs()
  local x = stg.grid * 1.5
  local y = 15
  drawLabel({input = 'B', x = x, y = y, color = 'redLight'})
  x = x + 10
  drawLabel({input = 'B', x = x, y = y, color = 'redLight'})
  x = x + 10
  drawLabel({input = 'B', x = x, y = y, color = 'redLight'})
end

local function draw()
  if stage.bossHealth > 0 and stage.bossMaxHealth > 0 then drawBoss() end
  drawPlayer()
  drawBombs()
end

return {
  load = load,
  draw = draw,
  drawLabel = drawLabel,
  update = update
}


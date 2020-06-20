local images, evadeMax, evadeWidth, bossMax, bossHeight, bossY, bossX

local function load()
  images = stg.images('chrome', {'bossbar', 'frameleft', 'frameright', 'suika', 'sweat', 'suika2'})
  evadeMax = 40
  evadeWidth = 12
  bossX = stg.width - stg.frameOffset - stg.grid * 1.75
  bossY = stg.grid * 3.75
  bossMax = stg.height - stg.grid * 4.5
  bossHeight = bossMax
end

local function update()
  if stage.bossHealth > 0 and stage.bossMaxHealth > 0 then
    bossHeight = math.floor(stage.bossHealth / stage.bossMaxHealth * bossMax)
  end
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
  -- if opts.big then love.graphics.setFont(stg.fontBig) end
	love.graphics.setColor(stg.colors.black)
  love.graphics.printf(opts.input, x + 1, opts.y + 1, limit, align)
	love.graphics.setColor(color)
  love.graphics.printf(opts.input, x, opts.y, limit, align)
	love.graphics.setColor(stg.colors.white)
  -- if opts.big then love.graphics.setFont(stg.font) end
end

local function drawBoss()
  local width = stg.grid
  local yMod = bossMax - bossHeight
  love.graphics.setColor(stg.colors.black)
  love.graphics.rectangle('fill', bossX + 1, bossY + yMod + 1, width, bossHeight)
  love.graphics.setColor(stg.colors.blueLight)
  love.graphics.rectangle('fill', bossX, bossY + yMod, width, bossHeight)
  love.graphics.setColor(stg.colors.white)
  drawLabel({input = 'a delicious scorpion bowl', y = stg.grid * 2, align = {type = 'right', width = bossX + width}})
end

local function drawScore()
  drawLabel({input = 'Score ' .. stg.processScore(stg.score), x = stg.frameOffset + stg.grid / 4 * 3, y = stg.grid / 2})
  drawLabel({input = 'High Score ' .. stg.processScore(stg.score), align = {type = 'right', width = stg.width - stg.frameOffset - stg.grid / 4 * 3}, y = stg.grid / 2})
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

local function drawFrame()
  local bgColor = stg.colors.black
  local fgColor = stg.colors.purple
  local width = images.frameleft:getWidth()

  love.graphics.setColor(bgColor)
  love.graphics.rectangle('fill', 0, 0, width, stg.height)
  love.graphics.rectangle('fill', stg.width - width, 0, width, stg.height)
  love.graphics.setColor(fgColor)
  love.graphics.draw(images.frameleft, 0, 0)
  love.graphics.draw(images.frameright, stg.width - images.frameright:getWidth(), 0)

  love.graphics.setColor(bgColor)
  love.graphics.rectangle('fill', width - 1, 0, 1, stg.height)
  love.graphics.rectangle('fill', width - 3, 0, 1, stg.height)
  love.graphics.rectangle('fill', stg.width - width, 0, 1, stg.height)
  love.graphics.rectangle('fill', stg.width - width + 2, 0, 1, stg.height)

  love.graphics.setColor(fgColor)
  love.graphics.rectangle('fill', width - 2, 0, 1, stg.height)
  love.graphics.rectangle('fill', stg.width - width + 1, 0, 1, stg.height)
  
  love.graphics.setColor(stg.colors.white)
end

local function drawDialog()
  love.graphics.setColor(stg.colors.black)
  local panelX = stg.grid * 8
  local panelY = stg.grid * 19.5
  local panelWidth = stg.grid * 36
  local panelHeight = stg.grid * 8
  local face = images.suika
  stg.mask('most', function() love.graphics.rectangle('fill', panelX, panelY, panelWidth, panelHeight) end)
  love.graphics.setColor(stg.colors.purple)
  love.graphics.setLineWidth(3)
  love.graphics.rectangle('line', panelX, panelY, panelWidth, panelHeight)
  love.graphics.setLineWidth(1)
  love.graphics.setColor(stg.colors.black)
  love.graphics.rectangle('line', panelX, panelY, panelWidth, panelHeight)
  love.graphics.setColor(stg.colors.white)
  love.graphics.draw(face, stg.grid, stg.height - face:getHeight() - stg.grid)
  -- love.graphics.draw(images.sweat, stg.grid * 9, stg.grid * 19.5)
  local dialogX = panelX + stg.grid * 6
  local dialogY = panelY + stg.grid * 2 + 6
  chrome.drawLabel({input = chrome.dialogTitle, x = dialogX, y = dialogY})
  dialogY = dialogY + stg.grid * 2
  chrome.drawLabel({input = '"' .. chrome.dialogText .. '"', x = dialogX, y = dialogY})
end

local function draw()
  -- love.graphics.setFont(stg.fontBig)
  drawFrame()
  drawScore()
  if stage.bossHealth > 0 and stage.bossMaxHealth > 0 then drawBoss() end
  if chrome.dialogActive then drawDialog() end
  -- drawBombs()
end

return {
  load = load,
  draw = draw,
  drawLabel = drawLabel,
  update = update,
  dialogActive = false,
  dialogTitle = 'Suika',
  dialogText = 'An alcoholic obsession!'
}


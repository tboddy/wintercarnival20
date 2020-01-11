local images

local function load()
  images = {
    bg = love.graphics.newImage('img/start/bg.png'),
    logo = love.graphics.newImage('img/start/logo.png'),
    peace = love.graphics.newImage('img/start/peace.png')
  }
  stg.loadImages(images)
end

local function update()
  if controls.shot() then loadGame() end
end

local function drawTitle()
  local y = stg.grid
  chrome.drawLabel({input = 'WINTER CARNIVAL \'20', y = y, align = {type = 'center'}})
  love.graphics.setColor(stg.colors.black)
  love.graphics.draw(images.logo, stg.width / 2 - images.logo:getWidth() / 2 + 1, y + 1 + stg.grid / 2 + 7)
  love.graphics.setColor(stg.colors.offWhite)
  love.graphics.draw(images.logo, stg.width / 2 - images.logo:getWidth() / 2, y + stg.grid / 2 + 7)
  love.graphics.setColor(stg.colors.white)
  chrome.drawLabel({input = ' THE POSITIVE', y = y + images.logo:getHeight() + stg.grid + 8, align = {type = 'center'}})
  chrome.drawLabel({input = 'DRINKING ATTITUDE', y = y + images.logo:getHeight() + stg.grid + 12 + 8, align = {type = 'center'}})
end

local function drawCredits()
  love.graphics.setColor(stg.colors.black)
  love.graphics.draw(images.peace, 8 + 1, stg.height - images.peace:getHeight() - 8 + 1)
  love.graphics.setColor(stg.colors.offWhite)
  love.graphics.draw(images.peace, 8, stg.height - images.peace:getHeight() - 8)
  love.graphics.setColor(stg.colors.white)
  local x = 8 + 4 + images.peace:getWidth()
  local y = stg.height - stg.grid
  chrome.drawLabel({input = '2020 PEACE', x = x, y = y - 12})
  chrome.drawLabel({input = 'RESEARCH CIRCLE', x = x, y = y})
end

local function draw()
  love.graphics.draw(images.bg, 0, 0)
  drawTitle()
  drawCredits()
end

return {
  load = load,
  update = update,
  draw = draw
}

local images, menuItems, currentMenuItem, movingMenu

local function load()
  images = {
    bg = love.graphics.newImage('img/start/bg.png'),
    logo = love.graphics.newImage('img/start/logo.png'),
    subLogo = love.graphics.newImage('img/start/sublogo.png')
  }
  stg.loadImages(images)
  menuItems = {'Game Start', 'Config', 'Score', 'Exit'}
  currentMenuItem = 1
  movingMenu = false
end

local function update()
  if controls.up() and not movingMenu then
    currentMenuItem = currentMenuItem - 1
    movingMenu = true
  elseif controls.down() and not movingMenu then
    currentMenuItem = currentMenuItem + 1
    movingMenu = true
  elseif not controls.up() and not controls.down() then movingMenu = false end
  if currentMenuItem < 1 then currentMenuItem = #menuItems
  elseif currentMenuItem > #menuItems then currentMenuItem = 1 end
  if controls.shot() then
    if currentMenuItem == 1 then loadGame()
    elseif currentMenuItem == 5 then love.event.quit() end
  end
end

local function drawTitle()
  local x = stg.winWidth / 2
  local y = stg.grid * 1.5
  local offset = stg.grid * 2 + 12
  love.graphics.setColor(stg.colors.black)
  love.graphics.draw(images.logo, x + 1, y + 1, 0, 1, 1, images.logo:getWidth() / 2, 0)
  love.graphics.draw(images.subLogo, x + 1, y + offset + 1, 0, 1, 1, images.subLogo:getWidth() / 2, 0)
  love.graphics.setColor(stg.colors.offWhite)
  love.graphics.draw(images.logo, x, y, 0, 1, 1, images.logo:getWidth() / 2, 0)
  love.graphics.draw(images.subLogo, x, y + offset, 0, 1, 1, images.subLogo:getWidth() / 2, 0)
  love.graphics.setColor(stg.colors.white)
end

local function drawCredits()

end

local function drawArrow(x, y, shadow)
  local color = stg.colors.yellowDark
  if shadow then
    color = stg.colors.black
    x = x + 1
    y = y + 1
  end
  love.graphics.setColor(color)
  love.graphics.rectangle('fill', x, y, 1, 7)
  love.graphics.rectangle('fill', x + 1, y + 1, 1, 5)
  love.graphics.rectangle('fill', x + 2, y + 2, 1, 3)
  love.graphics.rectangle('fill', x + 3, y + 3, 1, 1)
  love.graphics.setColor(stg.colors.white)
end

local function drawMenu()
  local x = stg.winWidth / 2 - 8 * 5
  local y = stg.height / 2 + 16
  local activeX = x - 10
  for i = 1, #menuItems do
    chrome.drawLabel({input = menuItems[i], x = x, y = y})
    if i == currentMenuItem then
      drawArrow(activeX, y, true)
      drawArrow(activeX, y)
    end
    y = y + 12
  end
end

local function draw()
  love.graphics.draw(images.bg, 0, 0)
  drawMenu()
  drawTitle()
  drawCredits()
  chrome.drawLabel({input = '2020 peace research', y = stg.height - 8 * 4, x = (stg.winWidth - stg.width) / 2, align = {type = 'center'}})
end

return {
  load = load,
  update = update,
  draw = draw
}

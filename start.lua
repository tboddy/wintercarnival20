local images, currentMenu, movingMenu, menus, selecting

local function load()
  images = stg.images('start', {'bg', 'logo', 'title', 'sublogo'})
  currentMenu = 1
  movingMenu = false
  menus = {
    {items = {'S T A R T', 'C O N F I G', 'S C O R E', 'E X I T'}, current = 1},
    {items = {'F U L L S C R E E N', 'B A C K'}, current = 1}
  }
  selecting = false
end

local function selectMenuItem()
  if not selecting then
    local current = menus[currentMenu].current
    if currentMenu == 1 then
      if current == 1 then loadGame()
      elseif current == 2 then currentMenu = 2
      elseif current == 4 then love.event.quit() end
    elseif currentMenu == 2 then
      if current == 2 then currentMenu = 1 end
    end
  end
end

local function update()
  if controls.up() and not movingMenu then
    menus[currentMenu].current = menus[currentMenu].current - 1
    movingMenu = true
  elseif controls.down() and not movingMenu then
    menus[currentMenu].current = menus[currentMenu].current + 1
    movingMenu = true
  elseif not controls.up() and not controls.down() then movingMenu = false end
  if menus[currentMenu].current < 1 then menus[currentMenu].current = #menus[currentMenu].items
  elseif menus[currentMenu].current > #menus[currentMenu].items then menus[currentMenu].current = 1 end
  if controls.shot() and not selecting then
    selectMenuItem()
    selecting = true
  elseif not controls.shot() then selecting = false end
end

local function drawTitle()
  local offset = stg.grid * 3
  local letterOffset = stg.grid
  local function drawLogos(shadow)
    local y = stg.grid * 5.75
    if shadow then
      love.graphics.setColor(stg.colors.black)
      y = y + 1
      offset = offset + 1
    else love.graphics.setColor(stg.colors.offWhite) end
    -- love.graphics.draw(images.title, stg.width - offset - images.title:getWidth(), y)
    -- y = y + images.title:getHeight() + letterOffset
    love.graphics.draw(images.logo, stg.width - offset - images.logo:getWidth(), y)
    y = y + images.logo:getHeight() + letterOffset
    love.graphics.draw(images.sublogo, stg.width - offset - images.sublogo:getWidth(), y)
    love.graphics.setColor(stg.colors.white)
  end
  drawLogos(true)
  drawLogos()
end

local function drawCredits()
  local offset = stg.height - stg.grid * 2
  chrome.drawLabel({input = 'v0.01', y = offset, align = {type = 'right', width = stg.width - stg.grid}})
  local credit = '2020 T.BODDY'
  chrome.drawLabel({input = credit, y = offset, x = stg.width / 2 - #credit * 8 / 2})
end

local function drawMenu()
  local yOffset = stg.grid * 1.75
  local y = stg.grid * 15
  local arr = menus[currentMenu]

  for i = 1, #menus[currentMenu].items do
    local labelObj = {input = menus[currentMenu].items[i], align = {type = 'right', width = stg.width - stg.grid * 4}, y = y}
    if i == menus[currentMenu].current then labelObj.color = 'blueLight' end
    chrome.drawLabel(labelObj)
    love.graphics.setColor(stg.colors.offWhite)
    y = y + yOffset
  end
end

local function draw()
  -- love.graphics.draw(images.bg, 0, 0)
  drawMenu()
  -- drawTitle()
  -- drawCredits()
  -- chrome.drawLabel({input = '2020 peace research', y = stg.height - 8 * 4, x = (stg.width - stg.width) / 2, align = {type = 'center'}})
end

return {
  load = load,
  update = update,
  draw = draw
}

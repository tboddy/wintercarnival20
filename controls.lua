local joystick = false

local function load()
  local joysticks = love.joystick.getJoysticks()
  for i = 1, #joysticks do if i == 1 then joystick = joysticks[i] end end
  local dirTable = {'left', 'right', 'up', 'down'}
  for i = 1, #dirTable do controls[dirTable[i]] = function() return love.keyboard.isDown(dirTable[i]) end end
end

local function shot()
  return love.keyboard.isDown('z') or (joystick and joystick:isDown(1))
end

local function focus()
  return love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift') or (joystick and joystick:isDown(2))
end

local function reload()
  return love.keyboard.isDown('r')
end

local function quit()
  return love.keyboard.isDown('escape')
end

return {
  load = load,
  shot = shot,
  focus = focus,
  reload = reload,
  quit = quit
}

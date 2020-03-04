local images, chipItems, chipSize

local function load()
  images = {}
  local types = {'star'}
  for i = 1, #types do images[types[i]] = love.graphics.newImage('img/chips/' .. types[i] .. '.png') end
  stg.loadImages(images)
  chipItems = {}
  for i = 1, 32 do chipItems[i] = {} end
  chipSize = 22
end

local function spawn(opts)
  local chip = chipItems[stg.getIndex(chipItems)]
  chip.active = true
  chip.x = opts.x
  chip.y = opts.y
  chip.flipped = false
  chip.direction = math.random() < .5
  chip.speed = -3
  chip.clock = 0
  chip.rotation = math.tau * math.random()
end

local function updateChip(chip)
  if chip.flipped then
    local angle = stg.getAngle(chip, player)
    chip.speed = chip.speed + .5
    chip.x = chip.x + math.cos(angle) * chip.speed
    chip.y = chip.y + math.sin(angle) * chip.speed
    local dx = player.x - chip.x
    local dy = player.y - chip.y
    if math.sqrt(dx * dx + dy * dy) < 10 + chipSize / 2 then
      chip.active = false
      stg.score = stg.score + 1500
      player.power = player.power + 1
    end
  else
    if chip.y >= stg.height + chipSize / 2 then chip.active = false
    else
      chip.y = chip.y + chip.speed
      if chip.speed < 1.5 then chip.speed = chip.speed + .075
      else chip.speed = 1.5 end
      local dx = player.x - chip.x
      local dy = player.y - chip.y
      if math.sqrt((player.x - chip.x) * (player.x - chip.x) + (player.y - chip.y) * (player.y - chip.y)) < 64 + chipSize / 2 then chip.flipped = true end
    end
  end
  chip.clock = chip.clock + 1
end

local function update()
  for i = 1, #chipItems do if chipItems[i].active then updateChip(chipItems[i]) end end
end

local function drawChip(chip)
  love.graphics.setColor(stg.colors.yellow); love.graphics.draw(images.star, chip.x, chip.y - 1, chip.rotation, 1, 1, chipSize / 2, chipSize / 2)
  love.graphics.setColor(stg.colors.offWhite); stg.mask('quarter', function() love.graphics.draw(images.star, chip.x, chip.y - 1, chip.rotation, 1, 1, chipSize / 2, chipSize / 2) end)
  love.graphics.setColor(stg.colors.yellowDark)
  love.graphics.draw(images.star, chip.x, chip.y, chip.rotation, 1, 1, chipSize / 2, chipSize / 2)
  love.graphics.setColor(stg.colors.yellow)
  local interval = 20
  local max = interval * 4
  if(chip.clock % max >= interval and chip.clock % max < interval * 2) or (chip.clock % max >= interval * 3) then
    stg.mask('quarter', function() love.graphics.draw(images.star, chip.x, chip.y, chip.rotation, 1, 1, chipSize / 2, chipSize / 2) end)
  elseif chip.clock % max >= interval * 2 and chip.clock % max < interval * 3 then
    stg.mask('half', function() love.graphics.draw(images.star, chip.x, chip.y, chip.rotation, 1, 1, chipSize / 2, chipSize / 2) end)
  end
  love.graphics.setColor(stg.colors.white)
end

local function draw()
  for i = 1, #chipItems do if chipItems[i].active then drawChip(chipItems[i]) end end
end

return {
  load = load,
  spawn = spawn,
  update = update,
  draw = draw
}

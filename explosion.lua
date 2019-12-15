local size, types, images, explosions

local function load()
  size = 32
  types = {'blue', 'red', 'gray'}
  images = {}
  explosions = {}
  for i = 1, 32 do explosions[i] = {} end
  for i = 1, #types do
    images[types[i]] = {}
    for j = 0, 4 do images[types[i]][j] = love.graphics.newImage('img/explosion/' .. types[i] .. tostring(j) .. '.png') end
    stg.loadImages(images[types[i]])
  end
end

local function spawn(opts)
	local exp = explosions[stg.getIndex(explosions)]
  exp.active = true
  exp.x = opts.x
  exp.y = opts.y
  exp.current = 0
  exp.clock = 0
  if opts.type then exp.type = opts.type else exp.type = 'blue' end
  if opts.big then
    exp.xScale = 2
    exp.yScale = 2
  else
    exp.xScale = 1
    exp.yScale = 1
  end
  if math.random() < .5 then exp.xScale = exp.xScale * -1 end
  if math.random() < .5 then exp.yScale = exp.yScale * -1 end
end

local function updateExplosion(exp)
  local interval = 4
  if exp.clock == interval then exp.current = 1
  elseif exp.clock == interval * 2 then exp.current = 2
  elseif exp.clock == interval * 3 then exp.current = 3
  elseif exp.clock == interval * 4 then exp.current = 4
  elseif exp.clock == interval * 5 then exp.active = false end
  exp.clock = exp.clock + 1
end

local function update()
  for i = 1, #explosions do if explosions[i].active then updateExplosion(explosions[i]) end end
end

local function drawExplosion(exp)
  love.graphics.draw(images[exp.type][exp.current], exp.x, exp.y, 0, exp.xScale, exp.yScale, size / 2, size / 2)
end

local function draw()
  for i = 1, #explosions do if explosions[i].active and explosions[i].big then drawExplosion(explosions[i]) end end
  for i = 1, #explosions do if explosions[i].active and not explosions[i].big then drawExplosion(explosions[i]) end end
end

return {
  load = load,
  update = update,
  spawn = spawn,
  draw = draw
}

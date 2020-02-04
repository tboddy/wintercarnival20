local blockSize

local function load()
	blockSize = 32
	for i = 1, 32 do blocks.blockItems[i] = {} end
end

local function spawn(opts)
	local block = stage.blocks[stg.getIndex(stage.blocks)]
	block.active = true
	block.health = 1
	block.seen = false
	block.x = opts.x * blockSize
	block.y = opts.y * -blockSize - blockSize
	block.clock = math.floor(math.random() * 4) * 40
	if opts.type then block.type = opts.type else block.type = false end
	local mod = .025
	block.rotation = -mod + mod * 2 * math.random()
end

local function updateBlock(block)
  if block.health <= 0 then
    explosion.spawn({x = block.x + 16, y = block.y + 16, big = true, type = 'gray'})
    if block.type == 'power' then spawnChip({x = block.x + 16, y = block.y + 16}) end
    block.active = false
    stg.score = stg.score + 100
  elseif block.active then
    block.y = block.y + .6
    if block.seen and (block.x < -blockSize / 2 or block.x > stg.width + blockSize / 2 or block.y < -blockSize / 2 or block.y > stg.height + blockSize / 2) then block.active = false
    elseif not block.seen and block.x > -blockSize / 2 and block.x < stg.width + blockSize / 2 and block.y > -blockSize / 2 and block.y < stg.height + blockSize / 2 then block.seen = true end
    block.clock = block.clock + 1
  end
end

local function update()
	for i = 1, #stage.blocks do if stage.blocks[i].active then updateBlock(stage.blocks[i]) end end
end

local function drawBlock(block)
   if block.type then
     if block.type == 'power' then love.graphics.setColor(stg.colors.redDark) end
   end
   local interval = 40
   local max = interval * 4
   if block.clock % max >= interval and block.clock % max < interval * 2 then love.graphics.draw(images.block, block.x + blockSize / 2, block.y + blockSize / 2, block.rotation, 1, 1, blockSize / 2, blockSize / 2) else
     local maskName = 'half'
     if block.clock % max >= interval * 3 then maskName = 'quarter' end
     stg.mask(maskName, function() love.graphics.draw(images.block, block.x + blockSize / 2, block.y + blockSize / 2, block.rotation, 1, 1, blockSize / 2, blockSize / 2) end)
   end
   if block.type then love.graphics.setColor(stg.colors.purple) end
end

local function draw()
	-- love.graphics.setColor(stg.colors.black)
	-- for i = 1, #stage.blocks do if stage.blocks[i].active then love.graphics.draw(images.blockback, stage.blocks[i].x + blockSize / 2, stage.blocks[i].y + blockSize / 2, stage.blocks[i].rotation, 1, 1, blockSize / 2, blockSize / 2) end end
	-- love.graphics.setColor(stg.colors.purple)
	-- for i = 1, #stage.blocks do if stage.blocks[i].active then drawBlock(stage.blocks[i]) end end
	-- love.graphics.setColor(stg.colors.white)
end

return {
	load = load,
	update = update,
	draw = draw,
	spawn = spawn
}

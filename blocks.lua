local images

local function load()
	images = {}
	local imageFiles = {'point'}
	for i = 1, #imageFiles do images[imageFiles[i]] = love.graphics.newImage('img/blocks/' .. imageFiles[i] .. '.png') end
	stg.loadImages(images)
	for i = 1, 64 do blocks.blockItems[i] = {} end
end

local function spawn(opts)
	local block = blocks.blockItems[stg.getIndex(blocks.blockItems)]
	block.active = true
	block.health = 1
	block.seen = false
	block.x = opts.x * blocks.blockSize + blocks.blockSize / 4
	block.y = opts.y * -blocks.blockSize - blocks.blockSize
	block.clock = math.floor(math.random() * 4) * 40
	if opts.type then block.type = opts.type else block.type = false end
	local mod = math.pi / 50
	block.rotation = -mod + mod * 2 * math.random()
	math.randomseed(1419 * math.random())
end

local function updateBlock(block)
  if block.health <= 0 then
    explosion.spawn({x = block.x + 16, y = block.y + 16, big = true, type = 'gray'})
    -- if block.type == 'power' then spawnChip({x = block.x + 16, y = block.y + 16}) end
    block.active = false
    stg.score = stg.score + 100
  elseif block.active then
    block.y = block.y + .6
    if block.seen and (block.x < -blocks.blockSize / 2 or block.x > stg.width + blocks.blockSize / 2 or block.y < -blocks.blockSize / 2 or block.y > stg.height + blocks.blockSize / 2) then block.active = false
    elseif not block.seen and block.x > -blocks.blockSize / 2 and block.x < stg.width + blocks.blockSize / 2 and block.y > -blocks.blockSize / 2 and block.y < stg.height + blocks.blockSize / 2 then block.seen = true end
    block.clock = block.clock + 1
  end
end

local function update()
	for i = 1, #blocks.blockItems do if blocks.blockItems[i].active then updateBlock(blocks.blockItems[i]) end end
end

local function drawBlock(block, middle)
	local offset = blocks.blockOffset
	if middle then offset = offset + 3 end
	love.graphics.setColor(stg.colors.brownDark)
	if block.type == 'power' then love.graphics.setColor(stg.colors.redDark)
	elseif block.type == 'alt' then love.graphics.setColor(stg.colors.brown) end
	love.graphics.circle('fill', block.x + blocks.blockSize / 2, block.y + blocks.blockSize / 2, blocks.blockSize / 2 - offset)
end

local function drawTop(block)
	local img = false
	local scale = .9
	if not block.type or block.type == 'alt' then
		img = images.point
		love.graphics.setColor(stg.colors.brown)
		if block.type == 'alt' then love.graphics.setColor(stg.colors.brownLight) end
	end
	if img then love.graphics.draw(img, block.x + blocks.blockSize / 2, block.y + blocks.blockSize / 2, block.rotation, scale, scale, img:getWidth() / 2, img:getHeight() / 2) end
end

local function draw()
	stg.mask('quarter', function() for i = 1, #blocks.blockItems do if blocks.blockItems[i].active then drawBlock(blocks.blockItems[i]) end end end)
	stg.mask('half', function()
		for i = 1, #blocks.blockItems do if blocks.blockItems[i].active then drawBlock(blocks.blockItems[i], true) end end
		for i = 1, #blocks.blockItems do if blocks.blockItems[i].active then drawTop(blocks.blockItems[i]) end end
	end)
	love.graphics.setColor(stg.colors.white)
end

return {
	load = load,
	update = update,
	draw = draw,
	spawn = spawn,
	blockItems = {},
	blockSize = 32,
	blockOffset = 1
}



-- love.graphics.setColor(stg.colors.black)
-- for i = 1, #blocks.blockItems do if blocks.blockItems[i].active then love.graphics.draw(images.blockback, blocks.blockItems[i].x + blocks.blockSize / 2, blocks.blockItems[i].y + blocks.blockSize / 2, blocks.blockItems[i].rotation, 1, 1, blocks.blockSize / 2, blocks.blockSize / 2) end end


   -- if block.type then
   --   if block.type == 'power' then love.graphics.setColor(stg.colors.redDark) end
   -- end
   -- local interval = 40
   -- local max = interval * 4
   -- if block.clock % max >= interval and block.clock % max < interval * 2 then love.graphics.draw(images.block, block.x + blocks.blockSize / 2, block.y + blocks.blockSize / 2, block.rotation, 1, 1, blocks.blockSize / 2, blocks.blockSize / 2) else
   --   local maskName = 'half'
   --   if block.clock % max >= interval * 3 then maskName = 'quarter' end
   --   stg.mask(maskName, function() love.graphics.draw(images.block, block.x + blocks.blockSize / 2, block.y + blocks.blockSize / 2, block.rotation, 1, 1, blocks.blockSize / 2, blocks.blockSize / 2) end)
   -- end
   -- if block.type then love.graphics.setColor(stg.colors.purple) end

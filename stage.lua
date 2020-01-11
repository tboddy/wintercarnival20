local killBulletLimit, bulletAnimateInterval, bulletAnimateMax, images, bullets, killBulletClock, blockSize, chips, chipSize

local function loadEnemies()
  local types = {'block', 'blockback', 'fairygreen', 'fairyblue', 'fairyred', 'chip', 'keg', 'scorpion'}
  for i = 1, 32 do stage.enemies[i] = {} end
  for i = 1, #types do images[types[i]] = love.graphics.newImage('img/enemies/' .. types[i] .. '.png') end
  images.border1 =  love.graphics.newImage('img/enemies/border1.png')
end

local function loadBullets()
  local types = {'small', 'big', 'bolt', 'arrow', 'pill'}
  for i = 1, 512 do bullets[i] = {} end
  for i = 1, #types do
    for j = 0, 3 do
      images[types[i] .. j] = love.graphics.newImage('img/bullets/' .. types[i] .. j .. '.png')
      images[types[i] .. 'Red' .. j] = love.graphics.newImage('img/bullets/' .. types[i] .. '-red' .. j .. '.png')
    end
  end
end

local function load()
  killBulletClock = 0
  killBulletLimit = 60
  bulletAnimateInterval = 8
  bulletAnimateMax = bulletAnimateInterval * 4
  blockSize = 32
  chipSize = 22
  images = {}
  bullets = {}
  chips = {}
  loadEnemies()
  loadBullets()
  for i = 1, 32 do stage.blocks[i] = {} end
  for i = 1, 8 do chips[i] = {} end
  stg.loadImages(images)
end

local function spawnEnemy(initFunc, updateFunc)
	local enemy = stage.enemies[stg.getIndex(stage.enemies)]
	enemy.active = true
  enemy.health = 1
  enemy.clock = 0
  enemy.flags = {}
  enemy.opposite = false
  enemy.speed = 0
  enemy.seen = false
  enemy.score = 250
  enemy.hit = false
  enemy.boss = false
  enemy.borderRotation = 0
  if math.random() < .5 then enemy.xScale = 1 else enemy.xScale = -1 end
  local mod = math.pi / 30
  enemy.rotation = -mod + mod * 2 * math.random()
  enemy.suicideFunc = false
	initFunc(enemy)
  enemy.maxHealth = enemy.health
  if enemy.type == 'fairygreen' or enemy.type == 'fairyred' or enemy.type == 'fairyblue' then enemy.width = 28; enemy.height = 24
  elseif enemy.type == 'scorpion' then enemy.width = 136; enemy.height = 84
  elseif enemy.type == 'keg' then enemy.width = 140; enemy.height = 134 end
	enemy.updateFunc = updateFunc
end

local function updateEnemy(enemy)
  stage.enemyCount = stage.enemyCount + 1
  if enemy.health <= 0 then
    explosion.spawn({x = enemy.x, y = enemy.y, big = true, type = 'gray'})
    stg.score = stg.score + enemy.score
    if enemy.suicideFunc then enemy.suicideFunc(enemy) end
    enemy.active = false
  end
  if enemy.seen and enemy.active then
    enemy.x = enemy.x + math.cos(enemy.angle) * enemy.speed
    enemy.y = enemy.y + math.sin(enemy.angle) * enemy.speed
    enemy.updateFunc(enemy)
    enemy.borderRotation = enemy.borderRotation + .0025
    if enemy.x < -enemy.width / 2 or enemy.x > stg.width + enemy.width / 2 or enemy.y < -enemy.height / 2 or enemy.y > stg.height + enemy.height / 2 then enemy.active = false end
    enemy.clock = enemy.clock + 1
  elseif not enemy.seen and enemy.active then
    enemy.clock = -1
    enemy.x = enemy.x + math.cos(enemy.angle)
    enemy.y = enemy.y + math.sin(enemy.angle)
    if enemy.x > -enemy.width / 2 and enemy.x < stg.width + enemy.width / 2 and enemy.y > -enemy.height / 2 and enemy.y < stg.height + enemy.height / 2 then enemy.seen = true end
  end
end

local function spawnBullet(initFunc, updateFunc)
	if killBulletClock == 0 then
	  local bullet = bullets[stg.getIndex(bullets)]
	  bullet.active = true
		bullet.rotation = 0
    bullet.top = false
    bullet.clock = 0
    bullet.flags = {}
    bullet.speed = 0
    bullet.angle = 0
    if math.random() < .5 then bullet.xScale = 1 else bullet.xScale = -1 end
    if math.random() < .5 then bullet.yScale = 1 else bullet.yScale = -1 end
	  initFunc(bullet)
    if string.find(bullet.type, 'arrow') then bullet.width = 16; bullet.height = 14; bullet.xScale = 1
    elseif string.find(bullet.type, 'big') then bullet.width = 16; bullet.height = 16
    elseif string.find(bullet.type, 'bolt') then bullet.width = 20; bullet.height = 6; bullet.xScale = 1
    elseif string.find(bullet.type, 'pill') then bullet.width = 12; bullet.height = 4; bullet.xScale = 1
    elseif string.find(bullet.type, 'small') then bullet.width = 8; bullet.height = 8 end
    if updateFunc then bullet.updateFunc = updateFunc else bullet.updateFunc = false end
	end
end

local function updateBullet(bullet)
	if bullet.updateFunc then bullet.updateFunc(bullet) end
  bullet.x = bullet.x + math.cos(bullet.angle) * bullet.speed
  bullet.y = bullet.y + math.sin(bullet.angle) * bullet.speed
	if bullet.clock % bulletAnimateMax < bulletAnimateInterval then bullet.animateIndex = 0
	elseif bullet.clock % bulletAnimateMax >= bulletAnimateInterval and bullet.clock % bulletAnimateMax < bulletAnimateInterval * 2 then bullet.animateIndex = 1
  elseif bullet.clock % bulletAnimateMax >= bulletAnimateInterval * 2 and bullet.clock % bulletAnimateMax < bulletAnimateInterval * 3 then bullet.animateIndex = 2
  elseif bullet.clock % bulletAnimateMax >= bulletAnimateInterval * 3 then bullet.animateIndex = 3 end
	if string.find(bullet.type, 'bolt') or string.find(bullet.type, 'arrow') or string.find(bullet.type, 'pill') then bullet.rotation = bullet.angle end
	bullet.clock = bullet.clock + 1
	if bullet.x < -bullet.width * 2 or bullet.x > stg.width + bullet.width * 2 or bullet.y < -bullet.height * 2 or bullet.y > stg.height + bullet.height * 2 then bullet.active = false
	elseif killBulletClock > 0 then
    if string.find(bullet.type, 'Red') then explosion.spawn({x = bullet.x, y = bullet.y, type = 'red'}) else explosion.spawn({x = bullet.x, y = bullet.y}) end
		bullet.active = false
	elseif bullet.active and player.invulnerableClock == 0 then
    if math.sqrt((player.x - bullet.x) * (player.x - bullet.x) + (player.y - bullet.y) * (player.y - bullet.y)) < 1 + bullet.height / 2 then player.getHit(bullet) end
  end
end

local function spawnChip(opts)
  local chip = chips[stg.getIndex(chips)]
  chip.active = true
  chip.x = opts.x
  chip.y = opts.y
  chip.initial = chip.x
  chip.count = 0
  chip.flipped = false
  chip.direction = math.random() < .5
  chip.speed = 3
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
    end
  else
    if chip.y >= stg.height + chipSize / 2 then chip.active = false
    else
      chip.y = chip.y + .4
      chip.x = chip.initial - math.sin(chip.count) * stg.grid * 4
      local mod = .04
      if chip.direction then mod = mod * -1 end
      chip.count = chip.count + mod
      local dx = player.x - chip.x
      local dy = player.y - chip.y
      if math.sqrt((player.x - chip.x) * (player.x - chip.x) + (player.y - chip.y) * (player.y - chip.y)) < 52 + chipSize / 2 then chip.flipped = true end
    end
  end
  chip.clock = chip.clock + 1
end

local function spawnBlock(opts)
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
  stage.enemyCount = 0
  for i = 1, #stage.blocks do if stage.blocks[i].active then updateBlock(stage.blocks[i]) end end
  for i = 1, #stage.enemies do if stage.enemies[i].active then updateEnemy(stage.enemies[i]) end end
  for i = 1, #bullets do if bullets[i].active then updateBullet(bullets[i]) end end
  for i = 1, #chips do if chips[i].active then updateChip(chips[i]) end end
  if stage.killBullets then
    killBulletClock = killBulletLimit
    stage.killBullets = false
  end
  if killBulletClock > 0 then killBulletClock = killBulletClock - 1 end
  stage.killBulletClock = killBulletClock
end

local function drawEnemy(enemy)
  if enemy.boss then
    love.graphics.setColor(stg.colors.redDark)
    love.graphics.draw(images.border1, enemy.x, enemy.y, enemy.borderRotation, 1, 1, images.border1:getWidth() / 2, images.border1:getHeight() / 2)
      love.graphics.setColor(stg.colors.white)
  end
  love.graphics.draw(images[enemy.type], enemy.x, enemy.y, enemy.rotation, enemy.xScale, 1, enemy.width / 2, enemy.height / 2)
end

local function drawBullets()
	local function drawBullet(bullet) love.graphics.draw(images[bullet.type .. bullet.animateIndex], bullet.x, bullet.y, bullet.rotation, bullet.xScale, bullet.yScale, bullet.width / 2, bullet.height / 2) end
	for i = 1, #bullets do if bullets[i].active and not bullets[i].top then drawBullet(bullets[i]) end end
	for i = 1, #bullets do if bullets[i].active and bullets[i].top then drawBullet(bullets[i]) end end
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

local function drawBlocks()
  love.graphics.setColor(stg.colors.black)
  for i = 1, #stage.blocks do if stage.blocks[i].active then love.graphics.draw(images.blockback, stage.blocks[i].x + blockSize / 2, stage.blocks[i].y + blockSize / 2, stage.blocks[i].rotation, 1, 1, blockSize / 2, blockSize / 2) end end
  love.graphics.setColor(stg.colors.purple)
    for i = 1, #stage.blocks do if stage.blocks[i].active then drawBlock(stage.blocks[i]) end end
  love.graphics.setColor(stg.colors.white)
end

local function drawChip(chip)
  love.graphics.setColor(stg.colors.yellow); love.graphics.draw(images.chip, chip.x, chip.y - 1, chip.rotation, 1, 1, chipSize / 2, chipSize / 2)
  love.graphics.setColor(stg.colors.offWhite); stg.mask('quarter', function() love.graphics.draw(images.chip, chip.x, chip.y - 1, chip.rotation, 1, 1, chipSize / 2, chipSize / 2) end)
  love.graphics.setColor(stg.colors.yellowDark)
  -- stg.mask('half', function() love.graphics.circle('line', chip.x, chip.y, 16) end)
  love.graphics.draw(images.chip, chip.x, chip.y, chip.rotation, 1, 1, chipSize / 2, chipSize / 2)
  love.graphics.setColor(stg.colors.yellow)
  local interval = 20
  local max = interval * 4
  if(chip.clock % max >= interval and chip.clock % max < interval * 2) or (chip.clock % max >= interval * 3) then
    stg.mask('quarter', function() love.graphics.draw(images.chip, chip.x, chip.y, chip.rotation, 1, 1, chipSize / 2, chipSize / 2) end)
  elseif chip.clock % max >= interval * 2 and chip.clock % max < interval * 3 then
    stg.mask('half', function() love.graphics.draw(images.chip, chip.x, chip.y, chip.rotation, 1, 1, chipSize / 2, chipSize / 2) end)
  end
  love.graphics.setColor(stg.colors.white)
end

local function draw()
  for i = 1, #stage.enemies do if stage.enemies[i].active then drawEnemy(stage.enemies[i]) end end
  for i = 1, #chips do if chips[i].active then drawChip(chips[i]) end end
  drawBullets()
end

return {
  load = load,
  update = update,
  draw = draw,
  enemies = {},
  blocks = {},
  drawBlocks = drawBlocks,
  enemyCount = 0,
  spawnEnemy = spawnEnemy,
  spawnBullet = spawnBullet,
  spawnBlock = spawnBlock,
  killBullets = false,
  killBulletClock = 0
}

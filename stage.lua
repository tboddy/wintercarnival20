local killBulletLimit, bulletAnimateInterval, bulletAnimateMax, images, bullets, killBulletClock, enemyAnimateInterval, enemyAnimateMax,
  bossBorderCurrent, bossBorderSize

local function loadEnemies()
  for i = 1, 32 do stage.enemies[i] = {} end
  local types = {'beerlight', 'sake', 'martini', 'bowl', 'kanpai'}
  for i = 1, #types do
    images[types[i]] = love.graphics.newImage('img/enemies/' .. types[i] .. '.png')
    -- for j = 1, 3 do
      -- if types[i] == 'yukari' or types[i] == 'mima' then
      --   images[types[i] .. j] = love.graphics.newImage('img/enemies/' .. types[i] .. '/1.png')
      -- else images[types[i] .. j] = love.graphics.newImage('img/enemies/' .. types[i] .. '/' .. j .. '.png') end
    -- end
  end
  stage.images = images
end

local function loadBullets()
  local types = {'small', 'big', 'bolt', 'arrow', 'pill'}
  for i = 1, 1024 do bullets[i] = {} end
  for i = 1, #types do
    for j = 0, 3 do
      images[types[i] .. j] = love.graphics.newImage('img/bullets/' .. types[i] .. j .. '.png')
      images[types[i] .. 'Red' .. j] = love.graphics.newImage('img/bullets/' .. types[i] .. '-red' .. j .. '.png')
      -- images[types[i] .. j] = love.graphics.newImage('img/bullets/' .. types[i] .. '-red' .. j .. '.png')
    end
  end
end

local function load()
  killBulletClock = 0
  killBulletLimit = 60
  bulletAnimateInterval = 8
  bulletAnimateMax = bulletAnimateInterval * 4
  enemyAnimateInterval = 15
  enemyAnimateMax = enemyAnimateInterval * 4
  images = {}
  bullets = {}
  loadEnemies()
  loadBullets()
  stg.loadImages(images)
  bossBorderCurrent = 0
  bossBorderSize = stg.grid * 20
end

local function spawnEnemy(initFunc, updateFunc)
	local enemy = stage.enemies[stg.getIndex(stage.enemies)]
	enemy.active = true
  enemy.health = 1
  enemy.clock = 0
  enemy.flags = {}
  enemy.opposite = false
  enemy.speed = 0
  enemy.animateIndex = 1
  enemy.seen = false
  enemy.score = 250
  enemy.hit = false
  enemy.boss = false
  enemy.borderRotation = 0
  enemy.suicideFunc = false
	initFunc(enemy)
  enemy.maxHealth = enemy.health
  enemy.width = images[enemy.type]:getWidth()
  enemy.height = images[enemy.type]:getHeight()
	enemy.updateFunc = updateFunc
  local staggerMod = math.pi / 45
  enemy.stagger = -staggerMod + staggerMod * 2 * math.random()
  enemy.xScale = 1; if math.random() < .5 then enemy.xScale = -1 end
end

local function updateEnemy(enemy)
  stage.enemyCount = stage.enemyCount + 1
  -- if enemy.angle then enemy.rotation = enemy.angle - math.pi / 2 end
  if enemy.boss then
    stage.bossHealth = enemy.health
    stage.bossMaxHealth = enemy.maxHealth
  end
  if enemy.health <= 0 then
    explosion.spawn({x = enemy.x, y = enemy.y, big = true, type = 'gray'})
    stg.score = stg.score + enemy.score
    if enemy.suicideFunc then enemy.suicideFunc(enemy)
    else
      -- chips.spawn({x = enemy.x, y = enemy.y})
    end
    enemy.active = false
  end
  if enemy.seen and enemy.active then
    enemy.x = enemy.x + math.cos(enemy.angle) * enemy.speed
    enemy.y = enemy.y + math.sin(enemy.angle) * enemy.speed
    if enemy.updateFunc then enemy.updateFunc(enemy) end
    enemy.borderRotation = enemy.borderRotation + .0025
  	if enemy.clock % enemyAnimateMax < enemyAnimateInterval then enemy.animateIndex = 3
  	elseif enemy.clock % enemyAnimateMax >= enemyAnimateInterval and enemy.clock % enemyAnimateMax < enemyAnimateInterval * 2 then enemy.animateIndex = 1
    elseif enemy.clock % enemyAnimateMax >= enemyAnimateInterval * 2 and enemy.clock % enemyAnimateMax < enemyAnimateInterval * 3 then enemy.animateIndex = 3
    elseif enemy.clock % enemyAnimateMax >= enemyAnimateInterval * 3 then enemy.animateIndex = 2 end
    if enemy.x < -enemy.width / 2 or enemy.x > stg.width + enemy.width / 2 or enemy.y < -enemy.height / 2 or enemy.y > stg.height + enemy.height / 2 then enemy.active = false end
    enemy.clock = enemy.clock + 1
  elseif not enemy.seen and enemy.active then
    enemy.clock = -1
    enemy.x = enemy.x + math.cos(enemy.angle)
    enemy.y = enemy.y + math.sin(enemy.angle)
    if enemy.x > -enemy.width / 2 + stg.frameOffset and enemy.x < stg.width + enemy.width / 2 - stg.frameOffset and enemy.y > -enemy.height / 2 and enemy.y < stg.height + enemy.height / 2 then enemy.seen = true end
  end
  if enemy.boss and not enemy.active then
    stage.bossHealth = 0
    stage.bossMaxHealth = 0
  end
end

local function placeEnemy(enemy)
  local yOffset = stg.grid * 2.5
  local xOffset = stg.grid * 1.5
  local xLimit = stg.grid * 4
  enemy.flags.moveX = (stg.width - xOffset - xLimit) + xLimit * math.random()
  enemy.flags.moveY = yOffset + (stg.height - yOffset * 2) * math.random()
  enemy.flags.moveTarget = {x = enemy.flags.moveX, y = enemy.flags.moveY}
  local distance = stg.getDistance(enemy, enemy.flags.moveTarget)
  if(distance < stg.grid * 5 or distance > stg.grid * 6) then placeEnemy(enemy)
  else enemy.flags.moveAngle = stg.getAngle(enemy, enemy.flags.moveTarget) end
end

local function moveEnemy(enemy)
  local speed = stg.getDistance(enemy, enemy.flags.moveTarget) / 20
  enemy.x = enemy.x + math.cos(enemy.flags.moveAngle) * speed
  enemy.y = enemy.y + math.sin(enemy.flags.moveAngle) * speed 
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
	  initFunc(bullet)
    if string.find(bullet.type, 'arrow') then bullet.width = images.arrow0:getWidth(); bullet.height = images.arrow0:getHeight()
    elseif string.find(bullet.type, 'big') then bullet.width = images.big0:getWidth(); bullet.height = images.big0:getHeight()
    elseif string.find(bullet.type, 'bolt') then bullet.width = images.bolt0:getWidth(); bullet.height = images.bolt0:getHeight()
    elseif string.find(bullet.type, 'pill') then bullet.width = images.pill0:getWidth(); bullet.height = images.pill0:getHeight()
    elseif string.find(bullet.type, 'small') then bullet.width = images.small0:getWidth(); bullet.height = images.small0:getHeight() end
    bullet.width = bullet.width * 2
    bullet.height = bullet.height * 2
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
  if bullet.x < -bullet.width * 2
    or bullet.x > stg.width + bullet.width * 2
    or bullet.y < -bullet.height * 2
    or bullet.y > stg.height + bullet.height * 2 then bullet.active = false end
  local offset = stg.grid * 5
  if bullet.x < -offset
    or bullet.x > stg.width + offset
    or bullet.y < -offset
    or bullet.y > stg.height + offset then bullet.active = false
	elseif killBulletClock > 0 then
    if string.find(bullet.type, 'Red') then explosion.spawn({x = bullet.x, y = bullet.y, type = 'red'}) else explosion.spawn({x = bullet.x, y = bullet.y}) end
		bullet.active = false
	elseif bullet.active and player.invulnerableClock == 0 then
    if math.sqrt((player.x - bullet.x) * (player.x - bullet.x) + (player.y - bullet.y) * (player.y - bullet.y)) < 1 + bullet.height / 2 then player.getHit(bullet) end
  end
end

local function updateBossBorder()
  local mod = 10
  if bossBorderCurrent < bossBorderSize / 2 - mod then bossBorderCurrent = bossBorderCurrent + mod
  elseif bossBorderCurrent ~= bossBorderSize / 2 then bossBorderCurrent = bossBorderSize / 2 end
end

local function update()
  stage.enemyCount = 0
  for i = 1, #stage.enemies do if stage.enemies[i].active then
    local enemy = stage.enemies[i]
    updateEnemy(enemy)
    if enemy.boss and enemy.flags.ready then updateBossBorder(enemy) end
  end end
  for i = 1, #bullets do if bullets[i].active then updateBullet(bullets[i]) end end
  if stage.killBullets then
    killBulletClock = killBulletLimit
    stage.killBullets = false
  end
  if killBulletClock > 0 then killBulletClock = killBulletClock - 1 end
  stage.killBulletClock = killBulletClock
end

-- local function drawShadow(enemy)
--   love.graphics.setColor(stg.colors.purple)
--   stg.mask('quarter', function() love.graphics.circle('fill', enemy.x + stg.frameOffset, enemy.y, 64) end)
--   stg.mask('half', function() love.graphics.circle('fill', enemy.x + stg.frameOffset, enemy.y, 42) end)
--   love.graphics.setColor(stg.colors.white)
-- end

local function drawBossBorder(enemy)
  local borderWidth = stg.grid * 1.5 - 2
  love.graphics.setLineWidth(borderWidth)
  love.graphics.setColor(stg.colors.redDark)
  stg.mask('most', function() love.graphics.circle('line', enemy.x + stg.frameOffset, enemy.y, bossBorderCurrent - borderWidth / 2) end)
  stg.mask('half', function() love.graphics.circle('line', enemy.x + stg.frameOffset, enemy.y, bossBorderCurrent - borderWidth * 1.5 + 1) end)
  stg.mask('quarter', function() love.graphics.circle('line', enemy.x + stg.frameOffset, enemy.y, bossBorderCurrent - borderWidth * 2.5 + 2) end)
  love.graphics.setLineWidth(2)
  love.graphics.circle('line', enemy.x + stg.frameOffset, enemy.y, bossBorderCurrent - borderWidth / 2 + borderWidth / 2)
  love.graphics.setColor(stg.colors.white)
end

local function drawBorders()
  for i = 1, #stage.enemies do if stage.enemies[i].active then
    local enemy = stage.enemies[i]
    if enemy.boss and enemy.flags.ready then drawBossBorder(enemy) end
  end end
end

local function drawEnemy(enemy)
  local rotation = 0
  if enemy.stagger then rotation = enemy.stagger end
  love.graphics.draw(images[enemy.type], enemy.x + stg.frameOffset, enemy.y, rotation, enemy.xScale, 1, enemy.width / 2, enemy.height / 2)
  --  .. enemy.animateIndex
end

local function drawBullets()
	local function drawBullet(bullet)
    if not bullet.flags.invisible then
      love.graphics.draw(images[bullet.type .. bullet.animateIndex], bullet.x + stg.frameOffset, bullet.y, bullet.rotation, 1, 1,
        images[bullet.type .. bullet.animateIndex]:getWidth() / 2, images[bullet.type .. bullet.animateIndex]:getHeight() / 2)
    end
  end
	for i = 1, #bullets do if bullets[i].active and not bullets[i].top then drawBullet(bullets[i]) end end
	for i = 1, #bullets do if bullets[i].active and bullets[i].top then drawBullet(bullets[i]) end end
end

local function draw()
  -- for i = 1, #stage.enemies do if stage.enemies[i].active then drawShadow(stage.enemies[i]) end end
  drawBullets()
  for i = 1, #stage.enemies do if stage.enemies[i].active then drawEnemy(stage.enemies[i]) end end
  -- love.graphics.draw(images.kanpai, stg.width - stg.frameOffset - images.kanpai:getWidth() - stg.grid, stg.grid * 2)
end

return {
  load = load,
  update = update,
  drawBorders = drawBorders,
  draw = draw,
  enemies = {},
  enemyCount = 0,
  spawnEnemy = spawnEnemy,
  spawnBullet = spawnBullet,
  killBullets = false,
  killBulletClock = 0,
  bossHealth = 0,
  bossMaxHealth = 0,
  placeEnemy = placeEnemy,
  moveEnemy = moveEnemy
}

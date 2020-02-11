local killBulletLimit, bulletAnimateInterval, bulletAnimateMax, images, bullets, killBulletClock, enemyAnimateInterval, enemyAnimateMax

local function loadEnemies()
  local types = {'fairyred', 'fairyblue', 'fairyyellow', 'fairygreen'}
  for i = 1, 32 do stage.enemies[i] = {} end
  for i = 1, #types do
    for j = 1, 3 do
      images[types[i] .. 'Center' .. j] = love.graphics.newImage('img/enemies/' .. types[i] .. '/center' .. j .. '.png')
      images[types[i] .. 'Left' .. j] = love.graphics.newImage('img/enemies/' .. types[i] .. '/left' .. j .. '.png')
    end
  end
  images.border1 =  love.graphics.newImage('img/enemies/border1.png')
  stage.images = images
end

local function loadBullets()
  local types = {'small', 'big', 'bolt', 'arrow', 'pill'}
  for i = 1, 1024 do bullets[i] = {} end
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
  enemyAnimateInterval = 8
  enemyAnimateMax = enemyAnimateInterval * 4
  images = {}
  bullets = {}
  loadEnemies()
  loadBullets()
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
  enemy.animateIndex = 1
  enemy.seen = false
  enemy.score = 250
  enemy.hit = false
  enemy.boss = false
  enemy.borderRotation = 0
  enemy.suicideFunc = false
  enemy.animateDir = 'Center'
	initFunc(enemy)
  enemy.xScale = 1
  enemy.lastX = enemy.x
  enemy.maxHealth = enemy.health
  enemy.width = images[enemy.type .. 'Center1']:getWidth()
  enemy.height = images[enemy.type .. 'Center1']:getHeight()
	enemy.updateFunc = updateFunc
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
  	if enemy.clock % enemyAnimateMax < enemyAnimateInterval then enemy.animateIndex = 1
  	elseif enemy.clock % enemyAnimateMax >= enemyAnimateInterval and enemy.clock % enemyAnimateMax < enemyAnimateInterval * 2 then enemy.animateIndex = 2
    elseif enemy.clock % enemyAnimateMax >= enemyAnimateInterval * 2 and enemy.clock % enemyAnimateMax < enemyAnimateInterval * 3 then enemy.animateIndex = 1
    elseif enemy.clock % enemyAnimateMax >= enemyAnimateInterval * 3 then enemy.animateIndex = 3 end
    enemy.animateDir = 'Center'
    enemy.xScale = 1
    if enemy.x < enemy.lastX then enemy.animateDir = 'Left'
    elseif enemy.x > enemy.lastX then
      enemy.animateDir = 'Left'
      enemy.xScale = -1
    end
    enemy.lastX = enemy.x
    if enemy.x < -enemy.width / 2 or enemy.x > stg.width + enemy.width / 2 or enemy.y < -enemy.height / 2 or enemy.y > stg.height + enemy.height / 2 then enemy.active = false end
    enemy.clock = enemy.clock + 1
  elseif not enemy.seen and enemy.active then
    enemy.clock = -1
    enemy.x = enemy.x + math.cos(enemy.angle)
    enemy.y = enemy.y + math.sin(enemy.angle)
    if enemy.x > -enemy.width / 2 and enemy.x < stg.width + enemy.width / 2 and enemy.y > -enemy.height / 2 and enemy.y < stg.height + enemy.height / 2 then enemy.seen = true end
  end
  if enemy.boss and not enemy.active then
    stage.bossHealth = 0
    stage.bossMaxHealth = 0
  end
end

local function setupMoveBoss(enemy)
  if enemy.speed <= 0 and not enemy.flags.ready then
    enemy.clock = -1
    enemy.flags.moveAngles = {
      math.pi / 10,
      math.pi / 10 * 11,
      math.pi / 10 * 9,
      math.pi / 10 * 19
    }
    enemy.flags.currentMoveAngle = 1
    enemy.flags.ready = true
  end
end

local function moveBoss(enemy, patternInterval, patternLimit)
  if enemy.clock % patternInterval >= patternLimit then
    if enemy.clock % patternInterval == patternLimit then enemy.speed = 5
      enemy.angle = enemy.flags.moveAngles[enemy.flags.currentMoveAngle]
      enemy.speed = 2
    end
  else enemy.speed = 0 end
  if enemy.clock % patternInterval == patternLimit and enemy.clock > 0 then
    enemy.flags.currentMoveAngle = enemy.flags.currentMoveAngle + 1
    if enemy.flags.currentMoveAngle > #enemy.flags.moveAngles then enemy.flags.currentMoveAngle = 1 end
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

local function update()
  stage.enemyCount = 0
  for i = 1, #stage.enemies do if stage.enemies[i].active then updateEnemy(stage.enemies[i]) end end
  for i = 1, #bullets do if bullets[i].active then updateBullet(bullets[i]) end end
  if stage.killBullets then
    killBulletClock = killBulletLimit
    stage.killBullets = false
  end
  if killBulletClock > 0 then killBulletClock = killBulletClock - 1 end
  stage.killBulletClock = killBulletClock
end

local function drawEnemy(enemy)
  if enemy.boss and enemy.flags.ready then
    love.graphics.setColor(enemy.flags.borderColor)
    stg.mask('most', function() love.graphics.draw(images.border1, enemy.x, enemy.y, enemy.borderRotation, 1, 1, images.border1:getWidth() / 2, images.border1:getHeight() / 2) end)
    love.graphics.setColor(stg.colors.white)
  end
  love.graphics.draw(images[enemy.type .. enemy.animateDir .. enemy.animateIndex], enemy.x, enemy.y, enemy.rotation, enemy.xScale, 1, enemy.width / 2, enemy.height / 2)
end

local function drawBullets()
	local function drawBullet(bullet)
    if not bullet.flags.invisible then
      love.graphics.draw(images[bullet.type .. bullet.animateIndex], bullet.x, bullet.y, bullet.rotation, bullet.xScale, bullet.yScale, bullet.width / 2, bullet.height / 2)
    end
  end
	for i = 1, #bullets do if bullets[i].active and not bullets[i].top then drawBullet(bullets[i]) end end
	for i = 1, #bullets do if bullets[i].active and bullets[i].top then drawBullet(bullets[i]) end end
end

local function draw()
  for i = 1, #stage.enemies do if stage.enemies[i].active then drawEnemy(stage.enemies[i]) end end
  drawBullets()
end

return {
  load = load,
  update = update,
  draw = draw,
  enemies = {},
  enemyCount = 0,
  spawnEnemy = spawnEnemy,
  spawnBullet = spawnBullet,
  killBullets = false,
  killBulletClock = 0,
  moveBoss = moveBoss,
  bossHealth = 0,
  bossMaxHealth = 0,
  setupMoveBoss = setupMoveBoss
}

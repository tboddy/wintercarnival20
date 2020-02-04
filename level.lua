-- https://www.youtube.com/watch?v=IWOhouJ7c04

local killBulletLimit = 60
local waveClock = 0
local nextWave

local flippedWaveOne = false

function waveOne()
  local function middle()
    local function spawnEnemy(yMod)
      stage.spawnEnemy(function(enemy)
        enemy.type = 'fairyred'
        enemy.x = stg.width / 2
        enemy.y = -(stage.images[enemy.type]:getHeight() / 2 + 16 * yMod)
        enemy.speed = .75
        enemy.angle = math.pi / 2
        enemy.flags.count = 0
        enemy.flags.initial = enemy.x
        enemy.count = 0
      end, function(enemy)
        enemy.x = enemy.flags.initial - math.sin(enemy.count) * stg.grid * 5
        enemy.count = enemy.count + .05
      end)
    end
    for i = 1, 10 do spawnEnemy(i - 1) end
  end
  local function sides()
    local function spawnBullets(enemy)
      local mod = math.pi / 2
      local angle = stg.getAngle(enemy, player) - mod / 2
      for i = 1, 5 do
        stage.spawnBullet(function(bullet)
          bullet.x = enemy.x
          bullet.y = enemy.y
          bullet.angle = angle + math.random() * mod
          bullet.speed = 2 + math.random() * .5
          bullet.type = 'small'; if i % 2 == 0 then bullet.type = 'big' end
        end, function(bullet)
          stg.slowEntity(bullet, 1.5, .015)
        end)
      end
    end
    local function spawnSide(opposite)
      local offset = stg.grid * 2
      local function spawnEnemy(xMod)
        stage.spawnEnemy(function(enemy)
          if opposite then
            enemy.x = -offset - xMod * offset
            enemy.angle = 0
          else
            enemy.x = stg.width + offset * 4 + xMod * offset
            enemy.angle = math.pi
          end
          enemy.y = stg.grid * 2 + math.random() * stg.grid * 3
          enemy.type = 'fairyblue'
          enemy.speed = 2
        end, function(enemy)
          if not enemy.flags.flipped then
            enemy.speed = enemy.speed - .025
            if enemy.speed <= 1 then
              enemy.flags.flipped = true
              enemy.speed = 1
              enemy.angle = stg.getAngle(enemy, player)
              spawnBullets(enemy)
            end
          end
        end)
      end
      for i = 1, 4 do spawnEnemy(i) end
    end
    spawnSide()
    spawnSide(true)
  end
  middle()
  sides()
  nextWave = waveTwo
end

function waveTwo()

  local function spawnBullet(enemy)
    stage.spawnBullet(function(bullet)
      bullet.x = enemy.flags.bulletPos.x
      bullet.y = enemy.flags.bulletPos.y
      local mod = math.pi / 60
      bullet.angle = enemy.flags.bulletAngle - mod / 2 + math.random() * mod
      bullet.speed = 3
      bullet.type = 'bigRed'
    end, function(bullet)
    end)
  end

  local function spawnEnemy(mod, opposite)
    stage.spawnEnemy(function(enemy)
      enemy.type = 'fairyblue'
      enemy.x = -stage.images[enemy.type]:getWidth() / 2 - mod * 32
      enemy.y = stg.height / 3
      enemy.angle = 0
      enemy.speed = 1.5
      enemy.flags.initial = enemy.x
      enemy.flags.angleMod = .035
      if opposite then
        enemy.x = enemy.x * -1 + stg.width * 1.25
        enemy.y = enemy.y - stg.grid * 3.5
        enemy.angle = math.pi
        enemy.flags.angleMod = enemy.flags.angleMod * -1
      end
    end, function(enemy)
      local mod = (stg.height / 2 - enemy.y) / 120
      -- enemy.x = enemy.x + mod
      local interval = 30
      local max = interval * 2.25
      if enemy.clock >= interval and enemy.clock <= max and enemy.clock % 5 == 0 then
        enemy.angle = enemy.angle + enemy.flags.angleMod
        if not enemy.flags.bulletStart then enemy.flags.bulletStart = 0 end
        if enemy.flags.bulletStart % 4 == 0 then
          enemy.flags.bulletAngle = stg.getAngle(enemy, player)
          enemy.flags.bulletPos = {x = enemy.x, y = enemy.y}
        end
        spawnBullet(enemy)
        enemy.flags.bulletStart = enemy.flags.bulletStart + 1
      end
    end)
  end
  for i = 1, 5 do
    spawnEnemy(i - 1)
    spawnEnemy(i - 1, true)
  end

  nextWave = waveTwo
end

local currentWave = waveTwo

local function update()
  if stage.enemyCount == 0 then
    if waveClock >= 10 then
      currentWave()
      currentWave = nextWave
      waveClock = 0
    else waveClock = waveClock + 1 end
  end
end

return {
  update = update
}



--
-- local flippedWaveTwo = false
--
-- function waveTwo()
--   local function lineEnemies()
--     local function spawnEnemy(yMod)
--       stage.spawnEnemy(function(enemy)
--         enemy.x = stg.width / 2
--         enemy.y = -(14 + 20 * yMod)
--         enemy.type = 'ship3'
--         enemy.speed = 1.5
--         enemy.angle = math.pi / 2
--         enemy.flags.angleMod = .015
--         if flippedWaveTwo then
--           -- enemy.x = enemy.x * 4
--           enemy.flags.angleMod = enemy.flags.angleMod * -1
--         end
--       end, function(enemy)
--         local interval = 60
--         if enemy.clock < interval then enemy.angle = enemy.angle + enemy.flags.angleMod
--         elseif enemy.clock < interval * 2.5 then enemy.angle = enemy.angle - enemy.flags.angleMod end
--       end)
--     end
--     for i = 1, 5 do spawnEnemy(i - 1) end
--   end
--   local function bigEnemy()
--     local function spawnBullets(enemy)
--       local count = 7
--       local mod = math.pi / 9
--       local angle = stg.getAngle(enemy, player) - mod * math.floor(count / 2)
--       for i = 1, count do
--         stage.spawnBullet(function(bullet)
--           bullet.x = enemy.x
--           bullet.y = enemy.y
--           bullet.angle = angle
--           bullet.speed = 1.75
--           bullet.type = 'big'
--         end, function(bullet)
--           stg.slowEntity(bullet, 1.75, .015)
--         end)
--         angle = angle + mod
--       end
--     end
--     local function spawnEnemy()
--       stage.spawnEnemy(function(enemy)
--         enemy.x = stg.width / 4 * 3
--         enemy.y = -14
--         enemy.type = 'ship4'
--         enemy.angle = math.pi / 2
--         enemy.speed = 2
--         enemy.health = 3
--         if flippedWaveTwo then
--           enemy.x = stg.width / 4
--         end
--       end, function(enemy)
--         stg.slowEntity(enemy, .75, .025)
--         if not enemy.flags.fired then
--           enemy.rotation = stg.getAngle(enemy, player) + math.pi / 2
--           if enemy.clock == 30 then
--             enemy.fired = true
--             spawnBullets(enemy)
--           end
--         end
--       end)
--     end
--     spawnEnemy()
--   end
--   lineEnemies()
--   bigEnemy()
--   if not flippedWaveTwo then
--     flippedWaveTwo = true
--     nextWave = waveTwo
--   else nextWave = waveThree end
-- end
--
-- function waveThree()
--   local x
--   local offset = stg.grid * 2
--   local function spawnEnemies(yOffset)
--     local function spawnEnemy(eX)
--       stage.spawnEnemy(function(enemy)
--         enemy.x = eX
--         enemy.y = -14 - stg.grid * 3 * yOffset
--         enemy.type = 'ship3'
--         enemy.speed = 3
--         enemy.angle = math.pi / 2
--       end, function(enemy)
--         local limit = 1.5
--         if enemy.speed > limit then
--           enemy.speed = enemy.speed - .075
--         elseif enemy.speed <= limit then
--           if not enemy.flags.flipped then
--             enemy.angle = stg.getAngle(enemy, player)
--             enemy.flags.flipped = true
--           end
--         end
--       end)
--     end
--     x = x - offset
--     for i = 1, 3 do
--       spawnEnemy(x)
--       x = x + offset
--     end
--   end
--   x = stg.width / 3
--   spawnEnemies(0)
--   x = stg.width / 3 * 2
--   spawnEnemies(1)
--   x = stg.width / 2
--   spawnEnemies(2)
--   nextWave = waveFour
-- end
--
-- function waveFour() -- 0:42
--   local function ring(enemy)
--     local angle = math.pi / 2
--     local count = 15
--     for i = 1, count do
--       stage.spawnBullet(function(bullet)
--         bullet.x = enemy.x
--         bullet.y = enemy.y
--         bullet.angle = angle
--         bullet.speed = 1.75
--         bullet.type = 'big'
--       end)
--       angle = angle + math.tau / count
--     end
--   end
--   local function spray(enemy)
--     local mod = math.pi / 15
--     local count = 5
--     local angle = math.pi / 2 - mod * math.floor(count / 2)
--     for i = 1, 7 do
--       stage.spawnBullet(function(bullet)
--         bullet.x = enemy.x
--         bullet.y = enemy.y
--         bullet.angle = angle + mod * count * math.random()
--         bullet.speed = 1.5 + math.random() * .75
--         bullet.type = 'bigRed'; if math.random() < .5 then bullet.type = 'smallRed' end
--         bullet.top = true
--       end)
--       -- angle = angle + mod
--     end
--   end
--   local function spawnEnemy(x, yOffset)
--     stage.spawnEnemy(function(enemy)
--       enemy.x = x
--       enemy.y = -14 - stg.grid * 8 * yOffset
--       enemy.type = 'ship3'
--       enemy.speed = 3
--       enemy.health = 8
--       enemy.angle = math.pi / 2
--       enemy.flags.speedMod = .035
--     end, function(enemy)
--       if enemy.clock == 45 then ring(enemy) end
--       if enemy.speed <= 0 then
--         if enemy.clock % 30 == 0 then spray(enemy) end
--         enemy.speed = enemy.speed - enemy.flags.speedMod / 2
--       else
--         enemy.speed = enemy.speed - enemy.flags.speedMod
--       end
--     end)
--   end
--   spawnEnemy(stg.width / 4, 0)
--   spawnEnemy(stg.width / 2, 1)
--   spawnEnemy(stg.width / 4 * 3, 2)
--   spawnEnemy(stg.width / 2, 3)
--   nextWave = midBossOne
-- end
--
-- function midBossOne() -- 0:54
--
--   local function patternOne(enemy)
--     local patternInterval = 60 * 1.75
--     local patternMax = patternInterval * 3
--     local patternLimit = patternInterval - 45
--     stage.moveBoss(enemy, patternInterval, patternLimit)
--   end
--   local function patternTwo(enemy) end
--
--   stage.spawnEnemy(function(enemy)
--     enemy.x = stg.width / 2
--     enemy.y = -30
--     enemy.type = 'boss2'
--     enemy.speed = 2.675
--     enemy.angle = math.pi / 2
--     enemy.boss = true
--     enemy.rotation = 0
--     enemy.health = 75
--     enemy.xScale = 1
--     enemy.flags.rotateCount = 0
--     enemy.flags.hitSpellTwo = false
--     enemy.flags.hitSpellThree = false
--     enemy.flags.borderColor = stg.colors.redDark
--     enemy.suicideFunc = function(enemy)
--       stage.killBullets = true
--     end
--   end, function(enemy)
--     stg.slowEntity(enemy, 0, .05)
--     stage.setupMoveBoss(enemy)
--     local currentPattern = patternOne
--     if enemy.health >= enemy.maxHealth / 5 then
--     elseif enemy.health < enemy.maxHealth / 5 then
--       currentPattern = patternTwo
--       if not enemy.flags.hitSpellTwo then
--         enemy.flags.hitSpellTwo = true
--         enemy.clock = -killBulletLimit
--         stage.killBullets = true
--       end
--     end
--     if enemy.clock >= 0 and enemy.flags.ready then currentPattern(enemy) end
--     enemy.rotation = math.sin(enemy.flags.rotateCount) / 60
--     enemy.flags.rotateCount = enemy.flags.rotateCount + .01
--   end)
--
--   nextWave = waveFive
-- end
--
-- function waveFive()
-- end
--
-- function bossOne()
--
--   local function patternOne(enemy) -- 1:50
--
--     local patternInterval = 60 * 1.75
--     local patternMax = patternInterval * 3
--     local patternLimit = patternInterval - 45
--
--     local function ring()
--       local function spawnBullets()
--         if enemy.clock % patternInterval == 0 then enemy.flags.ringAngle = math.tau * math.random() end
--         local count = 13
--         local angle = enemy.flags.ringAngle
--         for i = 1, count do
--           stage.spawnBullet(function(bullet)
--             bullet.x = enemy.x
--             bullet.y = enemy.y
--             bullet.angle = angle
--             bullet.speed = 3.75
--             bullet.type = 'big'
--           end)
--           angle = angle + math.tau / count
--         end
--         enemy.flags.ringAngle = enemy.flags.ringAngle + math.pi / 100
--       end
--       local interval = 3
--       if enemy.clock % interval == 0 then spawnBullets() end
--       if enemy.clock % 15 == 0 then explosion.spawn({x = enemy.x, y = enemy.y, enemy = true}) end
--     end
--
--     local function lasers()
--       local function spawnBullets()
--         if enemy.clock % patternInterval == 0 then
--           local mod = math.pi / 8 * 6
--           enemy.flags.laserAngleA = stg.getAngle(enemy, player) + mod
--           enemy.flags.laserAngleB = stg.getAngle(enemy, player) - mod
--         end
--         local laserSpawnA = {x = enemy.x, y = enemy.y}
--         local laserSpawnB = {x = enemy.x, y = enemy.y}
--         local function spawnBullet(opposite, clockMod)
--           stage.spawnBullet(function(bullet)
--             if opposite then
--               bullet.x = laserSpawnA.x
--               bullet.y = laserSpawnA.y
--               bullet.angle = enemy.flags.laserAngleA
--             else
--               bullet.x = laserSpawnB.x
--               bullet.y = laserSpawnB.y
--               bullet.angle = enemy.flags.laserAngleB
--             end
--             bullet.speed = 5.25
--             bullet.type = 'bolt'
--             bullet.flags.clockMod = clockMod
--             bullet.flags.invisible = true
--           end, function(bullet)
--             if bullet.clock >= bullet.flags.clockMod * 5 and bullet.flags.invisible then bullet.flags.invisible = false end
--           end)
--         end
--         local diff = 24
--         for i = 1, 3 do
--           spawnBullet(false, i - 1)
--           spawnBullet(true, i - 1)
--           laserSpawnA.x = laserSpawnA.x - math.cos(enemy.flags.laserAngleA) * diff
--           laserSpawnA.y = laserSpawnA.y - math.sin(enemy.flags.laserAngleA) * diff
--           laserSpawnB.x = laserSpawnB.x - math.cos(enemy.flags.laserAngleB) * diff
--           laserSpawnB.y = laserSpawnB.y - math.sin(enemy.flags.laserAngleB) * diff
--         end
--         local mod = math.pi / 83
--         enemy.flags.laserAngleA = enemy.flags.laserAngleA - mod
--         enemy.flags.laserAngleB = enemy.flags.laserAngleB + mod
--       end
--       spawnBullets()
--       if enemy.clock % 15 == 0 then explosion.spawn({x = enemy.x, y = enemy.y, enemy = true}) end
--     end
--
--     local function balls()
--       local function spawnBullets()
--         local mod = math.pi / 10
--         local count = 13
--         if enemy.clock % patternInterval == 0 then enemy.flags.ballsAngle = stg.getAngle(enemy, player) - math.floor(count / 2) * mod - mod end
--         local angle = enemy.flags.ballsAngle
--         for i = 1, count do
--           stage.spawnBullet(function(bullet)
--             bullet.x = enemy.x
--             bullet.y = enemy.y
--             bullet.angle = angle
--             bullet.speed = 3.75
--             bullet.type = 'bigRed'
--           end)
--           angle = angle + mod
--         end
--         enemy.flags.ballsAngle = enemy.flags.ballsAngle + mod / 2
--         explosion.spawn({x = enemy.x, y = enemy.y, type = 'red', enemy = true})
--       end
--       local interval = 10
--       if enemy.clock % interval == 0 then spawnBullets() end
--     end
--
--     stage.moveBoss(enemy, patternInterval, patternLimit)
--
--     if enemy.clock % patternInterval < patternLimit then
--       if enemy.clock % patternMax < patternInterval then ring()
--       elseif enemy.clock % patternMax >= patternInterval and enemy.clock % patternMax < patternInterval * 2 then lasers()
--       elseif enemy.clock % patternMax >= patternInterval * 2 then balls() end
--     end
--
--   end
--
--   local function patternTwo(enemy) -- 2:02
--
--     local patternInterval = 60 * 2.5
--     local patternMax = patternInterval * 3
--     local patternLimit = patternInterval - 30
--
--     local function ring()
--       if enemy.clock % patternInterval == 0 then
--         enemy.flags.ringAngle = math.pi / 2
--         enemy.flags.ringDirection = true
--       end
--       local function spawnBullets(opposite)
--         local count = 17
--         local angle = enemy.flags.ringAngle
--         for i = 1, count do
--           stage.spawnBullet(function(bullet)
--             bullet.x = enemy.x
--             bullet.y = enemy.y
--             bullet.angle = angle
--             bullet.speed = 5.5
--             bullet.type = 'big'; if opposite then bullet.type = 'small' end
--           end, function(bullet)
--             stg.slowEntity(bullet, 3, .15)
--           end)
--           angle = angle + math.tau / count
--         end
--         local mod = math.pi / 65
--         if enemy.flags.ringDirection then mod = mod * -1 end
--         enemy.flags.ringAngle = enemy.flags.ringAngle + mod
--       end
--       local interval = 4
--       if enemy.clock % (interval * 8) == 0 then if enemy.flags.ringDirection then enemy.flags.ringDirection = false else enemy.flags.ringDirection = true end end
--       if enemy.clock % interval == 0 then spawnBullets(enemy.clock % (interval * 2) == 0) end
--       if enemy.clock % 15 == 0 then explosion.spawn({x = enemy.x, y = enemy.y, enemy = true}) end
--     end
--
--     local function blast()
--       local function spawnBullets()
--         local count = 16 * 3.5
--         local angle = math.tau * math.random()
--         explosion.spawn({x = enemy.x, y = enemy.y, type = 'red', enemy = true})
--         for i = 1, count do
--           stage.spawnBullet(function(bullet)
--             bullet.x = enemy.x
--             bullet.y = enemy.y
--             bullet.angle = angle
--             bullet.minSpeed =  2 + math.random() * 1
--             bullet.speed = bullet.minSpeed + 2
--             bullet.type = 'bigRed'; if math.random() < .5 then bullet.type = 'smallRed' end
--           end, function(bullet)
--             stg.slowEntity(bullet, bullet.minSpeed, .1)
--           end)
--           angle = angle + math.pi * math.random()
--         end
--       end
--       local interval = math.floor(patternLimit / 4)
--       if enemy.clock % interval == 0 and enemy.clock % patternInterval < patternLimit * .75 then spawnBullets() end
--     end
--
--     local function lasers()
--       if enemy.clock % patternInterval == 0 then enemy.laserAngle = stg.getAngle(enemy, player) - math.pi / 2 end
--       local function spawnBullets(speedMod)
--         local count = 9
--         local mod = math.pi / 20
--         angle = enemy.laserAngle - mod * math.floor(count / 2)
--         for i = 1, count do
--           stage.spawnBullet(function(bullet)
--             bullet.x = enemy.x
--             bullet.y = enemy.y
--             bullet.angle = angle
--             bullet.speed = 3 + speedMod * .5
--             bullet.type = 'bolt'
--           end)
--           angle = angle + mod
--         end
--       end
--       local limit = 4 * 3
--       if enemy.clock % limit == 0 then enemy.laserAngle = enemy.laserAngle + math.pi / 2 end
--       if enemy.clock % limit == 0 then
--         explosion.spawn({x = enemy.x, y = enemy.y, enemy = true})
--         for i = 1, 4 do
--           spawnBullets(i - 1)
--         end
--       end
--     end
--
--     stage.moveBoss(enemy, patternInterval, patternLimit)
--
--     if enemy.clock % patternInterval < patternLimit then
--       if enemy.clock % patternMax < patternInterval then ring()
--       elseif enemy.clock % patternMax >= patternInterval and enemy.clock % patternMax < patternInterval * 2 then blast()
--       elseif enemy.clock % patternMax >= patternInterval * 2 then lasers() end
--     end
--
--   end
--
--   local function patternThree(enemy)
--     local angleMax = math.pi
--     local angleMin = 0
--     if not enemy.flags.dookieAngle then
--       enemy.flags.dookieAngle = angleMin
--       enemy.flags.dookieDirection = true
--     end
--     local mod = math.pi / 12
--     angle = enemy.flags.dookieAngle - mod + mod * 2 * math.random()
--     stage.spawnBullet(function(bullet)
--       bullet.x = enemy.x
--       bullet.y = enemy.y
--       bullet.angle = angle
--       bullet.speed = 2.5 + math.random() * 1.75
--       bullet.type = 'big'; if math.random() < .5 then bullet.type = 'small' end
--     end)
--     local dookieMod = math.pi / 30
--     if not enemy.flags.dookieDirection then dookieMod = dookieMod * -1 end
--     enemy.flags.dookieAngle = enemy.flags.dookieAngle + dookieMod
--     if enemy.flags.dookieAngle >= angleMax then enemy.flags.dookieDirection = false
--     elseif enemy.flags.dookieAngle <= angleMin then enemy.flags.dookieDirection = true end
--     if enemy.clock % 15 == 0 then explosion.spawn({x = enemy.x, y = enemy.y, enemy = true}) end
--   end
--
--   stage.spawnEnemy(function(enemy)
--     enemy.x = stg.width / 2
--     enemy.y = -30
--     enemy.type = 'boss1'
--     enemy.speed = 2.675
--     enemy.angle = math.pi / 2
--     enemy.boss = true
--     enemy.rotation = 0
--     enemy.health = 150
--     enemy.xScale = 1
--     enemy.flags.rotateCount = 0
--     enemy.flags.hitSpellTwo = false
--     enemy.flags.hitSpellThree = false
--     enemy.flags.borderColor = stg.colors.blueDark
--     enemy.suicideFunc = function(enemy)
--       stage.killBullets = true
--     end
--   end, function(enemy)
--     stg.slowEntity(enemy, 0, .05)
--     stage.setupMoveBoss(enemy)
--     local currentPattern = patternOne
--     if enemy.health < enemy.maxHealth / 6 * 4 and enemy.health >= enemy.maxHealth / 6 * 2 then
--       currentPattern = patternTwo
--       if not enemy.flags.hitSpellTwo then
--         enemy.flags.hitSpellTwo = true
--         enemy.clock = -killBulletLimit
--         stage.killBullets = true
--       end
--     elseif enemy.health < enemy.maxHealth / 6 * 2 then
--       currentPattern = patternThree
--       if not enemy.flags.hitSpellThree then
--         enemy.flags.hitSpellThree = true
--         enemy.clock = -killBulletLimit
--         stage.killBullets = true
--       end
--     end
--     if enemy.clock >= 0 and enemy.flags.ready then currentPattern(enemy) end
--     enemy.rotation = math.sin(enemy.flags.rotateCount) / 60
--     enemy.flags.rotateCount = enemy.flags.rotateCount + .01
--   end)
--
--   nextWave = waveOne
-- end

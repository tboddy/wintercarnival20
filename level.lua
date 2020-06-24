-- https://www.youtube.com/watch?v=IWOhouJ7c04

-- stage 1 enemies length: 1:00
-- stage 1 boss length: 1:30
-- stage 2 enemies length: 1:00
-- stage 2 boss length: 1:30
-- stage 3 enemies length: 1:00
-- stage 3 boss length: 4:00

local killBulletLimit = 60
local waveClock = -10

local currentWave = 1

local function xStart(type, big)
  local mod = stage.images[type]:getWidth() / 2
  if big then mod = mod * 1.5 end
  return stg.width - stg.frameOffset * 2 + mod + stg.grid / 2
end

local waves = {

  -- function()
  -- end,

  function() -- boss 1

    local patterns = {

      function(enemy)
        local function rings()
          local count = 36
          local angleLimit = math.pi / 2 + math.pi / 6
          local angle = enemy.flags.bulletAngle - angleLimit
          explosion.spawn({x = enemy.flags.bulletPos.x, y = enemy.flags.bulletPos.y, big = true, type = 'red'})
          for i = 0, count do
            if angle <= enemy.flags.bulletAngle + angleLimit then
              stage.spawnBullet(function(bullet)
                bullet.x = enemy.flags.bulletPos.x
                bullet.y = enemy.flags.bulletPos.y
                bullet.angle = angle
                bullet.speed = 8
                bullet.type = 'arrowRed'
              end, function(bullet)
                if bullet.flags.flipped and bullet.speed < 6 then
                  bullet.speed = bullet.speed + .1
                elseif not bullet.flags.flipped then
                  stg.slowEntity(bullet, 0, .25)
                  if bullet.speed <= 0 then bullet.flags.flipped = true end
                end
              end)
            end
            angle = angle + math.tau / count
          end
          local speed = 30
          enemy.flags.bulletPos.x = enemy.flags.bulletPos.x + math.cos(enemy.flags.bulletAngle) * speed
          enemy.flags.bulletPos.y = enemy.flags.bulletPos.y + math.sin(enemy.flags.bulletAngle) * speed
        end
        local function burst()
          local function burstAngle()
            local limit = math.pi / 3
            local angle = math.tau * math.random()
            if angle >= limit and angle <= math.tau - limit then return angle
            else return burstAngle() end
          end
          for i = 1, 50 do
            stage.spawnBullet(function(bullet)
              bullet.x = enemy.x
              bullet.y = enemy.y
              bullet.top = true
              bullet.angle = burstAngle()
              bullet.speed = 5 + math.random() * 2
              if math.random() < .5 then bullet.type = 'big' else bullet.type = 'small' end
              bullet.flags.minSpeed = bullet.speed - 1
            end, function(bullet)
              stg.slowEntity(bullet, bullet.flags.minSpeed, .1)
            end)
          end
        end
        local interval = 10
        local limit = interval * 5
        local max = 60 * 1.5
        local top = 75
        if enemy.clock % max == 0 then
          enemy.flags.bulletPos = {x = enemy.x, y = enemy.y}
          enemy.flags.bulletAngle = math.pi
          enemy.flags.bulletAngle = stg.getAngle(enemy, player)
        end
        if enemy.clock % interval == 0 and enemy.clock % max < limit then rings() end
        if enemy.clock % max == top then burst() end
      end,

      function(enemy)
        local interval = 5
        local limit = interval * 6
        local max = 60 * 1.5
        local function bulletsA()
          if enemy.clock % max == 0 then
            enemy.flags.bulletAngleA = math.tau * math.random()
            enemy.flags.bulletAngleB = math.tau * math.random()
          end
          local function spawnBullets(opposite)
            local count = 15
            local angle = enemy.flags.bulletAngleA
            local y = stg.grid * 5
            if opposite then
              y = stg.height - y
              angle = enemy.flags.bulletAngleB
            end
            explosion.spawn({x = enemy.x - stg.grid, y = y, big = true})
            for i = 1, count do
              stage.spawnBullet(function(bullet)
                bullet.x = enemy.x - stg.grid
                bullet.y = y
                bullet.angle = angle
                bullet.speed = 5
                bullet.type = 'arrow'
              end)
              angle = angle + math.tau / count
            end
            local mod = math.phi
            enemy.flags.bulletAngleB = enemy.flags.bulletAngleB + mod
            enemy.flags.bulletAngleA = enemy.flags.bulletAngleA - mod
          end
          if enemy.clock % interval == 0 and enemy.clock % max < limit then spawnBullets(enemy.clock % (max * 2) >= max) end
        end
        local function bulletsB()
          if enemy.clock % max == limit then
            enemy.flags.bulletAngleC = math.tau * math.random()
            enemy.flags.bulletAngleD = math.tau * math.random()
          end
          local function spawnBullets(opposite)
            local count = 11
            local angle = enemy.flags.bulletAngleC
            local y = stg.grid * 10
            if opposite then
              y = stg.height - y
              angle = enemy.flags.bulletAngleD
            end
            explosion.spawn({x = enemy.x, y = y, type = 'red', big = true})
            for i = 1, count do
              stage.spawnBullet(function(bullet)
                bullet.x = enemy.x
                bullet.y = y
                bullet.angle = angle
                bullet.speed = 6
                bullet.type = 'arrowRed'
                bullet.top = true
              end)
              angle = angle + math.tau / count
            end
            local mod = math.phi * 2
            enemy.flags.bulletAngleC = enemy.flags.bulletAngleC + mod
            enemy.flags.bulletAngleD = enemy.flags.bulletAngleD - mod
          end
          if enemy.clock % interval == 0 and enemy.clock % max >= max / 2 + interval and enemy.clock % max < max + limit then spawnBullets(enemy.clock % (max * 2) >= limit + max) end
        end
        bulletsA()
        bulletsB()
      end

    }

    local function spawnEnemy()
      stage.spawnEnemy(function(enemy)
        enemy.type = 'mamizou'
        enemy.x = xStart(enemy.type)
        enemy.y = stg.height / 2
        enemy.angle = math.pi
        enemy.health = 100
        enemy.boss = true
        enemy.offset = 0
        enemy.speedS = 3.5
        enemy.flags.currentPattern = 1
        enemy.suicideFunc = function()
          stage.killBullets = true
          stage.bossHealth = 0
          stage.bossMaxHealth = 0
        end
      end, function(enemy)
        if enemy.speed <= 0 then
          stage.bossMaxHealth = enemy.maxHealth
          stage.bossHealth = enemy.health
          enemy.speed = 0
          if not enemy.flags.ready then enemy.flags.ready = true end

          -- 10 * 2
          local max = 60 * 6
          local limit = 60 * 4.5
          if enemy.clock % max == 0 and enemy.clock > 0 then
            enemy.flags.currentPattern = enemy.flags.currentPattern + 1
            if enemy.flags.currentPattern > #patterns then enemy.flags.currentPattern = 1 end
          end
          -- print(enemy.clock)
          if enemy.clock % max < limit then patterns[enemy.flags.currentPattern](enemy) end
          local moveInterval = 60
          if enemy.clock % max == max - moveInterval then
            if enemy.flags.currentPattern == 1 then
              enemy.flags.moveTarget = {x = stg.gameWidth - stg.grid * 5.75 + 2, y = stg.height / 2}
              enemy.flags.moveAngle = stg.getAngle(enemy, enemy.flags.moveTarget)
            else stage.placeEnemy(enemy) end
          end
          if enemy.clock % max >= max - moveInterval then stage.moveEnemy(enemy) end

          -- local interval = 60 * 5
          -- local limit = 60
          -- local max = interval * #patterns
          -- if enemy.clock % max >= interval and enemy.clock % max < interval * 2 then pattern = 2
          -- elseif enemy.clock % max >= interval * 2 and enemy.clock % max < interval * 3 then pattern = 3
          -- elseif enemy.clock % max >= interval * 3 then pattern = 4 end
          -- if enemy.clock % interval < interval - limit then patterns[pattern](enemy) end
          -- patterns[1](enemy)
          -- print(enemy.clock)
        else
          enemy.clock = -1
          enemy.health = enemy.maxHealth
          enemy.speed = enemy.speed - .05
        end
      end)
    end

    spawnEnemy()
    -- currentWave = 1
  end,




  
  -- https://www.youtube.com/watch?v=8sjaSoQG7aA

  -- stage 1

  function()
    local function spawnBullets(enemy)
      local mod = math.pi / 60
      local angle = stg.getAngle(enemy, player) - mod
      for i = 1, 3 do
        stage.spawnBullet(function(bullet)
          bullet.x = enemy.x
          bullet.y = enemy.y
          bullet.angle = angle 
          bullet.type = 'arrow'
          bullet.speed = 5
          if i == 2 then bullet.speed = bullet.speed + .5 end
        end)
        angle = angle + mod
      end
    end
    local function spawnCenterBullets(enemy)
      local mod = math.pi / 10
      local count = 10
      local angle = stg.getAngle(enemy, player) - count * mod / 2
      for i = 1, count do
        stage.spawnBullet(function(bullet)
          bullet.x = enemy.x
          bullet.y = enemy.y
          bullet.angle = angle 
          bullet.type = 'arrowRed'
          bullet.speed = 4
        end)
        angle = angle + mod
      end
    end
    local function spawnSideEnemy(offset, opposite)
      stage.spawnEnemy(function(enemy)
        enemy.type = 'beerlight'
        enemy.x = xStart(enemy.type)
        enemy.y = stg.grid * 6
        enemy.angle = math.pi
        enemy.health = 2
        enemy.offset = offset * 30
        enemy.speedS = 3.75
        enemy.flags.angleMod = math.pi / (180 * 4)
        local shootNum = offset - 2
        if opposite then
          enemy.y = stg.height - enemy.y
          enemy.flags.angleMod = -enemy.flags.angleMod
        end
        if shootNum % 5 == 0 then
          enemy.flags.shooter = true
        end
      end, function(enemy)
        if enemy.clock >= 30 and enemy.clock < 90 then enemy.angle = enemy.angle - enemy.flags.angleMod end
        if enemy.flags.shooter and enemy.clock == 60 then spawnBullets(enemy) end
        if enemy.clock < 60 then enemy.speed = enemy.speed - .025 end
      end)
    end
    local function spawnCenterEnemy()
      stage.spawnEnemy(function(enemy)
        enemy.type = 'beerdark'
        enemy.x = xStart(enemy.type, true)
        enemy.y = stg.height / 2
        enemy.angle = math.pi
        enemy.offset = 60 * 3
        enemy.speedS = 1.75
        enemy.big = true
        enemy.health = 5
        enemy.flags.start = enemy.angle
        enemy.flags.diff = math.pi / 90
        enemy.flags.mod = 0
      end, function(enemy)
        local interval = 90
        -- if enemy.clock < interval then enemy.speed = enemy.speed - .025 end
        if enemy.clock % interval == interval / 2 and enemy.clock <= interval * 2 then spawnCenterBullets(enemy) end
        enemy.angle = enemy.flags.start + math.cos(enemy.flags.mod) / 2
        enemy.flags.mod = enemy.flags.mod + enemy.flags.diff
      end)
    end
    local function spawnEnemies()
      local count = 20
      for i = 1, count do
        if (i - 1) % 5 < 4 and i < count - 5 then spawnSideEnemy(i - 1, (i - 1) % (count / 2) < count / 4) end
      end
      spawnCenterEnemy()
    end
    spawnEnemies()
    currentWave = currentWave + 1
  end,

  function()
    local function spawnBullets(enemy)
      local mod = math.pi / 60
      local angle = stg.getAngle(enemy, player) - mod
      for i = 1, 5 do
        stage.spawnBullet(function(bullet)
          bullet.x = enemy.x
          bullet.y = enemy.y
          bullet.angle = angle 
          bullet.type = 'arrow'
          bullet.speed = 5
          if i == 2 or i == 4 then bullet.speed = bullet.speed + .25
          elseif i == 3 then bullet.speed = bullet.speed + .5 end
        end)
        angle = angle + mod
      end
    end
    local function spawnCenterBullets(enemy)
      local mod = math.pi / 13
      local count = 13
      local angle = stg.getAngle(enemy, player) - count * mod / 2
      for i = 1, count do
        stage.spawnBullet(function(bullet)
          bullet.x = enemy.x
          bullet.y = enemy.y
          bullet.angle = angle 
          bullet.type = 'arrowRed'
          bullet.speed = 4
        end)
        angle = angle + mod
      end
    end
    local function spawnSideEnemy(offset, opposite)
      stage.spawnEnemy(function(enemy)
        enemy.type = 'beerlight'
        enemy.x = xStart(enemy.type)
        enemy.y = stg.grid * 7.5
        enemy.offset = offset * 30
        enemy.speedS = 2
        enemy.health = 3
        enemy.angle = math.pi
        enemy.flags.start = enemy.angle
        enemy.flags.diff = math.pi / 90
        enemy.flags.mod = 0
        if opposite then enemy.y = stg.height - enemy.y end
        if offset % 5 == 2 then enemy.flags.shooter = true end
      end, function(enemy)
        enemy.angle = enemy.flags.start + math.cos(enemy.flags.mod) / 2
        enemy.flags.mod = enemy.flags.mod + enemy.flags.diff
        if enemy.flags.shooter then
          local interval = 60
          if enemy.clock == interval then spawnBullets(enemy) end
        end
      end)
    end
    local function spawnCenterEnemy()
      stage.spawnEnemy(function(enemy)
        enemy.type = 'beerdark'
        enemy.x = xStart(enemy.type, true)
        enemy.y = stg.height / 2
        enemy.big = true
        enemy.angle = math.pi
        enemy.offset = 70
        enemy.speedS = 2.5
        enemy.health = 5
      end, function(enemy)
        local interval = 90
        if enemy.clock < interval then enemy.speed = enemy.speed - .013 end
        if enemy.clock % interval == interval / 2 and enemy.clock <= interval * 2 then spawnCenterBullets(enemy) end
      end)
    end
    local function spawnEnemies()
      local count = 5 * 2
      for i = 1, count do
        spawnSideEnemy(i - 1, i > count / 2)
      end
      spawnCenterEnemy()
    end
    spawnEnemies()
    currentWave = currentWave + 1
  end, 

  function() -- :45-ish
    local function ball(enemy)
      local angle = stg.getAngle(enemy, player)
      local bAngle = math.tau * math.random()
      local count = 5
      local diff = stg.grid * 1.75
      for i = 1, count do
        stage.spawnBullet(function(bullet)
          bullet.x = enemy.x + math.cos(bAngle) * diff
          bullet.y = enemy.y + math.sin(bAngle) * diff
          bullet.angle = angle 
          bullet.type = 'big'
          bullet.top = true
          bullet.speed = 5
        end)
        bAngle = bAngle + math.tau / count
      end
    end
    local function ring(enemy)
      local count = 13
      local angle = enemy.flags.ringMod
      for i = 1, count do
        if angle % math.tau >= math.pi / 2 and angle % math.tau <= math.pi * 1.5 then
          stage.spawnBullet(function(bullet)
            bullet.x = enemy.x
            bullet.y = enemy.y
            bullet.angle = angle
            bullet.type = 'arrowRed'
            bullet.speed = 4
          end)
        end
        angle = angle + math.tau / count
      end
      local mod = math.phi
      if enemy.flags.ringDir then mod = -mod end
      enemy.flags.ringMod = enemy.flags.ringMod + mod
    end
    local function spawnEnemy(opposite)
      stage.spawnEnemy(function(enemy)
        enemy.type = 'winered'
        enemy.x = xStart(enemy.type, true)
        enemy.y = stg.grid * 8
        enemy.big = true
        enemy.angle = math.pi
        enemy.offset = 0
        enemy.speedS = 6.5
        enemy.health = 25
        enemy.flags.ringMod = 0
        if opposite then
          enemy.y = stg.height - enemy.y
          enemy.offset = 120
          enemy.flags.ringDir = true
        end
      end, function(enemy)
        if enemy.flags.done then
          if enemy.clock < 60 then
            enemy.speed = enemy.speed + .04
            local angleMod = math.pi / 220
            if enemy.flags.ringDir then angleMod = -angleMod end
            enemy.angle = enemy.angle + angleMod
          end
        elseif enemy.flags.flipped then
          local ballInterval = 75
          if enemy.clock % ballInterval == 0 then ball(enemy) end
          local ringStart = 50 * 2
          local ringInterval = 20
          local ringLimit = ringInterval * 3
          local ringMax = 100
          if enemy.clock >= ringStart and enemy.clock % ringInterval == 0 and enemy.clock % ringMax < ringLimit then ring(enemy) end
          if enemy.clock >= ringMax * 3.75 then
            enemy.flags.done = true
            enemy.clock = -1
          end
        elseif enemy.speed <= 0 then
          enemy.speed = 0
          enemy.flags.flipped = true
          enemy.clock = -1
        else enemy.speed = enemy.speed - .125 end
      end)
    end
    local function spawnEnemies()
      spawnEnemy()
      spawnEnemy(true)
    end
    spawnEnemies()
    currentWave = currentWave + 1
  end,

  function()
    local function spawnBullets(enemy)
      local angle = stg.getAngle(enemy, player)
      local bAngle = angle + math.pi / 2
      local diff = stg.grid * 1.5
      for i = 1, 2 do
        stage.spawnBullet(function(bullet)
          bullet.x = enemy.x + math.cos(bAngle) * diff
          bullet.y = enemy.y + math.sin(bAngle) * diff
          bullet.angle = angle
          bullet.type = 'arrow'
          bullet.speed = 4
        end)
        bAngle = bAngle + math.pi
      end
    end
    local function spawnEnemy(offset, column)
      local colMod = 30
      stage.spawnEnemy(function(enemy)
        enemy.type = 'beerlight'
        enemy.x = xStart(enemy.type)
        enemy.y = stg.grid * 7 + stg.grid * 8 * offset
        enemy.angle = math.pi
        enemy.offset = offset * colMod + column * 45 * 3
        enemy.speedS = 3
        enemy.health = 3
      end, function(enemy)
        local speed = 2
        if enemy.speed > speed then
          enemy.speed = enemy.speed - .025
          enemy.clock = -1
        else
          enemy.speed = speed
          local interval = 90
          if enemy.clock % interval == 0 and enemy.clock < interval * 2 then spawnBullets(enemy) end
        end
      end)
    end
    local function spawnEnemies()
      local count = 3
      for i = 1, count do
        spawnEnemy(i - 1, 0)
        spawnEnemy(i - 1, 1)
      end
    end
    spawnEnemies()
    currentWave = currentWave + 1
  end,

  function() -- 1:05-ish
    local function burst(enemy, opposite)
      local function spawnBullets()
        local count = 10
        if opposite then
          count = 15
        end
        local mod = math.pi / count
        local angle = math.pi - count * mod / 2
        for i = 1, count do
          stage.spawnBullet(function(bullet)
            bullet.x = enemy.x
            bullet.y = enemy.y
            bullet.angle = angle 
            bullet.type = 'arrowRed'
            bullet.speed = 4
            if opposite then
              bullet.type = 'arrow'
              bullet.speed = 5
            end
          end)
          angle = angle + mod
        end
      end
      local interval = 60
      if enemy.clock % interval == 0 and enemy.clock < interval * 2 then spawnBullets() end
    end
    local function spawnEnemy(xOffset, yOffset, opposite)
      stage.spawnEnemy(function(enemy)
        enemy.type = 'martini'
        enemy.x = xStart(enemy.type, true)
        enemy.y = stg.grid * 8
        enemy.angle = math.pi
        enemy.offset = xOffset * 60
        if yOffset == 1 then enemy.y = stg.height / 2
        elseif yOffset == 2 then enemy.y = stg.height - enemy.y end
        if opposite then enemy.opposite = true end
        enemy.speedS = 5
        enemy.health = 5
      end, function(enemy)
        local speed = 1.75
        if enemy.speed > speed then
          enemy.speed = enemy.speed - .08
          enemy.clock = -1
        else
          enemy.speed = speed
          if enemy.opposite then burst(enemy, true)
          else burst(enemy) end
        end
      end)
    end
    local function spawnEnemies()
      spawnEnemy(0, 0)
      spawnEnemy(1, 2)
      spawnEnemy(2, 1, true)
      spawnEnemy(3, 0)
      spawnEnemy(4, 2)
    end
    spawnEnemies()
    -- currentWave = currentWave + 1
  end,

  function()
  end,























  function()

  end,

}

local function update()
  if stage.enemyCount == 0 then
    if waveClock == 0 then
      waves[currentWave]()
      waveClock = -30
    else waveClock = waveClock + 1 end
  end
end











local patternsNext = {

  function(enemy)
    local function ring()
      local function spawnBullets(opposite)
        local angle = enemy.flags.ringAngle
        local count = 30
        local mod = 2
        for i = 1, count do
          -- print(math.cos(angle))
          local diff = math.cos(angle * mod)
          if opposite then diff = math.cos((angle + math.pi / 2) * mod) end
          stage.spawnBullet(function(bullet)
            bullet.x = enemy.x
            bullet.y = enemy.y
            bullet.angle = angle
            bullet.speed = 8 - diff
            bullet.type = 'big'
          end)
          angle = angle + math.tau / count
        end
        enemy.flags.ringAngle = enemy.flags.ringAngle + math.phi
      end
      local interval = 25
      if enemy.clock % interval == 0 then
        if not enemy.flags.ringAngle then enemy.flags.ringAngle = 0 end
        spawnBullets(enemy.clock % (interval * 2) == 0)
      end
    end
    local function arrows()
      local function spawnBullets()
        local count = 5
        local diff = math.pi / 35
        local angle = enemy.arrowAngle - diff * math.floor(count / 2)
        local speed = 7
        for i = 1, count do
          stage.spawnBullet(function(bullet)
            bullet.x = enemy.x
            bullet.y = enemy.y
            bullet.angle = angle
            bullet.speed = speed
            bullet.type = 'arrowRed'
            bullet.top = true
          end)
          angle = angle + diff
          local mod = 1.25
          if i > math.floor(count / 2) then speed = speed - mod
          else speed = speed + mod end
        end
        enemy.arrowAngle = enemy.arrowAngle - math.pi / 8

      end

      local interval = 15
      local limit = interval * 4
      local max = limit * 1.5
      if enemy.clock % interval == 0 and enemy.clock % max < limit then 
        if enemy.clock % max == 0 then enemy.arrowAngle = math.tau * (.75 - .125 * 1.25) end -- LMAO
        spawnBullets()
      end
    end
    ring()
    arrows()
  end,

  function(enemy)
    local function spawnBullets()
      -- local x = stg.width / 4 * 3 + (stg.width / 4 - stg.grid) * math.random()
      local xMod = stg.grid * 6
      local x = enemy.x - xMod + xMod * math.random()
      local y = (stg.height - stg.grid * 2) * math.random() + stg.grid
      local count = 10
      local angle = math.tau * math.random()
      explosion.spawn({x = x, y = y, big = true})
      for i = 1, count do
        stage.spawnBullet(function(bullet)
          bullet.x = x
          bullet.y = y
          bullet.angle = angle
          bullet.speed = 9
          bullet.top = true
          bullet.type = 'arrow'
        end, function(bullet)
          stg.slowEntity(bullet, 6, .1)
        end)
        angle = angle + math.tau / count
      end
    end
    local interval = 6
    if enemy.clock % interval == 0 then spawnBullets() end
  end,

  function(enemy)
    local function sides()
      local function spawnBullets(opposite, second)
        local y = stg.grid * 3
        local count = 3
        local mod = math.pi / 8
        local angle = math.pi - mod
        if second then
          count = 4
          angle = angle - mod / 2
        end
        if opposite then y = stg.height - y end
        explosion.spawn({x = enemy.x, y = y, type = 'red', big = 'true'})
        for i = 1, count do
          stage.spawnBullet(function(bullet)
            bullet.x = enemy.x
            bullet.y = y
            bullet.angle = angle
            bullet.speed = 8
            bullet.top = true
            bullet.type = 'arrowRed'
          end)
          angle = angle + mod
        end
      end
      local interval = 5
      local limit = interval * 3
      local max = limit * 2
      if enemy.clock % interval == 0 and enemy.clock % max < limit then
        spawnBullets(false, enemy.clock % (max * 2) >= limit)
        spawnBullets(true, enemy.clock % (max * 2) >= limit)
      end
    end
    local function spray()
      -- if enemy.clock % 2 == 0 then
        stage.spawnBullet(function(bullet)
          bullet.x = enemy.x
          bullet.y = enemy.y
          bullet.angle = math.tau * math.random()
          bullet.speed = 7 + math.random() * 4
          if math.random() < .5 then bullet.type = 'big' else bullet.type = 'small' end
          bullet.flags.minSpeed = bullet.speed - 4
        end, function(bullet)
          stg.slowEntity(bullet, bullet.flags.minSpeed, .1)
        end)
      -- end
    end
    sides()
    spray()
  end,

  function(enemy)
    local function lasers()
      local function spawnBullets(opposite)
        local count = 20
        local angle = math.pi / 2
        if opposite then angle = angle + math.pi / count end
        local function spawnBullet()
          stage.spawnBullet(function(bullet)
            bullet.x = enemy.x
            bullet.y = enemy.y
            bullet.angle = angle
            bullet.speed = 10
            bullet.type = 'arrow'
          end)
          angle = angle + math.tau / count
        end
        for i = 1, count do spawnBullet() end
      end
      local limit = 40
      if enemy.clock % limit <= 16 and enemy.clock % 4 == 0 then spawnBullets(enemy.clock % (limit * 2) >= limit) end
    end
    local function spray()
      local function spawnBullets()
        local count = 40
        local function spawnBullet()
          stage.spawnBullet(function(bullet)
            bullet.x = enemy.x
            bullet.y = enemy.y
            bullet.angle = math.tau * math.random()
            bullet.speed = 4 + math.random() * 3
            bullet.type = 'bigRed'; if math.random() < .5 then bullet.type = 'smallRed' end
            bullet.top = true
          end)
        end
        for i = 1, count do spawnBullet() end
      end
      local interval = 30
      if enemy.clock % interval == 0 then spawnBullets() end
    end
    lasers()
    spray()
  end,

  function(enemy)
    if not enemy.flags.ringAngleA then
      enemy.flags.ringAngleA = 0
      enemy.flags.ringAngleB = 0
    end
    local function spawnBullets(opposite) 
      local count = 25
      local angle = enemy.flags.ringAngleA; if opposite then angle = enemy.flags.ringAngleB end
      local angleLimit = math.pi / 5 * 2
      for i = 1, count do
        if angle % math.tau >= angleLimit and angle % math.tau <= math.tau - angleLimit then
          stage.spawnBullet(function(bullet)
            bullet.x = enemy.x
            bullet.y = enemy.y
            bullet.angle = angle
            bullet.speed = 7
            bullet.type = 'arrow'
            if opposite then
              bullet.type = 'arrowRed'
              bullet.top = true
            end
          end)
        end
        angle = angle + math.tau / count
      end
    end
    local interval = 10
    if enemy.clock % interval == 0 then
      spawnBullets(enemy.clock % (interval * 3) == 0)
      local mod = math.pi / 60
      enemy.flags.ringAngleA = enemy.flags.ringAngleA + mod
      enemy.flags.ringAngleB = enemy.flags.ringAngleB - mod
    end
  end,

  function(enemy)
    local function spawnBullets(opposite)
      local y = stg.grid * 3.5
      local count = 20
      local angle = enemy.flags.bulletAngle
      local explosionObj = {x = enemy.x, y = y, big = true}
      if opposite then
        y = stg.height - y
        angle = -angle
        explosionObj.type = 'red'
        explosionObj.y = y
      end
      explosion.spawn(explosionObj)
      local angleLimit = math.pi / 5 * 2
      for i = 1, count do
        if angle % math.tau >= angleLimit and angle % math.tau <= math.tau - angleLimit then
          stage.spawnBullet(function(bullet)
            bullet.x = enemy.x
            bullet.y = y
            bullet.angle = angle
            bullet.speed = 7
            bullet.type = 'arrow'
            if opposite then bullet.type = 'arrowRed' end
          end)
        end
        angle = angle + math.tau / count
      end
    end
    local interval = 5
    local limit = interval * 3
    local max = interval * 6
    if not enemy.flags.bulletAngle then enemy.flags.bulletAngle = 0 end
    if enemy.clock % interval == 0 and enemy.clock % max < limit then
      spawnBullets()
      spawnBullets(true)
      enemy.flags.bulletAngle = enemy.flags.bulletAngle + .0125
    end
  end,

  function(enemy)
    local function spawnBullets(opposite)
      local angle = enemy.flags.bulletAngle
      local count = 20
      local expObj = {x = enemy.flags.bulletPos.x, y = enemy.flags.bulletPos.y, big = true}
      if opposite then expObj.type = 'red' end
      explosion.spawn(expObj)
      for i = 1, count do
        stage.spawnBullet(function(bullet)
          bullet.x = enemy.flags.bulletPos.x
          bullet.y = enemy.flags.bulletPos.y
          bullet.angle = angle
          bullet.speed = 4
          bullet.type = 'big'
          if opposite then
            bullet.flags.opposite = true
            bullet.speed = 2
            bullet.type = 'bigRed'
            bullet.top = true
          end
        end, function(bullet)
          if bullet.speed > -8 then
            bullet.speed = bullet.speed - .1
          end
          local mod = math.pi / (360 + 90)
          if bullet.flags.opposite then
            mod = mod * -1
          end
          bullet.angle = bullet.angle + mod
        end)
        angle = angle + math.tau / count
      end
      local speed = stg.grid * 1.5
      enemy.flags.bulletPos.x = enemy.flags.bulletPos.x + math.cos(enemy.flags.bulletTarget) * speed
      enemy.flags.bulletPos.y = enemy.flags.bulletPos.y + math.sin(enemy.flags.bulletTarget) * speed
    end
    local interval = 5
    local limit = interval * 6
    local max = limit
    if enemy.clock % max == 0 then
      enemy.flags.bulletAngle = math.tau * math.random()
      enemy.flags.bulletPos = {x = enemy.x, y = stg.grid * 3}
      if enemy.clock % (max * 2) == max then enemy.flags.bulletPos.y = stg.height - enemy.flags.bulletPos.y end
      enemy.flags.bulletTarget = stg.getAngle(enemy.flags.bulletPos, {x = 0, y = stg.height / 2})
    end
    if enemy.clock % interval == 0 and enemy.clock % max < limit then spawnBullets(enemy.clock % (max * 2) >= max) end
  end,

  function(enemy)
    local function randomAngle()
      local angleLimit = math.pi / 4
      local angle = math.tau * math.random()
      if angle % math.tau >= angleLimit and angle % math.tau <= math.tau - angleLimit then
        return angle
      else return randomAngle() end
    end
    local function spawnBullet(opposite)
        stage.spawnBullet(function(bullet)
          bullet.x = enemy.x
          bullet.y = enemy.y
          bullet.angle = randomAngle()
          bullet.speed = 10
          bullet.top = true
          if opposite then bullet.type = 'pill' else bullet.type = 'arrowRed' end
        end, function(bullet)
          stg.slowEntity(bullet, 7, .1)
        end)
    end
    local limit = 60
    local max = limit * 2.5
    if enemy.clock % max < limit * 2 then
      for i = 1, 3 do spawnBullet(enemy.clock % max >= limit) end
    end
  end,

  function(enemy)
    local function burst()
      local function randomAngle()
        local angleLimit = math.pi / 4
        local angle = math.tau * math.random()
        if angle % math.tau >= angleLimit and angle % math.tau <= math.tau - angleLimit then
          return angle
        else return randomAngle() end
      end
      local function spawnBullet()
        stage.spawnBullet(function(bullet)
          bullet.x = enemy.x
          bullet.y = enemy.y
          bullet.angle = randomAngle()
          bullet.speed = 6 + math.random() * 2
          bullet.top = true
          bullet.type = 'bigRed'
        end)
      end
      spawnBullet()
      spawnBullet()
    end
    local function ring()
      local angleLimit = math.pi / 3
      local function spawnBullets()
        local angle = enemy.flags.bulletAngle
        local count = 25
        for i = 1, count do
          if angle % math.tau >= angleLimit and angle % math.tau <= math.tau - angleLimit then
            stage.spawnBullet(function(bullet)
              bullet.x = enemy.x
              bullet.y = enemy.y
              bullet.angle = angle
              bullet.speed = 7
              bullet.top = true
              bullet.type = 'arrow'
            end)
          end
          angle = angle + math.tau / count
        end
        enemy.flags.bulletAngle = enemy.flags.bulletAngle + math.pi / count + .01
      end
      local interval = 5
      if enemy.clock % interval == 0 then spawnBullets() end
    end
    local limit = 60
    local max = limit * 3
    if enemy.clock % max == 0 then enemy.flags.bulletAngle = math.pi / 2 end
    if enemy.clock % max < limit then burst()
    elseif enemy.clock % max >= limit and enemy.clock % max < limit * 2 then ring() end
  end,

  function(enemy)
    local function spawnBulletsA(opposite)
      local x = enemy.x
      local y = stg.grid * 3
      if opposite then y = stg.height - y end
      local angle = math.tau * math.random()
      local count = 20
      for i = 1, count do
        stage.spawnBullet(function(bullet)
          bullet.x = x
          bullet.y = y
          bullet.angle = angle
          bullet.speed = 6
          bullet.type = 'bigRed'
        end)
        angle = angle + math.tau / count
      end
      explosion.spawn({x = x, y = y, big = true, type = 'red'})
    end

    local function spawnBulletsB()
      local x = enemy.x - stg.grid
      local y = (stg.height - stg.grid * 6) * math.random() + stg.grid * 3
      local angle = math.tau * math.random()
      local count = 9
      for i = 1, count do
        stage.spawnBullet(function(bullet)
          bullet.x = x
          bullet.y = y
          bullet.angle = angle
          bullet.speed = 10
          bullet.top = true
          bullet.type = 'arrow'
          bullet.flags.pos = {x = x, y = y}
        end, function(bullet)
          if not bullet.flags.flipped then
            stg.slowEntity(bullet, 0, .25)
            if bullet.speed <= 0 then
              bullet.angle = stg.getAngle(bullet.flags.pos, player)
              bullet.speed = 5
              bullet.flags.flipped = true
            end
          end
        end)
        angle = angle + math.tau / count
      end
      explosion.spawn({x = x, y = y, big = true})
    end

    local interval = 16
    if enemy.clock % interval == 0 then
      if enemy.clock % (interval * 2) == 0 then spawnBulletsA(enemy.clock % (interval * 4) == 0)
      else spawnBulletsB() end
    end
  end,

  function(enemy)
    local function ring()
      local count = 5
      local function spawnBullets(opposite)
        local angle = enemy.flags.bulletAngleA; if opposite then angle = enemy.flags.bulletAngleB end
        for i = 1, count do
          stage.spawnBullet(function(bullet)
            bullet.x = enemy.x
            bullet.y = enemy.y
            bullet.angle = angle
            bullet.speed = 7
            bullet.type = 'arrowRed'
          end)
          angle = angle + math.tau / count
        end
      end
      spawnBullets()
      spawnBullets(true)
      local mod = math.pi / 15
      local limit = 60 * 3
      if enemy.clock % limit >= limit / 2 then mod = mod * .5 end
      enemy.flags.bulletAngleA = enemy.flags.bulletAngleA + mod
      enemy.flags.bulletAngleB = enemy.flags.bulletAngleB - mod
    end
    local function burst()
        stage.spawnBullet(function(bullet)
          bullet.x = enemy.x
          bullet.y = enemy.y
          bullet.angle = math.tau * math.random()
          bullet.speed = 4 + math.random() * 3
          bullet.type = 'big'; if math.random() < .5 then bullet.type = 'small' end
          bullet.top = true
        end)
    end
    if enemy.clock == 0 then
      enemy.flags.bulletAngleA = 0
      enemy.flags.bulletAngleB = 0
    end
    local interval = 5
    local bInterval = 15
    if enemy.clock % interval == 0 then ring() end
    burst()
  end,

  function(enemy)
    local function spawnBullets()
      local angle = enemy.flags.bulletAngle
      local count = 15
      for i = 1, count do
        stage.spawnBullet(function(bullet)
          bullet.x = enemy.x
          bullet.y = enemy.y
          bullet.angle = angle
          bullet.speed = 10
          bullet.type = 'arrow'
        end, function(bullet)
          stg.slowEntity(bullet, 7, .25)
        end)
        angle = angle + math.tau / count
      end
      enemy.flags.bulletAngle = enemy.flags.bulletAngle + enemy.flags.bulletMod
      enemy.flags.bulletMod = enemy.flags.bulletMod + enemy.flags.bulletModVar
    end
    if enemy.clock == 0 then
      enemy.flags.bulletAngle = 0
      enemy.flags.bulletMod = 0
      enemy.flags.bulletModVar = math.pi / 150
    end
    local interval = 6
    if enemy.clock % interval == 0 then spawnBullets() end
  end,

  function(enemy)
    local function spawnBullets(offset)
      local mod = math.pi / 3
      local y = stg.height / 5
      y = y + y * offset
      local angle = stg.getAngle({x = enemy.x, y = y}, player)
      explosion.spawn({x = enemy.x, y = y, big = true, type = 'red'})

      local function spawnBullet(faster, bigger)
        local bMod = mod
        if faster then bMod = bMod / 2
        elseif bigger then bMod = 0 end
        local bAngle = angle - bMod / 2
        local cAngle = bAngle + bMod * math.random()
        local cSpeed = 7 + math.random() * 2
        local circleAngle = math.pi * math.random()
        local function spawnBBullet(circleMod)
          local bX = enemy.x
          local bY = y
          if circleMod then
            local cMod = 52
            bX = bX + math.cos(circleAngle) * cMod
            bY = bY + math.sin(circleAngle) * cMod
          end
          stage.spawnBullet(function(bullet)
            bullet.x = bX
            bullet.y = bY
            bullet.angle = cAngle
            bullet.speed = cSpeed
            bullet.type = 'arrow'
            if faster then bullet.speed = bullet.speed + 1
            elseif bigger then
              bullet.speed = bullet.speed - 1.5
              bullet.top = true
              bullet.type = 'bigRed'
            end
            bullet.flags.speed = bullet.speed - 1
          end, function(bullet)
            stg.slowEntity(bullet, bullet.flags.speed, .25)
          end)
        end
        if bigger then
          local count = 14
          for i = 1, count do
            spawnBBullet(i)
            circleAngle = circleAngle + math.tau / count
          end
        else
          spawnBBullet()
        end
      end

      for i = 1, 6 do spawnBullet() end
      for i = 1, 6 do spawnBullet(true) end
      for i = 1, 1 do spawnBullet(false, true) end
    end
    local interval = 30
    local limit = interval * 4
    local max = interval * 5
    if enemy.clock % interval == 0 and enemy.clock % max < limit then spawnBullets(enemy.clock % max / interval) end
  end

}






return {
  update = update
}
-- https://www.youtube.com/watch?v=IWOhouJ7c04

local killBulletLimit = 60
local waveClock = -10

local currentWave = 2

local xStart = stg.width - stg.frameOffset + stg.grid

local waves = {

  function()

    local function spawnEnemies()

      local function spawnBullets(enemy, mod)
        local angleMod = math.pi / 9
        local angle = enemy.angle - angleMod
        for i = 1, 3 do
          stage.spawnBullet(function(bullet)
            bullet.x = enemy.x
            bullet.y = enemy.y
            bullet.angle = angle
            bullet.type = 'bigRed'
            bullet.speed = 6
            bullet.flags.mod = mod
          end, function(bullet)
            if bullet.clock < bullet.flags.mod then
              bullet.speed = bullet.speed + .5
            end
          end)
          angle = angle + angleMod
        end
      end

      local function spawnEnemy(xOffset, opposite)
        stage.spawnEnemy(function(enemy)
          enemy.type = 'beerlight'
          enemy.x = xStart + stg.grid * 3 * xOffset
          enemy.y = stg.grid * 5
          enemy.speed = 5
          enemy.angle = math.pi
          enemy.health = 5
          enemy.flags.mod = math.pi / (360 * 2)
          if opposite then
            enemy.y = stg.height - enemy.y
            enemy.flags.mod = enemy.flags.mod * -1
            enemy.x = enemy.x + stg.grid * 10
          end
        end, function(enemy)
          local limit = 2
          stg.slowEntity(enemy, limit, .05)
          if enemy.speed > limit then
            enemy.angle = enemy.angle - enemy.flags.mod
            enemy.flags.shotClock = -1
          elseif enemy.speed >= limit then
            local interval = 30
            local bInterval = 3
            local bMax = bInterval * 5
            local max = interval * 3
            if enemy.flags.shotClock < max and
              enemy.flags.shotClock % interval < interval / 2 and
              enemy.flags.shotClock % bInterval == 0 then
              spawnBullets(enemy, enemy.flags.shotClock % bMax / bInterval) end
            enemy.flags.shotClock = enemy.flags.shotClock + 1
          end
        end)
      end

      for i = 1, 4 do
        spawnEnemy(i)
        spawnEnemy(i, true)
      end

    end
    spawnEnemies()
    currentWave = 2
  end,

  function()

    local patterns = {

      function(enemy)
        local function rings()
          local count = 30
          local angle = enemy.flags.bulletAngle
          explosion.spawn({x = enemy.flags.bulletPos.x, y = enemy.flags.bulletPos.y, big = true, type = 'red'})
          for i = 0, count do
            stage.spawnBullet(function(bullet)
              bullet.x = enemy.flags.bulletPos.x
              bullet.y = enemy.flags.bulletPos.y
              bullet.angle = angle
              bullet.speed = 8
              bullet.type = 'arrowRed'
            end, function(bullet)
              if bullet.flags.flipped then
                bullet.speed = bullet.speed + .1
              else
                stg.slowEntity(bullet, 0, .25)
                if bullet.speed <= 0 then bullet.flags.flipped = true end
              end
            end)
            angle = angle + math.tau / count
          end
          local speed = 30
          enemy.flags.bulletPos.x = enemy.flags.bulletPos.x + math.cos(enemy.flags.bulletAngle) * speed
          enemy.flags.bulletPos.y = enemy.flags.bulletPos.y + math.sin(enemy.flags.bulletAngle) * speed
        end
        local function burst()
          for i = 1, 50 do
            stage.spawnBullet(function(bullet)
              bullet.x = enemy.x
              bullet.y = enemy.y
              bullet.top = true
              bullet.angle = math.tau * math.random()
              bullet.speed = 4.5 + math.random() * 4
              if math.random() < .5 then bullet.type = 'big' else bullet.type = 'small' end
              bullet.flags.minSpeed = bullet.speed - 1
            end, function(bullet)
              stg.slowEntity(bullet, bullet.flags.minSpeed, .1)
            end)
          end
        end
        local interval = 10
        local limit = interval * 5
        local max = limit * 3
        local top = limit * 1.5 + 20
        if enemy.clock % max == 0 then
          enemy.flags.bulletPos = {x = enemy.x, y = enemy.y}
          enemy.flags.bulletAngle = math.pi
          enemy.flags.bulletAngle = stg.getAngle(enemy, player)
        end
        if enemy.clock % interval == 0 and enemy.clock % max < limit then rings() end
        if enemy.clock % max == top then burst() end
        -- if enemy.clock % max == top + interval * 2 then stage.placeEnemy(enemy) end
        -- if enemy.clock % max >= top + interval * 2 then stage.moveEnemy(enemy) end
      end,

      function(enemy)
        local function bulletsA()
          local interval = 3
          local limit = interval * 10
          local max = interval * 20
          if enemy.clock % max == 0 then
            enemy.flags.bulletAngleA = math.tau * math.random()
            enemy.flags.bulletAngleB = math.tau * math.random()
          end
          local function spawnBullets(opposite)
            local count = 15
            local angle = enemy.flags.bulletAngleA
            local y = stg.grid * 2.5
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
                bullet.speed = 7
                bullet.type = 'arrow'
                bullet.top = true
              end)
              angle = angle + math.tau / count
            end
            local mod = math.pi / 180
            enemy.flags.bulletAngleB = enemy.flags.bulletAngleB + mod
            enemy.flags.bulletAngleA = enemy.flags.bulletAngleA - mod
          end
          if enemy.clock % interval == 0 and enemy.clock % max < limit then spawnBullets(enemy.clock % (max * 2) >= max) end
        end
        local function bulletsB()
          local interval = 3
          local limit = interval * 10
          local max = interval * 20
          if enemy.clock % max == limit then
            enemy.flags.bulletAngleC = math.tau * math.random()
            enemy.flags.bulletAngleD = math.tau * math.random()
          end
          local function spawnBullets(opposite)
            local count = 11
            local angle = enemy.flags.bulletAngleC
            local y = stg.grid * 5
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
                bullet.speed = 8
                bullet.type = 'arrowRed'
              end)
              angle = angle + math.tau / count
            end
            local mod = math.pi / 2 / count
            enemy.flags.bulletAngleC = enemy.flags.bulletAngleC + mod
            enemy.flags.bulletAngleD = enemy.flags.bulletAngleD - mod
          end
          if enemy.clock % interval == 0 and enemy.clock % max >= limit then spawnBullets(enemy.clock % (max * 2) >= limit + max) end
        end
        bulletsA()
        bulletsB()
      end

    }

    local patternsNext = {

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

    local function spawnEnemy()
      stage.spawnEnemy(function(enemy)
        enemy.type = 'sake'
        enemy.x = stg.gameWidth + stage.images[enemy.type]:getWidth() / 2
        enemy.y = stg.height / 2
        enemy.speed = 6
        enemy.angle = math.pi
        enemy.health = 100
        enemy.boss = true
        enemy.flags.initHealth = enemy.health
        enemy.flags.pattern = 1
        enemy.flags.borderColor = stg.colors.redLight
      end, function(enemy)
        stg.slowEntity(enemy, 0, .1)
        if enemy.speed <= 0 then
          if not enemy.flags.ready then enemy.flags.ready = true end
          local pattern = 1
          local interval = 60 * 5
          local limit = 60
          local max = interval * #patterns
          if enemy.clock % max >= interval and enemy.clock % max < interval * 2 then pattern = 2
          elseif enemy.clock % max >= interval * 2 and enemy.clock % max < interval * 3 then pattern = 3
          elseif enemy.clock % max >= interval * 3 then pattern = 4 end
          if enemy.clock % interval < interval - limit then patterns[pattern](enemy) end
          -- patterns2[10](enemy)
        else enemy.clock = -1 end
      end)
    end

    spawnEnemy()
    currentWave = 1
  end

}

local function update()
  if stage.enemyCount == 0 then
    if waveClock == 0 then
      waves[currentWave]()
      waveClock = -30
    else waveClock = waveClock + 1 end
  end
end

return {
  update = update
}
local images

local function load()
  images = {
    bg = love.graphics.newImage('img/start/bg.png')
  }
  stg.loadImages(images)
end

local function update()
  if controls.shot() then loadGame() end
end

local function draw()
  love.graphics.draw(images.bg, 0, 0)
end

return {
  load = load,
  update = update,
  draw = draw
}

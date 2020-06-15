math.tau = math.pi * 2

local function colors()
  local colorsTable = {
    black = '0d080d',
    brownDark = '4f2b24',
    brown = '825b31',
    brownLight = 'c59154',
    yellowDark = 'f0bd77',
    yellow = 'fbdf9b',
    offWhite = 'fff9e4',
    gray = 'bebbb2',
    green = '7bb24e',
    blueLight = '74adbb',
    blue = '4180a0',
    blueDark = '32535f',
    purple = '2a2349',
    redDark = '7d3840',
    red = 'c16c5b',
    redLight = 'e89973',
    white = 'ffffff'
  }
  local output = {}
  for color, v in pairs(colorsTable) do
    local _, _, r, g, b, a = colorsTable[color]:find('(%x%x)(%x%x)(%x%x)')
    output[color] = {tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, 1}
  end
  return output
end

local function loadImages(images)
	for img, file in pairs(images) do images[img]:setFilter('nearest', 'nearest') end
end

local function images(dir, files)
  local arr = {}
  for i = 1, #files do arr[files[i]] = love.graphics.newImage('img/' .. dir .. '/' .. files[i] .. '.png') end
  for img, file in pairs(arr) do arr[img]:setFilter('nearest', 'nearest') end
  return arr
end

local function processScore(input)
  local score = tostring(input)
  -- if input == 0 then score = '0' end
	for i = 1, 8 - #score do score = '0' .. score end
	return score
end

local function getAngle(a, b)
  return math.atan2(b.y - a.y, b.x - a.x)
end

local function getDistance(a, b)
  return  math.sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y))
end

local function getIndex(arr)
  local index = 1
  local found = false
  for i = 1, #arr do
    if not arr[i].active and not found then
      found = true
      index = i
    end
  end
  return index
end

local function slowEntity(entity, limit, mod)
  if entity.speed > limit then entity.speed = entity.speed - mod
  elseif entity.speed < limit then entity.speed = limit end
end

local masks = {
  half = love.graphics.newImage('img/masks/half.png'),
  quarter = love.graphics.newImage('img/masks/quarter.png'),
  most = love.graphics.newImage('img/masks/most.png'),
  fade = love.graphics.newImage('img/masks/fade.png')
}
local maskShader = love.graphics.newShader([[vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords){ if(Texel(texture, texture_coords).rgb == vec3(0.0)) {discard;} return vec4(1.0); }]])
local function doMask(mask, callback)
	love.graphics.stencil(function()
	  love.graphics.setShader(maskShader)
	  love.graphics.draw(masks[mask], 0, 0)
	  return love.graphics.setShader()
	end, 'replace', 1)
	love.graphics.setStencilTest('greater', 0)
	callback()
	love.graphics.setStencilTest()
end

return {
  scale = 1,
  width = 854,
  height = 480,
  gameWidth = 640,
  loaded = false,
  started = false,
  clock = 0,
  colors = colors(),
  processScore = processScore,
  getAngle = getAngle,
  getDistance = getDistance,
  getIndex = getIndex,
  limit = 1 / 60,
  score = 0,
  grid = 16,
  highScore = 0,
  slowEntity = slowEntity,
  maskShader = maskShader,
  mask = doMask,
  font = love.graphics.newFont('fonts/Gold Box 8x8 Monospaced.ttf', 8),
  fontBig = love.graphics.newFont('fonts/AtariST8x16SystemFont.ttf', 16),
  loadImages = loadImages,
  timeLimit = 60 * 2,
  frameOffset = 107,
  images = images
}

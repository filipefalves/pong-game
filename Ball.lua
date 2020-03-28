Ball = Class{}

-- Constructor
function Ball:init(x, y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height

  self.dy = 0
  self.dx = 0
end

-- AABB algoritmo de detecção de colisões
function Ball:collides(paddle)
  -- se x axis bola > x axis jogador + width jogador
  -- ou x axis jogador > x axis bola + width
  if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
    return false
  end

  -- o mesmo para o y axis
  if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
    return false
  end

  -- qualquer outra coisa constitui uma colisão
  return true
end

-- reset a bola p/ posição inicial
function Ball:reset()
  self.x = VIRTUAL_WIDTH / 2 - 2
  self.y = VIRTUAL_HEIGHT / 2 - 2
  self.dx = 0
  self.dy = 0
end

-- da à bola movimento constante
function Ball:update(dt)
  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt
end

-- renderiza a bola
function Ball:render()
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
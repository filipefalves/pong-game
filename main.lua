-- lib 'push' para resolução virtual
push = require 'push'

-- classes
Class = require 'class'
require 'Paddle'
require 'Ball'

-- largura e altura da janela
WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600

-- largura e altura virtuais da janela
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- velocidade dos jogadores
PADDLE_SPEED = 200

-- carrega todos os assets e informações do jogo
function love.load()
  -- desabilita o aliasing
  love.graphics.setDefaultFilter('nearest', 'nearest')

  -- usa o valor de retorno do OS p/ gerar a seed
  math.randomseed(os.time())

  -- configs da resolução virtual
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false, -- tela cheia
    resizable = false, -- tamanho ajustável
    vsync = true, -- sincronização vertical
    canvas = false -- desabilita canvas
  })

  -- título da janela
  love.window.setTitle('PONG')

  -- variável com arquivo da fonte
  font = 'font.ttf'

  -- carrega as variações do arquivo de fonte
  smallFont = love.graphics.newFont(font, 8)
  bigFont = love.graphics.newFont(font, 16)
  scoreFont = love.graphics.newFont(font, 32)
  love.graphics.setFont(smallFont) -- define variação padrão

  -- instanciamento dos jogadores
  -- player(x, y, width, heigth)
  p1 = Paddle(10, 30, 5, 20) 
  p2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

  -- instanciamento da bola
  -- ball(x, y, width, height)
  ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

  -- definição dos pontos iniciais
  p1Score = 0
  p2Score = 0

  -- definição do jogador com o saque
  servingPlayer = 1
  -- vencedor = ninguém
  winningPlayer = 0

  -- states: 'start', 'serve', 'play' e 'done'
  gamestate = 'start'
end

-- atualiza todos os elementos do jogo baseado no valor constante 'dt'
function love.update(dt)
  -- 'switch' de states com if else, já que Lua não tem switch case... :(
  -- 'serve' configura a bola para seguir num ângulo vertical entre -50 e 50
  -- e ajusta a direção da bola de acordo com o jogador
  if gamestate == 'serve' then
    ball.dy = math.random( -50, 50 )
    if servingPlayer == 1 then
      ball.dx = math.random( 140, 200 )
    else
      ball.dx = -math.random( 140, 200 )
    end
    -- 'play' chama as funções de detecção de colisão e checa se há colisão
    -- da bola com as margens superior e inferior da janela
    -- também checa se um ponto foi marcado e se algum jogador já tem + de 10
  elseif gamestate == 'play' then
    collisionDetector(p1, 5)
    collisionDetector(p2, -4)

    -- se o valor vertical da bola for menor do que 0
    -- o valor é fixado em zero para não sair da janela
    -- após a verificação, a bola é mandada para a direção vertical oposta
    if ball.y <= 0 then
      ball.y = 0
      ball.dy = -ball.dy
    end

    -- se o valor vertical for maior que o tamanho da janela
    -- o valor máximo é fixado no tamanho da janela - altura em px do jogador
    if ball.y >= VIRTUAL_HEIGHT - 4 then
      ball.y = VIRTUAL_HEIGHT - 4
      ball.dy = -ball.dy
    end

    -- se a bola tiver valor horizontal menor do que 0
    -- o jogador da direita (2) marcou um ponto
    if ball.x < 0 then
      servingPlayer = 1 -- jogador 1 é o próximo a sacar
      p2Score = p2Score + 1
      -- chamada da função que verifica o vencedor
      setWinner(p2Score, 2)
    end
    -- se a bola tiver valor horizontal maior do que o tamanho da janela
    -- o jogador da esquerda (1) marcou um ponto
    if ball.x > VIRTUAL_WIDTH then
      servingPlayer = 2 -- 2 é o próximo a sacar
      p1Score = p1Score + 1
      -- chamada da função de verificação do vencedor
      setWinner(p1Score, 1)
    end
  end
  
  -- funções de movimentação do jogador
  movePaddle(p1, 'w', 's')
  movePaddle(p2, 'up', 'down')

  -- aplica movimento à bola caso state seja 'play'
  if gamestate == 'play' then
    ball:update(dt)
  end

  -- atualização dinâmica dos jogadores
  p1:update(dt)
  p2:update(dt)
end

-- leitura de botões e mudança de states
function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  elseif key == 'enter' or key == 'return' then
    if gamestate == 'start' then
      gamestate = 'serve'
    elseif gamestate == 'serve' then
      gamestate = 'play'
    elseif gamestate == 'done' then
      gamestate = 'serve'
      ball:reset()
      p1Score = 0
      p2Score = 0

      if winningPlayer == 1 then
        servingPlayer = 2
      else
        servingPlayer = 1
      end
    end
  end
end

-- rendering dos elementos na tela
function love.draw()
  push:start()

  -- aplica a cor de fundo
  love.graphics.clear(0.15, 0.17, 0.20, 1)

  -- elementos de texto de acordo com o state
  if gamestate == 'start' then
    love.graphics.setFont(smallFont)
    love.graphics.printf('PONG', 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Aperte ENTER para começar', 0, 30, VIRTUAL_WIDTH, 'center')
  elseif gamestate == 'serve' then
    love.graphics.setFont(smallFont)
    love.graphics.printf('Jogador '.. tostring(servingPlayer) .. ' começa!', 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Aperte ENTER para sacar!', 0, 30, VIRTUAL_WIDTH, 'center')
  elseif gamestate == 'play' then

  elseif gamestate == 'done' then
    love.graphics.setFont(bigFont)
    love.graphics.printf('Jogador ' .. tostring(winningPlayer) .. ' ganhou!!', 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(smallFont)
    love.graphics.printf('Aperte ENTER para reiniciar o jogo', 0, 30, VIRTUAL_WIDTH, 'center')
  end

  -- mostra os pontos na tela 
  displayScore()

  -- renderiza os jogadores e a bola
  p1:render()
  p2:render()
  ball:render()

  push:finish()
end

-- detecção de colisões
function collisionDetector(player, offset)
  if ball:collides(player) then
    -- se colisão com o jogador é detectada, a bola segue na direção oposta
    -- e acelera 3%
    ball.dx = -ball.dx * 1.03
    -- o valor horizontal deve ser ajustado para evitar um loop após a colisão
    ball.x = player.x + offset

    -- mantém o ângulo e inverte a direção
    if ball.dy < 0 then
      ball.dy = -math.random( 10, 150 )
    else
      ball.dy = math.random( 10, 150 )
    end
  end
end

-- função que testa de há vencedor
function setWinner(score, playerID)
  -- vencedor = mais de 10 pontos
  if score == 10 then
    winningPlayer = playerID
    gamestate = 'done'
  else
    gamestate = 'serve'
    ball:reset()
  end
end

-- movimento do jogador
function movePaddle(player, keyUp, keyDown)
  -- movimento se a tecla pressionada é para cima ou para baixo
  if love.keyboard.isDown(keyUp) then
    player.dy = -PADDLE_SPEED -- dy negativo = para cima
  elseif love.keyboard.isDown(keyDown) then
    player.dy = PADDLE_SPEED -- dy positivo = para baixo
  else
    player.dy = 0 -- dy 0 = parado
  end
end

-- exibe os pontos dos jogadores na tela
function displayScore()
  love.graphics.setFont(scoreFont)
  love.graphics.print(tostring(p1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
  love.graphics.print(tostring(p2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end
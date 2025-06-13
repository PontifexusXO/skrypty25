#------------------------------------------
# Mario w Ruby2D ~ Arkadiusz Adamczyk
#------------------------------------------

require 'ruby2d'
set title: "MarioRuby", width: 800, height: 600
set background: 'black'

$GRAVITY = 0.8
$JUMP_POWER = -15
$MOVE_SPEED = 5
$GROUND_LEVEL = 550

$player_initial_x = 0
$player_initial_y = 350
$player_velocity = { x: 0, y: 0 }
$on_ground = false
$facing_right = true
$current_anim = :idle
$player = nil
$current_scene = "menu"
$platforms = []
$keys = []
$score = 0
$score_label = nil
$enemies = []
$lives = 3
$is_random = false

keys = {}
on :key_held do |event|
  keys[event.key] = true
end
on :key_up do |event|
  if $current_scene == "menu" && event.key == "return"
    $is_random = false
    start
  elsif $current_scene == "win" && event.key == "return"
    menu
  end
  if $current_scene == "menu" && event.key == "space"
    $is_random = true
    start
  end
  keys[event.key] = false
end

def load_level(file_path)
  $platforms = []
  $enemies = []
  $keys = []
  File.readlines(file_path).each do |line|
    next if line.strip.empty? || line.strip.start_with?('#')
    parts = line.strip.split
    type = parts[0]
    case type
      when "platform"
        x, y, w, h = parts[1..4].map(&:to_i)
        $platforms << create_static_platform(x: x, y: y, width: w, height: h)
      when "moving_platform"
        x, y, w, h, range, speed = parts[1..6].map(&:to_i)
        $platforms << create_moving_platform(x: x, y: y, width: w, height: h, range: range, speed: speed)
      when "enemy"
        x, y = parts[1..2].map(&:to_i)
        create_enemy(x: x, y: y)
    end
  end
end

def create_static_platform(x:, y:, width:, height:, color: 'white')
  key = Image.new('key.png', x: x + width / 2 - 24, y: y - 48, width: 48, height: 48)
  $keys << key
  {
    sprite: Rectangle.new(x: x, y: y, width: width, height: height, color: color),
    moving: false
  }
end

def create_moving_platform(x:, y:, width:, height:, range:, speed:, color: 'white')
  {
    sprite: Rectangle.new(x: x, y: y, width: width, height: height, color: color),
    moving: true,
    direction: 1,
    range: range,
    start_x: x,
    speed: speed
  }
end

def create_enemy(x:, y:)
  enemy_sprite = Sprite.new(
    'enemy.png',
    clip_width: 30,
    clip_height: 48,
    width: 30, height: 48,
    x: x, y: y,
    time: 40,
    animations: {
      run: 1..4
    }
  )
  $enemies << { sprite: enemy_sprite, direction: -1 }
end

def move_enemy
  $enemies.each do |enemy|
    sprite = enemy[:sprite]
    direction = enemy[:direction]
    left_foot_x = sprite.x + 2
    right_foot_x = sprite.x + sprite.width - 2
    foot_y = sprite.y + sprite.height + 1
    left_supported = $platforms.any? do |plat|
      plat_sprite = plat[:sprite]
      plat_sprite.y >= foot_y - 5 && plat_sprite.y <= foot_y + 5 &&
        left_foot_x >= plat_sprite.x && left_foot_x <= plat_sprite.x + plat_sprite.width
    end
    right_supported = $platforms.any? do |plat|
      plat_sprite = plat[:sprite]
      plat_sprite.y >= foot_y - 5 && plat_sprite.y <= foot_y + 5 &&
        right_foot_x >= plat_sprite.x && right_foot_x <= plat_sprite.x + plat_sprite.width
    end
    unless left_supported && right_supported
      direction *= -1
      enemy[:direction] = direction
    end
    sprite.x += direction * 2
    sprite.play animation: :run, loop: true, flip: (direction > 0 ? nil : :horizontal)
  end
end

def random
  $platforms = []
  $enemies = []
  $keys = []
  grid_cols = 5
  grid_rows = 6
  cell_width = Window.width / grid_cols
  cell_height = ($GROUND_LEVEL) / grid_rows
  player_spawned = false
  platform_count = 12
  placed = 0
  occupied_cells = []

  while placed < platform_count
    col = rand(0...grid_cols)
    row = rand(0...grid_rows)

    next if occupied_cells.include?([col, row])

    occupied_cells << [col, row]
    w = cell_width * rand(0.3...1.1)
    h = 20
    x = col * cell_width + (cell_width - w) / 2
    y = 50 + row * cell_height

    if rand < 0.15
      $platforms << create_moving_platform(x: x, y: y, width: w, height: h, range: rand(100..200), speed: 4)
    else
      plat = create_static_platform(x: x, y: y, width: w, height: h)
      $platforms << plat

      if !player_spawned
        player_spawned = true
        $player.x = x + w / 2 - $player.width / 2
        $player.y = y - $player.height
        $player_initial_x = $player.x
        $player_initial_y = $player.y
      else
        if rand < 0.3 && !occupied_cells.include?([col, row - 1])
          create_enemy(x: x + w / 2, y: y - 50)
        end
      end
    end
    placed += 1
  end
end

def menu
  clear
  $current_scene = "menu"
  title = Text.new(
    "MarioRuby",
    x: Window.width / 2, 
    y: Window.height / 2 - 100,
    size: 50,
    color: 'white'
  )
  title.x -= title.width / 2
  author = Text.new(
    "Arkadiusz Adamczyk",
    x: Window.width / 2, 
    y: Window.height / 2 - 50,
    size: 20,
    color: 'white'
  )
  author.x -= author.width / 2
  start_game = Text.new(
    "ENTER to start",
    x: Window.width / 2, 
    y: Window.height / 2 + 25,
    size: 25,
    color: 'white'
    )
  start_game.x -= start_game.width / 2
  start_game = Text.new(
    "SPACE to start random level",
    x: Window.width / 2, 
    y: Window.height / 2 + 75,
    size: 25,
    color: 'white'
    )
  start_game.x -= start_game.width / 2
end

def start
  clear
  $score = 0
  $keys = []
  $lives = 3
  $score_label = Text.new(
    "Score: 0",
    x: 24,
    y: 24,
    size: 20,
    color: 'white',
  )
  $lives_label = Text.new(
    "Lives: 3",
    x: Window.width - 100,
    y: 24,
    size: 20,
    color: 'white',
  )
  $player = Sprite.new(
    'player.png',
    clip_width: 24,
    clip_height: 48,
    width: 24, height: 48,
    x: $player_initial_x, y: $player_initial_y,
    time: 40,
    animations: {
      idle: 1,
      run: 5..8
    }
  )

  if $is_random == false
    load_level("level1.txt")
  else
    random
  end
  $current_scene = "start"
end

def win(won: true)
  clear
  $current_scene = "win"
  if won == true
    title = Text.new(
      "YOU WON",
      x: Window.width / 2, 
      y: Window.height / 2 - 100,
      size: 50,
      color: 'green'
    )
  else
    title = Text.new(
      "YOU LOST",
      x: Window.width / 2, 
      y: Window.height / 2 - 100,
      size: 50,
      color: 'red'
  )
  end
  title.x -= title.width / 2
  score = Text.new(
    "Score: #{$score}",
    x: Window.width / 2, 
    y: Window.height / 2 - 35,
    size: 25,
    color: 'white'
    )
  score.x -= score.width / 2
  menu = Text.new(
    "ENTER to go to menu",
    x: Window.width / 2, 
    y: Window.height / 2 + 50,
    size: 25,
    color: 'white'
    )
  menu.x -= menu.width / 2
end

def aabb_collision?(a, b)
  a.x < b.x + b.width &&
  a.x + a.width > b.x &&
  a.y < b.y + b.height &&
  a.y + a.height > b.y
end

update do
  if $current_scene == "start"
    $enemies.reject! do |enemy|
      sprite = enemy[:sprite]
      if aabb_collision?($player, sprite)
        if $player.y + $player.height - 10 < sprite.y
          $player_velocity[:y] = $JUMP_POWER / 1.5
          sprite.remove
          $score += 5
          $score_label.text = "Score: #{$score}"
          true
        else
          $lives -= 1
          $lives_label.text = "Lives: #{$lives}"
          $player.x = $player_initial_x
          $player.y = $player_initial_y
          $player_velocity[:x] = 0
          $player_velocity[:y] = 0
          win(won: false) if $lives <= 0
          false
        end
      else
        false
      end
    end
    move_enemy

    $player_velocity[:x] = 0
    $moving = false
    if keys['left']
      $facing_right = false
      $player_velocity[:x] = -$MOVE_SPEED
      $moving = true
      $player.play animation: :run, loop: false, flip: :horizontal do
      $player.play animation: :idle, loop: true, flip: :horizontal
      end
    elsif keys['right']
      $facing_right = true
      $player_velocity[:x] = $MOVE_SPEED
      $moving = true
      $player.play animation: :run, loop: false, flip: nil do
      $player.play animation: :idle, loop: true, flip: nil
      end
    end
    if keys['up'] && $on_ground
      $player_velocity[:y] = $JUMP_POWER
      $on_ground = false
    end

    $platforms.each do |plat|
      next unless plat[:moving]
      plat[:sprite].x += plat[:speed] * plat[:direction]
      if plat[:sprite].x > plat[:start_x] + plat[:range] || plat[:sprite].x < plat[:start_x]
        plat[:direction] *= -1
      end
    end

    $player_velocity[:y] += $GRAVITY
    $player.x += $player_velocity[:x]
    $platforms.each do |plat|
      sprite = plat[:sprite]
      next unless aabb_collision?($player, sprite)

      if $player_velocity[:x] > 0
        $player.x = sprite.x - $player.width
      elsif $player_velocity[:x] < 0
        $player.x = sprite.x + sprite.width
      end
      $player_velocity[:x] = 0
    end
    $player.y += $player_velocity[:y]
    $on_ground = false
    $platforms.each do |plat|
      sprite = plat[:sprite]
      next unless aabb_collision?($player, sprite)
      if $player_velocity[:y] > 0
        $player.y = sprite.y - $player.height
        $player_velocity[:y] = 0
        $on_ground = true
      elsif $player_velocity[:y] < 0
        $player.y = sprite.y + sprite.height
        $player_velocity[:y] = 0
      end
    end

    $keys.reject! do |key|
    if $player.x < key.x + key.width && $player.x + $player.width > key.x && $player.y < key.y + key.height && $player.y + $player.height > key.y
        key.remove
        $score += 10
        $score_label.text = "Score: #{$score}"
        true
      else
        false
      end
    end
    if $keys.length == 0
      win
    end

    $player.x = [[$player.x, 0].max, Window.width - $player.width].min
    if $player.y > Window.height + 400
      $player.x = $player_initial_x
      $player.y = $player_initial_y
      $player_velocity[:x] = 0
      $player_velocity[:y] = 0
      $lives = $lives - 1
      $lives_label.text = "Lives: #{$lives}"
      if $lives == 0
        win(won: false)
      end
    end
  end
end

menu
show
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

$player_initial_x = 50
$player_initial_y = 350
$player_velocity = { x: 0, y: 0 }
$on_ground = false
$facing_right = true
$current_anim = :idle
$player = nil
$current_scene = "menu"
$platforms = nil

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
subtitle = Text.new(
  "Press ENTER to start",
  x: Window.width / 2, 
  y: Window.height / 2 + 25,
  size: 25,
  color: 'white'
  )
subtitle.x -= subtitle.width / 2

keys = {}
on :key_held do |event|
  keys[event.key] = true
end
on :key_up do |event|
  if $current_scene == "menu" && event.key == "return"
    start
  end
  keys[event.key] = false
end

def create_static_platform(x:, y:, width:, height:, color: 'white')
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

def aabb_collision?(a, b)
  a.x < b.x + b.width &&
  a.x + a.width > b.x &&
  a.y < b.y + b.height &&
  a.y + a.height > b.y
end

def start
  clear
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
  $platforms = [
    create_static_platform(x: 0, y: 400, width: 100, height: 20),
    create_static_platform(x: 375, y: 450, width: 20, height: 40),
    create_moving_platform(x: 200, y: 500, width: 150, height: 20, range: 200, speed: 4),
    create_static_platform(x: 550, y: 400, width: 150, height: 20),
    create_static_platform(x: 400, y: 275, width: 150, height: 20),
    create_static_platform(x: 150, y: 175, width: 150, height: 20)
  ]
  $current_scene = "start"
end

update do
  if $current_scene == "start"
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

    $player.x = [[$player.x, 0].max, Window.width - $player.width].min
    if $player.y > Window.height + 400
      $player.x = $player_initial_x
      $player.y = $player_initial_y
      $player_velocity[:x] = 0
      $player_velocity[:y] = 0
    end
  end
end

show
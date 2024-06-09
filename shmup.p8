pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- ∧main∧ --

-- called once at startup
function _init()
  init_bg_handler()
  init_player_handler()
  init_enemy_handler()
  init_bullet_handler()
end
 
-- called once per update
function _update60()
  update_bg_handler()
  update_player_handler()
  update_enemy_handler()
  update_bullet_handler()
end
 
-- called once per frame
function _draw()
  cls(0)
  draw_bg_handler()
  draw_player_handler()
  draw_enemy_handler()
  draw_bullet_handler()
end
-->8
-- ∧player handler∧ --

player = {
  x_pos = 60,
  y_pos = 100,
  width = 8,
  height = 8
}

function init_player_handler()

end


function update_player_handler()
  if btn(⬆️) do
    player.y_pos -= 1
  end
  if btn(⬇️) do
    player.y_pos += 1
  end
  if btn(⬅️) do
    player.x_pos -= 1
  end
  if btn(➡️) do
    player.x_pos += 1
  end
  
  if btnp(❎) do
    bullet = {
      x_pos = player.x_pos+3,
      y_pos = player.y_pos,
      width = 2,
      height = 2
    }
    add(bullets, bullet)
  end
end


function draw_player_handler()
  spr(193, player.x_pos, player.y_pos)
end
-->8
-- ∧enemy handler∧ --
enemy_handler = {
  ready = false,
  respawn = false,
  respawn_timer = 0,
  enemies = {},
  formations = {
    -- rows
		  {
		    {"❎","❎","❎","❎","❎","❎","❎"},
		    {"🅾️","🅾️","🅾️","🅾️","🅾️","🅾️","🅾️"},
		    {"❎","❎","❎","❎","❎","❎","❎"},
		    {"🅾️","🅾️","🅾️","🅾️","🅾️","🅾️","🅾️"},
		    {"❎","❎","❎","❎","❎","❎","❎"}
		  },
		  -- box
		  {
		    {"❎","❎","❎","❎","❎","❎","❎"},
		    {"❎","🅾️","🅾️","🅾️","🅾️","🅾️","❎"},
		    {"❎","🅾️","🅾️","🅾️","🅾️","🅾️","❎"},
		    {"❎","🅾️","🅾️","🅾️","🅾️","🅾️","❎"},
		    {"❎","❎","❎","❎","❎","❎","❎"}
		  },
		  -- m
		  {
		    {"❎","❎","❎","🅾️","❎","❎","❎"},
		    {"❎","🅾️","❎","🅾️","❎","🅾️","❎"},
		    {"❎","🅾️","❎","🅾️","❎","🅾️","❎"},
		    {"❎","🅾️","❎","🅾️","❎","🅾️","❎"},
		    {"❎","🅾️","❎","❎","❎","🅾️","❎"}
		  },
		  -- checkers
		  {
		    {"❎","🅾️","❎","🅾️","❎","🅾️","❎"},
		    {"🅾️","❎","🅾️","❎","🅾️","❎","🅾️"},
		    {"❎","🅾️","❎","🅾️","❎","🅾️","❎"},
		    {"🅾️","❎","🅾️","❎","🅾️","❎","🅾️"},
		    {"❎","🅾️","❎","🅾️","❎","🅾️","❎"}
		  },
		  -- target
		  {
		    {"❎","❎","❎","❎","❎","❎","❎"},
		    {"❎","🅾️","🅾️","🅾️","🅾️","🅾️","❎"},
		    {"❎","🅾️","❎","❎","❎","🅾️","❎"},
		    {"❎","🅾️","🅾️","🅾️","🅾️","🅾️","❎"},
		    {"❎","❎","❎","❎","❎","❎","❎"}
		  },
		  -- weird x
		  {
		    {"❎","🅾️","🅾️","🅾️","🅾️","🅾️","❎"},
		    {"🅾️","❎","❎","❎","❎","❎","🅾️"},
		    {"🅾️","❎","🅾️","🅾️","🅾️","❎","🅾️"},
		    {"🅾️","❎","❎","❎","❎","❎","🅾️"},
		    {"❎","🅾️","🅾️","🅾️","🅾️","🅾️","❎"}
		  }
  }
}

function init_enemy_handler()
  instantiate_enemies(flr(rnd(count(enemy_handler.formations)))+1)
end


function update_enemy_handler()
  for enemy in all(enemy_handler.enemies) do
    if enemy ~= nil do
      update_enemy(enemy)
    end
  end
  
  if not enemy_handler.ready do
    local move = true
  	 for enemy in all(enemy_handler.enemies) do
  	   if not enemy.ready do
  	     move = false
  	   end
  	 end
  	 if move do
  	   enemy_handler.ready = true
  	 end
  end
  
  if count(enemy_handler.enemies) == 0 do
    enemy_handler.ready = false
    enemy_handler.respawn = true
  end
  
  if enemy_handler.respawn do
    enemy_handler.respawn_timer += 1
    if enemy_handler.respawn_timer == 30 do
      enemy_handler.respawn = false
      enemy_handler.respawn_timer = 0
      instantiate_enemies(flr(rnd(count(enemy_handler.formations)))+1)
    end
  end
end


function update_enemy(enemy)
  if enemy.y_pos > 130 do
    del(enemy_handler.enemies, enemy)
  end

  if enemy_handler.ready do
    enemy.move_counter += 1
    enemy.move_counter2 += 1

    --vertical movement
    if enemy.move_counter == 60 do
      enemy.y_pos += enemy.y_spd
      enemy.move_counter = 0
    end
  
    -- horizontal movement
    if enemy.move_counter2 == 10 do
      if enemy.move_left == true do
        enemy.x_pos -= 1
      else
        enemy.x_pos += 1
      end
      enemy.move_counter2 = 0
    
      if abs(enemy.x_pos - enemy.x_start) > 1 do
        enemy.move_left = not enemy.move_left
      end
    
    end
  elseif not enemy.ready do
  
    -- get unit vector
    local delta_x = enemy.x_start - enemy.x_pos
    local delta_y = enemy.y_start - enemy.y_pos
    local magnitude = sqrt((delta_x)^2+(delta_y)^2)
    local unit_x = delta_x/magnitude
    local unit_y = delta_y/magnitude
    
    -- move
    enemy.x_pos += unit_x * 3
    enemy.y_pos += unit_y * 3
    
    -- dont overshoot
    if enemy.y_pos >= enemy.y_start do
      enemy.y_pos = enemy.y_start
      enemy.x_pos = enemy.x_start
      enemy.ready = true
    end
  
  end
end


function draw_enemy_handler()
  for enemy in all(enemy_handler.enemies) do
    if enemy ~= nil do
      draw_enemy(enemy)
    end
  end
end


function draw_enemy(enemy)
  spr(enemy.spr_index, enemy.x_pos, enemy.y_pos)
end


function instantiate_enemies(index)
  local formation = enemy_handler.formations[index]
  local x_spawn = 11
  local y_spawn = 0
  local move_dir = true
  for row in all(formation) do
    for element in all(row) do
      if element == "❎" then
        enemy = {
          x_pos = 60,
          y_pos = -8,
          x_start = x_spawn,
          y_start = y_spawn,
          width = 8,
          height = 8,
          y_spd = 8,
          move_counter = 0,
          move_counter2 = 0,
          move_left = move_dir,
          x_start = x_spawn,
          ready = false,
          spr_index = 208 + flr(rnd(3))
        }
        add(enemy_handler.enemies, enemy)
      end
      x_spawn += 16
    end
    x_spawn = 11
    y_spawn += 10
    move_dir = not move_dir
  end
end


-->8
-- ∧bullet handler∧ --

bullets = {}

function init_bullet_handler()

end


function update_bullet_handler()
  for bullet in all(bullets) do
    if bullet ~= nil do
      update_bullet(bullet)
    end
  end
end


function update_bullet(bullet)
  bullet.y_pos -= 2
  if bullet.y_pos < -5 do
    del(bullets, bullet)
  end
  for enemy in all(enemy_handler.enemies) do
    if enemy_handler.ready and check_collision(bullet, enemy) do
      del(enemy_handler.enemies, enemy)
      del(bullets, bullet)
    end
  end
end


function draw_bullet_handler()
  for bullet in all(bullets) do
    if bullet ~= nil do
      draw_bullet(bullet)
    end
  end
end


function draw_bullet(bullet)
  spr(194, bullet.x_pos, bullet.y_pos)
end
-->8
-- ∧bg handler∧ --

stars = {}

function init_bg_handler()
  local curr_x = 0
  local curr_y = 0
  while curr_y < 128 do
    while curr_x < 128 do
      local num = flr(rnd(100))+1
      if (num <= 5) do
        star = {
          x_pos = curr_x,
          y_pos = curr_y,
          depth = flr(rnd(3))+1
        }
        add(stars, star)
      end
      curr_x += 4
    end
    curr_x = 0
    curr_y += 4
  end
end


function update_bg_handler()
  for star in all(stars) do
    if star ~= nil do
      update_star(star)
    end
  end
end


function update_star(star)
  star.y_pos += star.depth / 20
  if star.y_pos > 128 do
    star.y_pos = 0
  end
end


function draw_bg_handler()
  for star in all(stars) do
    if star ~= nil do
      draw_star(star)
    end
  end
end

function draw_star(star)
  spr(195, star.x_pos, star.y_pos)
end
-->8
-- ∧collision handler∧ --

function check_collision(obj1, obj2)
  
  if (
    (obj1.x_pos < obj2.x_pos + obj2.width) and
    (obj1.x_pos + obj1.width > obj2.x_pos) and
    (obj1.y_pos < obj2.y_pos + obj2.height) and
    (obj1.y_pos + obj1.height > obj2.y_pos)) do
    return true 
  else
    return false
  end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000066000aa00000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000eeeeee0aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eeeddeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eee00eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eee00eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008a0000a80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0088880000bbbb0000cccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
088888800bbbbbb00cccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88088088bb0bb0bbcc0cc0cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888bbbbbbbbcccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888bbbbbbbbcccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
080000800b0000b00c0000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
080000800b0000b00c0000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
080000800b0000b00c0000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

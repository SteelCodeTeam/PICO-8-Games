fase = 0
game_time = 0
current_level = 1
paused = true
paused_timer = 0
game_over = false
final_score = 0
score_display_timer = 0

projectiles = {}
obstacles = {}
trails = {}  
last_projectile_time = 0
last_obstacle_time = 0

levels = {
    {sen_amplifier = 5, fase_speed = 0.002, frequency = 1, offset = 100, 
     projectile_type = "quadratic", projectile_freq = 80, obstacle_type = "pendulum"},
    {sen_amplifier = 9, fase_speed = 0.003, frequency = 0.25, offset = 95,
     projectile_type = "sine_wave", projectile_freq = 150, obstacle_type = "rotating"},
    {sen_amplifier = 12, fase_speed = 0.008, frequency = 2, offset = 105,
     projectile_type = "zigzag", projectile_freq = 120, obstacle_type = "oscillating"},
    {sen_amplifier = 15, fase_speed = 0.01, frequency = 0.8, offset = 90,
     projectile_type = "ellipse", projectile_freq = 200, obstacle_type = "bouncing"},
    {sen_amplifier = 18, fase_speed = 0.0125, frequency = 1.2, offset = 100,
     projectile_type = "inverse", projectile_freq = 100, obstacle_type = "circle"},
    {sen_amplifier = 20, fase_speed = 0.015, frequency = 0.39, offset = 85,
     projectile_type = "heart", projectile_freq = 90, obstacle_type = "oscillating"},
    {sen_amplifier = 18, fase_speed = 0.018, frequency = 0.5, offset = 110,
     projectile_type = "rose", projectile_freq = 110, obstacle_type = "lemniscata"},
    {sen_amplifier = 25, fase_speed = 0.02, frequency = 0.6, offset = 95,
     projectile_type = "butterfly", projectile_freq = 160, obstacle_type = "spiral"},
    {sen_amplifier = 28, fase_speed = 0.023, frequency = 1, offset = 80,
     projectile_type = "cycloid", projectile_freq = 80, obstacle_type = "lemniscata"},
    {sen_amplifier = 20, fase_speed = 0.035, frequency = 0.8, offset = 100,
     projectile_type = "fractal", projectile_freq = 40, obstacle_type = "circle"}
}

player = {
    x = 64,
    y = 50,
    vx = 0,
    vy = 0,
    w = 6,
    h = 6,
    speed = 1.5,
    jump_power = 3,
    gravity = 0.15,
    on_ground = false,
    color = 12,
    lives = 5,
    invulnerable = 0
}

function calculate_score()
    local seconds = flr(game_time / 30)
    local score = seconds * current_level
    if current_level == 10 then
        score = score * 1.5
    end
    return flr(score)
end

function reset_game()
    player.lives = 5
    player.x = 64
    player.y = 50
    player.vx = 0
    player.vy = 0
    player.on_ground = false
    player.invulnerable = 0
    current_level = 1
    game_time = 0
    fase = 0
    paused = true
    paused_timer = 0
    game_over = false
    final_score = 0
    score_display_timer = 0
    projectiles = {}
    obstacles = {}
    trails = {}
    last_projectile_time = 0
    last_obstacle_time = 0
end

function _update()
    if game_over then
        score_display_timer = score_display_timer + 1
        if btnp(4) or btnp(5) then
            reset_game()
        end
        return
    end

    if not paused then 
        local new_level = flr(game_time / 900) + 1
        if new_level > 10 then
            new_level = 10
        end

        if (new_level ~= current_level) then
              paused=true
              current_level = new_level
              projectiles = {}
              obstacles = {}
              trails = {}
        end

        fase = fase + levels[current_level].fase_speed
        game_time = game_time + 1

        update_projectiles()
        update_obstacles()
        update_trails()
        spawn_projectiles()
        spawn_obstacles()

        player_update()

        check_projectile_collisions()
        check_obstacle_collisions()

        if player.invulnerable > 0 then
            player.invulnerable = player.invulnerable - 1
        end

    else 
        if flr(paused_timer / 30) >= 4 then
            paused_timer = 0
            paused = false
        else 
            paused_timer = paused_timer + 1
        end
    end
end

function _draw()
    cls()

    if game_over then
        rectfill(0, 0, 127, 127, 0) 
        
        local game_over_text = "GAME OVER"
        local text_width = #game_over_text * 4
        print(game_over_text, 64 - text_width/2, 40, 8)
        
        local score_text = "SCORE: " .. final_score
        local score_width = #score_text * 4
        print(score_text, 64 - score_width/2, 60, 7)
        
        if flr(score_display_timer / 30) % 2 == 0 then
            local restart_text = "PRESS X OR Z TO RESTART"
            local restart_width = #restart_text * 4
            print(restart_text, 64 - restart_width/2, 80, 6)
        end
        
        return
    end

    if paused then
        rectfill(0, 0, 127, 127, 1) 

        if (current_level > 1 and (flr(paused_timer / 20) % 2 == 0)) then
            local clear_text = "clear"
            local text_width = #clear_text * 4
            print(clear_text, 64 - text_width/2, 50, 7)
        elseif (flr(paused_timer / 20) % 2 == 0) then
            local clear_text = "dont die on the graph"
            local text_width = #clear_text * 4
            print(clear_text, 64 - text_width/2, 50, 3)
        end 

        if (current_level < 10) then
            local level_text = "level " .. current_level
            local level_width = #level_text * 4
            print(level_text, 64 - level_width/2, 70, 10)
        else 
            local level_text = "INFINITE LEVEL "
            local level_width = #level_text * 4
            print(level_text, 64 - level_width/2, 70, paused_timer)
        end

    else
        local level = levels[current_level]
        for x = 0, 126 do
            local t1 = (x / 128) * level.frequency + fase
            local y1 = level.offset - sin(t1) * level.sen_amplifier
            local t2 = ((x + 1) / 128) * level.frequency + fase
            local y2 = level.offset - sin(t2) * level.sen_amplifier
            line(x, y1, x + 1, y2, 7)
        end

        draw_trails()

        draw_obstacles()

        draw_projectiles()

        local seconds = flr(game_time / 30)
        print("time: " .. seconds .. "s", 2, 2, 7)
        print("level: " .. current_level, 2, 8, 10)
        print("lives: " .. player.lives, 2, 14, 8)

        player_draw()
    end
end

function spawn_projectiles()
    local level = levels[current_level]
    if game_time - last_projectile_time > level.projectile_freq then
        add(projectiles, create_projectile(level.projectile_type))
        last_projectile_time = game_time
    end
end

function get_safe_spawn_y()
    return rnd(88) + 20
end

function create_projectile(type)
    local spawn_y = get_safe_spawn_y()
    local proj = {
        x = 128,
        y = spawn_y,
        vx = -1,
        vy = 0,
        life = 0,
        type = type,
        color = 8,
        shape = "circle"
    }

        if type == "quadratic" then
        proj.start_x = 128
        proj.start_y = spawn_y
        proj.scale = 0.005
        proj.vx = -1.5
        proj.color = 8
        proj.shape = "square"
    elseif type == "sine_wave" then
        proj.start_x = 128
        proj.start_y = spawn_y
        proj.amplitude = 8
        proj.frequency = 0.05
        proj.phase = rnd(6.28)
        proj.vx = -1.2
        proj.color = 9
        proj.shape = "diamond"
    elseif type == "zigzag" then
        proj.start_x = 128
        proj.start_y = spawn_y
        proj.amplitude = 12
        proj.direction = 1
        proj.step_size = 15
        proj.vx = -0.8
        proj.color = 10
        proj.shape = "triangle"
    elseif type == "ellipse" then
        proj.a = 15
        proj.b = 8
        proj.angle = 0
        proj.center_x = 140
        proj.center_y = spawn_y
        proj.angular_speed = 0.08
        proj.vx = -1.0
        proj.color = 11
        proj.shape = "circle"
    elseif type == "inverse" then
        proj.start_y = spawn_y
        proj.scale = 50
        proj.vx = -1.3
        proj.color = 12
        proj.shape = "plus"
    elseif type == "heart" then
        proj.scale = 1.5
        proj.t = 0
        proj.center_y = spawn_y
        proj.vx = -0.5
        proj.color = 8
        proj.shape = "heart"
    elseif type == "rose" then
        proj.a = 12
        proj.k = 3
        proj.t = 0
        proj.center_x = 140
        proj.center_y = spawn_y
        proj.vx = -0.8
        proj.color = 14
        proj.shape = "star"
    elseif type == "butterfly" then
        proj.scale = 4
        proj.t = 0
        proj.center_x = 140
        proj.center_y = spawn_y
        proj.vx = -0.8
        proj.color = 13
        proj.shape = "butterfly"
    elseif type == "cycloid" then
        proj.r = 8
        proj.t = 0
        proj.start_y = spawn_y
        proj.vx = -0.9
        proj.color = 6
        proj.shape = "circle"
    elseif type == "fractal" then
        proj.iterations = 3
        proj.scale = 5
        proj.t = 0
        proj.start_y = spawn_y
        proj.vx = -1.1
        proj.color = 7
        proj.shape = "fractal"
    end
    return proj
end

log10_table = {
 0, 3, 4.75,
 6, 7, 7.75,
 8.375, 9, 9.5, 10
}

function log10(n)
 if (n < 1) then return 0.1 end
 local e = 0
 while n > 10 do
  n = n / 10
  e = e + 1
 end
 return log10_table[flr(n)] + e

end


function update_projectiles()
    for i = #projectiles, 1, -1 do
        local proj = projectiles[i]
        add_trail(proj.x, proj.y, proj.color, proj.shape)

        proj.life = proj.life + 1
        
        if proj.type == "quadratic" then
            proj.x = proj.x + proj.vx
            local dx = proj.start_x - proj.x
            proj.y = proj.start_y + dx * dx * proj.scale
            
        elseif proj.type == "sine_wave" then
            proj.x = proj.x + proj.vx
            if proj.x >= 0 and proj.x <= 128 then
                local progress = proj.life * proj.frequency
                proj.y = proj.start_y + sin(progress + proj.phase) * proj.amplitude
                if proj.y < 10 then proj.y = 10 end
                if proj.y > 118 then proj.y = 118 end
            end
            
        elseif proj.type == "zigzag" then
            proj.x = proj.x + proj.vx
            if proj.x >= 0 and proj.x <= 128 then
                local time_steps = flr(proj.life / proj.step_size)
                if time_steps % 2 == 0 then
                    proj.direction = 1
                else
                    proj.direction = -1
                end
                local step_progress = (proj.life % proj.step_size) / proj.step_size
                proj.y = proj.start_y + proj.direction * step_progress * proj.amplitude
                if proj.y < 10 then proj.y = 10 end
                if proj.y > 118 then proj.y = 118 end
            end
            
        elseif proj.type == "ellipse" then
            proj.angle = proj.angle + proj.angular_speed
            proj.center_x = proj.center_x + proj.vx
            proj.x = proj.center_x + cos(proj.angle) * proj.a
            proj.y = proj.center_y + sin(proj.angle) * proj.b
            if proj.center_x < -5 then
                proj.center_x = 240
            end
            
        elseif proj.type == "inverse" then
            proj.x = proj.x + proj.vx
            if proj.x > 0 and proj.x <= 128 then
                local distance_from_start = abs(proj.x - 128)
                if distance_from_start > 1 then
                    proj.y = proj.start_y + proj.scale / (distance_from_start + 1)
                end
            end
            
        elseif proj.type == "heart" then
            proj.t = proj.t + 0.03
            proj.x = proj.x + proj.vx
            local heart_x = 1.5 * (16 * sin(proj.t)^3)
            local heart_y = 1.5 * (13 * cos(proj.t) - 5 * cos(2*proj.t) - 2 * cos(3*proj.t) - cos(4*proj.t))
            proj.y = proj.center_y + heart_y / 8
            
        elseif proj.type == "rose" then
            proj.t = proj.t + 0.15
            proj.center_x = proj.center_x + proj.vx
            local r = proj.a * cos(proj.k * proj.t)
            proj.x = proj.center_x + r * cos(proj.t)
            proj.y = proj.center_y + r * sin(proj.t)
            
        elseif proj.type == "butterfly" then
            proj.t = proj.t + 0.1
            proj.center_x = proj.center_x + proj.vx
            local butterfly_x = sin(proj.t) * cos(proj.t) - 2*cos(4*proj.t) - sin(proj.t/12)^5
            local butterfly_y = cos(proj.t) * cos(proj.t) - 2*cos(4*proj.t) - sin(proj.t/12)^5
            proj.x = proj.center_x + butterfly_x * proj.scale
            proj.y = proj.center_y + butterfly_y * proj.scale
            
        elseif proj.type == "cycloid" then
            proj.t = proj.t + 0.08
            proj.x = proj.x + proj.vx
            proj.y = proj.start_y + 6 * (1 - cos(proj.t))
        elseif proj.type == "fractal" then
            proj.t = proj.t + 0.1
            proj.x = proj.x + proj.vx
            local fractal_y = 0
            for n = 1, proj.iterations do
                fractal_y = fractal_y + sin(proj.t * n * 2) / n
            end
            proj.y = proj.start_y + fractal_y * proj.scale
        end
        
        if proj.type == "ellipse" or proj.type == "rose" or proj.type == "butterfly" then
            if proj.center_x < -40 or proj.center_x > 170 then
                del(projectiles, proj)
            end
        else
            if proj.x < -8 or proj.x > 136 or proj.y < -8 or proj.y > 136 then
                del(projectiles, proj)
            end
        end
    end
end


function draw_projectiles()
    for proj in all(projectiles) do
        draw_shape(proj.x, proj.y, proj.shape, proj.color, 3)
    end
end

function add_trail(x, y, color, shape)
    add(trails, {
        x = x,
        y = y,
        color = color,
        shape = shape,
        life = 8
    })
end

function update_trails()
    for i = #trails, 1, -1 do
        local trail = trails[i]
        trail.life = trail.life - 1
        if trail.life <= 0 then
            del(trails, trail)
        end
    end
end

function draw_trails()
    for trail in all(trails) do
        local alpha = trail.life / 8
        local fade_color = trail.color
        if alpha < 0.5 then
            fade_color = 0
        end
        draw_shape(trail.x, trail.y, trail.shape, fade_color, 1)
    end
end

function draw_shape(x, y, shape, color, size)
    if shape == "circle" then
        circfill(x, y, size, color)
    elseif shape == "square" then
        rectfill(x-size, y-size, x+size, y+size, color)
    elseif shape == "diamond" then
        pset(x, y-size, color)
        pset(x-size, y, color)
        pset(x+size, y, color)
        pset(x, y+size, color)
        line(x, y-size, x-size, y, color)
        line(x-size, y, x, y+size, color)
        line(x, y+size, x+size, y, color)
        line(x+size, y, x, y-size, color)
    elseif shape == "triangle" then
        line(x, y-size, x-size, y+size, color)
        line(x-size, y+size, x+size, y+size, color)
        line(x+size, y+size, x, y-size, color)
    elseif shape == "plus" then
        line(x-size, y, x+size, y, color)
        line(x, y-size, x, y+size, color)
    elseif shape == "heart" then
        circfill(x-1, y-1, 1, color)
        circfill(x+1, y-1, 1, color)
        pset(x, y+2, color)
        line(x-2, y, x, y+2, color)
        line(x+2, y, x, y+2, color)
    elseif shape == "star" then
        line(x, y-size, x, y+size, color)
        line(x-size, y, x+size, y, color)
        line(x-size*0.7, y-size*0.7, x+size*0.7, y+size*0.7, color)
        line(x+size*0.7, y-size*0.7, x-size*0.7, y+size*0.7, color)
    elseif shape == "butterfly" then
        circfill(x-1, y-1, 1, color)
        circfill(x+1, y-1, 1, color)
        circfill(x-1, y+1, 1, color)
        circfill(x+1, y+1, 1, color)
        line(x, y-2, x, y+2, color)
    elseif shape == "fractal" then
        pset(x, y, color)
        pset(x-1, y-1, color)
        pset(x+1, y-1, color)
        pset(x-1, y+1, color)
        pset(x+1, y+1, color)
    else
        circfill(x, y, size, color)
    end
end

function spawn_obstacles()
    local level = levels[current_level]
    if level.obstacle_type ~= "none" and game_time - last_obstacle_time > 300 then
        add(obstacles, create_obstacle(level.obstacle_type))
        last_obstacle_time = game_time
    end
end

function create_obstacle(type)
    local obs = {
        x = rnd(100) + 14,
        y = rnd(60) + 20,
        life = 0,
        type = type,
        color = 2,
        size = 4
    }

    if type == "rotating" then
        obs.angle = 0
        obs.radius = 8
        obs.speed = 0.05
        obs.center_x = obs.x
        obs.center_y = obs.y
    elseif type == "oscillating" then
        obs.amplitude = 20
        obs.frequency = 0.02
        obs.start_x = obs.x
    elseif type == "bouncing" then
        obs.vx = rnd(2) - 1
        obs.vy = rnd(2) - 1
    elseif type == "circle" then
        obs.angle = 0
        obs.radius = 25
        obs.center_x = 64
        obs.center_y = 64
    elseif type == "lemniscata" then
        obs.a = 15
        obs.t = 0
        obs.center_x = 64
        obs.center_y = 64
    elseif type == "spiral" then
        obs.angle = 0
        obs.radius = 5
        obs.center_x = 64
        obs.center_y = 64
    elseif type == "pendulum" then
        obs.length = 30
        obs.angle = 1
        obs.angular_vel = 0
        obs.gravity = 0.01
        obs.center_x = 64
        obs.center_y = 30
    end

    return obs
end

function update_obstacles()
    for i = #obstacles, 1, -1 do
        local obs = obstacles[i]
        obs.life = obs.life + 1

        if obs.type == "rotating" then
            obs.angle = obs.angle + obs.speed
            obs.x = obs.center_x + cos(obs.angle) * obs.radius
            obs.y = obs.center_y + sin(obs.angle) * obs.radius
        elseif obs.type == "oscillating" then
            obs.x = obs.start_x + sin(obs.life * obs.frequency) * obs.amplitude
        elseif obs.type == "bouncing" then
            obs.x = obs.x + obs.vx
            obs.y = obs.y + obs.vy
            if obs.x < 8 or obs.x > 120 then obs.vx = -obs.vx end
            if obs.y < 8 or obs.y > 120 then obs.vy = -obs.vy end
        elseif obs.type == "circle" then
            obs.angle = obs.angle + 0.015
            obs.x = obs.center_x + cos(obs.angle) * obs.radius
            obs.y = obs.center_y + sin(obs.angle) * obs.radius
        elseif obs.type == "lemniscata" then
            obs.t = obs.t + 0.02
            local cos_t = cos(obs.t)
            local denom = 1 + sin(obs.t) * sin(obs.t)
            obs.x = obs.center_x + obs.a * cos_t / denom
            obs.y = obs.center_y + obs.a * sin(obs.t) * cos_t / denom
        elseif obs.type == "spiral" then
            obs.angle = obs.angle + 0.05
            obs.radius = obs.radius + 0.1
            obs.x = obs.center_x + cos(obs.angle) * obs.radius
            obs.y = obs.center_y + sin(obs.angle) * obs.radius
        elseif obs.type == "pendulum" then
            obs.angular_vel = obs.angular_vel + (-obs.gravity / obs.length) * sin(obs.angle)
            obs.angle = obs.angle + obs.angular_vel
            obs.x = obs.center_x + sin(obs.angle) * obs.length
            obs.y = obs.center_y + cos(obs.angle) * obs.length
        end
        if obs.life > 1800 or obs.x < -16 or obs.x > 144 or obs.y < -16 or obs.y > 144 then
            del(obstacles, obs)
        end
    end
end

function draw_obstacles()
    for obs in all(obstacles) do
        rectfill(obs.x - obs.size/2, obs.y - obs.size/2, 
                obs.x + obs.size/2, obs.y + obs.size/2, obs.color)
        rect(obs.x - obs.size/2, obs.y - obs.size/2, 
             obs.x + obs.size/2, obs.y + obs.size/2, obs.color + 6)
    end
end

function check_projectile_collisions()
    if player.invulnerable > 0 then return end

    for proj in all(projectiles) do
        if collision_check(player.x, player.y, player.w, player.h,
                          proj.x - 2, proj.y - 2, 4, 4) then
            player.lives = player.lives - 1
            player.invulnerable = 60
            del(projectiles, proj)

            if player.lives <= 0 then
                final_score = calculate_score()
                game_over = true
                score_display_timer = 0
            end
            break
        end
    end
end

function check_obstacle_collisions()
    if player.invulnerable > 0 then return end

    for obs in all(obstacles) do
        if collision_check(player.x, player.y, player.w, player.h,
                          obs.x - obs.size/2, obs.y - obs.size/2, obs.size, obs.size) then
            player.lives = player.lives - 1
            player.invulnerable = 60
            del(obstacles, obs)

            if player.lives <= 0 then
                final_score = calculate_score()
                game_over = true
                score_display_timer = 0
            end
            break
        end
    end
end

function collision_check(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

function player_update()
    if btn(0) then
        player.vx = -player.speed
    elseif btn(1) then
        player.vx = player.speed
    else
        player.vx = player.vx * 0.8
    end

    if btnp(2) and player.on_ground then
        player.vy = -player.jump_power
        player.on_ground = false
    end

    if not player.on_ground then
        player.vy = player.vy + player.gravity
    end

    player.x = player.x + player.vx
    player.y = player.y + player.vy

    if player.x < 0 then
        player.x = 0
        player.vx = 0
    elseif player.x > 128 - player.w then
        player.x = 128 - player.w
        player.vx = 0
    end

    player_check_ground_collision()
end

function player_check_ground_collision()
    local level = levels[current_level]
    local t = (player.x + player.w/2) / 128 * level.frequency + fase
    local ground_y = level.offset - sin(t) * level.sen_amplifier

    local tolerance = 3

    if player.y + player.h >= ground_y - tolerance then
        if player.vy >= 0 then
            player.y = ground_y - player.h
            player.vy = 0
        end
        player.on_ground = true
    else
        player.on_ground = false
    end

    if player.y < 0 then
        player.y = 0
        player.vy = 0
    end
end

function player_draw()
    local color = player.color
    if player.invulnerable > 0 and player.invulnerable % 8 < 4 then
        color = 7
    end

    rectfill(player.x, player.y, player.x + player.w - 1, player.y + player.h - 1, color)
    pset(player.x + 2, player.y + 2, 7)
    pset(player.x + 4, player.y + 2, 7)
end

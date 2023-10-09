local hidapi = require 'hidapi.hidapi'
local hidlib = require 'hidapi.hidlib'
local joycon = require 'joyconlib'
local raylib = require 'raylib.raylib'
local rl = raylib.raylib
local rlcolor = raylib.rlcolor
local ffi = require 'ffi'

local init_c = function()
  ffi.cdef [[
    int usleep(unsigned int  microseconds);
  ]]
end

init_c()

local init_joycon = function()
  local dev = hidapi.hid_open(joycon.vendor_id_l, joycon.product_id_l, nil)

  if dev == nil then
    print 'cannot open device'
    hidapi.hid_exit()
    os.exit(1)
  end

  -- enable nonblocking
  hidapi.hid_set_nonblocking(dev, 1)

  joycon.enable_imu(dev)
  ffi.C.usleep(200 * 1000)
  joycon.standard_full_mode(dev)

  return dev
end

-- window
local win = {}
win.w = 800
win.h = 640
win.title = 'My Raylib Window'

-- data queues
axq = {}
ayq = {}
azq = {}
g1q = {}
g2q = {}
g3q = {}

local fps = 60
local duration = 10
local q_max_length = fps * duration

local insert_queue = function(queue, value)
  table.insert(queue, value)
  if(#queue > q_max_length) then
    table.remove(queue, 1)
  end
end

local raw_to_percent = function(val)
  return (val + 32768) / 65536
end

local draw_chart = function(base_x, base_y, base_w, base_h)
  rl.DrawRectangleLines(base_x, base_y, base_w, base_h, rlcolor.BLACK)

  local draw_lines = function(queue, color)
    local width = base_w / q_max_length
    local prev_x = base_x
    local cur_x = base_x + width

    for i,v in pairs(queue) do
      local prev = 0
      if i ~= 1 then
        prev = queue[i - 1]
      end

      local prev_y = base_y + base_h * (1 - prev)
      local cur_y = base_y + base_h * (1 - v)

      rl.DrawLine(prev_x, prev_y, cur_x, cur_y, color)

      prev_x = cur_x
      cur_x = cur_x + width
    end

  end

  draw_lines(axq, rlcolor.BLUE)
  draw_lines(ayq, rlcolor.BROWN)
  draw_lines(azq, rlcolor.GREEN)
  draw_lines(g1q, rlcolor.MAGENTA)
  draw_lines(g2q, rlcolor.PINK)
  draw_lines(g3q, rlcolor.ORANGE)

end

local draw = function(buf)
  local ax = raw_to_percent(joycon.get_accel_x(buf))
  local ay = raw_to_percent(joycon.get_accel_y(buf))
  local az = raw_to_percent(joycon.get_accel_z(buf))
  local g1 = raw_to_percent(joycon.get_gyro_1(buf))
  local g2 = raw_to_percent(joycon.get_gyro_2(buf))
  local g3 = raw_to_percent(joycon.get_gyro_3(buf))

  insert_queue(axq, ax)
  insert_queue(ayq, ay)
  insert_queue(azq, az)
  insert_queue(g1q, g1)
  insert_queue(g2q, g2)
  insert_queue(g3q, g3)

  rl.BeginDrawing()
  rl.ClearBackground(rlcolor.RAYWHITE)

  base = {}
  base.y = 30
  base.x = 30
  base.w = win.w - base.y * 2
  base.h = win.h - base.x * 2

  draw_chart(base.x, base.y, base.w, base.h)

  rl.EndDrawing()
end

local main = function()
  rl.InitWindow(win.w, win.h, win.title)

  -- 60 FPS
  rl.SetTargetFPS(60)

  local dev = init_joycon()

  -- read buffer
  local rlen = 49
  local rbuf = hidlib.create_uchar_buffer(rlen)

  while not rl.WindowShouldClose() do
    rbuf:bzero()
    if 0 ~= hidapi.hid_read(dev, rbuf.buf, rbuf.length) then
      draw(rbuf.buf)
    end
  end

  rl.CloseWindow()
end

main()

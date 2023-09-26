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
win.w = 600
win.h = 400
win.title = 'My Raylib Window'

local draw = function(buf)
  local ax = (joycon.get_accel_x(buf) + 32768) / 65536
  local ay = (joycon.get_accel_y(buf) + 32768) / 65536
  local az = (joycon.get_accel_z(buf) + 32768) / 65536
  local g1 = (joycon.get_gyro_1(buf) + 32768) / 65536
  local g2 = (joycon.get_gyro_2(buf) + 32768) / 65536
  local g3 = (joycon.get_gyro_3(buf) + 32768) / 65536

  rl.BeginDrawing()
  rl.ClearBackground(rlcolor.RAYWHITE)

  base = {}
  base.y = 30
  base.x = 30
  base.w = win.w - base.y * 2 -- 560
  base.h = win.h - base.x * 2 - 30 -- 360

  local draw_bar = function(x, val, name)
    -- draw bar
    local x = x
    local y = base.y + base.h * (1 - val)
    local w = base.w / 6 * 0.8
    local h = base.h * val
    rl.DrawRectangle(x, y, w, h, rlcolor.BLUE)

    -- draw label
    local x = x + 20
    local y = base.y + base.h + 10
    local h = 30
    local c = rlcolor.GRAY
    local t = name
    rl.DrawText(t, x, y, h, c)
  end

  -- ax
  local x = base.x
  local val = ax
  local name = 'ax'
  draw_bar(x, val, name)

  -- ay
  local x = base.x + base.w / 6 * 1
  local val = ay
  local name = 'ay'
  draw_bar(x, val, name)

  -- az
  local x = base.x + base.w / 6 * 2
  local val = az
  local name = 'az'
  draw_bar(x, val, name)

  -- g1
  local x = base.x + base.w / 6 * 3
  local val = g1
  local name = 'g1'
  draw_bar(x, val, name)

  -- g2
  local x = base.x + base.w / 6 * 4
  local val = g2
  local name = 'g2'
  draw_bar(x, val, name)

  -- g3
  local x = base.x + base.w / 6 * 5
  local val = g3
  local name = 'g3'
  draw_bar(x, val, name)

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

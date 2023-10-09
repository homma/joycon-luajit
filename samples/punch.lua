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

local draw = function(buf)
  local ax = joycon.get_accel_x(buf)

  rl.BeginDrawing()
  rl.ClearBackground(rlcolor.RAYWHITE)

  base = {}
  base.y = 30
  base.x = 30
  base.w = win.w - base.y * 2
  base.h = win.h - base.x * 2

  local punch = 8000
  if ax > punch then
    rl.DrawRectangle(base.x, base.y, base.w, base.h, rlcolor.BLUE)
  end

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

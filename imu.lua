local hidapi = require 'hidapi'
local hidlib = require 'hidlib'
local joycon = require 'joycon'
local ffi = require 'ffi'

local init_c = function()
  ffi.cdef [[
    int usleep(unsigned int  microseconds);
  ]]
end

init_c()

local main = function()
  local dev = hidapi.hid_open(joycon.vendor_id_l, joycon.product_id_l, nil)

  if dev == nil then
    print 'cannot open device'
    hidapi.hid_exit()
    os.exit(1)
  end

  joycon.enable_imu(dev)
  ffi.C.usleep(200 * 1000)
  joycon.standard_full_mode(dev)

  -- read buffer
  local rlen = 49
  local rbuf = hidlib.create_uchar_buffer(rlen)

  -- read
  while true do
    rbuf:bzero()
    hidapi.hid_read(dev, rbuf.buf, rbuf.length)

    joycon.print_imu(rbuf.buf)
  end
end

main()

local hidapi = require 'hidapi'
local hidlib = require 'hidlib'
local joycon = require 'joycon'

local main = function()
  local dev = hidapi.hid_open(joycon.vendor_id_l, joycon.product_id_l, nil)

  if dev == nil then
    print 'cannot open device'
    hidapi.hid_exit()
    os.exit(1)
  end

  joycon.simple_hid_mode(dev)

  -- read buffer
  local rlen = 12
  local rbuf = hidlib.create_uchar_buffer(rlen)

  -- read
  while true do
    rbuf:bzero()
    hidapi.hid_read(dev, rbuf.buf, rbuf.length)

    rbuf:hex_print()
  end
end

main()

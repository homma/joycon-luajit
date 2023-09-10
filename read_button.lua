local hidapi = require 'hidapi'
local hidlib = require 'hidlib'

-- product_string Joy-Con (L)
local vendor_id_l = 1406
local product_id_l = 8198

local main = function()
  local dev = hidapi.hid_open(vendor_id_l, product_id_l, nil)

  if dev == nil then
    print 'cannot open device'
    hidapi.hid_exit()
    os.exit(1)
  end

  local output_1 = 0x1
  local global_packet_number = 0

  -- write buffer
  local wlen = 64
  local wbuf = hidlib.create_uchar_buffer(wlen)
  wbuf:bzero()
  wbuf.buf[0] = output_1
  wbuf.buf[1] = global_packet_number
  wbuf.buf[2] = 0x0
  wbuf.buf[3] = 0x1
  wbuf.buf[4] = 0x4
  wbuf.buf[5] = 0x4
  wbuf.buf[6] = 0x0
  wbuf.buf[7] = 0x1
  wbuf.buf[8] = 0x4
  wbuf.buf[9] = 0x4
  wbuf.buf[10] = 0x3
  wbuf.buf[11] = 0x3f

  -- write
  hidapi.hid_write(dev, wbuf.buf, wbuf.length)

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

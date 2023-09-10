local hidapi = require 'hidapi'
local hidlib = require 'hidlib'

local main = function()
  -- look up hid devices
  local dev = hidapi.hid_enumerate(0, 0)

  while true do
    hidlib.print_hid_device_info(dev)

    if dev.next == nil then
      break
    else
      dev = dev.next
    end
  end
end

main()

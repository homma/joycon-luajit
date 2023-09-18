local hidapi = require 'hidapi.hidapi'
local hidlib = require 'hidapi.hidlib'
local bit = require 'bit'

local M = {}

-- Joy-Con (L)
M.vendor_id_l = 1406
M.product_id_l = 8198
M.x_default_l = 350
M.z_default_l = 4081

-- Joy-Con (R)
M.x_default_r = 350
M.z_default_r = -4081

-- global packet number
local _global_packet_number = 0
M.global_packet_number = function()
  _global_packet_number = _global_packet_number + 1 % 16
  return _global_packet_number
end

-- command
M.command = {}
M.command.output_1 = 0x1

-- subcommand for command.output_1
M.subcommand = {}
M.subcommand.set_input_report_mode = 0x3
M.subcommand.enable_imu = 0x40

-- input report mode
-- command = command.output_1
-- subcommand = subcommand.set_input_report_mode

local set_input_report_mode = function(dev, arg)
  local gpn = M.global_packet_number()

  -- write buffer
  local wlen = 64
  local wbuf = hidlib.create_uchar_buffer(wlen)
  wbuf:bzero()
  wbuf.buf[0] = M.command.output_1
  wbuf.buf[1] = gpn
  wbuf.buf[2] = 0x0
  wbuf.buf[3] = 0x0
  wbuf.buf[4] = 0x0
  wbuf.buf[5] = 0x0
  wbuf.buf[6] = 0x0
  wbuf.buf[7] = 0x0
  wbuf.buf[8] = 0x0
  wbuf.buf[9] = 0x0
  wbuf.buf[10] = M.subcommand.set_input_report_mode
  wbuf.buf[11] = arg

  -- write
  hidapi.hid_write(dev, wbuf.buf, wbuf.length)
end

-- standard full mode
M.standard_full_mode = function(dev)
  -- argument = 0x30
  set_input_report_mode(dev, 0x30)
end

-- simple HID mode
M.simple_hid_mode = function(dev)
  -- argument = 0x3F
  set_input_report_mode(dev, 0x3F)
end

-- imu on/off
local toggle_imu = function(dev, enable)
  local gpn = M.global_packet_number()

  -- write buffer
  local wlen = 64
  local wbuf = hidlib.create_uchar_buffer(wlen)
  wbuf:bzero()
  wbuf.buf[0] = M.command.output_1
  wbuf.buf[1] = gpn
  wbuf.buf[2] = 0x0
  wbuf.buf[3] = 0x0
  wbuf.buf[4] = 0x0
  wbuf.buf[5] = 0x0
  wbuf.buf[6] = 0x0
  wbuf.buf[7] = 0x0
  wbuf.buf[8] = 0x0
  wbuf.buf[9] = 0x0
  wbuf.buf[10] = M.subcommand.enable_imu
  wbuf.buf[11] = enable

  -- write
  hidapi.hid_write(dev, wbuf.buf, wbuf.length)
end

M.disable_imu = function(dev)
  toggle_imu(dev, 0)
end

M.enable_imu = function(dev)
  toggle_imu(dev, 1)
end

M.get_accel_x = function(buf)
  b0 = buf[13]
  b1 = buf[14]

  local raw = bit.bor(bit.lshift(b1, 8), b0)
  -- to uint16 : -32768 ~ 32767
  local result = (raw <= 32767) and raw or raw - 65536
  -- L
  result = result - M.x_default_l
  return result
end

M.get_accel_y = function(buf)
  b0 = buf[15]
  b1 = buf[16]

  local raw = bit.bor(bit.lshift(b1, 8), b0)
  local result = (raw <= 32767) and raw or raw - 65536
  return result
end

M.get_accel_z = function(buf)
  b0 = buf[17]
  b1 = buf[18]

  local raw = bit.bor(bit.lshift(b1, 8), b0)
  local result = (raw <= 32767) and raw or raw - 65536
  -- L
  result = result - M.z_default_l
  return result
end

M.get_gyro_1 = function(buf)
  b0 = buf[19]
  b1 = buf[20]

  local raw = bit.bor(bit.lshift(b1, 8), b0)
  local result = (raw <= 32767) and raw or raw - 65536
  return result
end

M.get_gyro_2 = function(buf)
  b0 = buf[21]
  b1 = buf[22]

  local raw = bit.bor(bit.lshift(b1, 8), b0)
  local result = (raw <= 32767) and raw or raw - 65536
  return result
end

M.get_gyro_3 = function(buf)
  b0 = buf[23]
  b1 = buf[24]

  local raw = bit.bor(bit.lshift(b1, 8), b0)
  local result = (raw <= 32767) and raw or raw - 65536
  return result
end

M.print_imu = function(buf)
  local ax = M.get_accel_x(buf)
  local ay = M.get_accel_y(buf)
  local az = M.get_accel_z(buf)
  local g1 = M.get_gyro_1(buf)
  local g2 = M.get_gyro_2(buf)
  local g3 = M.get_gyro_3(buf)

  print(
    string.format(
      'ax: %05d ay: %05d az: %05d g1: %05d g2: %05d g3: %05d',
      ax,
      ay,
      az,
      g1,
      g2,
      g3
    )
  )
end

return M

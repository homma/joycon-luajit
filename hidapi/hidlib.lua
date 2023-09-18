local ffi = require 'ffi'

local M = {}

local init_c = function()
  -- additional libc function
  ffi.cdef [[
    size_t wcstombs(char * dest, const wchar_t * src, size_t n);
    void bzero(void *s, size_t n);
  ]]
end

local init_module = function()
  init_c()
end

-- char buffer
M.create_char_buffer = function(size)
  return ffi.new('char[?]', size)
end

-- unsigned char buffer
local UCharBuffer = {}

function UCharBuffer:new(size)
  local obj = {}
  obj.length = size
  obj.buf = ffi.new('unsigned char[?]', size)

  setmetatable(obj, self)
  self.__index = self

  return obj
end

function UCharBuffer:bzero()
  ffi.C.bzero(self.buf, self.length)
end

function UCharBuffer:hex_print()
  local str = ''
  for i = 0, self.length do
    str = str .. string.format('%02X ', self.buf[i])
  end
  print(str)
end

M.create_uchar_buffer = function(size)
  return UCharBuffer:new(size)
end

-- wchar buffer
M.create_wchar_buffer = function(size)
  return ffi.new('wchar_t[?]', size)
end

M.wchar_to_string = function(str)
  local wchar_size = ffi.sizeof 'wchar_t'
  local len = ffi.C.wcslen(str)
  local buf = M.create_char_buffer(len * wchar_size)
  ffi.C.wcstombs(buf, str, len)

  return ffi.string(buf)
end

M.print_hid_device_info = function(dev)
  print '\n== DEVICE =='
  print('path                 ' .. ffi.string(dev.path))
  print('vendor_id            ' .. dev.vendor_id)
  print('product_id           ' .. dev.product_id)
  print('serial_number        ' .. M.wchar_to_string(dev.serial_number))
  print('release_number       ' .. dev.release_number)
  print('manufacturer_string  ' .. M.wchar_to_string(dev.manufacturer_string))
  print('product_string       ' .. M.wchar_to_string(dev.product_string))
  print('usage_page           ' .. dev.usage_page)
  print('usage                ' .. dev.usage)
  print('interface_number     ' .. dev.interface_number)
end

init_module()

return M
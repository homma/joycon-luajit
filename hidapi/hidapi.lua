local ffi = require 'ffi'

local hidapi

local init_ffi = function()
  -- initialize ffi
  local f = io.open('ext/hidapi.cdef', 'r')
  local cdefs = f:read 'a'
  ffi.cdef(cdefs)

  hidapi = ffi.load 'hidapi'
end

local init_hidapi = function()
  -- initialize hidapi
  hidapi.hid_init()
  hidapi.hid_darwin_set_open_exclusive(0)
end

local init_module = function()
  init_ffi()
  init_hidapi()
end

init_module()

return hidapi

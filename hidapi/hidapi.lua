local ffi = require 'ffi'

local basename = function(path)
  local p = {}
  for w in string.gmatch(path, '[^/]+') do
    table.insert(p, w)
  end
  table.remove(p)
  local base = table.concat(p, '/')
  return base
end

local script_dir = basename(debug.getinfo(1).short_src) .. '/'

local hidapi

local init_ffi = function()
  -- initialize ffi
  local f = io.open(script_dir .. 'ext/hidapi.cdef', 'r')
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

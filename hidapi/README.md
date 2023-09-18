#### About

Sample codes using [HIDAPI library](https://github.com/libusb/hidapi) from LuaJIT on macOS

#### Prerequisites

- macOS
- [clang](https://clang.llvm.org)
- [hidapi](https://github.com/libusb/hidapi) (ex. `brew install hidapi`)
- [luajit](https://luajit.org) (ex. `brew install luajit`)

#### Preparation

generate the cdef file as below.

````sh
$ ./gen_hidapi_cdef.sh
````

#### Usage

````sh
$ luajit samples/dump_hid_device_info.lua
````

#### Files

`hidapi.lua`

A Lua module which offers an interface to the HIDAPI library.

`hidlib.lua`

A supplemental module to the hidapi module.

`gen_hidapi_cdef.sh`

A shell script to generate a C definition file for LuaJIT FFI.

`hidapi_umbrella.h`

An umbrella header file which includes necessary header files.

`dump_hid_device_info.lua`

A sample Lua script which uses HIDAPI library.

#### Licenses

- `LICENSE.hidapi-luajit` except generated ext/hidapi.cdef file.
- `LICENSE.hidapi` for generated ext/hidapi.cdef file.


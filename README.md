
#### About

Using Joy-Con from LuaJIT on macOS

#### Prerequistes

- macOS
- [clang](https://clang.llvm.org)
- [luajit](https://luajit.org) (ex. `brew install luajit`)
- [hidapi](https://github.com/libusb/hidapi) (ex. `brew install hidapi`)
- [raylib](https://www.raylib.com) (ex. `brew install raylib`)

#### Preparation

generate necessary files as below.

````sh
$ cd hidapi
$ ./gen_hidapi_cdef.sh
$ cd ..
````

````sh
$ cd raylib
$ ./gen_raylib_cdef.sh
$ cd ext
$ ./gen_raylib_color.sh
$ cd ../..
````

#### Usage

````sh
$ luajit samples/imu_graph.lua
````

#### Licenses

- read `hidapi/README.md` for files under `hidapi` directory
- read `raylib/README.md` for files under `raylib` directory
- `LICENSE.joycon-luajit` for other files

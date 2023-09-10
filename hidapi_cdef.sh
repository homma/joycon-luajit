#!/bin/sh -x

# generates cdef file to be used by luajit ffi

# system include path
BASE=/Library/Developer/CommandLineTools
SDK_INCLUDE=${BASE}/SDKs/MacOSX.sdk/usr/include

# toolchain include path
CLANG_VER=$(clang -dumpversion)
TOOL_INCLUDE=${BASE}/usr/lib/clang/${CLANG_VER}/include

# hidapi include path
# we assume it is installed with Homebrew (brew install hidapi)
HIDAPI_INCLUDE=$(brew --prefix hidapi)/include/hidapi

# umbrella header file
TARGET=hidapi_umbrella.h

OUTPUT=hidapi.cdef

# generates cdefs from header files
clang -cc1 -ast-print \
-I ${SDK_INCLUDE} -I ${TOOL_INCLUDE} -I ${HIDAPI_INCLUDE} \
-D _VA_LIST \
${TARGET} \
| sed 's/_Nullable//' \
| sed 's/__attribute__((.*))//' > ${OUTPUT}

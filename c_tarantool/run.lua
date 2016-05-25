#!/usr/bin/env tarantool

local ffi = require('ffi')
local lib = ffi.load('taran.dylib')
ffi.cdef[[int main();]]

lib.main()

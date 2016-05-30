git clone https//github.com/tarantool/tarantool

clang -dynamiclib -undefined dynamic_lookup -o libtaran.dylib skynet.c \
  -std=c11 \
  -I$(pwd)/tarantool \
  -I$(pwd)/tarantool/src \
  -I$(pwd)/tarantool/src/lib/small \
  -I$(pwd)/tarantool/third_party 
  
chmod +x ./run.lua && ./run.lua 

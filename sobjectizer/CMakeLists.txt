cmake_minimum_required(VERSION 2.8)

# Extract SO_5_VERSION from version.rb
set(SO_5_VERSION "")

file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/so_5/version.rb"
     _SO_5_VERSION_RB_CONTENTS
     REGEX "^[ \t]*VERSION[ \t]*=[ \t]*\"[0-9]+[.][0-9]+[.][0-9]+[^\"]*\"[ \t]*")

set(_SO_5_VERSION_REGEX "\"([0-9.]+)\"")
if("${_SO_5_VERSION_RB_CONTENTS}" MATCHES "^[ \t]*VERSION[ \t]*=[ \t]*${_SO_5_VERSION_REGEX}[ \t]*")
    set(SO_5_VERSION "${CMAKE_MATCH_1}")
else()
    message("Failed extract version information from ${CMAKE_CURRENT_SOURCE_DIR}/so_5/version.rb")
    message("_SO_5_VERSION_RB_CONTENTS :${_SO_5_VERSION_RB_CONTENTS}:")
    message(FATAL_ERROR "SO_5_VERSION \"${SO_5_VERSION}\"")
endif()

if ("x${CMAKE_CXX_COMPILER_ID}" MATCHES "xGNU"
     OR "x${CMAKE_CXX_COMPILER_ID}" MATCHES "xClang"
     OR "x${CMAKE_CXX_COMPILER_ID}" MATCHES "xIntel"
)
	add_definitions(-std=c++11 -pthread -mtune=native -march=native -Wall)
	set(CMAKE_EXE_LINKER_FLAGS "-pthread")
	set(CMAKE_SHARED_LINKER_FLAGS "-pthread")
else ()
    message(FATAL_ERROR "Your C++ compiler is not supported.")
endif ()

include_directories( ${CMAKE_CURRENT_LIST_DIR} )

add_subdirectory(so_5)

add_executable(skynet1m skynet1m.cpp)
target_link_libraries(skynet1m so.${SO_5_VERSION})
install(TARGETS skynet1m DESTINATION bin)

add_executable(skynet1m-tp_disp skynet1m-tp_disp.cpp)
target_link_libraries(skynet1m-tp_disp so.${SO_5_VERSION})
install(TARGETS skynet1m-tp_disp DESTINATION bin)


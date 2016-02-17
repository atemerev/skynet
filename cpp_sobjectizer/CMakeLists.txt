cmake_minimum_required(VERSION 2.8)

include(ExternalProject)

ExternalProject_add(so_5_prj
	SVN_REPOSITORY http://svn.code.sf.net/p/sobjectizer/repo/tags/so_5/5.5.15.2/dev
	CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
				-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
	INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
	LOG_DOWNLOAD ON
	LOG_CONFIGURE ON
	LOG_BUILD ON
)

# Extract SO_5_VERSION from version.rb
set(SO_5_VERSION "5.5.15.2")

if ("x${CMAKE_CXX_COMPILER_ID}" MATCHES "xGNU"
     OR "x${CMAKE_CXX_COMPILER_ID}" MATCHES "xClang"
     OR "x${CMAKE_CXX_COMPILER_ID}" MATCHES "xIntel"
)
	add_definitions(-std=c++11 -pthread -mtune=native -march=native -Wall)
	set(CMAKE_EXE_LINKER_FLAGS "-pthread")
	set(CMAKE_SHARED_LINKER_FLAGS "-pthread")
elseif (${MSVC})
    # message("Using MSVC compiler!!!")
else ()
    message(FATAL_ERROR "Your C++ compiler is not supported.")
endif ()

ExternalProject_Get_Property(so_5_prj source_dir)
ExternalProject_Get_Property(so_5_prj binary_dir)
include_directories( ${CMAKE_CURRENT_LIST_DIR} )
include_directories( ${source_dir} )
link_directories( ${binary_dir}/so_5 )

add_executable(skynet1m skynet1m.cpp)
add_dependencies(skynet1m so_5_prj)
target_link_libraries(skynet1m so.${SO_5_VERSION})
install(TARGETS skynet1m DESTINATION bin)

add_executable(skynet1m-tp_disp skynet1m-tp_disp.cpp)
add_dependencies(skynet1m-tp_disp so_5_prj)
target_link_libraries(skynet1m-tp_disp so.${SO_5_VERSION})
install(TARGETS skynet1m-tp_disp DESTINATION bin)


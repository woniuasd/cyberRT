cmake_minimum_required(VERSION 3.14)
project(cyber CXX ASM)

#第三方库
find_package(fastrtps REQUIRED)
find_package(fastcdr REQUIRED)
find_package(Protobuf REQUIRED)
include_directories(${FASTRTPS_INCLUDE_DIRS}
					${FASTCDR_INCLUDE_DIRS}
					${PROTOBUF_INCLUDE_DIR}
					${CMAKE_CURRENT_SOURCE_DIR})

set(BUILD_TYPE Debug) # Debug or Release
if(BUILD_TYPE STREQUAL "Debug")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g")
else()
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O2")	
endif()

set(CMAKE_CXX_STANDARD 14)

#protobuf代码生成
file(GLOB PROTO_FILES ${CMAKE_CURRENT_SOURCE_DIR}/cyber/proto/*.proto)
foreach(PROTO_FILE ${PROTO_FILES})
	execute_process(
		COMMAND protoc --proto_path=${CMAKE_CURRENT_SOURCE_DIR} -I=${CMAKE_CURRENT_SOURCE_DIR}/cyber/proto
		 --cpp_out=${CMAKE_CURRENT_SOURCE_DIR} ${PROTO_FILE}
		)
endforeach()

file(GLOB_RECURSE ALL_SRC ${CMAKE_CURRENT_SOURCE_DIR}/cyber/*.cc)
#examples
file(GLOB_RECURSE EXAMPLES_SRC ${CMAKE_CURRENT_SOURCE_DIR}/cyber/examples/*.cc)
#test
file(GLOB_RECURSE ALL_TEST ${CMAKE_CURRENT_SOURCE_DIR}/cyber/*_test.cc)
#python接口
file(GLOB_RECURSE PYTHON_INTERFACE_SRC ${CMAKE_CURRENT_SOURCE_DIR}/cyber/python/*.cc)
#io example
file(GLOB_RECURSE IO_EXAMPLE_SRC ${CMAKE_CURRENT_SOURCE_DIR}/cyber/io/example/*.cc)
#tools
file(GLOB_RECURSE TOOLS_SRC ${CMAKE_CURRENT_SOURCE_DIR}/cyber/tools/*.cc)

#移除相关代码
list(REMOVE_ITEM ALL_SRC ${ALL_TEST})
list(REMOVE_ITEM ALL_SRC ${EXAMPLES_SRC})
list(REMOVE_ITEM ALL_SRC ${PYTHON_INTERFACE_SRC})
list(REMOVE_ITEM ALL_SRC ${IO_EXAMPLE_SRC})
list(REMOVE_ITEM ALL_SRC ${TOOLS_SRC})
#添加汇编代码
if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "x86_64")
	list(APPEND ALL_SRC ${CMAKE_CURRENT_SOURCE_DIR}/cyber/croutine/detail/swap_x86_64.S)
elseif(${CMAKE_SYSTEM_PROCESSOR} MATCHES "aarch64")
	list(APPEND ALL_SRC ${CMAKE_CURRENT_SOURCE_DIR}/cyber/croutine/detail/swap_aarch64.S)
else()
	message(FATAL_ERROR "system processor not supported ")
endif()

add_library(cyber SHARED ${ALL_SRC})
target_link_libraries(cyber ${PROTOBUF_LIBRARIES} fastrtps fastcdr glog rt atomic uuid dl)

#protobuf代码生成
file(GLOB EXAMPLES_PROTO_FILES ${CMAKE_CURRENT_SOURCE_DIR}/proto/*.proto)
foreach(PROTO_FILE ${EXAMPLES_PROTO_FILES})
	execute_process(
		COMMAND protoc -I=${CMAKE_CURRENT_SOURCE_DIR}/proto
		 --cpp_out=${CMAKE_CURRENT_SOURCE_DIR}/proto ${PROTO_FILE})
endforeach()
file(GLOB EXAMPLES_PROTO_GEN ${CMAKE_CURRENT_SOURCE_DIR}/proto/*.pb.cc)

add_executable(talker  ${CMAKE_CURRENT_SOURCE_DIR}/talker.cc
                       ${EXAMPLES_PROTO_GEN})
target_link_libraries(talker cyber)

add_executable(listener  ${CMAKE_CURRENT_SOURCE_DIR}/listener.cc
                         ${EXAMPLES_PROTO_GEN})
target_link_libraries(listener cyber)

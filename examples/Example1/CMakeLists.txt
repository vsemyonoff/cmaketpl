cmake_minimum_required (VERSION 3.1 FATAL_ERROR)

project ("example1")

if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
    list (APPEND CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/../build/package/lib/cmake")
    find_package (Example REQUIRED)
    set (LIB_TYPE "static")
endif ()

add_executable ("${PROJECT_NAME}" "${PROJECT_NAME}.cpp")
target_link_libraries ("${PROJECT_NAME}" Example::library::${LIB_TYPE})

if (INSTALL_EXAMPLES)
    install (TARGETS "${PROJECT_NAME}" RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
endif ()

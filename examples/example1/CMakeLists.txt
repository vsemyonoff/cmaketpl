cmake_minimum_required (VERSION 3.1 FATAL_ERROR)

project (mylib_example)

#list (APPEND CMAKE_MODULE_PATH "$ENV{XDG_HOME}/lib/cmake")
if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
    find_package (MyLib)
endif ()

add_executable(mylib_example "mylib_example.cpp")
target_link_libraries("mylib_example" Example::mylib::shared)

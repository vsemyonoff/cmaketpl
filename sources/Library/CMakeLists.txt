project("Library" VERSION "1.0.0")

set (SOURCES
    "include/Example/Library/Library.hpp"
    "src/Library.cpp"
    )

add_config ("Config.hpp.in" "Config.hpp"
    "${CMAKE_INSTALL_INCLUDEDIR}/${CMAKE_PROJECT_NAME}/${PROJECT_NAME}")

add_custom_library ("${PROJECT_NAME}" "${SOURCES}" "include")

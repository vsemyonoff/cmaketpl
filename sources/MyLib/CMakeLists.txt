project("MyLib" VERSION "1.0.0")

set (SRC_LIST
    "include/MyLib/MyLib.hpp"
    "src/MyLib.cpp"
    )

add_config ("Config.hpp.in" "Config.hpp"
	"${CMAKE_INSTALL_INCLUDEDIR}/${CMAKE_PROJECT_NAME}/${PROJECT_NAME}")

add_custom_library ("${PROJECT_NAME}" "${SRC_LIST}" "include")

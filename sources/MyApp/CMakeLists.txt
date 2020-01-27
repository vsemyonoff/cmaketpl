project ("MyApp")

add_application("${PROJECT_NAME}" "MyApp.cpp" "Example::mylib::${LIB_TYPE}")

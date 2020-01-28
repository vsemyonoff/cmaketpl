project ("BaseTest")

set (SRC_LIST
    "add.cpp"
    "edit.cpp"
    "list.cpp"
    "remove.cpp"
    )

add_boost_test("${PROJECT_NAME}" "${SRC_LIST}" Example::library::${LIB_TYPE})

############ Utilities

include (GNUInstallDirs)

set (BUILD_TESTING OFF CACHE BOOL "Build the testing tree.")
include (CTest)

# Add target configuration ini file:
#   infile  - input file name
#   outfile - output file name
#   ARGV2   - deploy path (optional)
function (add_config infile outfile)
	configure_file ("${infile}" "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${outfile}" @ONLY)
    if (ARGV2)
		install (FILES "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${outfile}" DESTINATION "${ARGV2}")
    endif ()
endfunction ()

# Add 'parent' as subproject if CMakeLists.txt present there or
# add all subprojects from 'parent'
function (add_dir_or_subdirs parent)
    if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${parent}/CMakeLists.txt")
        add_subdirectory ("${parent}")
    else ()
        file (GLOB SDIRS RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "${parent}/*")
        foreach (SUBDIR ${SDIRS})
            if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${SUBDIR}/CMakeLists.txt")
                add_subdirectory ("${CMAKE_CURRENT_SOURCE_DIR}/${SUBDIR}")
            endif ()
        endforeach ()
    endif ()
endfunction()

# Add custom library target:
#   name         - library name
#   sources_list - source files list
#   ARGV2        - public headers dir (optional)
#   ARGV3        - extra libraries list to link with (optional)
#   ARGV4        - private headers dir (optional)
function (add_custom_library name sources_list)
    if (DISABLE_STATIC AND DISABLE_SHARED)
        message (FATAL_ERROR "Error: both static and shared library versions disabled")
    endif ()

    string (TOLOWER "${name}" library_name)
	add_library ("${library_name}_object" OBJECT ${sources_list})
	set_target_properties ("${library_name}_object" PROPERTIES POSITION_INDEPENDENT_CODE ON)

    set (public_headers_dir "${CMAKE_CURRENT_SOURCE_DIR}")
    if (ARGV2)
        set (public_headers_dir "${public_headers_dir}/${ARGV2}")
    endif ()
	target_include_directories ("${library_name}_object" PUBLIC
        "${public_headers_dir}"
        "${ARGV4}"
		)
	if (ARGV3)
		target_link_libraries ("${library_name}_object" ${ARGV3})
	endif ()

	if (NOT DISABLE_STATIC)
		add_library ("${library_name}_static" STATIC "$<TARGET_OBJECTS:${library_name}_object>")

		set_target_properties ("${library_name}_static" PROPERTIES
			EXPORT_NAME "${library_name}::static"
			OUTPUT_NAME "${library_name}"
			)

		target_include_directories ("${library_name}_static"
			PUBLIC
			"$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${CMAKE_PROJECT_NAME}>"
			"$<BUILD_INTERFACE:${public_headers_dir}>"
			)

		if (ARGV3)
			target_link_libraries ("${library_name}_static" ${ARGV3})
		endif ()

		install (TARGETS "${library_name}_static" EXPORT "${name}Config"
            ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
            )

            export(TARGETS "${library_name}_static" NAMESPACE "${CMAKE_PROJECT_NAME}::"
            FILE "${CMAKE_CURRENT_BINARY_DIR}/${name}Config.cmake"
            )

		add_library("${CMAKE_PROJECT_NAME}::${library_name}::static" ALIAS "${library_name}_static")
    endif ()


    if (NOT DISABLE_SHARED)
		add_library ("${library_name}_shared" SHARED "$<TARGET_OBJECTS:${library_name}_object>")

        set (lib_version "${CMAKE_PROJECT_VERSION}")
        if (PROJECT_VERSION)
			set (lib_version "${PROJECT_VERSION}")
		endif ()

		set_target_properties ("${library_name}_shared" PROPERTIES
            VERSION "${lib_version}"
			EXPORT_NAME "${library_name}::shared"
			OUTPUT_NAME "${library_name}"
            )

		target_include_directories ("${library_name}_shared"
			PUBLIC
			"$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${CMAKE_PROJECT_NAME}>"
			"$<BUILD_INTERFACE:${public_headers_dir}>"
			)

        if (ARGV3)
			target_link_libraries ("${library_name}_shared" ${ARGV3})
        endif ()

		install (TARGETS "${library_name}_shared" EXPORT "${name}Config"
            LIBRARY
            NAMELINK_COMPONENT Development
            DESTINATION "${CMAKE_INSTALL_LIBDIR}"
            )

		export(TARGETS "${library_name}_shared" NAMESPACE "${CMAKE_PROJECT_NAME}::"
            FILE "${CMAKE_CURRENT_BINARY_DIR}/${name}Config.cmake"
            )

		add_library("${CMAKE_PROJECT_NAME}::${library_name}::shared" ALIAS "${library_name}_shared")
    endif ()

    install (EXPORT "${name}Config" NAMESPACE "${CMAKE_PROJECT_NAME}::"
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${name}")

	install (DIRECTORY "${public_headers_dir}/"
		DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${CMAKE_PROJECT_NAME}"
		FILES_MATCHING REGEX "^.*\.h(pp|xx)?$"
		PATTERN "private" EXCLUDE
		)
endfunction ()

# Add executable target:
#   name         - application name
#   sources_list - source files list
#   ARGV2        - extra libraries to link with (optional)
#   ARGV3        - private headers dir (optional)
#   ARGV4        - public headers dir use with other targets (optional)
function (add_application name sources_list)
    string (TOLOWER "${name}" executable_name)
    add_executable ("${executable_name}" "${sources_list}")

    if (ARGV2)
        target_link_libraries ("${executable_name}" "${ARGV2}")
    endif ()

	if (ARGV3)
        target_include_directories("${executable_name}" PRIVATE "${ARGV3}")
    endif ()

    set (public_headers_dir "${CMAKE_CURRENT_SOURCE_DIR}")
    if (ARGV4)
        set (public_headers_dir "${public_headers_dir}/${ARGV4}")
    endif ()
    target_include_directories ("${executable_name}" PUBLIC
        "$<BUILD_INTERFACE:${public_headers_dir}>"
        )

    install (TARGETS "${executable_name}" RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
endfunction ()

# Add Boost test with separate test cases for CTest:
#   name         - test target name
#   sources_list - test source files
#   ARGN         - extra libraries to link with (optional)
# also add post-build action to run tests after build.
function (add_boost_test name sources_list)
    string (TOLOWER "${name}" executable_name)
    add_executable ("${executable_name}" ${sources_list})

    target_link_libraries("${executable_name}"
        Boost::system
        Boost::unit_test_framework
        ${ARGN}
        )

    foreach (src IN LISTS sources_list)
        get_filename_component (src_name ${src} NAME)
        file (READ "${src_name}" src_contents)
        string (REGEX MATCHALL "BOOST_AUTO_TEST_CASE\\( *([A-Za-z_0-9]+) *\\)" found_tests ${src_contents})
        foreach (test ${found_tests})
            string (REGEX REPLACE ".*\\( *([A-Za-z_0-9]+) *\\).*" "\\1" test_name ${test})
            add_test (NAME "${name}.${test_name}"
                COMMAND ${executable_name} --run_test=${test_name} --catch_system_error=yes)
        endforeach ()
    endforeach ()

    if (AUTORUN_TESTS)
        add_custom_command (TARGET ${executable_name} POST_BUILD COMMAND make test)
    endif ()
endfunction()

############ End

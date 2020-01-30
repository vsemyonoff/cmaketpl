### CMake template

#### Overview

Repository contains `Application`, `Library`, tests and some other examples, top level project
configuration file `config.cmake.example` and some useful __CMake__ macros in `.cmake/CustomUtils.cmake`.
`Boost::unit_test_framework` integration with `CTest` inspired by [this article](https://eb2.co/blog/2015/06/driving-boost.test-with-cmake/).

Build example:
```bash
mkdir -p "build/release"
cd "build/release"
(
cmake -DCMAKE_INSTALL_PREFIX="/usr" \
      -DCMAKE_STAGING_PREFIX="../package/usr" \
      -DCMAKE_BUILD_TYPE="Release" \
      -DINSTALL_EXAMPLES=ON \
      -DBUILD_EXAMPLES=ON \
      -DBUILD_TESTING=ON \
        ../.. || exit 1
  cmake --build . --target install || exit 1
)
```

#### Build options

| Option | Description |
| --- | --- |
| __AUTORUN\_TESTS__ | Run CTest after project build. Default: ON |
| __BUILD\_EXAMPLES__ | Build examples. Default: OFF |
| __BUILD\_TESTING__ | Build unit tests (CTest). Default: OFF |
| __DISABLE\_SHARED__ | Disable shared libraries building. Default: OFF |
| __DISABLE\_STATIC__ | Disable static libraries building. Default: OFF |
| __ENABLE\_FAKEIT__ | Setup 'FakeIt' mocking library for Boost. Default: OFF |
| __INSTALL\_EXAMPLES__ | Install examples. Default: OFF |
| __STATIC\_LINKAGE__ | Link executables with static libraries. Default: OFF |


#### Some description

* __AUTORUN_TESTS__ make sense only with `BUILD_TESTING`. Will run `make test` after building
all project targets.
* __ENABLE_FAKEIT__ will clone last commit from `FakeIt`master branch to `extlibs/fakeit`
and add `IMPORTED` target to use with unit testing subsystem. Also make sense when testing
enabled.
* __STATIC_LINKAGE__ will set global `LIB_TYPE` variable to `static` (default: `shared`).
Useful while linking targets like: `target_link_libraries ("server" Example::library::${LIB_TYPE})`.
This variable also sets `Boost_USE_STATIC_LIBS` ON/OFF.
* __DISABLE_STATIC/SHARED__ will disable static/shared or both library variants compilation.


Some useful functions declared in `.cmake/CustomUtils.cmake` file:
* __add\_config__ - process configuration file `some.hpp.in` and fill with `CMake` variables values.
* __add\_dir\_or\_subdirs__ - add `directory` to build tree if `CMakeLists.txt` present there or add
all subdirectories from it by the same algorithm.
* __add\_custom\_library__ - declare three library target variants: object, static, shared. Also
makes proper export and install targets to use with external projects.
* __add\_application__ - the same like above but for executable targets.
* __add\_boost\_test__ - simplify `Boost` tests registration in `CTest`

For more syntax description see: `.cmake/CustomUtils.cmake`

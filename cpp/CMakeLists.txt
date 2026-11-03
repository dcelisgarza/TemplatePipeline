cmake_minimum_required(VERSION 3.21)
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/../VERSION" SHAPES_VERSION)
string(STRIP "${SHAPES_VERSION}" SHAPES_VERSION)
project(shapes-cpp VERSION ${SHAPES_VERSION} DESCRIPTION "Area and perimeter of plane shapes" LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
include(GNUInstallDirs)
include(CTest)

option(SHAPES_BUILD_DOCS "Build the API documentation with Doxygen" OFF)

# Library ---------------------------------------------------------------------
add_library(shapes src/shapes.cpp)
add_library(shapes::shapes ALIAS shapes)
target_include_directories(shapes PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
target_compile_features(shapes PUBLIC cxx_std_17)
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  target_compile_options(shapes PRIVATE -Wall -Wextra -Wpedantic)
endif()

# Program ---------------------------------------------------------------------
add_executable(shapes-cpp app/main.cpp)
target_link_libraries(shapes-cpp PRIVATE shapes::shapes)
target_compile_definitions(shapes-cpp PRIVATE SHAPES_VERSION="${PROJECT_VERSION}")

# Tests -----------------------------------------------------------------------
if(BUILD_TESTING)
  include(FetchContent)
  set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
  set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
  FetchContent_Declare(googletest
    URL https://github.com/google/googletest/archive/refs/tags/v1.15.2.tar.gz
    URL_HASH SHA256=7b42b4d6ed48810c5362c265a17faebe90dc2373c885e5216439d37927f02926
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE)
  FetchContent_MakeAvailable(googletest)

  add_executable(test_shapes tests/test_shapes.cpp)
  target_link_libraries(test_shapes PRIVATE shapes::shapes GTest::gtest_main)
  include(GoogleTest)
  gtest_discover_tests(test_shapes)

  add_test(NAME cli_circle COMMAND shapes-cpp circle 2)
  set_tests_properties(cli_circle PROPERTIES
    PASS_REGULAR_EXPRESSION "circle: area = 12.566371, perimeter = 12.566371")
  add_test(NAME cli_version COMMAND shapes-cpp --version)
  set_tests_properties(cli_version PROPERTIES
    PASS_REGULAR_EXPRESSION "^shapes-cpp ${PROJECT_VERSION}")
  add_test(NAME cli_bad_triangle COMMAND shapes-cpp triangle 1 1 5)
  set_tests_properties(cli_bad_triangle PROPERTIES WILL_FAIL TRUE)
endif()

# Documentation ---------------------------------------------------------------
if(SHAPES_BUILD_DOCS)
  find_package(Doxygen REQUIRED)
  set(DOXYGEN_PROJECT_NUMBER ${PROJECT_VERSION})
  set(DOXYGEN_PROJECT_BRIEF "${PROJECT_DESCRIPTION}")
  set(DOXYGEN_GENERATE_TREEVIEW YES)
  set(DOXYGEN_STRIP_FROM_PATH ${CMAKE_CURRENT_SOURCE_DIR}/..)
  set(DOXYGEN_EXTRACT_ALL YES)
  set(DOXYGEN_USE_MDFILE_AS_MAINPAGE README.md)
  doxygen_add_docs(docs include README.md ../SPEC.md WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
endif()

# Install and package ---------------------------------------------------------
install(TARGETS shapes shapes-cpp EXPORT shapesTargets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(DIRECTORY include/shapes DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(EXPORT shapesTargets NAMESPACE shapes::
  FILE shapesConfig.cmake DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/shapes)

set(CPACK_GENERATOR TGZ)
set(CPACK_PACKAGE_VENDOR "TemplatePipeline")
include(CPack)

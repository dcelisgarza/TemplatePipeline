cmake_minimum_required(VERSION 3.21)
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/../VERSION" SHAPES_VERSION)
string(STRIP "${SHAPES_VERSION}" SHAPES_VERSION)
project(shapes-c VERSION ${SHAPES_VERSION} DESCRIPTION "Area and perimeter of plane shapes" LANGUAGES C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
include(GNUInstallDirs)
include(CTest)

option(SHAPES_BUILD_DOCS "Build the API documentation with Doxygen" OFF)

# Library ---------------------------------------------------------------------
add_library(shapes src/shapes.c)
add_library(shapes::shapes ALIAS shapes)
target_include_directories(shapes PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
find_library(MATH_LIBRARY m)
if(MATH_LIBRARY)
  target_link_libraries(shapes PUBLIC ${MATH_LIBRARY})
endif()
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
  target_compile_options(shapes PRIVATE -Wall -Wextra -Wpedantic)
endif()

# Program ---------------------------------------------------------------------
add_executable(shapes-c app/main.c)
target_link_libraries(shapes-c PRIVATE shapes::shapes)
target_compile_definitions(shapes-c PRIVATE SHAPES_VERSION="${PROJECT_VERSION}")

# Tests -----------------------------------------------------------------------
if(BUILD_TESTING)
  add_executable(test_shapes tests/test_shapes.c)
  target_link_libraries(test_shapes PRIVATE shapes::shapes)
  add_test(NAME unit COMMAND test_shapes)
  add_test(NAME cli_circle COMMAND shapes-c circle 2)
  set_tests_properties(cli_circle PROPERTIES
    PASS_REGULAR_EXPRESSION "circle: area = 12.566371, perimeter = 12.566371")
  add_test(NAME cli_bad_triangle COMMAND shapes-c triangle 1 1 5)
  set_tests_properties(cli_bad_triangle PROPERTIES WILL_FAIL TRUE)
endif()

# Documentation ---------------------------------------------------------------
if(SHAPES_BUILD_DOCS)
  find_package(Doxygen REQUIRED)
  set(DOXYGEN_PROJECT_NUMBER ${PROJECT_VERSION})
  set(DOXYGEN_PROJECT_BRIEF "${PROJECT_DESCRIPTION}")
  set(DOXYGEN_OPTIMIZE_OUTPUT_FOR_C YES)
  set(DOXYGEN_GENERATE_TREEVIEW YES)
  set(DOXYGEN_STRIP_FROM_PATH ${CMAKE_CURRENT_SOURCE_DIR}/..)
  set(DOXYGEN_USE_MDFILE_AS_MAINPAGE README.md)
  doxygen_add_docs(docs include README.md ../SPEC.md WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
endif()

# Install and package ---------------------------------------------------------
install(TARGETS shapes shapes-c EXPORT shapesTargets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(FILES include/shapes.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(EXPORT shapesTargets NAMESPACE shapes::
  FILE shapesConfig.cmake DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/shapes)

set(CPACK_GENERATOR TGZ)
set(CPACK_PACKAGE_VENDOR "TemplatePipeline")
include(CPack)

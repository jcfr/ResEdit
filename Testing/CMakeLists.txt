
# --------------------------------------------------------------------------
set(RESEDIT_NAME ${PROJECT_NAME})
set(RESEDIT_VERSION ${CTKResEdit_VERSION})
set(RESEDIT_BINARY_DIR ${CTKResEdit_BINARY_DIR})
set(RESEDIT_SOURCE_DIR ${CTKResEdit_SOURCE_DIR})

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/ResEditTestPrerequisites.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/ResEditTestPrerequisites.cmake
  @ONLY
  )

# --------------------------------------------------------------------------
project(App4Test)

set(SRCS
  App4TestMain.cpp
  )

set(App4Test_Resources
  App4Test.rc
  )

# --------------------------------------------------------------------------
# Create app for test
add_executable(${PROJECT_NAME} ${SRCS} ${App4Test_Resources})
add_executable(${PROJECT_NAME}_Without_Resource ${SRCS})

# --------------------------------------------------------------------------
# Helper macro
macro(resedit_add_test testname)
  add_test(NAME ${testname} COMMAND ${CTKResEdit_LAUNCH_COMMAND} ${CMAKE_COMMAND}
    -DTEST_SOURCE_DIR:PATH=${CMAKE_CURRENT_SOURCE_DIR}
    -DTEST_BINARY_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}
    -P ${CMAKE_CURRENT_SOURCE_DIR}/${testname}.cmake
    )
    set_property(TEST ${testname} PROPERTY LABELS ResEdit)
endmacro()

# --------------------------------------------------------------------------
# Add Test:
resedit_add_test(ResEditNoCommandTest)
resedit_add_test(ResEditCommandHelpTest)
resedit_add_test(ResEditCommandListTest)
resedit_add_test(ResEditCommandUpdateIcoOnExeWithIcoTest)
resedit_add_test(ResEditCommandUpdateIcoOnExeWithoutIcoTest)

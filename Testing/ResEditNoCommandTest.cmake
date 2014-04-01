
include(${TEST_SOURCE_DIR}/ResEditTestMacros.cmake)
include(${TEST_BINARY_DIR}/ResEditTestPrerequisites.cmake)

# --------------------------------------------------------------------------------
# Test without argument - Expect to faile - Command full name

verify_command(
  ""
  ""
  ""
  ""
  "${EXIT_SUCCESS}"
  )

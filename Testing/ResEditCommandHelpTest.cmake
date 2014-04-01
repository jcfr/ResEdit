
include(${TEST_SOURCE_DIR}/ResEditTestMacros.cmake)
include(${TEST_BINARY_DIR}/ResEditTestPrerequisites.cmake)

set(Expected_OUTPUT_Lines
  "Option"
  "-h, --help"
  "-l, --list-resources"
  "--add-resource-bitmap"
  "--update-resource-ico"
  "--delete-resource"
  )

# --------------------------------------------------------------------------------
# Command full name

verify_command(
  "--help"
  "${Expected_OUTPUT_Lines}"
  ""
  ""
  "${EXIT_SUCCESS}"
  )

# --------------------------------------------------------------------------------
# Command shortcut

verify_command(
  "-h"
  "${Expected_OUTPUT_Lines}"
  ""
  ""
  "${EXIT_SUCCESS}"
  )

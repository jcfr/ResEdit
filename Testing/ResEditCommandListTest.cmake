
include(${TEST_SOURCE_DIR}/ResEditTestMacros.cmake)
include(${TEST_BINARY_DIR}/ResEditTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------------
# Test without argument - Expect to faile - Command full name

verify_command(
  "--list-resources"
  ""
  ""
  "Error parsing arguments : Argument --list-resources has 0 value(s) associated whereas exacly 1 are expected.\n"
  ${EXIT_FAILURE}
  )

# --------------------------------------------------------------------------------
# Test without argument - Expect to faile - Command shortcut

verify_command(
  "-l"
  ""
  ""
  "Error parsing arguments : Argument -l has 0 value(s) associated whereas exacly 1 are expected.\n"
  ${EXIT_FAILURE}
  )

# --------------------------------------------------------------------------------
set(expected_resource_list
  "Type : 24 -- RT_MANIFEST\n\tName : 1"
  "Type : 14 -- RT_GROUP_ICON\n\tName : IDI_ICON1"
  "Type : 3 -- RT_ICON\n\tName : 1"
  "Type : 3 -- RT_ICON\n\tName : 2"
  )

# --------------------------------------------------------------------------------
# Test with argument - Command full name

verify_command(
  "--list-resources;${App4Test_Path}"
  "${expected_resource_list}"
  ""
  ""
  ${EXIT_SUCCESS}
  )

# --------------------------------------------------------------------------------
# Test with argument - Expect to faile - Command shortcut

verify_command(
  "-l;${App4Test_Path}"
  "${expected_resource_list}"
  ""
  ""
  ${EXIT_SUCCESS}
  )

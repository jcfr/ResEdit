
include(${TEST_SOURCE_DIR}/ResEditTestMacros.cmake)
include(${TEST_BINARY_DIR}/ResEditTestPrerequisites.cmake)

# --------------------------------------------------------------------------------
# First we list resources
set(Expected_OUTPUT_Lines
  "Type : 24 -- RT_MANIFEST\n\tName : 1"
  "Type : 14 -- RT_GROUP_ICON\n\tName : IDI_ICON1"
  "Type : 3 -- RT_ICON\n\tName : 1"
  "Type : 3 -- RT_ICON\n\tName : 2"
  )


verify_command(
  "--list-resources;${App4Test_Path}"
  "${Expected_OUTPUT_Lines}"
  ""
  ""
  "${EXIT_SUCCESS}"
  )

# --------------------------------------------------------------------------------
# Update the Ico resource

verify_command(
  "--update-resource-ico;${App4Test_Path};IDI_ICON1;${ResourceIco1_Path}"
  "Resource ico updated"
  ""
  ""
  "${EXIT_SUCCESS}"
  )

# We list to be positive

set(Expected_OUTPUT_Lines
  "Type : 24 -- RT_MANIFEST\n\tName : 1"
  "Type : 14 -- RT_GROUP_ICON\n\tName : IDI_ICON1"
  "Type : 3 -- RT_ICON\n\tName : 1"
  "Type : 3 -- RT_ICON\n\tName : 2"
  "Type : 3 -- RT_ICON\n\tName : 3"
  "Type : 3 -- RT_ICON\n\tName : 4"
  "Type : 3 -- RT_ICON\n\tName : 5"
  )

verify_command(
  "-l;${App4Test_Path}"
  "${Expected_OUTPUT_Lines}"
  ""
  ""
  "${EXIT_SUCCESS}"
  )

# --------------------------------------------------------------------------------
# Update the Ico resource

verify_command(
  "--update-resource-ico;${App4Test_Path};IDI_ICON1;${ResourceIco2_Path}"
  "${Expected_OUTPUT_msg}"
  ""
  ""
  "${EXIT_SUCCESS}"
  )

# We list to be positive
set(Expected_OUTPUT_Lines
  "Type : 24 -- RT_MANIFEST\n\tName : 1"
  "Type : 14 -- RT_GROUP_ICON\n\tName : IDI_ICON1"
  "Type : 3 -- RT_ICON\n\tName : 1"
  "Type : 3 -- RT_ICON\n\tName : 2"
  )
set(Not_Expected_OUTPUT_Lines
  "Type : 3 -- RT_ICON\n\tName : 3"
  "Type : 3 -- RT_ICON\n\tName : 4"
  "Type : 3 -- RT_ICON\n\tName : 5"
  )

verify_command(
  "-l;${App4Test_Path}"
  "${Expected_OUTPUT_Lines}"
  "${Not_Expected_OUTPUT_Lines}"
  ""
  "${EXIT_SUCCESS}"
  )

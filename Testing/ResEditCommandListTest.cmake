
include(${TEST_SOURCE_DIR}/ResEditTestMacros.cmake)
include(${TEST_BINARY_DIR}/ResEditTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

function(verify_command command_arguments expected_output expected_error expected_result)

  set(command ${resedit_exe} ${command_arguments})
  execute_process(
    COMMAND ${command}
    WORKING_DIRECTORY ${resedit_binary_dir}
    OUTPUT_VARIABLE current_output
    ERROR_VARIABLE current_error
    RESULT_VARIABLE current_result
    )

  print_command_as_string("${command}")

  if(NOT "${expected_error}" STREQUAL "${current_error}")
    message(FATAL_ERROR "Problem with flag ${command_arguments}."
                        "\n expected_error: [${expected_error}]"
                        "\n current_error: [${current_error}]")
  endif()

  if(NOT "${expected_result}" STREQUAL "${current_result}")
    message(FATAL_ERROR "Problem with flag ${command_arguments}."
                        "\n expected_result: [${expected_result}]"
                        "\n current_result: [${current_result}]")
  endif()

  #if(NOT "${expected_output}" STREQUAL "${current_output}")
  #  message(FATAL_ERROR "Problem with flag ${command_arguments}."
  #                      "\n expected_output: [${expected_output}]"
  #                      "\n current_output: [${current_output}]")
  #endif()

  foreach(expected_output_line ${expected_output})
    string(FIND "${current_output}" ${expected_output_line} pos)
    if(${pos} STREQUAL -1)
      message(FATAL_ERROR "Problem with flag ${command_arguments}."
                          "\n expected_output_line: [${expected_output_line}]"
                          "\n current_output: [${current_output}]")
    endif()
  endforeach()

endfunction()

# --------------------------------------------------------------------------------
# Test without argument - Expect to faile - Command full name

verify_command(
  "--list-resources"
  ""
  "Error parsing arguments : Argument --list-resources has 0 value(s) associated whereas exacly 1 are expected.\n"
  ${EXIT_FAILURE}
  )

# --------------------------------------------------------------------------------
# Test without argument - Expect to faile - Command shortcut

verify_command(
  "-l"
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
  ${EXIT_SUCCESS}
  )

# --------------------------------------------------------------------------------
# Test with argument - Expect to faile - Command shortcut

verify_command(
  "-l;${App4Test_Path}"
  "${expected_resource_list}"
  ""
  ${EXIT_SUCCESS}
  )

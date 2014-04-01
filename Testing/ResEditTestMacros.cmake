
# --------------------------------------------------------------------------
# Helper macro(s)/function(s)

function(print_command_as_string command)
  if(PRINT_COMMAND)
    set(command_as_string)
    foreach(elem ${command})
      set(command_as_string "${command_as_string} ${elem}")
    endforeach()
    message(STATUS "COMMAND:${command_as_string}")
  endif()
endfunction()

function(verify_command command_arguments expected_output unexpected_output expected_error expected_result)

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

  foreach(expected_output_line ${expected_output})
    string(FIND "${current_output}" ${expected_output_line} pos)
    if(${pos} STREQUAL -1)
      message(FATAL_ERROR "Problem with flag ${command_arguments}."
                          "\n expected_output_line: [${expected_output_line}]"
                          "\n current_output: [${current_output}]")
    endif()
  endforeach()

  foreach(unexpected_output_line ${unexpected_output})
    string(FIND "${current_output}" ${unexpected_output_line} pos)
    if(NOT ${pos} STREQUAL -1)
      message(FATAL_ERROR "Problem with flag ${command_arguments}."
                          "\n expected_output_line: [${unexpected_output_line}]"
                          "\n current_output: [${current_output}]")
    endif()
  endforeach()

endfunction()

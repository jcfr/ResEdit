
include(${TEST_BINARY_DIR}/ResEditTestPrerequisites.cmake)

# --------------------------------------------------------------------------------
# Test without argument - Expect to faile - Command full name

set(Error_expected_msg
  ""
  )

set(command ${resedit_exe})
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${resedit_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

if(ev)
  message(FATAL_ERROR "Test - [${resedit_exe}] failed to start using ' ' "
                      "Directory [${resedit_binary_dir}]\n${ev}")
endif()

if(NOT "${Error_expected_msg}" STREQUAL "${ov}")
  message(FATAL_ERROR "Test No command - Failed \n"
                      "Error expected : ${Error_expected_msg}\n"
                      "Current message : ${ov}")
endif()

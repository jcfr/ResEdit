
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
set(command ${resedit_exe} --help)
execute_process(
	COMMAND ${command}
	WORKING_DIRECTORY ${resedit_binary_dir}
	ERROR_VARIABLE ev
	OUTPUT_VARIABLE ov
	RESULT_VARIABLE rv
	)

if(ev)
	message(FATAL_ERROR "Test - [${resedit_exe}] failed to start using '--help' "
                      "directory [${resedit_binary_dir}]\n${ev}")
endif()

foreach(Expected_OUTPUT_Line ${Expected_OUTPUT_Lines})
	string(FIND "${ov}" ${Expected_OUTPUT_Line} pos)
  if(${pos} STREQUAL -1)
    message(FATAL_ERROR "Test - Problem with flag --help - expected_ov_line:${Expected_OUTPUT_Line} "
                        "not found in current_ov:${ov}")
  endif()
endforeach()

# --------------------------------------------------------------------------------
# Command shortcut
set(command ${resedit_exe} -h)
execute_process(
	COMMAND ${command}
	WORKING_DIRECTORY ${resedit_binary_dir}
	ERROR_VARIABLE ev
	OUTPUT_VARIABLE ov
	RESULT_VARIABLE rv
	)

if(ev)
	message(FATAL_ERROR "Test - [${resedit_exe}] failed to start using '-h' "
                      "directory [${resedit_binary_dir}]\n${ev}")
endif()

foreach(Expected_OUTPUT_Line ${Expected_OUTPUT_Lines})
	string(FIND "${ov}" ${Expected_OUTPUT_Line} pos)
  if(${pos} STREQUAL -1)
    message(FATAL_ERROR "Test - Problem with flag -h - expected_ov_line:${Expected_OUTPUT_Line} "
                        "not found in current_ov:${ov}")
  endif()
endforeach()


include(${CMAKE_SOURCE_DIR}/ResEditTestPrerequisites.cmake)


# --------------------------------------------------------------------------------
# Test without argument - Expect to faile - Command full name

set(Error_expected_msg
	"Error parsing arguments : Argument --list-resources has 0 value"
	)

set(command ${resedit_exe} --list-resources)
execute_process(
	COMMAND ${command}
	WORKING_DIRECTORY ${resedit_binary_dir}
	ERROR_VARIABLE ev
	OUTPUT_VARIABLE ov
	RESULT_VARIABLE rv
	)

if(ev)
	message(FATAL_ERROR "Test - [${resedit_exe}] failed to start using '--list' "
                      "Directory [${resedit_binary_dir}]\n${ev}")
endif()

string(REGEX MATCH ${Error_expected_msg} current_msg ${ov})
message("match:${current_msg}")
if(NOT "${Error_expected_msg}" STREQUAL "${current_msg}")
  message(FATAL_ERROR "Test List - Wihtout Argument - Failed \n"
                      "Error expected : ${Error_expected_msg}\n"
											"Current message : ${ov}")
endif()

# --------------------------------------------------------------------------------
# Test without argument - Expect to faile - Command shortcut
set(Error_expected_msg
	"Error parsing arguments : Argument -l has 0 value"
	)

set(command ${resedit_exe} -l)
execute_process(
	COMMAND ${command}
	WORKING_DIRECTORY ${resedit_binary_dir}
	ERROR_VARIABLE ev
	OUTPUT_VARIABLE ov
	RESULT_VARIABLE rv
	)

if(ev)
	message(FATAL_ERROR "Test - [${resedit_exe}] failed to start using '-l' "
                      "Directory [${resedit_binary_dir}]\n${ev}")
endif()

string(REGEX MATCH ${Error_expected_msg} current_msg ${ov})
if(NOT "${Error_expected_msg}" STREQUAL "${current_msg}")
  message(FATAL_ERROR "Test List - Wihtout Argument - Failed \n"
                      "Error expected : ${Error_expected_msg}\n"
											"Current message : ${ov}")
endif()


# --------------------------------------------------------------------------------
# Test with argument - Command full name

set(Expected_OUTPUT_Lines
	"Type : 24 -- RT_MANIFEST\n\tName : 1"
	"Type : 14 -- RT_GROUP_ICON\n\tName : IDI_ICON1"
	"Type : 3 -- RT_ICON\n\tName : 1"
	"Type : 3 -- RT_ICON\n\tName : 2"
	)

message("App4Test_Path:${App4Test_Path}")
set(command ${resedit_exe} --list-resources ${App4Test_Path})
execute_process(
	COMMAND ${command}
	WORKING_DIRECTORY ${resedit_binary_dir}
	ERROR_VARIABLE ev
	OUTPUT_VARIABLE ov
	RESULT_VARIABLE rv
	)

if(ev)
	message(FATAL_ERROR "Test - [${resedit_exe}] failed to start using '--list' "
                      "Directory [${resedit_binary_dir}]\n${ev}")
endif()

foreach(Expected_OUTPUT_Line ${Expected_OUTPUT_Lines})
	string(FIND "${ov}" ${Expected_OUTPUT_Line} pos)
  if(${pos} STREQUAL -1)
    message(FATAL_ERROR "Test - Problem with flag -l - expected_ov_line:${Expected_OUTPUT_Line} "
                        "not found in current_ov:${ov}")
  endif()
endforeach()

# --------------------------------------------------------------------------------
# Test with argument - Expect to faile - Command shortcut

set(Expected_OUTPUT_Lines
	"Type : 24 -- RT_MANIFEST\n\tName : 1"
	"Type : 14 -- RT_GROUP_ICON\n\tName : IDI_ICON1"
	"Type : 3 -- RT_ICON\n\tName : 1"
	"Type : 3 -- RT_ICON\n\tName : 2"
	)

set(command ${resedit_exe} -l ${App4Test_Path})
execute_process(
	COMMAND ${command}
	WORKING_DIRECTORY ${resedit_binary_dir}
	ERROR_VARIABLE ev
	OUTPUT_VARIABLE ov
	RESULT_VARIABLE rv
	)

if(ev)
	message(FATAL_ERROR "Test - [${resedit_exe}] failed to start using '-l' "
                      "directory [${resedit_binary_dir}]\n${ev}")
endif()

foreach(Expected_OUTPUT_Line ${Expected_OUTPUT_Lines})
	string(FIND "${ov}" ${Expected_OUTPUT_Line} pos)
  if(${pos} STREQUAL -1)
    message(FATAL_ERROR "Test - Problem with flag -l - expected_ov_line:${Expected_OUTPUT_Line} "
                        "not found in current_ov:${ov}")
  endif()
endforeach()

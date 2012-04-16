
include(${CMAKE_SOURCE_DIR}/ResEditTestPrerequisites.cmake)

# --------------------------------------------------------------------------------
# First we list resources
set(Expected_OUTPUT_Lines
	"Type : 24 -- RT_MANIFEST\n\tName : 1"
	"Type : 14 -- RT_GROUP_ICON\n\tName : IDI_ICON1"
	"Type : 3 -- RT_ICON\n\tName : 1"
	"Type : 3 -- RT_ICON\n\tName : 2"
	)

set(command ${resedit_exe} --list-resources ${App4Test_Path})
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
    message(FATAL_ERROR "Test Update Ico - Problem with flag --list-resources"
												"Expected_ov_line:${Expected_OUTPUT_Line} "
                        "Not found in current_ov:${ov}")
  endif()
endforeach()

# --------------------------------------------------------------------------------
# Update the Ico resource
set(Expected_OUTPUT_msg "Resource ico updated")

set(command ${resedit_exe} --update-resource-ico ${App4Test_Path} IDI_ICON1 ${ResourceIco1_Path})
execute_process(
	COMMAND ${command}
	WORKING_DIRECTORY ${resedit_binary_dir}
	ERROR_VARIABLE ev
	OUTPUT_VARIABLE ov
	RESULT_VARIABLE rv
	)

if(ev)
	message(FATAL_ERROR "Test - [${resedit_exe}] failed to start using '--update-resource-ico' "
                      "Directory [${resedit_binary_dir}]\n${ev}")
endif()

string(REGEX MATCH ${Expected_OUTPUT_msg} current_msg ${ov})
if(NOT "${Expected_OUTPUT_msg}" STREQUAL "${current_msg}")
  message(FATAL_ERROR "Test Update Ico resource - Failed \n"
                      "Error expected : ${Expected_OUTPUT_msg}\n"
											"Current message : ${ov}")
endif()

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

set(command ${resedit_exe} -l ${App4Test_Path})
execute_process(
	COMMAND ${command}
	WORKING_DIRECTORY ${resedit_binary_dir}
	ERROR_VARIABLE ev
	OUTPUT_VARIABLE ov
	RESULT_VARIABLE rv
	)

if(ev)
	message(FATAL_ERROR "Test - [${resedit_exe}] failed to start using '--update-resource-ico' "
                      "Directory [${resedit_binary_dir}]\n${ev}")
endif()

foreach(Expected_OUTPUT_Line ${Expected_OUTPUT_Lines})
	string(FIND "${ov}" ${Expected_OUTPUT_Line} pos)
  if(${pos} STREQUAL -1)
    message(FATAL_ERROR "Test Update Ico - Problem with flag --list-resources"
												"Expected_ov_line:${Expected_OUTPUT_Line} "
                        "Not found in current_ov:${ov}")
  endif()
endforeach()

# --------------------------------------------------------------------------------
# Update the Ico resource

set(command ${resedit_exe} --update-resource-ico ${App4Test_Path} IDI_ICON1 ${ResourceIco2_Path})
execute_process(
	COMMAND ${command}
	WORKING_DIRECTORY ${resedit_binary_dir}
	ERROR_VARIABLE ev
	OUTPUT_VARIABLE ov
	RESULT_VARIABLE rv
	)

if(ev)
	message(FATAL_ERROR "Test - [${resedit_exe}] failed to start using '--update-resource-ico' "
                      "Directory [${resedit_binary_dir}]\n${ev}")
endif()

string(REGEX MATCH ${Expected_OUTPUT_msg} current_msg ${ov})
if(NOT "${Expected_OUTPUT_msg}" STREQUAL "${current_msg}")
  message(FATAL_ERROR "Test Update Ico resource - Failed \n"
                      "Error expected : ${Expected_OUTPUT_msg}\n"
											"Current message : ${ov}")
endif()

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

set(command ${resedit_exe} -l ${App4Test_Path})
execute_process(
	COMMAND ${command}
	WORKING_DIRECTORY ${resedit_binary_dir}
	ERROR_VARIABLE ev
	OUTPUT_VARIABLE ov
	RESULT_VARIABLE rv
	)

if(ev)
	message(FATAL_ERROR "Test - [${resedit_exe}] failed to start using '--update-resource-ico' "
                      "Directory [${resedit_binary_dir}]\n${ev}")
endif()

foreach(Expected_OUTPUT_Line ${Expected_OUTPUT_Lines})
	string(FIND "${ov}" ${Expected_OUTPUT_Line} pos)
  if(${pos} STREQUAL -1)
    message(FATAL_ERROR "Test Update Ico - Problem with flag --update-resource-ico"
												"Expected_ov_line:${Expected_OUTPUT_Line} "
                        "Not found in current_ov:${ov}")
  endif()
endforeach()

foreach(Not_Expected_OUTPUT_Line ${Not_Expected_OUTPUT_Lines})
	string(FIND "${ov}" ${Not_Expected_OUTPUT_Line} pos)
  if(NOT ${pos} STREQUAL -1)
    message(FATAL_ERROR "Test Update Ico - Problem with flag --update-resource-ico"
												"Non_Expected_ov_line:${Not_Expected_OUTPUT_Line} "
                        "Found in current_ov:${ov}")
  endif()
endforeach()

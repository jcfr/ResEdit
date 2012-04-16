#
# OS: Ubuntu 9.04 2.6.28-18-generic
# Hardware: x86_64 GNU/Linux
# GPU: NA
#

# Note: The specific version and processor type of this machine should be reported in the 
# header above. Indeed, this file will be send to the dashboard as a NOTE file. 

cmake_minimum_required(VERSION 2.8)

#
# For additional information, see http://www.commontk.org/index.php/Dashboard_setup
#

#
# Dashboard properties
#
set(MY_OPERATING_SYSTEM "Windows7") # Windows, Linux, Darwin... 
set(MY_COMPILER "VS2010express")
set(MY_QT_VERSION "4.7.3")
set(QT_QMAKE_EXECUTABLE "C:/work/Qt/qt-everywhere-opensource-src-4.7.3/bin/qmake.exe")
set(CTEST_SITE "Alienware.kitware") # for example: mymachine.kitware, mymachine.dkfz, ...
set(CTEST_DASHBOARD_ROOT "C:/work/ResEdit/Dashboards")

#
# Dashboard options
#
set(WITH_KWSTYLE FALSE)
set(WITH_MEMCHECK FALSE)
set(WITH_COVERAGE FALSE)
set(WITH_DOCUMENTATION FALSE)
#set(DOCUMENTATION_ARCHIVES_OUTPUT_DIRECTORY ) # for example: $ENV{HOME}/Projects/Doxygen
set(CTEST_BUILD_CONFIGURATION "Debug")
set(CTEST_TEST_TIMEOUT 500)
set(CTEST_BUILD_FLAGS "") # Use multiple CPU cores to build

# experimental: 
#     - run_ctest() macro will be called *ONE* time
#     - binary directory will *NOT* be cleaned
# continuous: 
#     - run_ctest() macro will be called EVERY 5 minutes ... 
#     - binary directory will *NOT* be cleaned
#     - configure/build will be executed *ONLY* if the repository has been updated
# nightly: 
#     - run_ctest() macro will be called *ONE* time
#     - binary directory *WILL BE* cleaned
set(SCRIPT_MODE "experimental") # "experimental", "continuous", "nightly"

#
# Project specific properties
#
set(CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}/ResEdit")
set(CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}/ResEdit-build-${CTEST_BUILD_CONFIGURATION}-${SCRIPT_MODE}")

# Additionnal CMakeCache options - For example:
# CTK_LIB_Widgets:BOOL=ON
# CTK_APP_ctkDICOM:BOOL=ON

set(ADDITIONNAL_CMAKECACHE_OPTION "
#CTK_LIB_Scripting/Python/Widgets:BOOL=ON
")

# List of test that should be explicitly disabled on this machine
set(TEST_TO_EXCLUDE_REGEX "")

# set any extra environment variables here
set(ENV{DISPLAY} ":0")

find_program(CTEST_COVERAGE_COMMAND NAMES gcov)
find_program(CTEST_MEMORYCHECK_COMMAND NAMES valgrind)
find_program(CTEST_GIT_COMMAND NAMES git)

#
# Git repository - Overwrite the default value provided by the driver script
#
# set(GIT_REPOSITORY http://github.com/YOURUSERNAME/CTK.git)

##########################################
# WARNING: DO NOT EDIT BEYOND THIS POINT #
##########################################

set(CTEST_NOTES_FILES "${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}")

#
# Project specific properties
#
set(CTEST_PROJECT_NAME "ResEdit")
set(CTEST_BUILD_NAME "${MY_OPERATING_SYSTEM}-${MY_COMPILER}-QT${MY_QT_VERSION}-${CTEST_BUILD_CONFIGURATION}")

#
# Display build info
#
message("site name: ${CTEST_SITE}")
message("build name: ${CTEST_BUILD_NAME}")
message("script mode: ${SCRIPT_MODE}")
message("coverage: ${WITH_COVERAGE}, memcheck: ${WITH_MEMCHECK}")

#
# Convenient macro allowing to download a file
#
macro(downloadFile url dest)
  file(DOWNLOAD ${url} ${dest} STATUS status)
  list(GET status 0 error_code)
  list(GET status 1 error_msg)
  if(error_code)
    message(FATAL_ERROR "error: Failed to download ${url} - ${error_msg}")
  endif()
endmacro()

#
# Download and include dashboard driver script 
#
#set(url https://github.com/benjaminlong/ResEdit/blob/master/CMake/reseditDashboardDriverScript.cmake)
set(dest ${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}.driver)
#downloadfile(${url} ${dest})
include(${dest})


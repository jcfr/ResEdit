####################################################################################
# OS      :
# Hardware:
# GPU     :
####################################################################################
# WARNING - The specific version and processor type of this machine should be reported
# in the header above. Indeed, this file will be send to the dashboard as a NOTE file.
#
# On linux, you could run:
#     'uname -o' and 'cat /etc/*-release' to obtain the OS name.
#     'uname -mpi' to obtain hardware details.
#     'glxinfo | grep OpenGL' to obtain GPU details.
####################################################################################

cmake_minimum_required(VERSION 2.8)

#-----------------------------------------------------------------------------
# Experimental:
#     - run_ctest() macro will be called *ONE* time
#     - binary directory will *NOT* be cleaned
# Continuous:
#     - run_ctest() macro will be called EVERY 5 minutes ...
#     - binary directory will *NOT* be cleaned
#     - configure/build will be executed *ONLY* if the repository has been updated
# Nightly:
#     - run_ctest() macro will be called *ONE* time
#     - binary directory *WILL BE* cleaned
set(SCRIPT_MODE "Nightly") # "Experimental", "Continuous", "Nightly"

# You could invoke the script with the following syntax:
#  ctest -S this_dashboard_script.cmake -C <CTEST_BUILD_CONFIGURATION> -V
#
# Note that '-C <CTEST_BUILD_CONFIGURATION>' is mandatory on windows

#-----------------------------------------------------------------------------
# Dashboard properties
#-----------------------------------------------------------------------------
set(MY_OPERATING_SYSTEM   "Windows7") # Windows, Linux, Darwin...
set(MY_COMPILER           "VS2008")
set(MY_BITNESS            "32")
set(MY_QT_VERSION         "4.7.3")
set(QT_QMAKE_EXECUTABLE   "C:/D/Support/qt-${MY_QT_VERSION}-${MY_BITNESS}-rel/bin/qmake.exe")
set(CTEST_SITE            "factory-south-win7.kitware") # for example: mymachine.kitware, mymachine.bwh.harvard.edu, ...
set(CTEST_DASHBOARD_ROOT  "C:/D/N")

# Open a shell and type in "cmake --help" to obtain the proper spelling of the generator
set(CTEST_CMAKE_GENERATOR "Visual Studio 9 2008")

# Each dashboard script should specify a unique ID per CTEST_DASHBOARD_ROOT.
# It means the following directories will be created:
#   <CTEST_DASHBOARD_ROOT>/<DIRECTORY_NAME>-<DIRECTORY_IDENTIFIER>        # Source directory
#   <CTEST_DASHBOARD_ROOT>/<DIRECTORY_NAME>-<DIRECTORY_IDENTIFIER>-build  # Build directory
set(DIRECTORY_IDENTIFIER  "0")

#-----------------------------------------------------------------------------
# Dashboard options
#-----------------------------------------------------------------------------
set(WITH_KWSTYLE FALSE)
set(WITH_MEMCHECK FALSE)
set(WITH_COVERAGE FALSE)
set(WITH_DOCUMENTATION FALSE)
#set(DOCUMENTATION_ARCHIVES_OUTPUT_DIRECTORY ) # for example: $ENV{HOME}/Projects/Doxygen
set(WITH_PACKAGES FALSE)
#set(MIDAS_PACKAGES_CREDENTIAL_FILE "/path/to/Kitware-MidasPackagesCredential.cmake")
set(CTEST_BUILD_CONFIGURATION "Release")
set(CTEST_TEST_TIMEOUT 500)
set(CTEST_BUILD_FLAGS "") # Use multiple CPU cores to build

#-----------------------------------------------------------------------------
# Additional CMakeCache options
#-----------------------------------------------------------------------------
set(ADDITIONAL_CMAKECACHE_OPTION "
")

#-----------------------------------------------------------------------------
# List of test that should be explicitly disabled on this machine
#-----------------------------------------------------------------------------
set(TEST_TO_EXCLUDE_REGEX "")

#-----------------------------------------------------------------------------
# Set any extra environment variables here
#-----------------------------------------------------------------------------
if(UNIX)
  set(ENV{DISPLAY} ":0")
endif()

#-----------------------------------------------------------------------------
# Required executables
#-----------------------------------------------------------------------------
find_program(CTEST_COVERAGE_COMMAND NAMES gcov)
find_program(CTEST_MEMORYCHECK_COMMAND NAMES valgrind)
find_program(CTEST_GIT_COMMAND NAMES git)

#-----------------------------------------------------------------------------
# Build Name
#-----------------------------------------------------------------------------
# Update the following variable to match the chosen build options. This variable is used to
# generate both the build directory and the build name.
set(BUILD_OPTIONS_STRING "${MY_BITNESS}bits-QT${MY_QT_VERSION}")

#-----------------------------------------------------------------------------
# Directory name
#-----------------------------------------------------------------------------
set(DIRECTORY_NAME "CTKResEdit")

#-----------------------------------------------------------------------------
# Build directory
#-----------------------------------------------------------------------------
set(CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}/${DIRECTORY_NAME}-${DIRECTORY_IDENTIFIER}-build")
file(WRITE "${CTEST_DASHBOARD_ROOT}/${DIRECTORY_NAME}-${DIRECTORY_IDENTIFIER}-build - ${BUILD_OPTIONS_STRING}-${CTEST_BUILD_CONFIGURATION}-${SCRIPT_MODE}.txt" "Generated by ${CTEST_SCRIPT_NAME}")

#-----------------------------------------------------------------------------
# Source directory
#-----------------------------------------------------------------------------
set(CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}/${DIRECTORY_NAME}-${DIRECTORY_IDENTIFIER}")

##########################################
# WARNING: DO NOT EDIT BEYOND THIS POINT #
##########################################

set(CTEST_NOTES_FILES "${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}")

#
# Project specific properties
#
set(CTEST_PROJECT_NAME "CTKResEdit")
set(CTEST_BUILD_NAME "${MY_OPERATING_SYSTEM}-${MY_COMPILER}-${BUILD_OPTIONS_STRING}-${CTEST_BUILD_CONFIGURATION}")

#
# Display build info
#
message("CTEST_SITE ................: ${CTEST_SITE}")
message("CTEST_BUILD_NAME ..........: ${CTEST_BUILD_NAME}")
message("SCRIPT_MODE ...............: ${SCRIPT_MODE}")
message("CTEST_BUILD_CONFIGURATION .: ${CTEST_BUILD_CONFIGURATION}")
message("WITH_KWSTYLE ..............: ${WITH_KWSTYLE}")
message("WITH_COVERAGE: ............: ${WITH_COVERAGE}")
message("WITH_MEMCHECK .............: ${WITH_MEMCHECK}")
message("WITH_PACKAGES .............: ${WITH_PACKAGES}")
message("WITH_DOCUMENTATION ........: ${WITH_DOCUMENTATION}")
message("DOCUMENTATION_ARCHIVES_OUTPUT_DIRECTORY: ${DOCUMENTATION_ARCHIVES_OUTPUT_DIRECTORY}")

#
# Convenient function allowing to download a file
#
function(download_file url dest)
  file(DOWNLOAD ${url} ${dest} STATUS status)
  list(GET status 0 error_code)
  list(GET status 1 error_msg)
  if(error_code)
    message(FATAL_ERROR "error: Failed to download ${url} - ${error_msg}")
  endif()
endfunction()

#
# Download and include dashboard driver script 
#
set(url https://raw.githubusercontent.com/jcfr/ResEdit/master/CMake/reseditDashboardDriverScript.cmake)
set(dest ${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}.driver)
download_file(${url} ${dest})
include(${dest})


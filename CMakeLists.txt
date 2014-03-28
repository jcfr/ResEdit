cmake_minimum_required(VERSION 2.8.2)

# --------------------------------------------------------------------------
project(CTKResEdit)

#-----------------------------------------------------------------------------
# Set a default build type if none was specified
#
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'Debug' as none was specified.")
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release"
    "MinSizeRel" "RelWithDebInfo")
endif()

#-----------------------------------------------------------------------------
# Version number.
#
set(CTKResEdit_MAJOR_VERSION 0)
set(CTKResEdit_MINOR_VERSION 1)
set(CTKResEdit_BUILD_VERSION 0)
set(CTKResEdit_VERSION_IS_RELEASE 0)
#set(CTKResEdit_VERSION_RC 1)

if(CTKResEdit_VERSION_IS_RELEASE)
  set(CTKResEdit_VERSION_SOURCE "")
else()
  include(${CMAKE_SOURCE_DIR}/CMake/ctkVersionSource.cmake)
endif()

# Compute the full version string.
set(CTKResEdit_VERSION
    "${CTKResEdit_MAJOR_VERSION}.${CTKResEdit_MINOR_VERSION}.${CTKResEdit_BUILD_VERSION}")
if(CTKResEdit_VERSION_RC)
  set(CTKResEdit_VERSION ${CTKResEdit_VERSION}-rc${CTKResEdit_VERSION_RC})
endif()
if(CTKResEdit_VERSION_SOURCE)
  set(CTKResEdit_VERSION ${CTKResEdit_VERSION}-${CTKResEdit_VERSION_SOURCE})
endif()
message(STATUS "CTKResEdit version: ${CTKResEdit_VERSION}")

configure_file(
  CMake/ctkResEditVersionConfig.h.in
  ${CMAKE_CURRENT_BINARY_DIR}/ctkResEditVersionConfig.h
  )

#-----------------------------------------------------------------------------
# Install directories, used for install rules.
#
set(CTK_INSTALL_BIN_DIR "bin")
set(CTK_INSTALL_LIB_DIR "lib")

#-----------------------------------------------------------------------------
#
FIND_PACKAGE(Qt4 4.7 REQUIRED)
include(${QT_USE_FILE})

set(ResEdit_SRCS
	ctkCommandLineParser.cpp
	ctkCommandLineParser.h
  Main.cpp
  )

set(ResEdit_MOC_SRCS
	ctkCommandLineParser.h
	)

QT4_WRAP_CPP(ResEditQt_SRCS ${ResEdit_MOC_SRCS})

# --------------------------------------------------------------------------
# Testing
#
OPTION(BUILD_TESTING "Test the project" ON)
IF(BUILD_TESTING)
  ENABLE_TESTING()
  include(CTest)
ENDIF()

#-----------------------------------------------------------------------------
# Coverage
#
option(WITH_COVERAGE "Enable/Disable coverage" OFF)

#-----------------------------------------------------------------------------
# Set coverage Flags
#
if(WITH_COVERAGE)
  if(CMAKE_CXX_COMPILER_ID AND ${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
    set(coverage_flags "-g -fprofile-arcs -ftest-coverage -O3 -DNDEBUG")
    set(COVERAGE_C_FLAGS ${coverage_flags})
    set(COVERAGE_CXX_FLAGS ${coverage_flags})
  endif()
endif()

#-----------------------------------------------------------------------------
# Additional CXX/C Flags
#
set(ADDITIONAL_C_FLAGS "" CACHE STRING "Additional C Flags")
mark_as_advanced(ADDITIONAL_C_FLAGS)
set(ADDITIONAL_CXX_FLAGS "" CACHE STRING "Additional CXX Flags")
mark_as_advanced(ADDITIONAL_CXX_FLAGS)

#-----------------------------------------------------------------------------
# ResEdit C/CXX Flags
#
set(ResEdit_C_FLAGS "${CMAKE_C_FLAGS_INIT} ${COVERAGE_C_FLAGS} ${ADDITIONAL_C_FLAGS}")
set(ResEdit_CXX_FLAGS "${CMAKE_CXX_FLAGS_INIT} ${COVERAGE_CXX_FLAGS} ${ADDITIONAL_CXX_FLAGS}")

#-----------------------------------------------------------------------------
# Set C/CXX Flags
#
set(CMAKE_CXX_FLAGS ${ResEdit_CXX_FLAGS} CACHE STRING "CMake C Flags" FORCE)
set(CMAKE_C_FLAGS ${ResEdit_C_FLAGS} CACHE STRING "CMake CXX Flags" FORCE)

#-----------------------------------------------------------------------------
# Remove warning for not using the _s
if(MSVC)
add_definitions(
	-D_CRT_SECURE_NO_WARNINGS
	)
endif()

# --------------------------------------------------------------------------
# Include dirs
#
set(include_dirs
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_BINARY_DIR}
	)
include_directories(${include_dirs})

# --------------------------------------------------------------------------
# Build executable
#

ADD_EXECUTABLE(${PROJECT_NAME} ${ResEdit_SRCS} ${ResEditQt_SRCS})

TARGET_LINK_LIBRARIES(${PROJECT_NAME} ${QT_LIBRARIES})

# Install rules
install(TARGETS ${PROJECT_NAME}
  RUNTIME DESTINATION ${CTK_INSTALL_BIN_DIR} COMPONENT Runtime
  LIBRARY DESTINATION ${CTK_INSTALL_LIB_DIR} COMPONENT Runtime
  ARCHIVE DESTINATION ${CTK_INSTALL_LIB_DIR} COMPONENT Development)

# --------------------------------------------------------------------------
# Build Test
#
IF(BUILD_TESTING)
  ADD_SUBDIRECTORY(Testing)
ENDIF()

# --------------------------------------------------------------------------
# Configure launcher
#
get_filename_component(QT_SHARED_LIBRARY_PATH_CONFIG ${QT_QMAKE_EXECUTABLE} PATH)
configure_file(
  SetEnv.bat.in
  ${CMAKE_BINARY_DIR}/SetEnv.bat
  )

#-----------------------------------------------------------------------------
# Build a CPack installer if CPack is available and this is a build of just
# CTKResEdit (as opposed to a build of CTKResEdit included in some other project...)

if("${CTKResEdit_BINARY_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")

  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(CPACK_SYSTEM_NAME "win-i386")
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
      set(CPACK_SYSTEM_NAME "win-amd64")
    endif()
  endif()

  set(CPACK_MONOLITHIC_INSTALL ON)
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PROJECT_NAME} - The Common Toolkit Application Launcher")
  set(CPACK_PACKAGE_VENDOR "Kitware, Inc.")
  #set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/Copyright.txt")
  #set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/Copyright.txt")
  set(CPACK_PACKAGE_VERSION "${CTKResEdit_VERSION}")
  set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_NAME} ${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}")
  set(CPACK_PACKAGE_EXECUTABLES "${PROJECT_NAME}")
  set(CPACK_GENERATOR "TGZ")
  include(CPack)
endif()

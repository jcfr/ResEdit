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

# --------------------------------------------------------------------------
# Build Test
#
IF(BUILD_TESTING)
  ADD_SUBDIRECTORY(Testing)
ENDIF()
cmake_minimum_required(VERSION 2.8.2)

# --------------------------------------------------------------------------
project(ResEdit)

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
  #ENABLE_TESTING()
  #INCLUDE(CTest)
ENDIF()

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
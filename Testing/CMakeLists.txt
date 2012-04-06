cmake_minimum_required(VERSION 2.8.2)

# --------------------------------------------------------------------------
project(App4Test)

set(SRCS
	App4TestMain.cpp
	)

set(App4Test_Resources
	App4Test.rc
	)

# --------------------------------------------------------------------------
# Create app for test
ADD_EXECUTABLE(${PROJECT_NAME} ${SRCS} ${App4Test_Resources})

# --------------------------------------------------------------------------
# Add Test:
#
# Included from a dashboard script, this cmake file will drive the configure and build
# steps of ResEdit
#

#-----------------------------------------------------------------------------
# The following variable are expected to be define in the top-level script:
set(expected_variables
  ADDITIONAL_CMAKECACHE_OPTION
  CTEST_NOTES_FILES
  CTEST_SITE
  CTEST_DASHBOARD_ROOT
  CTEST_CMAKE_GENERATOR
  WITH_MEMCHECK
  WITH_COVERAGE
  WITH_DOCUMENTATION
  CTEST_BUILD_CONFIGURATION
  CTEST_TEST_TIMEOUT
  CTEST_BUILD_FLAGS
  TEST_TO_EXCLUDE_REGEX
  CTEST_PROJECT_NAME
  CTEST_SOURCE_DIRECTORY
  CTEST_BINARY_DIRECTORY
  CTEST_BUILD_NAME
  SCRIPT_MODE
  CTEST_COVERAGE_COMMAND
  CTEST_MEMORYCHECK_COMMAND
  CTEST_GIT_COMMAND
  QT_QMAKE_EXECUTABLE
  )
if(WITH_DOCUMENTATION)
  list(APPEND expected_variables DOCUMENTATION_ARCHIVES_OUTPUT_DIRECTORY)
endif()
if(WITH_PACKAGES)
  list(APPEND expected_variables MIDAS_PACKAGES_CREDENTIAL_FILE)
endif()

if(NOT DEFINED MIDAS_PACKAGES_URL)
  set(MIDAS_PACKAGES_URL "http://packages.kitware.com")
endif()
if(NOT DEFINED MIDAS_PACKAGES_FOLDER_ID)
  set(MIDAS_PACKAGES_FOLDER_ID 271)
endif()
if(NOT DEFINED MIDAS_PACKAGES_APPLICATION_ID)
  set(MIDAS_PACKAGES_APPLICATION_ID 21)
endif()

foreach(var ${expected_variables})
  if(NOT DEFINED ${var})
    message(FATAL_ERROR "Variable ${var} should be defined in top-level script !")
  endif()
endforeach()

# If the dashscript doesn't define a GIT_REPOSITORY variable, let's define it here.
if (NOT DEFINED GIT_REPOSITORY OR GIT_REPOSITORY STREQUAL "")
  set(GIT_REPOSITORY git://github.com/jcfr/ResEdit.git)
endif()

set(git_branch_option "")
if(NOT "${GIT_TAG}" STREQUAL "")
  set(git_branch_option "-b ${GIT_TAG}")
endif()
message("GIT_REPOSITORY ......: ${GIT_REPOSITORY}")
message("GIT_TAG .............: ${GIT_TAG}")

# Should binary directory be cleaned?
set(empty_binary_directory FALSE)

# Attempt to build and test also if 'ctest_update' returned an error
set(force_build FALSE)

# Ensure SCRIPT_MODE is lowercase
string(TOLOWER ${SCRIPT_MODE} SCRIPT_MODE)

# Set model and track options
set(model "")
if(SCRIPT_MODE STREQUAL "experimental")
  set(empty_binary_directory FALSE)
  set(force_build TRUE)
  set(model Experimental)
elseif(SCRIPT_MODE STREQUAL "continuous")
  set(empty_binary_directory TRUE)
  set(force_build FALSE)
  set(model Continuous)
elseif(SCRIPT_MODE STREQUAL "nightly")
  set(empty_binary_directory TRUE)
  set(force_build TRUE)
  set(model Nightly)
else()
  message(FATAL_ERROR "Unknown script mode: '${SCRIPT_MODE}'. Script mode should be either 'experimental', 'continuous' or 'nightly'")
endif()
set(track ${model})
#if(WITH_PACKAGES)
#  set(track "${track}-Packages")
#endif()
set(track ${CTEST_TRACK_PREFIX}${track}${CTEST_TRACK_SUFFIX})

# For more details, see http://www.kitware.com/blog/home/post/11
set(CTEST_USE_LAUNCHERS 1)
if(NOT "${CTEST_CMAKE_GENERATOR}" MATCHES "Make")
  set(CTEST_USE_LAUNCHERS 0)
endif()
set(ENV{CTEST_USE_LAUNCHERS_DEFAULT} ${CTEST_USE_LAUNCHERS})

if(empty_binary_directory)
  message("Directory ${CTEST_BINARY_DIRECTORY} cleaned !")
  ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
endif()

if(NOT EXISTS "${CTEST_SOURCE_DIRECTORY}")
  set(CTEST_CHECKOUT_COMMAND "${CTEST_GIT_COMMAND} clone ${git_branch_option} ${GIT_REPOSITORY} ${CTEST_SOURCE_DIRECTORY}")
endif()
set(CTEST_UPDATE_COMMAND "${CTEST_GIT_COMMAND}")

set(CTEST_SOURCE_DIRECTORY "${CTEST_SOURCE_DIRECTORY}")

#-----------------------------------------------------------------------------
# Macro allowing to set a variable to its default value only if not already defined
macro(setOnlyIfNotDefined var defaultvalue)
  if(NOT DEFINED ${var})
    set(${var} "${defaultvalue}")
  endif()
endmacro()

#-----------------------------------------------------------------------------
# The following variable can be used while testing the driver scripts
#-----------------------------------------------------------------------------
setOnlyIfNotDefined(run_ctest_submit TRUE)
setOnlyIfNotDefined(run_ctest_with_update TRUE)
setOnlyIfNotDefined(run_ctest_with_configure TRUE)
setOnlyIfNotDefined(run_ctest_with_build TRUE)
setOnlyIfNotDefined(run_ctest_with_test TRUE)
setOnlyIfNotDefined(run_ctest_with_coverage TRUE)
setOnlyIfNotDefined(run_ctest_with_memcheck TRUE)
setOnlyIfNotDefined(run_ctest_with_packages TRUE)
setOnlyIfNotDefined(run_ctest_with_upload TRUE)
setOnlyIfNotDefined(run_ctest_with_notes TRUE)

#
# run_ctest macro
#
macro(run_ctest)
  ctest_start(${model} TRACK ${track})
  ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}" RETURN_VALUE FILES_UPDATED)

  # force a build if this is the first run and the build dir is empty
  if(NOT EXISTS "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt")
    message("First time build - Initialize CMakeCache.txt")
    set(force_build 1)

    if(WITH_EXTENSIONS)
      set(ADDITIONAL_CMAKECACHE_OPTION
        "${ADDITIONAL_CMAKECACHE_OPTION} CTEST_MODEL:STRING=${model}")
    endif()

    #-----------------------------------------------------------------------------
    # Write initial cache.
    #-----------------------------------------------------------------------------
    file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" "
    QT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_EXECUTABLE}
    GIT_EXECUTABLE:FILEPATH=${CTEST_GIT_COMMAND}
    WITH_COVERAGE:BOOL=${WITH_COVERAGE}
    ${ADDITIONAL_CMAKECACHE_OPTION}
    ")
  endif()

  if(FILES_UPDATED GREATER 0 OR force_build)

    set(force_build 0)

    #-----------------------------------------------------------------------------
    # Update
    #-----------------------------------------------------------------------------
    if(run_ctest_with_update AND run_ctest_submit)
      ctest_submit(PARTS Update)
    endif()

    #-----------------------------------------------------------------------------
    # Configure
    #-----------------------------------------------------------------------------
    if(run_ctest_with_configure)
      message("----------- [ Configure ${CTEST_PROJECT_NAME} ] -----------")

      set(label ResEdit)

      set_property(GLOBAL PROPERTY SubProject ${label})
      set_property(GLOBAL PROPERTY Label ${label})

      ctest_configure(BUILD "${CTEST_BINARY_DIRECTORY}")
      ctest_read_custom_files("${CTEST_BINARY_DIRECTORY}")
      if(run_ctest_submit)
        ctest_submit(PARTS Configure)
      endif()
    endif()

    #-----------------------------------------------------------------------------
    # Build top level
    #-----------------------------------------------------------------------------
    set(build_errors)
    if(run_ctest_with_build)
      message("----------- [ Build ${CTEST_PROJECT_NAME} ] -----------")
      ctest_build(BUILD "${CTEST_BINARY_DIRECTORY}" NUMBER_ERRORS build_errors APPEND)
      if(run_ctest_submit)
        ctest_submit(PARTS Build)
      endif()
    endif()

    #-----------------------------------------------------------------------------
    # Inner build directory
    #-----------------------------------------------------------------------------
    set(resedit_build_dir "${CTEST_BINARY_DIRECTORY}")

    #-----------------------------------------------------------------------------
    # Test
    #-----------------------------------------------------------------------------
    if(run_ctest_with_test)
      message("----------- [ Test ${CTEST_PROJECT_NAME} ] -----------")
      ctest_test(
        BUILD "${resedit_build_dir}"
        INCLUDE_LABEL ${label}
        PARALLEL_LEVEL ${CTEST_PARALLEL_LEVEL}
        EXCLUDE ${TEST_TO_EXCLUDE_REGEX})
      # runs only tests that have a LABELS property matching "${label}"
      if(run_ctest_submit)
        ctest_submit(PARTS Test)
      endif()
    endif()

    #-----------------------------------------------------------------------------
    # Global coverage ...
    #-----------------------------------------------------------------------------
    if(run_ctest_with_coverage)
      # HACK Unfortunately ctest_coverage ignores the BUILD argument, try to force it...
      file(READ ${resedit_build_dir}/CMakeFiles/TargetDirectories.txt resedit_build_coverage_dirs)
      file(APPEND "${CTEST_BINARY_DIRECTORY}/CMakeFiles/TargetDirectories.txt" "${resedit_build_coverage_dirs}")

      if(WITH_COVERAGE AND CTEST_COVERAGE_COMMAND)
        message("----------- [ Global coverage ] -----------")
        ctest_coverage(BUILD "${resedit_build_dir}")
        if(run_ctest_submit)
          ctest_submit(PARTS Coverage)
        endif()
      endif()
    endif()

    #-----------------------------------------------------------------------------
    # Global dynamic analysis ...
    #-----------------------------------------------------------------------------
    if(WITH_MEMCHECK AND CTEST_MEMORYCHECK_COMMAND AND run_ctest_with_memcheck)
        message("----------- [ Global memcheck ] -----------")
        ctest_memcheck(BUILD "${resedit_build_dir}")
        if(run_ctest_submit)
          ctest_submit(PARTS MemCheck)
        endif()
    endif()

    #-----------------------------------------------------------------------------
    # Create packages / installers ...
    #-----------------------------------------------------------------------------
    if(WITH_PACKAGES AND (run_ctest_with_packages OR run_ctest_with_upload))
      message("----------- [ WITH_PACKAGES and UPLOAD ] -----------")

      include(${MIDAS_PACKAGES_CREDENTIAL_FILE})

      if("${MIDAS_PACKAGES_API_EMAIL}" STREQUAL "")
        message(FATAL_ERROR "Failed to upload package - MIDAS_PACKAGES_API_EMAIL variable not set !")
      endif()
      if("${MIDAS_PACKAGES_API_KEY}" STREQUAL "")
        message(FATAL_ERROR "Failed to upload package - MIDAS_PACKAGES_API_KEY variable not set !")
      endif()

      if(build_errors GREATER "0")
        message("Build Errors Detected: ${build_errors}. Aborting package generation")
      else()

        # Update CMake module path so that our custom macros/functions can be included.
        set(CMAKE_MODULE_PATH ${CTEST_SOURCE_DIRECTORY}/CMake ${CMAKE_MODULE_PATH})

        # Download and include CTestPackage
        set(url http://viewvc.slicer.org/viewvc.cgi/Slicer4/trunk/CMake/CTestPackage.cmake?revision=19739&view=co)
        set(dest ${CTEST_BINARY_DIRECTORY}/CTestPackage.cmake)
        download_file(${url} ${dest})
        include(${dest})

        # Download and include MIDASCTestUploadURL
        set(url http://viewvc.slicer.org/viewvc.cgi/Slicer4/trunk/CMake/MIDASCTestUploadURL.cmake?revision=19739&view=co)
        set(dest ${CTEST_BINARY_DIRECTORY}/MIDASCTestUploadURL.cmake)
        download_file(${url} ${dest})
        include(${dest})

        # Download and include MidasAPI
        set(url ${MIDAS_PACKAGES_URL}/api/rest?method=midas.packages.script.download)
        set(dest ${CMAKE_CURRENT_LIST_DIR}/MidasAPI.cmake)
        download_file(${url} ${dest})
        include(${dest})

        set(packages)
        if(run_ctest_with_packages)
          message("Packaging ...")
          ctest_package(
            BINARY_DIR ${CTEST_BINARY_DIRECTORY}
            CONFIG ${CTEST_BUILD_CONFIGURATION}
            RETURN_VAR packages)
        else()
          set(packages ${CMAKE_CURRENT_LIST_FILE})
        endif()

        if(WIN32)
          set(PACKAGE_OS "Windows")
        elseif(APPLE)
          set(PACKAGE_OS "MacOSX")
        elseif(UNIX)
          set(PACKAGE_OS "Linux")
        endif()

        set(PACKAGE_BITNESS "${MY_BITNESS}-bit")

        if(run_ctest_with_upload)
          message("Uploading ...")
          foreach(p ${packages})
            get_filename_component(PACKAGE_NAME "${p}" NAME)

            set(_version_regex "0.[0-9].[0-9][0-9]?")
            set(_os_regex "-(win|linux|macosx|Darwin|Windows|Linux)")
            string(REGEX MATCH ${_version_regex} PACKAGE_VERSION ${PACKAGE_NAME})
            set(PACKAGE_RELEASE "")
            if(PACKAGE_NAME MATCHES ${_version_regex}${_os_regex})
              set(PACKAGE_RELEASE ${PACKAGE_VERSION})
            endif()

            message("Uploading [${PACKAGE_NAME}] on [${MIDAS_PACKAGES_URL}]")
            midas_api_package_upload(
              API_URL ${MIDAS_PACKAGES_URL}
              API_EMAIL ${MIDAS_PACKAGES_API_EMAIL}
              API_KEY ${MIDAS_PACKAGES_API_KEY}
              FILE ${p}
              NAME ${PACKAGE_NAME}
              FOLDER_ID ${MIDAS_PACKAGES_FOLDER_ID}
              APPLICATION_ID ${MIDAS_PACKAGES_APPLICATION_ID}
              OS ${PACKAGE_OS}
              ARCH ${PACKAGE_BITNESS}
              PACKAGE_TYPE "TGZ Archive"
              SUBMISSION_TYPE ${model}
              RELEASE ${PACKAGE_RELEASE}
              RESULT_VARNAME midas_upload_status
              )
            if(midas_upload_status STREQUAL "ok")
              message("Uploading URL on CDash")
              set(MIDAS_PACKAGE_URL ${MIDAS_PACKAGES_URL})
              midas_ctest_upload_url(${p}) # on success, upload a link to CDash
            endif()
            if(NOT midas_upload_status STREQUAL "ok")
              message("        => Failed to upload item package ! See [${CMAKE_CURRENT_BINARY_DIR}/midas.*_response.txt] for more details.\n")
              message("Uploading [${PACKAGE_NAME}] on CDash")
              ctest_upload(FILES ${p})
            endif()
            if(run_ctest_submit)
              ctest_submit(PARTS Upload)
            endif()
          endforeach()
        endif()

      endif()
    endif()

    #-----------------------------------------------------------------------------
    # Note should be at the end
    #-----------------------------------------------------------------------------
    if(run_ctest_with_notes AND run_ctest_submit)
      ctest_submit(PARTS Notes)
    endif()

  endif()
endmacro()

if(SCRIPT_MODE STREQUAL "continuous")
  while(${CTEST_ELAPSED_TIME} LESS 46800) # Lasts 13 hours (Assuming it starts at 9am, it will end around 10pm)
    set(START_TIME ${CTEST_ELAPSED_TIME})
    run_ctest()
    set(interval 300)
    # Loop no faster than once every <interval> seconds
    message("Wait for ${interval} seconds ...")
    ctest_sleep(${START_TIME} ${interval} ${CTEST_ELAPSED_TIME})
  endwhile()
else()
  run_ctest()
endif()

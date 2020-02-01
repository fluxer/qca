IF (KATIE_BUILD)
  MACRO (SETUP_KATIE_DIRS)
    set(QT_PREFIX_DIR ${QT_PREFIX_PATH})
    set(QT_DATA_DIR ${QT_DATA_PATH})
  ENDMACRO()
ELSE ()
  # Cmake FindQt4 module doesn't provide QT_INSTALL_PREFIX and QT_INSTALL_DATA vars
  # It will be done here
  MACRO(SETUP_QT4_DIRS)
    _qt4_query_qmake(QT_INSTALL_PREFIX QT_PREFIX_DIR)
    _qt4_query_qmake(QT_INSTALL_DATA QT_DATA_DIR)
  ENDMACRO(SETUP_QT4_DIRS)
ENDIF()

MACRO(MY_AUTOMOC _srcsList)
  # QT4_GET_MOC_INC_DIRS(_moc_INCS)
  FOREACH (_current_FILE ${${_srcsList}})
    GET_FILENAME_COMPONENT(_abs_FILE ${_current_FILE} ABSOLUTE)
    GET_FILENAME_COMPONENT(_basename ${_current_FILE} NAME_WE)
    SET(_moc ${CMAKE_CURRENT_BINARY_DIR}/${_basename}.moc)
    # SET(extra_moc_argument)
    # if(WIN32)
    #    SET(extra_moc_argument -DWIN32)
    # endif(WIN32)
    QT4_GENERATE_MOC(${_abs_FILE} ${_moc})
    # ADD_CUSTOM_COMMAND(OUTPUT ${_moc}
    #                    COMMAND ${QT_MOC_EXECUTABLE}
    #                    ARGS ${extra_moc_argument} ${_moc_INCS} -o ${_moc} ${_abs_FILE}
    #                    DEPENDS ${_current_FILE}
    # )
    LIST(APPEND ${_srcsList} ${_moc})
  ENDFOREACH (_current_FILE)
ENDMACRO(MY_AUTOMOC)

macro(set_enabled_plugin PLUGIN ENABLED)
  # To nice looks
  if(ENABLED)
    set(ENABLED "on")
  else(ENABLED)
    set(ENABLED "off")
  endif(ENABLED)
  set(WITH_${PLUGIN}_PLUGIN_INTERNAL ${ENABLED} CACHE INTERNAL "")
endmacro(set_enabled_plugin)

macro(enable_plugin PLUGIN)
  set_enabled_plugin(${PLUGIN} "on")
endmacro(enable_plugin)

macro(disable_plugin PLUGIN)
  set_enabled_plugin(${PLUGIN} "off")
endmacro(disable_plugin)

# it used to build examples and tools
macro(target_link_qca_libraries TARGET)
  # Link with QCA library
  target_link_libraries(${TARGET} ${QT_QTCORE_LIBRARY})
  target_link_libraries(${TARGET} ${QCA_LIB_NAME})

  # Statically link with all enabled QCA plugins
  if(STATIC_PLUGINS)
    target_link_libraries(${TARGET} ${QT_QTCORE_LIB_DEPENDENCIES})
    foreach(PLUGIN IN LISTS PLUGINS)
      # Check plugin for enabled
      if(WITH_${PLUGIN}_PLUGIN_INTERNAL)
        target_link_libraries(${TARGET} qca-${PLUGIN})
      endif(WITH_${PLUGIN}_PLUGIN_INTERNAL)
    endforeach(PLUGIN)
  endif(STATIC_PLUGINS)
endmacro(target_link_qca_libraries)

# it used to build unittests
macro(target_link_qca_test_libraries TARGET)
  target_link_qca_libraries(${TARGET})
  target_link_libraries(${TARGET} ${QT_QTTEST_LIBRARY})
endmacro(target_link_qca_test_libraries)

# it used to build unittests
macro(add_qca_test TARGET DESCRIPTION)
  add_test(NAME "${DESCRIPTION}"
           WORKING_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
           COMMAND "${TARGET}")
endmacro(add_qca_test)

macro(install_pdb TARGET INSTALL_PATH)
  if(MSVC)
    get_target_property(LOCATION ${TARGET} LOCATION_DEBUG)
    string(REGEX REPLACE "\\.[^.]*$" ".pdb" LOCATION "${LOCATION}")
    install(FILES ${LOCATION} DESTINATION ${INSTALL_PATH} CONFIGURATIONS Debug)

    get_target_property(LOCATION ${TARGET} LOCATION_RELWITHDEBINFO)
    string(REGEX REPLACE "\\.[^.]*$" ".pdb" LOCATION "${LOCATION}")
    install(FILES ${LOCATION} DESTINATION ${INSTALL_PATH} CONFIGURATIONS RelWithDebInfo)
  endif(MSVC)
endmacro(install_pdb)

macro(normalize_path PATH)
  get_filename_component(${PATH} "${${PATH}}" ABSOLUTE)
  # Strip trailing slashes
  string(REGEX REPLACE "/+$" "" PATH ${PATH})
endmacro()

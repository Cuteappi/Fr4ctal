find_package(Qt6 REQUIRED COMPONENTS Core Qml Gui Quick Concurrent)

# Standard Qt project setup
qt_standard_project_setup()

# Create the plugin library
add_library(plugins SHARED
    FpsText.cpp
    XyraPluginsPlugin.cpp
)

# Set target properties
set_target_properties(plugins PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/plugins
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/plugins
)

# Link Qt libraries
target_link_libraries(plugins PRIVATE
    Qt6::Core
    Qt6::Qml
    Qt6::Gui
    Qt6::Quick
    Qt6::Concurrent
)

# Add QML module
qt_add_qml_module(plugins
    URI Xyra.Plugins
    VERSION 1.0
    DEPENDENCIES QtQuick
)

# Include directories
target_include_directories(plugins PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

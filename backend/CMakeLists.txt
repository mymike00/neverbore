include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
)

set(
    Neverborebackend_SRCS
    modules/Neverbore/backend.cpp
    modules/Neverbore/level.cpp
    modules/Neverbore/levels.cpp
    modules/Neverbore/pack.cpp
)

add_library(Neverborebackend MODULE
    ${Neverborebackend_SRCS}
)

set_target_properties(Neverborebackend PROPERTIES
         LIBRARY_OUTPUT_DIRECTORY Neverbore)

qt5_use_modules(Neverborebackend Gui Qml Quick)

# Copy qmldir file to build dir for running in QtCreator
add_custom_target(Neverborebackend-qmldir ALL
    COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/modules/Neverbore/qmldir ${CMAKE_CURRENT_BINARY_DIR}/Neverbore
    DEPENDS ${QMLFILES}
)

# Install plugin file
install(TARGETS Neverborebackend DESTINATION ${QT_IMPORTS_DIR}/Neverbore/)
install(FILES   modules/Neverbore/qmldir DESTINATION ${QT_IMPORTS_DIR}/Neverbore/)


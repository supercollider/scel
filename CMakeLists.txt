add_subdirectory(el)
add_subdirectory(sc/scide_scel)
install(DIRECTORY HelpSource
        DESTINATION share/SuperCollider/Extensions/scide_scel/)

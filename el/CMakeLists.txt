option(SC_EL_BYTECOMPILE "Build emacs-based IDE." ON)
mark_as_advanced(SC_EL_BYTECOMPILE)

set(PKG_DATA_DIR ${CMAKE_INSTALL_PREFIX}/share/SuperCollider)

file(GLOB scel_sources
	 RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.el)

# if w3m in installed locally add to the load-path
file(GLOB local-load-path
	LIST_DIRECTORIES true
	"$ENV{HOME}/.emacs.d/site-lisp/w3m-*"
	"$ENV{HOME}/.emacs.d/elpa/w3m-*")

foreach (path ${local-load-path})
	if(NOT IS_DIRECTORY ${path})
		list(REMOVE_ITEM local-load-path ${path})
	endif()
endforeach()

list(APPEND local-load-path ${CMAKE_CURRENT_BINARY_DIR})

# convert to string of form " dir1 -L dir2 -L dir3 ..." when more than one dir
string(JOIN " -L " load-path ${local-load-path})

# build the argument string
string(CONCAT EMACS_ARGS "-batch -L " ${load-path} " -f batch-byte-compile")

configure_file(sclang-vars.el.in
			   ${CMAKE_CURRENT_BINARY_DIR}/sclang-vars.el)

foreach (el ${scel_sources})
	configure_file(${el} ${CMAKE_CURRENT_BINARY_DIR}/${el})
endforeach()

set(all_scel_sources ${scel_sources} sclang-vars.el)

install (FILES ${scel_sources} ${CMAKE_CURRENT_BINARY_DIR}/sclang-vars.el
			DESTINATION share/emacs/site-lisp/SuperCollider)

# the emacs command needs to be evaled due to layers of (un)escaping required to add load-path
if (SC_EL_BYTECOMPILE)
	find_program(EMACS_EXECUTABLE emacs)
	if(NOT EMACS_EXECUTABLE)
		message(SEND_ERROR "Emacs could not be found.\n (If emacs interface is not required, then set SC_EL=no)")
	endif()

	foreach (el ${all_scel_sources})
		add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${el}c
			VERBATIM
			COMMAND eval "${EMACS_EXECUTABLE} ${EMACS_ARGS} ${CMAKE_CURRENT_BINARY_DIR}/${el}"
			DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${el}
			WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
			COMMENT "Creating byte-compiled Emacs lisp ${CMAKE_CURRENT_BINARY_DIR}/${el}c")

		add_custom_target(compile_${el}c ALL
		DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${el}c)

		install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${el}c
		DESTINATION share/emacs/site-lisp/SuperCollider)
	endforeach()
endif()

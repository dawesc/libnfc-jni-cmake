cmake_minimum_required(VERSION 3.1)

project(ThirdParty)

include(ExternalProject)

option(BUILD_LIBNFC          "Build local libnfc library"       on)
option(BUILD_LIBLLCP         "Build local libllcp library"      on)

########################################
## libnfc

if(BUILD_LIBNFC)
  set(LIBNFC_SOURCE_URL    "https://github.com/nfc-tools/libnfc/releases/download/libnfc-1.7.1/libnfc-1.7.1.tar.bz2")
  set(LIBNFC_SOURCE_MD5    "a3bea901778ac324e802b8ffb86820ff")
  set(LIBNFC_DOWNLOAD_DIR  "${CMAKE_SOURCE_DIR}/src")
  set(LIBNFC_SOURCE_DIR    "${CMAKE_SOURCE_DIR}/src/LIBNFC")
  set(LIBNFC_INSTALL_DIR   "${CMAKE_BINARY_DIR}/LIBNFC")

  externalproject_add(LIBNFC
    URL          ${LIBNFC_SOURCE_URL}
    URL_MD5      ${LIBNFC_SOURCE_MD5}
    DOWNLOAD_DIR ${LIBNFC_DOWNLOAD_DIR}
    SOURCE_DIR   ${LIBNFC_SOURCE_DIR}
    INSTALL_DIR  ${LIBNFC_INSTALL_DIR}
    BUILD_IN_SOURCE TRUE
    CONFIGURE_COMMAND 	cd <SOURCE_DIR> && ./configure --prefix=<INSTALL_DIR>
    BUILD_COMMAND 		make
    INSTALL_COMMAND 	make install)

  install(DIRECTORY "${LIBNFC_INSTALL_DIR}/bin/"
    DESTINATION bin COMPONENT runtime-third-party-third-party USE_SOURCE_PERMISSIONS OPTIONAL)
  install(DIRECTORY "${LIBNFC_INSTALL_DIR}/lib/"
    DESTINATION lib COMPONENT runtime-third-party-third-party USE_SOURCE_PERMISSIONS)
  install(DIRECTORY "${LIBNFC_INSTALL_DIR}/include/"
    DESTINATION include COMPONENT devel-third-party USE_SOURCE_PERMISSIONS)
  install(DIRECTORY "${LIBNFC_INSTALL_DIR}/share/"
    DESTINATION share COMPONENT devel-third-party USE_SOURCE_PERMISSIONS)
endif()

########################################
## libllcp

if(BUILD_LIBLLCP)
  set(LIBLLCP_GIT_URL 		"https://github.com/nfc-tools/libllcp.git")
  set(LIBLLCP_GIT_VERSION 	"05dfa8003433a7070bfd8ae02efdb0203bbf34aa")
  set(LIBLLCP_SOURCE_DIR 	"${CMAKE_SOURCE_DIR}/src/libllcp")
  set(LIBLLCP_INSTALL_DIR 	"${CMAKE_BINARY_DIR}/libllcp")

  externalproject_add(libllcp
    DOWNLOAD_COMMAND git clone ${LIBLLCP_GIT_URL} ${LIBLLCP_SOURCE_DIR} || true
    UPDATE_COMMAND 	 git fetch --prune --tags && git checkout ${LIBLLCP_GIT_VERSION}
    SOURCE_DIR       ${LIBLLCP_SOURCE_DIR}
    INSTALL_DIR      ${LIBLLCP_INSTALL_DIR}
    BUILD_IN_SOURCE TRUE
    CONFIGURE_COMMAND cd <SOURCE_DIR> && autoreconf --force --install && env LIBNFC_CFLAGS="-I${LIBNFC_INSTALL_DIR}/include" LIBNFC_LIBS="-L${LIBNFC_INSTALL_DIR}/lib -lnfc" ./configure --prefix=<INSTALL_DIR>
    BUILD_COMMAND    make
    INSTALL_COMMAND  make install
    DEPENDS          LIBNFC)

  install(DIRECTORY "${LIBLLCP_INSTALL_DIR}/lib/"
    DESTINATION lib COMPONENT runtime-third-party USE_SOURCE_PERMISSIONS)
  install(DIRECTORY "${LIBLLCP_INSTALL_DIR}/include/"
    DESTINATION include COMPONENT devel-third-party USE_SOURCE_PERMISSIONS)
endif()

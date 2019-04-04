cmake_minimum_required(VERSION 3.5)

project(libnfc_libfreefare)

SET(MAJOR_VERSION 1)
SET(MINOR_VERSION 0)
SET(PATCH_VERSION 0)

include(ExternalProject)

option(BUILD_LIBNFC          "Build local libnfc library"       on)
option(BUILD_LIBFREEFARE         "Build local libfreefare library"      on)
option(BUILD_GSL             "Build local gsl library"          on)

########################################
## libnfc

if(BUILD_LIBNFC)
  set(LIBNFC_SOURCE_URL    "https://github.com/nfc-tools/libnfc.git")
  set(LIBNFC_SOURCE_MD5    "c59219905c7fa136205d4f65edd3f9dfc4efe239")
  set(LIBNFC_SOURCE_DIR    "${CMAKE_SOURCE_DIR}/src/libnfc")
  set(LIBNFC_INSTALL_DIR   "${CMAKE_BINARY_DIR}/libnfc")

  externalproject_add(libnfc
    DOWNLOAD_COMMAND git clone ${LIBNFC_GIT_URL} ${LIBNFC_SOURCE_DIR} || true
    UPDATE_COMMAND 	 git fetch --prune --tags && git checkout ${LIBNFC_GIT_VERSION}
    SOURCE_DIR   ${LIBNFC_SOURCE_DIR}
    INSTALL_DIR  ${LIBNFC_INSTALL_DIR}
    BUILD_IN_SOURCE TRUE
    CONFIGURE_COMMAND 	cd <SOURCE_DIR> && ./configure --prefix=<INSTALL_DIR> --sysconfdir=/etc
    BUILD_COMMAND 		make
    INSTALL_COMMAND 	make install)

  install(DIRECTORY "${LIBNFC_INSTALL_DIR}/bin/"
    DESTINATION bin COMPONENT runtime USE_SOURCE_PERMISSIONS OPTIONAL)
  install(DIRECTORY "${LIBNFC_INSTALL_DIR}/lib/"
    DESTINATION lib COMPONENT runtime USE_SOURCE_PERMISSIONS)
  install(DIRECTORY "${LIBNFC_INSTALL_DIR}/include/"
    DESTINATION include COMPONENT dev USE_SOURCE_PERMISSIONS)
  install(DIRECTORY "${LIBNFC_INSTALL_DIR}/share/"
    DESTINATION share COMPONENT dev USE_SOURCE_PERMISSIONS)
endif()

########################################
## libfreefare

if(BUILD_LIBFREEFARE)
  set(LIBFREEFARE_GIT_URL 		"https://github.com/nfc-tools/libfreefare.git")
  set(LIBFREEFARE_GIT_VERSION 	"5459806659d5f6aa0e7705b88c48775ea6c861a6")
  set(LIBFREEFARE_SOURCE_DIR 	"${CMAKE_SOURCE_DIR}/src/libfreefare")
  set(LIBFREEFARE_INSTALL_DIR 	"${CMAKE_BINARY_DIR}/libfreefare")

  externalproject_add(libfreefare
    DOWNLOAD_COMMAND git clone ${LIBFREEFARE_GIT_URL} ${LIBFREEFARE_SOURCE_DIR} || true
    UPDATE_COMMAND 	 git fetch --prune --tags && git checkout ${LIBFREEFARE_GIT_VERSION}
    SOURCE_DIR       ${LIBFREEFARE_SOURCE_DIR}
    INSTALL_DIR      ${LIBFREEFARE_INSTALL_DIR}
    BUILD_IN_SOURCE TRUE
    CONFIGURE_COMMAND cd <SOURCE_DIR> && autoreconf -vis && env LIBNFC_CFLAGS="-I${LIBNFC_INSTALL_DIR}/include" LIBNFC_LIBS="-L${LIBNFC_INSTALL_DIR}/lib -lnfc" ./configure --prefix=<INSTALL_DIR>
    BUILD_COMMAND    make
    INSTALL_COMMAND  make install
    DEPENDS          libnfc)

  install(DIRECTORY "${LIBFREEFARE_INSTALL_DIR}/lib/"
    DESTINATION lib COMPONENT runtime USE_SOURCE_PERMISSIONS)
  install(DIRECTORY "${LIBFREEFARE_INSTALL_DIR}/include/"
    DESTINATION include COMPONENT dev USE_SOURCE_PERMISSIONS)
endif()


########################################
## Microsoft GSL

if(BUILD_GSL)
  set(GSL_GIT_URL "https://github.com/Microsoft/GSL.git")
  set(GSL_GIT_VERSION "0cebbd77bfc21acbf1cc05983ad626539eeeb8e0")
  set(GSL_SOURCE_DIR "${CMAKE_SOURCE_DIR}/src/gsl")

  externalproject_add(gsl
    DOWNLOAD_COMMAND git clone ${GSL_GIT_URL} ${GSL_SOURCE_DIR} || true
    UPDATE_COMMAND git fetch --prune --tags && git checkout ${GSL_GIT_VERSION}
    SOURCE_DIR ${GSL_SOURCE_DIR}
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND "")

  install(DIRECTORY "${GSL_SOURCE_DIR}/include/"
    DESTINATION include COMPONENT dev USE_SOURCE_PERMISSIONS)
endif()

########################################
## Packaging
########################################
#

SET(CPACK_GENERATOR "DEB")
SET(CPACK_DEBIAN_PACKAGE_MAINTAINER "Christopher Dawes")

SET(CPACK_PACKAGE_DESCRIPTION "libnfc and libfreefare")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Includes packages for libnfc and libfreefare")
SET(CPACK_PACKAGE_VENDOR "N/A")
SET(CPACK_PACKAGE_CONTACT "Christopher Dawes")
SET(CPACK_PACKAGE_VERSION_MAJOR "${MAJOR_VERSION}")
SET(CPACK_PACKAGE_VERSION_MINOR "${MINOR_VERSION}")
SET(CPACK_PACKAGE_VERSION_PATCH "${PATCH_VERSION}")
SET(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}_${MAJOR_VERSION}.${MINOR_VERSION}.${CPACK_PACKAGE_VERSION_PATCH}.${CMAKE_SYSTEM_PROCESSOR}")
SET(CPACK_SOURCE_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}_${MAJOR_VERSION}.${MINOR_VERSION}.${CPACK_PACKAGE_VERSION_PATCH}.${CMAKE_SYSTEM_PROCESSOR}")

SET(CPACK_DEBIAN_PACKAGE_DEPENDS "libusb-dev,libfontconfig1,libxrender1")

SET(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
SET(CPACK_DEBIAN_PACKAGE_SECTION "development")
SET(CPACK_DEBIAN_ARCHITECTURE ${CMAKE_SYSTEM_PROCESSOR})
SET (CPACK_DEB_COMPONENT_INSTALL ON)

SET(CPACK_COMPONENTS_ALL runtime dev)

INCLUDE(CPack)

cpack_add_component_group("runtime")
cpack_add_component_group("dev")
cpack_add_install_type(Full)
cpack_add_install_type(Core)

cpack_add_component("runtime"
                        DISPLAY_NAME "Runtime Components"
                        DESCRIPTION "Runtime Components"
                        GROUP "runtime"
                        INSTALL_TYPES Core Full)
cpack_add_component("dev"
                        DISPLAY_NAME "Development"
                        DESCRIPTION "C++ Headers"
                        GROUP "dev"
                        DEPENDS "runtime"
                        INSTALL_TYPES Full)

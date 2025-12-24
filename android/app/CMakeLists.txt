cmake_minimum_required(VERSION 3.14)
project(freeman)
add_library( freemanffi
        SHARED
        ../../lib/cpp/include/dart_api_dl.c
        ../../lib/cpp/freemanffi.cpp)

set(CURR_TARGET_NAME "freemanffi")

message(STATUS "CMAKE_SOURCE_DIR:${CMAKE_SOURCE_DIR}")

target_include_directories(
        freemanffi PUBLIC
        ../../lib/cpp/include
        ${CMAKE_SOURCE_DIR}/../third_sdk/freeman/include)

target_link_directories( ${CURR_TARGET_NAME} PRIVATE
        ${CMAKE_SOURCE_DIR}/../third_sdk/freeman/${ANDROID_ABI}
        )

set(LINK_THIRD_LIBS
        freeman
        opendht
        argon2
        cppunit
        fmt
        pjnath-aarch64-unknown-linux-android
        pj-aarch64-unknown-linux-android
        pjlib-util-aarch64-unknown-linux-android
        gmp gnutls gnutlsxx hogweed msgpackc nettle
        uuid
        crypto ssl
        )

target_link_libraries(
        freemanffi
        ${LINK_THIRD_LIBS}
        log
        android
        z
        ${log-lib})
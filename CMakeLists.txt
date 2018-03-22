cmake_minimum_required(VERSION 3.7)
project(XSBench)

find_package(OpenMP)
if (OPENMP_FOUND)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
    set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
endif()

find_package(caliper)
if (caliper_FOUND)
    add_definitions(-DWITH_CALIPER)
    include_directories(${caliper_INCLUDE_DIR})
endif()

set(SOURCE_FILES
        src/CalculateXS.c
        src/GridInit.c
        src/io.c
        src/Main.c
        src/Materials.c
        src/XSbench_header.h
        src/XSutils.c)

find_package(PAPI)
if(PAPI_FOUND)
    # TODO: include_directories and target_link_libraries
    set(SOURCE_FILES "${SOURCE_FILES} src/papi.c")
endif()

add_executable(XSBench ${SOURCE_FILES})

set_property(TARGET XSBench PROPERTY C_STANDARD 99)
target_link_libraries(XSBench m)

if (caliper_FOUND)
    target_link_libraries(XSBench caliper)
endif()

# Makefile for compiling MSIS Fortran code into a shared library for C# interop
#
# Prerequisites:
# - gfortran (GNU Fortran compiler)
# - The MSIS Fortran source files should be in the same directory

# Compiler settings
FC = gfortran
FFLAGS = -fPIC -O2 -shared
TARGET = libmsis21.so
HEADERS = msis_c_interface.h

# Fortran source files in dependency order
SOURCES = msis_constants.F90 msis_utils.F90 msis_init.F90 msis_gfn.F90 msis_tfn.F90 msis_dfn.F90 msis_calc.F90

# Object files
OBJECTS = $(SOURCES:.F90=.o)

# Default target
all: $(TARGET)

# Build the shared library
$(TARGET): $(OBJECTS)
	$(FC) $(FFLAGS) -o $@ $^

# Compile Fortran source files with explicit dependencies
CPPFLAGS = -DDBLE

msis_constants.o: msis_constants.F90
	$(FC) -fPIC $(CPPFLAGS) -c $< -o $@

msis_utils.o: msis_utils.F90 msis_constants.o
	$(FC) -fPIC $(CPPFLAGS) -c $< -o $@

msis_init.o: msis_init.F90 msis_constants.o
	$(FC) -fPIC $(CPPFLAGS) -c $< -o $@

msis_gfn.o: msis_gfn.F90 msis_constants.o msis_init.o
	$(FC) -fPIC $(CPPFLAGS) -c $< -o $@

msis_tfn.o: msis_tfn.F90 msis_constants.o msis_init.o msis_gfn.o msis_utils.o
	$(FC) -fPIC $(CPPFLAGS) -c $< -o $@

msis_dfn.o: msis_dfn.F90 msis_constants.o msis_utils.o
	$(FC) -fPIC $(CPPFLAGS) -c $< -o $@

msis_calc.o: msis_calc.F90 msis_constants.o msis_init.o msis_gfn.o msis_tfn.o msis_dfn.o msis_utils.o
	$(FC) -fPIC $(CPPFLAGS) -c $< -o $@

# Clean build artifacts
clean:
	rm -f *.o *.mod $(TARGET)

# Install the library (optional - adjust paths as needed)
install: $(TARGET)
	sudo cp $(TARGET) /usr/local/lib/
	sudo cp $(HEADERS) /usr/local/include/
	sudo ldconfig

# Show help
help:
	@echo "Available targets:"
	@echo "  all      - Build the shared library (default)"
	@echo "  clean    - Remove build artifacts"
	@echo "  install  - Install library and headers to system directories"
	@echo "  help     - Show this help message"
	@echo ""
	@echo "Usage:"
	@echo "  make         # Build libmsis21.so"
	@echo "  make clean   # Clean up"
	@echo "  make install # Install to system (requires sudo)"

.PHONY: all clean install help

# Notes:
# 1. Adjust SOURCES to include all necessary MSIS Fortran files
# 2. On macOS, change .so to .dylib and adjust FFLAGS accordingly
# 3. For Windows, you might want to create a .dll instead
# 4. Make sure all Fortran modules are compiled in the correct order

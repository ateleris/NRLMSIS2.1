# MSIS C# Interop

This directory contains the necessary files to create a C#-compatible interface for the NRLMSIS 2.1 Fortran library.

## Files Created

1. **msis_init.F90** (modified) - Added `msisinit_c` subroutine with `bind(C)` for C# interop
2. **msis_c_interface.h** - C header file defining the interface
3. **MsisInterop.cs** - C# P/Invoke wrapper class
4. **Makefile** - Build script for creating the shared library

## The Problem with Optional Arguments

The original `msisinit` subroutine uses Fortran's optional arguments with `character(len=*)` parameters:

```fortran
subroutine msisinit(parmpath,parmfile,iun,switch_gfn,switch_legacy, &
                    lzalt_type,lspec_select,lmass_include,lN2_msis00)
  character(len=*), intent(in), optional :: parmpath
  character(len=*), intent(in), optional :: parmfile
  ! ... other optional parameters
```

**C# P/Invoke cannot handle this** because:

- Optional arguments require special Fortran runtime handling
- `character(len=*)` creates variable-length character parameters
- The compiled signature doesn't match what C# expects

## The Solution: C-Compatible Wrapper

The `msisinit_c` wrapper subroutine:

- Uses `bind(C)` to create a C-compatible interface
- Converts all optional arguments to required arguments
- Uses fixed-size arrays instead of optional arrays
- Handles string length explicitly
- Converts between C and Fortran data types internally

## Compilation

### Prerequisites

- GNU Fortran compiler (`gfortran`)
- All MSIS Fortran source files

### Build the Shared Library

```bash
# Make sure all MSIS Fortran files are present
make

# This creates libmsis21.so (Linux) or equivalent on other platforms
```

### For Other Platforms

**macOS:**

```bash
# Modify Makefile to use .dylib extension
FC = gfortran
FFLAGS = -fPIC -O2 -dynamiclib
TARGET = libmsis21.dylib
```

**Windows (MinGW):**

```bash
# Modify Makefile for Windows
FC = gfortran
FFLAGS = -fPIC -O2 -shared
TARGET = msis21.dll
```

## C# Usage

### Basic Usage

```csharp
using MSIS.Interop;

// Initialize with defaults
MsisInterop.InitializeDefault();
```

### Advanced Usage

```csharp
// Custom initialization
var legacySwitches = new float[25];
for (int i = 0; i < 25; i++)
{
    legacySwitches[i] = 1.0f; // All switches on
}

var speciesSelection = new bool[10] { true, true, true, true, true, true, true, true, true, true };
var massInclusion = new bool[10] { true, true, true, true, true, true, true, true, true, true };

MsisInterop.Initialize(
    parameterPath: "/path/to/parameters",
    parameterFile: "msis21.parm",
    fileUnit: 67,
    useLegacySwitches: true,
    legacySwitches: legacySwitches,
    geometricAltitude: true,
    speciesSelection: speciesSelection,
    massInclusion: massInclusion,
    useN2Msis00: false);
```

## Array Meanings

### Legacy Switches (25 elements)

1. F10.7
2. Time independent
3. Symmetrical annual
4. Symmetrical semiannual
5. Asymmetrical annual
6. Asymmetrical semiannual
7. Diurnal
8. Semidiurnal
9. Geomagnetic activity (1.0 = Daily Ap mode, -1.0 = Storm-time ap mode)
10. All UT/long effects
11. Longitudinal
12. UT and mixed UT/long
13. Mixed Ap/UT/long
14. Terdiurnal
    15-25. Not used in NRLMSIS 2.1

### Species Selection (10 elements)

1. Mass density
2. N2
3. O2
4. O
5. He
6. H
7. Ar
8. N
9. Anomalous O
10. NO

### Mass Inclusion (10 elements)

Same ordering as species selection - flags which species to include in mass density calculation.

## Deployment

### Option 1: Copy Library to Application Directory

Place the compiled library (`libmsis21.so`, `libmsis21.dylib`, or `msis21.dll`) in the same directory as your C# application executable.

### Option 2: System Installation

```bash
make install  # Requires sudo on Linux/macOS
```

### Option 3: Specify Full Path

Modify the `LibraryName` constant in `MsisInterop.cs` to include the full path to your library.

## Troubleshooting

### Library Not Found

- Ensure the library is in the same directory as your executable
- Or ensure it's in your system's library path (`LD_LIBRARY_PATH` on Linux, `DYLD_LIBRARY_PATH` on macOS)
- Check that the library name in C# matches the compiled library name

### Runtime Errors

- Verify that the parameter file (`msis21.parm`) exists and is accessible
- Check file permissions
- Ensure all array sizes are correct (25 for legacy switches, 10 for species arrays)

### Compilation Errors

- Make sure all MSIS Fortran source files are present
- Check that module dependencies are resolved in the correct order
- Verify that your Fortran compiler supports the `iso_c_binding` module

## Next Steps

After successful initialization, you'll need to create similar C-compatible wrappers for other MSIS functions you want to call from C#, such as the main calculation routines.

#ifndef MSIS_C_INTERFACE_H
#define MSIS_C_INTERFACE_H

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * C-compatible wrapper for MSIS initialization
 *
 * @param parmpath_c      Path to parameter file (null-terminated string)
 * @param parmpath_len    Length of parmpath string (excluding null terminator)
 * @param parmfile_c      Parameter file name (null-terminated string)
 * @param parmfile_len    Length of parmfile string (excluding null terminator)
 * @param iun_c           File unit number for reading parameter file
 * @param use_switch_legacy Whether to use the legacy switch array
 * @param switch_legacy_c Legacy switch array (25 elements)
 * @param lzalt_type_c    true: height input is geometric, false: height input is geopotential
 * @param lspec_select_c  Array flagging which species densities are required (10 elements)
 * @param lmass_include_c Array flagging which species should be included in mass density (10 elements)
 * @param lN2_msis00_c    Flag for retrieving NRLMSISE-00 thermospheric N2 variations
 */
void msisinit_c(const char* parmpath_c, int parmpath_len,
                const char* parmfile_c, int parmfile_len,
                int iun_c, bool use_switch_legacy,
                const double* switch_legacy_c,
                bool lzalt_type_c,
                const bool* lspec_select_c,
                const bool* lmass_include_c,
                bool lN2_msis00_c);

/**
 * C-compatible wrapper for MSIS calculation
 *
 * @param day_c       Day of year (1-366)
 * @param utsec_c     Universal time in seconds (0-86400)
 * @param z_c         Altitude in kilometers
 * @param lat_c       Latitude in degrees (-90 to 90)
 * @param lon_c       Longitude in degrees (0-360)
 * @param sfluxavg_c  81-day average solar flux F10.7
 * @param sflux_c     Daily solar flux F10.7
 * @param ap_c        Geomagnetic activity indices (7 elements)
 * @param tn_c        Temperature at altitude (output)
 * @param dn_c        Density array (10 elements, output)
 * @param tex_c       Exospheric temperature (output)
 */
void msiscalc_c(double day_c, double utsec_c, double z_c, double lat_c, double lon_c,
                double sfluxavg_c, double sflux_c, const double* ap_c,
                double* tn_c, double* dn_c, double* tex_c);

#ifdef __cplusplus
}
#endif

#endif /* MSIS_C_INTERFACE_H */

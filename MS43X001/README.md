# MS43X001 (Initial release)
Release date: **31st Oct 2025** // **MAPocalypse**

## Downloads
- **E36/7 Z3-series**
  - coming soon

- **E39 5-series**
  - M54B30: [EU4 LHD](https://github.com/ms4x-net/MS43X-Custom-Firmware/raw/refs/heads/main/MS43X001/firmware/Siemens_MS43_MS43X001_E39_M54B30_EU4_LHD.bin)

- **E46 3-series**
  - M52TUB28: coming soon
  - M54B22: [EU4 LHD](https://github.com/ms4x-net/MS43X-Custom-Firmware/raw/refs/heads/main/MS43X001/firmware/Siemens_MS43_MS43X001_E46_M54B22_EU4_LHD.bin)
  - M54B25: [EU4 LHD](https://github.com/ms4x-net/MS43X-Custom-Firmware/raw/refs/heads/main/MS43X001/firmware/Siemens_MS43_MS43X001_E46_M54B25_EU4_LHD.bin)
  - M54B30: [EU4 LHD](https://github.com/ms4x-net/MS43X-Custom-Firmware/raw/refs/heads/main/MS43X001/firmware/Siemens_MS43_MS43X001_E46_M54B30_EU4_LHD.bin) || [US](https://github.com/ms4x-net/MS43X-Custom-Firmware/raw/refs/heads/main/MS43X001/firmware/Siemens_MS43_MS43X001_E46_M54B30_US.bin) ||

- **E53 X5-series**
  - M54B30: coming soon


## Changelog

### Behavior Changes
- Added configurable load input (MAP / MAF / Alpha-N)
- Switched from VO (valve overlap) tables to VE (volumetric efficiency) tables
- Removed legacy injection timing correction tables; replaced with dynamic injector scalars
- Reworked full-load detection logic
- Added intake air temperature dependency to electric cooling fan logic
- Enhanced engine speed limiter (with optional ignition cut)
- Improved serial communication routines
- Removed immobilizer (EWS) logic to free resources

### New Features
- Closed-loop boost controller (boost by gear)
- Overboost protection
- Flex-fuel support
- MIL warning indicator
- Shift-lights
- Launch control
- No-lift shift
- Rolling anti-lag mode


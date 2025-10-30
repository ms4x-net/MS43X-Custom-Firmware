# MS43X001 (Initial release)
Release date: **31st Oct 2025** // **MAPocalypse**

## Downloads
- **E36/7 Z3-series**
  - coming soon

- **E39 5-series**
  - [M54B30](https://github.com/ms4x-net/MS43X-Custom-Firmware/raw/refs/heads/main/MS43X001/firmware/Siemens_MS43_MS43X001_E39_M54B30.bin)

- **E46 3-series**
  - M52TUB28: coming soon
  - M54B22: coming soon
  - [M54B25](https://github.com/ms4x-net/MS43X-Custom-Firmware/raw/refs/heads/main/MS43X001/firmware/Siemens_MS43_MS43X001_E46_M54B25.bin)
  - [M54B30](https://github.com/ms4x-net/MS43X-Custom-Firmware/raw/refs/heads/main/MS43X001/firmware/Siemens_MS43_MS43X001_E46_M54B30.bin)

- **E53 X5-series**
  - M54B30: coming soon


## Changelog

### Behavior Changes
- Added configurable load input (MAP / MAF / Alpha-N)
- Switched from VO (speed-density) tables to VE (volumetric efficiency) tables
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


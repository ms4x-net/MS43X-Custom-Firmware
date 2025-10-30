# Changelog MS43X001 (Initial release)
Release date: **31st Oct 2025**
## Behavior Changes
- Added configurable load input (MAP / MAF / Alpha-N)
- Switched from VO (speed-density) tables to VE (volumetric efficiency) tables
- Removed legacy injection timing correction tables; replaced with dynamic injector scalars
- Reworked full-load detection logic
- Added intake air temperature dependency to electric cooling fan logic
- Enhanced engine speed limiter (with optional ignition cut)
- Improved serial communication routines
- Removed immobilizer (EWS) logic to free resources

## New Features
- Closed-loop boost controller (boost by gear)
- Overboost protection
- Flex-fuel support
- MIL warning indicator
- Shift-lights
- Launch control
- No-lift shift
- Rolling anti-lag mode

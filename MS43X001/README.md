MS43X001 (Initial release)

# Downloads
- **E36/7 Z3-series**
  - coming soon

- **E39 5-series**
  - M54B30: coming soon

- **E46 3-series**
  - M52TUB28: coming soon
  - M54B22: coming soon
  - M54B25: coming soon
  - M54B30: coming soon

- **E53 X5-series**
  - M54B30: coming soon


# Changelog
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


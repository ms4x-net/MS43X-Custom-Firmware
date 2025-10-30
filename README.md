# MS43X Custom Firmware

## Disclaimer  
This firmware is intended **only** for off-road and closed-course use. It is **not** legal for use on public roads, streets, or highways. Installing or using it on a vehicle intended for road use may violate local, state, or federal laws.  
By installing the software, you accept full responsibility for compliance with any applicable laws, and the developers disclaim liability for any damages, penalties, or injuries arising from its use.

## Overview  
MS43X is a custom firmware built on top of the Siemens MS430069 firmware. It is designed as a successor to community patch list approaches and integrates many new features and enhancements into a unified, maintainable platform. The shift to MS43X is motivated by the increasing difficulty of safely injecting new features into the stock firmware without breaking stability or performance.

Unlike earlier methods of distributing patches, each release of MS43X includes fully integrated definition files bundled with the firmware, eliminating the need for external patching.

### Changelog (Latest Version)  
Current release: **MS43X001 (Oct 2025)**  
#### Behavior Changes  
- Added configurable load input (MAP / MAF / Alpha-N)
- Switched from VO (valve overlap) tables to VE (volumetric efficiency) tables
- Removed legacy injection timing correction tables; replaced with dynamic injector scalars
- Reworked full-load detection logic
- Added intake air temperature dependency to electric cooling fan logic
- Enhanced engine speed limiter (with optional ignition cut)
- Improved serial communication routines
- Removed immobilizer (EWS) logic to free resources
#### New Features  
- Closed-loop boost controller (boost by gear)
- Overboost protection
- Flex-fuel support
- MIL warning indicator
- Shift-lights
- Launch control
- No-lift shift
- Rolling anti-lag mode

## Behavior & Functional Changes  

### Load Acquisition  
The firmware supports selecting the method of measuring engine load: MAF, MAP, or Alpha-N. You can switch at runtime via calibration (`c_conf_load`). Sensor diagnostic routines check whether the selected load sensor value stays within permissible ranges; if a fault is detected, the firmware falls back to Alpha-N mode. 

### Volumetric Efficiency (VE) Tables  
Instead of predefined VO tables, MS43X uses 16×16 VE tables. This aligns its operation more closely with standalone ECUs and simplifies tuning workflows.

### Injection & AFR Targeting  
- Injection timing correction tables (ip_ti_tco) are removed  
- The firmware calculates injector pulse widths dynamically using scalar factors and AFR target tables  
- New tables allow injector linearization (ip_ti_fac_map, ip_ti_fac_ti)  
- AFR target tables support both RON98 and E85 fuels 

### Full Load Detection  
Full load detection now triggers based on load thresholds and AFR deviations, rather than time-limited states or PVS-based logic. 

### Electric Cooling Fan  
The cooling fan logic now can include intake air temperature (IAT) dependency, useful for forced induction setups with external cooling systems.  

### Engine Speed Limiter  
The speed limiter logic allows choosing between fuel cut or ignition cut modes (`c_conf_n_max`). 

### Serial Communication  
Improved communication routines allow faster baud rate changes on-the-fly without requiring the engine to be off, and enter a higher-speed processing mode for better message throughput. 

### Immobilizer  
The immobilizer (EWS) logic has been removed to free up resources for the newly added features like boost control. 

## New Feature Details  

### Boost Controller  
- Fully configurable boost controller with open-loop and closed-loop (PID) modes  
- Gear-dependent boost targets (RON98 / E85)  
- Safety features to prevent overboost  
- Overboost protection: injector shut-off if MAP exceeds a threshold, and hysteresis for reactivation 

### Flex Fuel  
- Reads a 0–5V signal from an ethanol sensor  
- Blends between RON98 and E85 calibrations using blending tables  
- Diagnostic checks trigger fault codes if signal is out of bounds, and fallback values are used

### MIL Light Indicator  
Allows the ECU to trigger the dashboard MIL light under configurable conditions (e.g. knock events, flex-fuel errors, overboost). 

### M Cluster Shift Lights  
Uses the LED segments in BMW “M cluster” gauge clusters to show variable redline segments and shift indicator based on RPM, and optionally oil temperature. 

### Launch Control  
Holds engine speed (with limits) during a standing launch until vehicle speed exceeds a configured threshold. Activation via clutch + throttle criteria. 

### No-Lift Shift  
Allows shifting while holding throttle open, keeping boost pressure between shifts. Activation criteria configurable. 

### Rolling Anti-Lag  
Allows the engine to build boost while maintaining a constant vehicle speed. Activated via buttons (e.g. cruise control decrement) when throttle is above threshold.

---

## Notes & Recommendations  
- Always verify that your ECU hardware supports the required inputs/outputs before flashing.  
- The bundled definition files ensure consistency and reduce error risk compared to patch-based systems.  
- Because of the deep integration and complexity, careful calibration and testing is essential.  
- Observe local laws and regulations — this firmware is *not* road-legal.

---

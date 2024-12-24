# BFSUITE Lua Scripts for Ethos

Betaflight is a Flight Control software suite 

- Betaflight Flight Controller Firmware
- Betaflight Configurator, for flashing and configuring the flight controller
- Betaflight Blackbox Explorer, for analyzing blackbox flight logs
- Betaflight Lua Scripts, for configuring the flight controller using a transmitter running:
  - EdgeTX/OpenTX
  - Ethos (this repository)

Built on Betaflight 4.3, Betaflight incorporates numerous advanced features specifically
tailored for helicopters. It's important to note that Betaflight does _not_ support multi-rotor
crafts or airplanes; it's exclusively designed for RC helicopters.

This version of Betaflight is also known as **Betaflight 2** or **RF2**.


## Information

Tutorials, documentation, and flight videos can be found on the [Betaflight website](https://www.rotorflight.org/).


## Features

Betaflight has many features:

* Many receiver protocols: CRSF, S.BUS, F.Port, DSM, IBUS, XBUS, EXBUS, GHOST, CPPM
* Support for various telemetry protocols: CSRF, S.Port, HoTT, etc.
* ESC telemetry protocols: BLHeli32, Hobbywing, Scorpion, Kontronik, OMP Hobby, ZTW, APD, YGE
* Advanced PID control tuned for helicopters
* Stabilisation modes (6D)
* Rotor speed governor
* Motorised tail support with Tail Torque Assist (TTA, also known as TALY)
* Remote configuration and tuning with the transmitter
  - With knobs / switches assigned to functions
  - With Lua scripts on EdgeTX, OpenTX and Ethos
* Extra servo/motor outputs for AUX functions
* Fully customisable servo/motor mixer
* Sensors for battery voltage, current, BEC, etc.
* Advanced gyro filtering
  - Dynamic RPM based notch filters
  - Dynamic notch filters based on FFT
  - Dynamic LPF
* High-speed Blackbox logging

Plus lots of features inherited from Betaflight:

* Configuration profiles for changing various tuning parameters
* Rates profiles for changing the stick feel and agility
* Multiple ESC protocols: PWM, DSHOT, Multishot, etc.
* Configurable buzzer sounds
* Multi-color RGB LEDs
* GPS support

And many more...


## Lua Scripts Requirements

- Ethos 1.5.18 or later
- an X10, X12, X14, X18, X20 or Twin X Lite transmitter
- a FrSky Smartport or F.Port receiver using ACCESS, ACCST, TD or TW mode
- a ELRS Module supported by Ethos


## Tested Receivers

The following receivers were correctly working with an X18 or X20, X10, XLite and X14 transmitter.
- TWMX
- TD MX
- R9 MX ACCESS 
- R9 Mini ACCESS 
- Archer RS ACCESS
- RX6R ACCESS 
- R-XSR ACCESS
- R-XSR ACCST FCC F.port 
- Archer Plus RS and Archer Plus RS Mini ACCESS F.Port 
- ELRS (all versions)


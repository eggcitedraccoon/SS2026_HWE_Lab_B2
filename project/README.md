# FPGA RGB LED PWM Controller

This project will implement an RGB LED controller on an FPGA using pulse-width modulation (PWM). The FPGA generates separate PWM signals for the red, green, and blue channels of an RGB diode, allowing different brightness levels and colour combinations to be produced.

The system will support several operating modes, which can be selected using an external input such as a button or switch. Each mode changes the PWM duty cycles in a different way to create decorative lighting effects.

## Planned Modes

* **Smooth Colour Transition**
  The RGB LED gradually changes between different colours by slowly increasing and decreasing the PWM duty cycles of the red, green, and blue channels.

* **Colour Blink Mode**
  The LED blinks in different colours. Each colour is displayed for a short time before switching to the next one.

* **Fade In / Fade Out Mode**
  The LED smoothly fades in and out by changing the overall brightness while keeping the selected colour pattern.

## Main Components

* FPGA-based PWM generator
* RGB LED output control
* Mode selection using external input
* Timing logic for colour changes, blinking, and fading effects

The goal of the project is to demonstrate how an FPGA can be used to generate precise digital control signals for visible lighting effects.

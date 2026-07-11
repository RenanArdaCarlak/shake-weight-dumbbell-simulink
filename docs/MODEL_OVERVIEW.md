# Model overview

## Purpose

The model simulates a simplified shake-weight/dumbbell mechanism as a one-dimensional dynamic system. It focuses on the interaction between two side masses and a central bar through spring-like force elements.

## Physical abstraction

The model uses three translational bodies:

- left mass;
- center bar;
- right mass.

Each body has a center-of-mass position, velocity, and acceleration. The center bar receives an excitation force, while spring forces act between the bar and the side masses depending on deformation and direction.

## Main computational blocks

1. **Applied excitation**  
   A signal-generator block defines the forcing input through amplitude and frequency parameters.

2. **Spring deformation calculation**  
   Left and right spring deformation values are computed from the current body positions and geometric dimensions.

3. **Force-direction switching**  
   Switch blocks select the appropriate left/right spring-force contribution depending on the sign or direction of the applied force.

4. **Contact and overlap constraints**  
   Conditional subsystems prevent the bar from crossing into the side masses. When bodies touch, constrained position expressions are applied.

5. **State integration**  
   Acceleration is integrated into velocity, and velocity is integrated into position for the left mass, center bar, and right mass.

6. **Visualization output**  
   VR-related blocks are included for motion visualization when supported by the local MATLAB/Simulink installation.

## Interpretation

The model is best treated as a compact demonstration of physical modeling logic in Simulink rather than a high-fidelity mechanical product simulation. Its value is in the explicit construction of force balance, conditional contact logic, and parameterized dynamics.

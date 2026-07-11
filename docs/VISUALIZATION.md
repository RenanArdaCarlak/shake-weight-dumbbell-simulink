# Visualization strategy

The original model used a legacy Simulink 3D Animation `VR Sink` block and a VRML world file (`.WRL`). That workflow is fragile in recent MATLAB releases because the old viewer has been removed and the model requires the matching world file to be available on the MATLAB path.

For reproducibility, this repository keeps the original Simulink model but uses a MATLAB-based 2D animation path by default:

1. run the Simulink model,
2. log the three top-level position outputs,
3. reconstruct the shake-weight mechanism as left mass, center bar, right mass, and two springs,
4. export a GIF to `media/shake_weight_animation.gif`.

Run from the repository root:

```matlab
addpath(genpath(pwd))
run('scripts/run_visual_simulation.m')
```

The old `VR Sink` block is automatically commented out at run time. The model file itself is not modified unless the user explicitly saves the model after running the script.

## Why not use the old VR Sink path?

The old path depends on `RenanArdaCarlak_ShakeWeightDumbbell.WRL`. If that file is missing, simulation stops at the visualization block even though the dynamic model itself is still valid. The default workflow therefore avoids the `.WRL` dependency and produces a standard GIF that can be viewed directly on GitHub.

## Animation logging implementation

The current animation path does not rely on root-level `yout` because the original model has no root-level Outport blocks. `scripts/configure_animation_logging.m` adds temporary `To Workspace` blocks to the three outputs of the main top-level `Subsystem` and logs them as `anim_xLeft`, `anim_xBar`, and `anim_xRight`.

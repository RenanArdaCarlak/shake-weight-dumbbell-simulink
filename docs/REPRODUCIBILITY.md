# Reproducibility notes

## Known dependencies

The original model contains Simulink VR/3D visualization-related blocks. On systems without the corresponding Simulink library support, the model may load with missing-library warnings or may require disabling/removing the visualization block before simulation.

## Recommended workflow

1. Open MATLAB from the repository root.
2. Run `scripts/init_parameters.m` to initialize default parameters.
3. Open `model/RenanArdaCarlak_ShakeWeightDumbbell.slx`.
4. Run the model using the Simulink UI or `scripts/run_simulation.m` with comment out `run(fullfile(repoRoot, 'scripts', 'disable_legacy_vr_blocks.m'));`.
5. If visualization blocks cause errors, temporarily comment out or disconnect the VR sink section in Simulink model or uncomment `run(fullfile(repoRoot, 'scripts', 'disable_legacy_vr_blocks.m'));` and rerun the dynamic model.
6. If visualization blocks cause errors, run `scripts/run_visual_simulation.m` to create MATLAB-based 2D animation and export a GIF to `media/shake_weight_animation.gif`.

## Version note

The repository contains the original `.slx` file. Solver behavior and block-library compatibility can vary across MATLAB releases. A clean technical check should first confirm that the model loads, then that the simulation executes, and only then that visualization works.

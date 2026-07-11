%RUN_VISUAL_SIMULATION Run the model and export a MATLAB-based animation.
%
% This script avoids the legacy VR Sink / .WRL visualization path. The
% original VR block is left in the model for historical reference, but it is
% disabled at run time. The visualization is reconstructed from three logged
% outputs of the main top-level Subsystem:
%   1) left mass center position
%   2) bar center position
%   3) right mass center position
%
% Run from the repository root:
%   run('scripts/run_visual_simulation.m')

clearvars -except ans;
clc;

thisFile = mfilename('fullpath');
repoRoot = fileparts(fileparts(thisFile));
modelDir = fullfile(repoRoot, 'model');
modelName = 'RenanArdaCarlak_ShakeWeightDumbbell';
modelFile = fullfile(modelDir, [modelName '.slx']);
resultsDir = fullfile(repoRoot, 'results');
mediaDir = fullfile(repoRoot, 'media');

addpath(genpath(repoRoot));
run(fullfile(repoRoot, 'scripts', 'init_parameters.m'));

if ~isfile(modelFile)
    error('Model file not found: %s', modelFile);
end

if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

if ~exist(mediaDir, 'dir')
    mkdir(mediaDir);
end

load_system(modelFile);

% Disable old VR blocks. The current MATLAB path uses standard figures/GIFs.
run(fullfile(repoRoot, 'scripts', 'disable_legacy_vr_blocks.m'));

% The model does not have root-level Outport blocks, so yout is not reliable.
% Add temporary To Workspace loggers for the three position signals used by
% the animation. Do not save the model unless you intentionally want these
% helper blocks to become permanent.
configure_animation_logging(modelName);

set_param(modelName, ...
          'SaveTime', 'on', ...
          'TimeSaveName', 'tout', ...
          'ReturnWorkspaceOutputs', 'on');

try
    simOut = sim(modelName);
    save(fullfile(resultsDir, 'simOut.mat'), 'simOut');
    fprintf('Simulation completed. Output saved to results/simOut.mat\n');

    gifFile = fullfile(mediaDir, 'shake_weight_animation.gif');
    animate_shake_weight(simOut, gifFile);
    fprintf('Animation exported to media/shake_weight_animation.gif\n');
catch ME
    fprintf(2, 'Simulation or animation did not complete.\n');
    fprintf(2, 'Reason: %s\n', ME.message);
    rethrow(ME);
end

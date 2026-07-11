%RUN_SIMULATION Load and run the shake-weight Simulink model.
%
% Run from the repository root:
%   run('scripts/run_simulation.m')

clearvars -except ans;
clc;

thisFile = mfilename('fullpath');
repoRoot = fileparts(fileparts(thisFile));
modelDir = fullfile(repoRoot, 'model');
modelName = 'RenanArdaCarlak_ShakeWeightDumbbell';
modelFile = fullfile(modelDir, [modelName '.slx']);
resultsDir = fullfile(repoRoot, 'results');

addpath(genpath(repoRoot));
run(fullfile(repoRoot, 'scripts', 'init_parameters.m'));

if ~isfile(modelFile)
    error('Model file not found: %s', modelFile);
end

if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

load_system(modelFile);

% Disable legacy VR/3D visualization blocks before simulation.
% They are not required for the dynamic model and can fail in recent MATLAB releases.
run(fullfile(repoRoot, 'scripts', 'disable_legacy_vr_blocks.m'));

try
    simOut = sim(modelName);
    save(fullfile(resultsDir, 'simOut.mat'), 'simOut');
    fprintf('Simulation completed. Output saved to results/simOut.mat\n');
catch ME
    fprintf(2, 'Simulation did not complete.\n');
    fprintf(2, 'Reason: %s\n', ME.message);
    fprintf(2, ['If the error is related to VR/3D visualization blocks, ', ...
                'disable or disconnect the visualization section and rerun.\n']);
    rethrow(ME);
end

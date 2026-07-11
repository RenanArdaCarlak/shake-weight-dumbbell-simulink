%INIT_PARAMETERS Initialize parameters for the shake-weight Simulink model.
%
% This script exports the parameter structure fields to the MATLAB base
% workspace because the original Simulink model was designed with base
% workspace access enabled.

thisFile = mfilename('fullpath');
repoRoot = fileparts(fileparts(thisFile));
addpath(fullfile(repoRoot, 'scripts'));

p = model_parameters();
paramNames = fieldnames(p);

for k = 1:numel(paramNames)
    assignin('base', paramNames{k}, p.(paramNames{k}));
end

fprintf('Initialized %d model parameters in the base workspace.\n', numel(paramNames));

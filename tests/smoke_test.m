%SMOKE_TEST Basic repository and model-configuration check.
%
% This test checks parameter validity and attempts to load the Simulink
% model. It does not guarantee full visualization compatibility.

clearvars;
clc;

thisFile = mfilename('fullpath');
repoRoot = fileparts(fileparts(thisFile));
addpath(genpath(repoRoot));

p = model_parameters();

required = {'amplitude','frequency','m1','m2','m3', ...
            'BarThickness','LeftThickness','RightThickness', ...
            'LeftLength','RightLength','LeftSpringConstant','RightSpringConstant'};

for k = 1:numel(required)
    assert(isfield(p, required{k}), 'Missing parameter: %s', required{k});
    assert(isnumeric(p.(required{k})) && isscalar(p.(required{k})), ...
           'Parameter must be a numeric scalar: %s', required{k});
end

assert(p.m1 > 0 && p.m2 > 0 && p.m3 > 0, 'Mass parameters must be positive.');
assert(p.LeftSpringConstant > 0 && p.RightSpringConstant > 0, ...
       'Spring constants must be positive.');
assert(p.LeftLength > 0 && p.RightLength > 0, 'Spring lengths must be positive.');

run(fullfile(repoRoot, 'scripts', 'init_parameters.m'));

modelName = 'RenanArdaCarlak_ShakeWeightDumbbell';
modelFile = fullfile(repoRoot, 'model', [modelName '.slx']);
assert(isfile(modelFile), 'Model file not found.');

try
    load_system(modelFile);
    fprintf('Smoke test passed: parameters are valid and model loaded.\n');
catch ME
    fprintf(2, 'Model load failed: %s\n', ME.message);
    rethrow(ME);
end

%DISABLE_LEGACY_VR_BLOCKS Disable legacy Simulink 3D Animation / VR sink blocks.
%
% Recent MATLAB releases no longer open Simulink 3D Animation Viewer. The
% original model also references a .WRL virtual-world file that is not part of
% this repository. These visualization blocks are not required for numerical
% simulation, so this script comments them out before running the model.

if ~exist('modelName', 'var')
    error('Expected variable modelName in the caller workspace.');
end

load_system(modelName);

candidateBlocks = {};

% Legacy VR Sink blocks are implemented as S-Function blocks that call vrsfunc.
try
    candidateBlocks = [candidateBlocks; find_system(modelName, ...
                       'LookUnderMasks', 'all', ...
                       'FollowLinks', 'on', ...
                       'BlockType', 'S-Function', ...
                       'FunctionName', 'vrsfunc')]; 
catch
    % Keep going; not every MATLAB version exposes the same parameters.
end

% Fallback by name, useful when the block parameters differ across releases.
try
    candidateBlocks = [candidateBlocks; find_system(modelName, ...
                       'LookUnderMasks', 'all', ...
                       'FollowLinks', 'on', ...
                       'RegExp', 'on', ...
                       'Name', '.*VR.*')]; 
catch
end

candidateBlocks = unique(candidateBlocks);

for k = 1:numel(candidateBlocks)
    blockPath = candidateBlocks{k};
    try
        set_param(blockPath, 'Commented', 'on');
        fprintf('Disabled legacy visualization block: %s\n', blockPath);
    catch ME
        warning('Could not disable block %s: %s', blockPath, ME.message);
    end
end

function configure_animation_logging(modelName)
         %CONFIGURE_ANIMATION_LOGGING Add temporary To Workspace loggers for animation.
         %
         % The original model has no root-level Outport blocks. Its internal subsystem
         % outputs are routed to legacy VR blocks. Therefore SaveOutput/yout is not a
         % reliable way to collect animation data. This helper adds three temporary
         % To Workspace sink blocks at the top level and branches the subsystem outputs
         % into them:
         %   Subsystem/1 -> anim_xLeft
         %   Subsystem/2 -> anim_xBar
         %   Subsystem/3 -> anim_xRight
         %
         % These blocks are added only for the current MATLAB session unless the user
         % explicitly saves the model.

         arguments
             modelName (1,:) char
         end

         subsystemPath = [modelName '/Subsystem'];
         if ~bdIsLoaded(modelName)
             load_system(modelName);
         end

         if isempty(find_system(modelName, 'SearchDepth', 1, 'Name', 'Subsystem'))
            error('Expected top-level block not found: %s', subsystemPath);
         end

         loggerNames = {'anim_xLeft', 'anim_xBar', 'anim_xRight'};
         positions = [1110 250 1230 280; 1110 300 1230 330; 1110 350 1230 380];

         for k = 1:numel(loggerNames)
             blockPath = [modelName '/' loggerNames{k}];

             % Remove an earlier temporary logger from the current session, if present.
             if ~isempty(find_system(modelName, 'SearchDepth', 1, 'Name', loggerNames{k}))
                 try
                     delete_block(blockPath);
                 catch ME
                     warning('Could not delete existing logger block %s: %s', blockPath, ME.message);
                 end
             end

             % Keep the block configuration minimal for MATLAB release compatibility.
             % Some releases do not expose older parameters such as LimitDataPoints.
             add_block('simulink/Sinks/To Workspace', blockPath, ...
                       'VariableName', loggerNames{k}, ...
                       'SaveFormat', 'Timeseries', ...
                       'Position', positions(k, :));

             % Branch from the subsystem output port to the logger input. The original
             % VR-routing line remains untouched.
             try
                 add_line(modelName, sprintf('Subsystem/%d', k), sprintf('%s/1', loggerNames{k}), 'autorouting', 'on');
             catch ME
                 error('Could not connect %s output %d to %s. MATLAB reported: %s', subsystemPath, k, blockPath, ME.message);
             end
         end
end

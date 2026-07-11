function [t, xLeft, xBar, xRight] = extract_position_outputs(simOut)
         %EXTRACT_POSITION_OUTPUTS Extract left/bar/right position outputs.
         %
         % Preferred path: temporary To Workspace loggers added by
         % configure_animation_logging.m. Fallbacks are retained for models that later
         % expose root-level yout or logsout data.

         % --- Preferred animation logger path -------------------------------------
         [xLeftTS, foundLeft] = getSimulationItem(simOut, 'anim_xLeft');
         [xBarTS, foundBar] = getSimulationItem(simOut, 'anim_xBar');
         [xRightTS, foundRight] = getSimulationItem(simOut, 'anim_xRight');

         if foundLeft && foundBar && foundRight
            [t, xLeft] = readTimeseriesLike(xLeftTS);
            [tBar, xBar] = readTimeseriesLike(xBarTS);
            [tRight, xRight] = readTimeseriesLike(xRightTS);

            % Align by interpolation if solvers produce slightly different time vectors.
            if ~isequal(t, tBar)
                xBar = interp1(tBar, xBar, t, 'linear', 'extrap');
            end
            if ~isequal(t, tRight)
                xRight = interp1(tRight, xRight, t, 'linear', 'extrap');
            end
            return;
         end

         % --- Fallback: signal logging dataset ------------------------------------
         [logsout, foundLogsout] = getSimulationItem(simOut, 'logsout');
         if foundLogsout && isa(logsout, 'Simulink.SimulationData.Dataset')
            try
                left = logsout.get('anim_xLeft');
                bar = logsout.get('anim_xBar');
                right = logsout.get('anim_xRight');
                [t, xLeft] = readTimeseriesLike(left.Values);
                [tBar, xBar] = readTimeseriesLike(bar.Values);
                [tRight, xRight] = readTimeseriesLike(right.Values);
                if ~isequal(t, tBar)
                    xBar = interp1(tBar, xBar, t, 'linear', 'extrap');
                end
                if ~isequal(t, tRight)
                    xRight = interp1(tRight, xRight, t, 'linear', 'extrap');
                end
                return;
            catch
                % Continue to older yout fallbacks below.
            end
         end

         % --- Fallback: root Outport output, if a future model version adds it ------
         [yout, foundYout] = getSimulationItem(simOut, 'yout');
         if ~foundYout
             error(['No animation position outputs were found. ', ...
                    'Expected anim_xLeft, anim_xBar, and anim_xRight. ', ...
                    'Run configure_animation_logging(modelName) before sim(modelName).']);
         end

         if isa(yout, 'Simulink.SimulationData.Dataset')
            if yout.numElements < 3
               error('Expected at least three output elements, but found %d.', yout.numElements);
            end

            values = cell(1, yout.numElements);
            names = strings(1, yout.numElements);
            for k = 1:yout.numElements
                elem = yout.get(k);
                values{k} = elem.Values;
                names(k) = string(elem.Name);
            end

            idxLeft = findOutputIndex(names, 'left', 1);
            idxBar = findOutputIndex(names, 'bar', 2);
            idxRight = findOutputIndex(names, 'right', 3);

            [t, xLeft] = readTimeseriesLike(values{idxLeft});
            [tBar, xBar] = readTimeseriesLike(values{idxBar});
            [tRight, xRight] = readTimeseriesLike(values{idxRight});
            if ~isequal(t, tBar)
                xBar = interp1(tBar, xBar, t, 'linear', 'extrap');
            end
            if ~isequal(t, tRight)
                xRight = interp1(tRight, xRight, t, 'linear', 'extrap');
            end
            return;
         end

         if isa(yout, 'timeseries')
            t = yout.Time;
            data = squeeze(yout.Data);
            if size(data, 2) < 3 && size(data, 1) >= 3
               data = data.';
            end
            if size(data, 2) < 3
               error('Expected a timeseries with at least three columns for left/bar/right positions.');
            end
            xLeft = data(:, 1);
            xBar = data(:, 2);
            xRight = data(:, 3);
            return;
         end

         if isnumeric(yout)
            if size(yout, 2) < 4
               error('Expected numeric yout as [time left bar right].');
            end
            t = yout(:, 1);
            xLeft = yout(:, 2);
            xBar = yout(:, 3);
            xRight = yout(:, 4);
            return;
         end

         error('Unsupported simulation output format: %s', class(yout));
end

function [value, found] = getSimulationItem(simOut, name)
         found = false;
         value = [];

         if isa(simOut, 'Simulink.SimulationOutput')
            try
                value = simOut.get(name);
                found = true;
                return;
            catch
                try
                    names = simOut.who;
                    if any(strcmp(names, name))
                       value = simOut.get(name);
                       found = true;
                       return;
                    end
                catch
                end
            end
         end

         if isstruct(simOut) && isfield(simOut, name)
            value = simOut.(name);
            found = true;
         end
end

function [t, x] = readTimeseriesLike(value)
         if isa(value, 'timeseries')
            t = value.Time(:);
            x = squeeze(value.Data);
         elseif isa(value, 'timetable')
            t = seconds(value.Properties.RowTimes - value.Properties.RowTimes(1));
            t = t(:);
            x = value{:, 1};
         elseif isnumeric(value)
            if size(value, 2) >= 2
               t = value(:, 1);
               x = value(:, 2);
            else
                error('Numeric logged output needs at least two columns: time and value.');
            end
         else
            error('Unsupported logged output type: %s', class(value));
         end

         x = squeeze(x);
         if isrow(x)
            x = x.';
         end
         if size(x, 2) > 1
            x = x(:, 1);
         end
end

function idx = findOutputIndex(names, keyword, fallback)
         idx = find(contains(lower(names), keyword), 1, 'first');
         if isempty(idx)
            idx = fallback;
         end
end

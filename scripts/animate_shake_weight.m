function animate_shake_weight(simOut, outputFile)
         %ANIMATE_SHAKE_WEIGHT Create a 2D animation from model position outputs.
         %
         % animate_shake_weight(simOut, outputFile) reads the top-level Simulink
         % outputs from simOut and exports a GIF showing the one-dimensional motion of
         % the left mass, center bar, right mass, and two springs.
         %
         % This function intentionally avoids the deprecated VR Sink / .WRL workflow.

         if nargin < 2 || strlength(string(outputFile)) == 0
            outputFile = fullfile('media', 'shake_weight_animation.gif');
         end

         [t, xLeft, xBar, xRight] = extract_position_outputs(simOut);

         p = model_parameters();

         % Reduce frame count for compact GitHub-friendly GIFs.
         maxFrames = 220;
         frameIdx = unique(round(linspace(1, numel(t), min(maxFrames, numel(t)))));

         xAll = [xLeft(:); xBar(:); xRight(:)];
         xMargin = max([0.05, 0.20 * range(xAll)]);
         xLim = [min(xAll) - xMargin, max(xAll) + xMargin];

         bodyHeight = 0.08;
         barHeight = 0.025;
         springAmp = 0.018;
         y0 = 0;

         fig = figure('Name', 'Shake-weight mechanism animation', 'Color', 'w', 'Position', [100 100 900 320]);
         ax = axes(fig);
         hold(ax, 'on');
         grid(ax, 'on');
         axis(ax, [xLim -0.12 0.12]);
         axis(ax, 'manual');
         ylabel(ax, 'visualized height');
         xlabel(ax, 'position');
         title(ax, 'Spring-mass shake-weight mechanism');

         % Initial graphical objects.
         leftPatch = rectangle(ax, 'Position', rectPosition(xLeft(frameIdx(1)), p.LeftThickness, bodyHeight, y0), ...
                                   'FaceColor', [0.75 0.75 0.75], 'EdgeColor', 'k', 'LineWidth', 1.2);
         barPatch = rectangle(ax, 'Position', rectPosition(xBar(frameIdx(1)), p.BarThickness, barHeight, y0), ...
                                  'FaceColor', [0.55 0.55 0.55], 'EdgeColor', 'k', 'LineWidth', 1.2);
         rightPatch = rectangle(ax, 'Position', rectPosition(xRight(frameIdx(1)), p.RightThickness, bodyHeight, y0), ...
                                    'FaceColor', [0.75 0.75 0.75], 'EdgeColor', 'k', 'LineWidth', 1.2);

         leftSpring = plot(ax, nan, nan, 'k-', 'LineWidth', 1.1);
         rightSpring = plot(ax, nan, nan, 'k-', 'LineWidth', 1.1);
         timeText = text(ax, xLim(1) + 0.02 * diff(xLim), 0.095, '', 'FontSize', 11);

         for k = 1:numel(frameIdx)
             i = frameIdx(k);

             set(leftPatch, 'Position', rectPosition(xLeft(i), p.LeftThickness, bodyHeight, y0));
             set(barPatch, 'Position', rectPosition(xBar(i), p.BarThickness, barHeight, y0));
             set(rightPatch, 'Position', rectPosition(xRight(i), p.RightThickness, bodyHeight, y0));

             leftSpringStart = xLeft(i) + p.LeftThickness / 2;
             leftSpringEnd = xBar(i) - p.BarThickness / 2;
             [xs, ys] = springLine(leftSpringStart, leftSpringEnd, y0, springAmp, 7);
             set(leftSpring, 'XData', xs, 'YData', ys);

             rightSpringStart = xBar(i) + p.BarThickness / 2;
             rightSpringEnd = xRight(i) - p.RightThickness / 2;
             [xs, ys] = springLine(rightSpringStart, rightSpringEnd, y0, springAmp, 7);
             set(rightSpring, 'XData', xs, 'YData', ys);

             set(timeText, 'String', sprintf('t = %.2f s', t(i)));
             drawnow;

             frame = getframe(fig);
             [im, map] = rgb2ind(frame2im(frame), 256);

             if k == 1
                 imwrite(im, map, outputFile, 'gif', 'LoopCount', inf, 'DelayTime', 0.04);
             else
                 imwrite(im, map, outputFile, 'gif', 'WriteMode', 'append', 'DelayTime', 0.04);
             end
         end

         close(fig);
end

function pos = rectPosition(xCenter, width, height, yCenter)
         pos = [xCenter - width / 2, yCenter - height / 2, width, height];
end

function [x, y] = springLine(xStart, xEnd, yCenter, amplitude, nCoils)
         % Return a simple zig-zag spring line between two x positions.
         if abs(xEnd - xStart) < eps
             x = [xStart xEnd];
             y = [yCenter yCenter];
             return;
         end

         n = 2 * nCoils + 2;
         x = linspace(xStart, xEnd, n);
         y = yCenter * ones(size(x));

         for i = 2:(n - 1)
             if mod(i, 2) == 0
                 y(i) = yCenter + amplitude;
             else
                 y(i) = yCenter - amplitude;
             end
         end
end

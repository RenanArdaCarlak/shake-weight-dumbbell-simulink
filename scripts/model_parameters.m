function p = model_parameters()
         %MODEL_PARAMETERS Default parameter set for the shake-weight Simulink model.
         %
         % The values mirror the mask values found in the original model. They are
         % grouped in a structure first so they can be reviewed, modified, and then
         % exported to the base workspace by init_parameters.m.

         p = struct();

         % Excitation
         p.amplitude = -0.001;
         p.frequency = 0.32;

         % Mass parameters
         p.m1 = 1.0;
         p.m2 = 0.5;
         p.m3 = 1.0;

         % Geometry
         p.BarThickness = 0.05;
         p.LeftThickness = 0.03;
         p.RightThickness = 0.03;
         p.LeftLength = 0.10;
         p.RightLength = 0.10;

         % Spring stiffnesses
         p.LeftSpringConstant = 1.0;
         p.RightSpringConstant = 1.0;

end

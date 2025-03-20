classdef TSMRF_ENGINE_SET < handle
   properties
        % [POTTS_MODEL]
        adaptive = 1;
        betaMin = 0.0;
        betaMax = 3.0;
        betaBound = 3.0;
        rangeBandwidth = 0.25; % check
        spatialBandwidth = 3.0; % check
        % [MEANSHIFT]
        autoAdjustkNN = 2; % check
        skipLast = 0.1; % check
        tolerance = 0.1; % check
        kernelType = 1; % check % magari usiamo nomi simbolici ? 
   end
end
classdef TSMRF_UNSUP_SET < handle
   properties
        variableMultiplicity = 0;
        multiplicity = 2;
        blind = 0;
        splitwiseDisconnect = 0;
        
        blindSet = TSMRF_BLIND_SET;
        classicSet = TSMRF_CLASSIC_SET;

        % deprecabili
        balancedTree = 0; % deprecabile, si usi blind
        growDepth = 2; % attivo se BalancedTree = true
        doubleSplit = 0; % modalità di funzionamento da verificare
   end
end
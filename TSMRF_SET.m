classdef TSMRF_SET < handle
   
   properties
        %MaxLabel = 1000000000;
        supervisedMode = 0;
        
        fragmentation = 0; % inattivo se SplitwiseDisconnect = true in modalità non supervisionata
	
        unsupSet = TSMRF_UNSUP_SET ;
        supSet = TSMRF_SUP_SET;
        engineSet = TSMRF_ENGINE_SET ;
   end
   
    methods
        function obj = setClassic(obj,splitGainThreshold,maxNumberOfClasses,minSplitArea,varargin)
            % obj.setClassic(splitGainThreshold,maxNumberOfClasses,minSplitArea)
            % 
            % obj.setClassic(splitGainThreshold,maxNumberOfClasses,minSplitArea,finalFragmentation)
            %
            % where:
            %      -  'splitGainThreshold' is a double indicating the requireired minimum gain of a split to be validated.
            %
            %       -   'maxNumberOfClasses' indicates the maximum number of classes
            %
            %       - 'minSplitArea' indicates the minimum size of a region to be
            %       split.
            %
            %       The optional boolean 'finalFragmentation' specify if
            %       to provide as a by-product of the segmentation, the
            %       labeling of its 8-connected components            
            
            obj.supervisedMode = 0;
            obj.unsupSet.blind = 0;
            obj.unsupSet.splitwiseDisconnect = 0;
            obj.unsupSet.classicSet.splitGainThreshold = splitGainThreshold;
            obj.unsupSet.classicSet.maxNumberOfClasses = maxNumberOfClasses;
            obj.unsupSet.classicSet.minSplitArea = minSplitArea;
            if nargin==5,
                obj.fragmentation = varargin{1};
            end

        end
        
        function obj = setClassicDisconnecting(obj,splitGainThreshold,minSplitArea)
            % obj.setClassicDisconnecting(splitGainThreshold,minSplitArea)
            % 
            % where:
            %      -  'splitGainThreshold' is a double indicating the requireired minimum gain of a split to be validated.
            %
            %       - 'minSplitArea' indicates the minimum size of a region to be
            %       split.
            %

            obj.supervisedMode = 0;
            obj.fragmentation = 0;
            obj.unsupSet.blind = 0;
            obj.unsupSet.splitwiseDisconnect = 1;
            obj.unsupSet.classicSet.splitGainThreshold = splitGainThreshold;
            obj.unsupSet.classicSet.maxNumberOfClasses = 1000000;
            obj.unsupSet.classicSet.minSplitArea = minSplitArea;
        end

        function obj = setBlind(obj,depthTh,mseTh,areaTh,varargin)
            % obj.setBlind(depthTh,mseTh,areaTh)
            % 
            % obj.setBlind(depthTh,mseTh,areaTh,finalFragmentation)
            %
            % where:
            %      -  'depthTh' is an integer indicating the maximum grow depth.             
            %       The default value '0' indicates no constraint on depth.
            %
            %       -   'mseTh' is a double indicating the minimum average distorsion of a given region 
            %       to be further split.
            %       The default value '0' indicates no constraint on such
            %       parameter.
            %
            %       - 'areaTh' indicates the minimum size of a region to be
            %       split.
            %       The default value '0' means no constraint on the area
            %
            %       The optional boolean 'finalFragmentation' specify if
            %       to provide as a by-product of the segmentation, the
            %       labeling of its 8-connected components
            %
            
            obj.supervisedMode = 0;
            obj.unsupSet.blind = 1;
            obj.unsupSet.splitwiseDisconnect = 0;
            obj.unsupSet.blindSet.active = 1;
            obj.unsupSet.blindSet.depth = depthTh;
            obj.unsupSet.blindSet.MSE = mseTh;
            obj.unsupSet.blindSet.area = areaTh;
            if nargin==5,
                obj.fragmentation = varargin{1};
            end
        end

        function obj = setBlindDisconnecting(obj,depthTh,mseTh,areaTh)
            % obj.setBlindDisconnecting(depthTh,mseTh,areaTh)
            % 
            % where:
            %      -  'depthTh' is an integer indicating the maximum grow depth.             
            %       The default value '0' indicates no constraint on depth.
            %
            %       -   'mseTh' is a double indicating the minimum average distorsion of a given region 
            %       to be further split.
            %       The default value '0' indicates no constraint on such
            %       parameter.
            %
            %       - 'areaTh' indicates the minimum size of a region to be
            %       split.
            %       The default value '0' means no constraint on the area
            %
            
            obj.unsupSet.classicSet.maxNumberOfClasses = 1000000;
            obj.supervisedMode = 0;
            obj.fragmentation = 0;
            obj.unsupSet.blind = 1;
            obj.unsupSet.splitwiseDisconnect = 1;
            obj.unsupSet.blindSet.active = 1;
            obj.unsupSet.blindSet.depth = 2*depthTh;
            obj.unsupSet.blindSet.MSE = mseTh;
            obj.unsupSet.blindSet.area = areaTh;
        end

        function obj = setSupervised(obj,leavesLevels,leavesPaths,varargin)
            % obj.setSupervised(leavesLevels,leavesPaths)
            % 
            % obj.setSupervised(leavesLevels,leavesPaths,finalFragmentation)
            %
            % where:
            %      -  'leaves' is a row vector containing the levels on the tree associated to the classes (leaves).
            %
            %      -  'leavesPaths' row vector containing (concatenated)
            %      tree-paths associated to the classes (leaves).
            %
            %       The optional boolean 'finalFragmentation' specify if
            %       to provide as a by-product of the segmentation, the
            %       labeling of its 8-connected components            
            
            obj.supervisedMode = 1;
            obj.supSet.numberOfClasses = length(leavesLevels);
            obj.supSet.structureLevels = leavesLevels;
            obj.supSet.structurePaths = leavesPaths;
            if nargin==4,
                obj.fragmentation = varargin{1};
            end
        end

    end
end
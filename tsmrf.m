function varargout = tsmrf(varargin)
%
% [S] = tsmrf(data);
%
% In this case the segmentation <S> of the image <data> is performed with the
% "classic", "unsupervised" setting: tree growth controlled by the split gain, and maximum
% # of classes equal to 12.
%
% ------------
%
% [S] = tsmrf(tsmrf_image);
%
% If the input variable is an istance of the class/struct TSMRF_IMAGE (public class
% member <gt> MUST BE be empty in this case) then:
%
%       - if (public) class member <roi> (region of interest, or mask) is not empty,
%       then the algorithm is applied locally to the specified roi (use 0
%       for background and a positive integer for the foreground)
%
%       - if (public) class member <initSeg> is not empty the segmentation process
%       will start from the given initial partition
%
% ------------
% 
% [S,F] = tsmrf(data,tsmrf_setting);  or 
% [S,F] = tsmrf(tsmrf_image,tsmrf_setting);
% 
% The eventual second input parameter of class TSMRF_SET can specify a desired
% setting. 
% 
% IMPORTANT. It is recommended to use exclusively the following member
% functions of class TSMRF_SET to configure the setting:
%
%   For Unsupervised segmentation: 
%           - setClassic
%           - setClassicDisconnecting
%           - setBlind
%           - setBlindDisconnecting
%
%   For Supervised segmentation:
%           - setSupervised
%
% In the this last case the first input parameter has to be necessarily an
% istance of TSMRF_IMAGE with non-empty fields <gt>
% 
% IMPORTANT. The ground-truth <gt> has to be provided with the following
% constraints:
%       a) use 0 for unclassified pixels
%       b) use a compact range of labels [1,N] for the N sampled classes
% 
%  The eventual second output <F> may represent the "8-connected" labeling of
%  the segmentation <S>. It has to be required when configuring TSMRF_SET,
%  and it is allowed only under profiles <setClassic>, <setBlind> and
%  <setSupervised>. 
% In particular it should be set "tsmrf_setting.fragmentation = 1".
%
%  Under teh same profiles if, instead, "tsmrf_setting.fragmentation = 0", 
%  then the second output <F> will contain the segmentation report.
%

    if  isobject(varargin{1}),
        im = varargin{1};
    else
        im = TSMRF_IMAGE;
        im.data = varargin{1};
    end

    im.data = double(im.data);
    im.roi = double(im.roi>0);
    im.initSeg = double(im.initSeg);
    im.gt = double(im.gt);

    if nargin==2,
        set = varargin{2};
    else
        set = TSMRF_SET;
    end

    
    computeReport = (set.supervisedMode~=0) || ((set.supervisedMode==0)&&(set.unsupSet.splitwiseDisconnect==0));
    computeReport = computeReport  && (set.fragmentation==0);
    getReport = computeReport && (nargout==2);
    
    maxNumCompThreads(1)

    if computeReport,
        [out headReport wsReports]  = tsmrfMex(im,set);
    else
        out = tsmrfMex(im,set);
    end
        
    clear mex;

    
    varargout{1} = out.segmentation;
    if (nargout ==2) && set.fragmentation
            varargout{2} = out.fragmentation;
    end
    
    if getReport,        
        REP.header = headReport;
        nodes = wsReports;
                REP.nodes = nodes(1);
        for k=2:REP.header.NSplit,
            h=2;
            while nodes(h).label~=REP.header.SplitOrder(k),
                h = h+1;
            end
            REP.nodes = [REP.nodes ; nodes(h)];
        end
        
        len = length(nodes);
        for k=1:len,
            found = false;
            for h=1:REP.header.NSplit,
                if nodes(k).label == REP.header.SplitOrder(h),
                    found = true;
                end
            end
            if (~found),
                REP.nodes = [REP.nodes ; nodes(k)];
            end
        end
        
        if REP.nodes(1).nChildren==1,
            REP.header.SplitOrder = REP.header.SplitOrder(2:end);
            REP.header.NSplit = REP.header.NSplit-1;
            REP.header.OffspringMat = REP.header.OffspringMat(2:end,:);
            REP.nodes = REP.nodes(2:end);
            for k=1:length(REP.nodes),
                REP.nodes(k).depth = REP.nodes(k).depth-1;
                if REP.nodes(k).depth==0,
                    REP.nodes(k).path = [];
                else
                    REP.nodes(k).path = REP.nodes(k).path(2:end);
                end
            end
        end
        
        
   
        varargout{2} = REP;  
    end
    
    if (nargout==2)&&(~getReport)&&(~set.fragmentation),
        varargout{2} = [];
    end
    
end


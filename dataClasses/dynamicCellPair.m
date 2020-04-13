classdef dynamicCellPair < dynamicCell
    properties 
        daughter1fluorData
        daughter2fluorData
    end
    
    methods
        function [fluorData, frames] = exportFluorData(this)
            %export frames and fluorData. fluorData - columns are each
            %cells fluorescence, rows are time frames
            firstFrame = this.divisionFrame;
            nF = size(this.daughter1fluorData);
            frames = (firstFrame:(firstFrame+nF-1));
            fluorData = [this.daughter1fluorData, this.daughter2fluorData];
        end
        function lf = lastFrame(this)
            lf = this.divisionFrame + size(this.daughter1fluorData,1) - 1;
        end
        function as = asymmetry(this)
            fD = [this.daughter1fluorData, this.daughter2fluorData];
            as = max(fD,[],2)./min(fD,[],2);
        end
    end
    
end
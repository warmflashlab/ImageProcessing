classdef frame 
   % class to store data from one imaging field of view 
    properties
        fluorData
        posData
        nZ
        nC
        time_index
        frameId
    end
    
    methods
        function mf = meanFluor(this)
            mf = mean(this.fluorData,'omitnan');
        end
    end
    
end
    
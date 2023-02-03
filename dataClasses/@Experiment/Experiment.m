classdef Experiment < handle
    properties
        data %An array of either Position or Colony objects
        metaData %appropriate metadata object.
        processedImageDirectory
        rawImageDirectory
        experimentType % Standard (std) or micropattern (mp)
        imageNameStruct
        processingParameters %for storing image processing
        conditionAverages
    end
    methods
        %constructor
        function this = Experiment(varargin)
            if nargin == 0
                return;
            end
            if nargin == 1
                this.rawImageDirectory = varargin{1};
            end
        end
        %list methods here but functions are in separate files
        fileStruct = readRawDirectory(this) 
        filename = getFileNameFromStruct(this,imgNum)

    end
end
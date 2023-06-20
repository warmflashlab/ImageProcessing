classdef ImageDirectory < handle
    %Data class for storing information about a directory of images.  
    properties
        path %path to directory
        prefix %prefix of image file names. Use only if separated by '_' from portions with numbers
                    % e.g cells_plate1_well1_1.tif has prefix cells
                    % 'p1_w1_1.tif' has no prefix
        plate %array of plate numbers 1 entry per image
        well   %array of well numbers 1 entry per image
        position %array of position numbers 1 entry per image
        ordering %cell array of strings that go with numbers. e.g. for p1_w1_1.tif etc ordering is {'p','w',''}. 
        extension % file extension e.g. '.tif'
        pathstring % string with %d for numbers to be used with sprintf for generating file names
    end
    methods

        function this = ImageDirectory(varargin)

            %Simple constructor. If no inputs, just makes an empty object.
            %Can supply the path to directory as one input. 

            if nargin == 0
                return;
            elseif nargin == 1
                this.path = varargin{1};
            end
        end
        
        function setPositionNumbersFromRanges(this,plates,wells,positions)
            
            %Allow you to set plate, well, and position properties from
            %arrays. Needs to be "rectangular" with equal numbers of
            %positions for each well etc. cannot currently have missing
            %files or these need to be removed manually. 

            npos = length(positions);
            nplates = length(plates);
            nwells = length(wells);
            nimages = npos*nplates*nwells;
            this.well = zeros(1,nimages);
            this.position = zeros(1,nimages);
            this.plate = zeros(1,nimages);

            qq = 1;
            for pl = 1:length(plates)
                for we = 1:length(wells)
                    for po = 1:length(positions)
                        this.plate(qq) = plates(pl);
                        this.well(qq) = wells(we);
                        this.position(qq) = positions(po);
                        qq = qq + 1;
                    end
                end
            end

        end

        function filename = getFileName(this,imgNum,includeDirectory)
            
            %Returns the filename of the image at imgNum. if
            %includeDirectory is true will include full path (default is
            %false).
            % can use getLinIndex to get index from plate, well, position

            if ~exist("includeDirectory","var")
                includeDirectory = false;
            end

            ins = this;
            filename = ins.prefix;
            ord = ins.ordering;

            if ~isempty(ins.prefix)
                filename = [filename '_'];
            end
            filename = [filename ord{1} int2str(ins.plate(imgNum)) '_' ord{2} int2str(ins.well(imgNum))...
                '_' ord{3} int2str(ins.position(imgNum)) ins.extension];

            if includeDirectory
                filename = fullfile(this.path,filename);
            end

        end

         function linIndex = getLinIndex(this,plate,well,pos)

             %get the linear index given plate, well, position
             
            linIndex =find( ismember(this.plate,plate) & ismember(this.well,well) & ismember(this.position,pos));
         end
    end
end
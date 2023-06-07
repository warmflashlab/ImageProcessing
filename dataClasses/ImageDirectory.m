classdef ImageDirectory < handle
    properties
        path
        prefix
        plate
        well
        position
        ordering
        extension
        pathstring
    end
    methods
        function this = ImageDirectory(varargin)
            if nargin == 0
                return;
            elseif nargin == 1
                this.path = varargin{1};
            end
        end
        function setPositionNumbersFromRanges(this,plates,wells,positions)
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
            linIndex =find( ismember(this.plate,plate) & ismember(this.well,well) & ismember(this.position,pos));
         end
    end
end
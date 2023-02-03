classdef MetadataMicropattern < Metadata
    % metadata with additional properties for Andor IQ output

    % ---------------------
    % Idse Heemskerk, 2016
    % ---------------------

    properties

        colRadiiMicron
        colRadiiPixel
        colMargin
        colBlah
    end

    methods

        function this = MetadataMicropattern(filename)

            this = this@Metadata(filename);


            % default margin outside colony to process, in pixels
            this.colMargin = 10;
        end

        function this = setColRadiiPixel(this)
            if isempty(this.xres)  || isempty(this.colRadiiMicron)
                disp('Need to set .xres and .colRadiiMicron before running this function');
                return;
            end
            this.colRadiiPixel = this.colRadiiMicron/this.xres;


        end
    end
end
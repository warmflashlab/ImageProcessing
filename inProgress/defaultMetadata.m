function meta = defaultMetadata(filename, magnification, micropattern)


if ~exist('magnification','var')
    magnification = '20X';
end

if ~exist('micropattern','var')
    micropattern = false;
end

switch micropattern 
    case 'plate'
        meta.colRadiiMicron = 350;
    case 'chip'
        meta.colRadiiMicron = [50, 100, 250, 400, 500];
end

function computeConditions(this)
%fill in conditions from well/plate info

dat = this.data; %this could be Position array or Colony array

plates = unique([dat.plate]);
wells = cell(length(plates),1);
nwells = zeros(length(plates),1);

for pp = 1:length(plates)
    dat_plate = dat([dat.plate]==plates(pp));
    wells{pp} = unique([dat_plate.well]);
    nwells(pp) = length(wells{pp});
end

for pp = 1:length(plates)
    for ww = 1:nwells(pp)
        conditionNum = sum(nwells(1:(pp-1)))+ww;
        datNow = dat([dat.plate]==plates(pp) & [dat.well]==wells{pp}(ww));
        for dd = 1:length(datNow)
            datNow(dd).condition = conditionNum;
        end
    end
end



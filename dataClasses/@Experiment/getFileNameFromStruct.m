function filename = getFileNameFromStruct(this,imgNum)
ins = this.imageNameStruct;
filename = ins.prefix;
filename = [filename '_plate' int2str(ins.plate(imgNum)) '_well'...
    int2str(ins.well(imgNum)), '_pos' int2str(ins.position(imgNum)) ins.extension];
end
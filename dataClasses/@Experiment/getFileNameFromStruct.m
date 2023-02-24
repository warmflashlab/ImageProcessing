function filename = getFileNameFromStruct(this,imgNum)
ins = this.imageNameStruct;
filename = ins.prefix;
ord = ins.ordering;

if ~isempty(ins.prefix)
    filename = [filename '_'];
end
filename = [filename ord{1} int2str(ins.plate(imgNum)) '_' ord{2} int2str(ins.well(imgNum))...
'_' ord{3} int2str(ins.position(imgNum)) ins.extension];
    
end
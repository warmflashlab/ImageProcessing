# ImageProcessing
Code for analyzing microscopy images. Developed by the Warmflash lab at Rice University

## Overview


## Useful Routines
**High level scripts**   
analyseOneColonyOneImageLSM   

**Data classes**  
Metadata - useful for storing information about image   
MetadataMicropattern - metadata subclass for micropatterned experiment

**Utilities**   
MakeMaxZImage - max z projection. Input: bf reader. Output: image  
splitLargeImageFile - split big tiled image to smaller ones for analysis   
smoothAndBackgroundSubtractOneImage - apply gaussian filter and subtract background    
readIlastikFile - reads output binary masks (h5 format) from Ilastik



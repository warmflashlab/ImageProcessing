# ImageProcessing
Code for analyzing microscopy images. Developed by the Warmflash lab at Rice University

## Overview


## Useful Routines
### High level scripts   
analyseOneColonyOneImageLSM   

### Data classes  
Metadata - useful for storing information about image   
MetadataMicropattern - metadata subclass for micropatterned experiment

### Utilities

**Max Intensity**      
bfMaxIntensity - make max intensity from bioformats reader
mkMaxIntensity - run on file to output max intensity file to disk   
mkMaxIntensities - run on whole directory to make max intensity images   
splitLargeImageFile - split big tiled image to smaller ones for analysis   

**Image Correction**   
smoothAndBackgroundSubtractOneImage - apply gaussian filter and subtract background    

**Input output**   
readIlastikFile - reads output binary masks (h5 format) from Ilastik
readImageDir - read a directory of images into cell array. options for selection by string

**Visualization**   
compareMultiChannelImages - show composite image. multiple channels, multiple conditions. consistent lookup table   




# CI-ImagingLIF
Accessing Leica LIF and XLEF files in Matlab (App written in Matlab version 2022b)

[![View Access Leica LIF and XLEF Files on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://nl.mathworks.com/matlabcentral/fileexchange/48774-access-leica-lif-and-xlef-files)

Matlab App

![ScreenShot of App](https://github.com/Cellular-Imaging-Amsterdam-UMC/CI-ImagingLIF/blob/main/Screenshot.png?raw=true)

You can open multiple files

![ScreenShot of App](https://github.com/Cellular-Imaging-Amsterdam-UMC/CI-ImagingLIF/blob/main/ScreenshotDetail.png?raw=true)

You're free to use this code in any way you like

The code is 99.99% Matlab, 0.01% c++ (github does not index it correctly). Or fully Matlab if you use the .m versions of xml2struct

The code is tested on Windows, so linux/mac users should probably have to change some parts of the code (changing \ in  /)
The xml2struct and xm2lstructstring MEX64 sources can be found in the xm2struct subfolder. Or use the slower m files (and change this in the code)

To run the binary Windows release, download and install the Windows version of the MATLAB Runtime for R2022b 
from the following link on the MathWorks website: https://www.mathworks.com/products/compiler/mcr/index.html

# Citation
If you like the code and use it for a publication please use the citation provided at this link DOI

[![DOI](https://zenodo.org/badge/629414184.svg)](https://zenodo.org/badge/latestdoi/629414184)

https://zenodo.org/badge/latestdoi/629414184

# Used Code
xml2struct: https://github.com/acampb311/xml2struct

AdvancedColormap: Andriy Nych (2023). (https://www.mathworks.com/matlabcentral/fileexchange/41583-advancedcolormap), MATLAB Central File Exchange. Retrieved April 18, 2023.





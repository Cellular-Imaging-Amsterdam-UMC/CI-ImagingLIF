# xml2struct
Semi-optimized utility for converting an xml document to a MATLAB structure. It was created in order to facilitate time-efficient parsing of large XML files on windows based systems.

This project utilizes pugixml, an XML parser for C++ found here: https://github.com/zeux/pugixml

This utility has been tested in MATLAB using the MinGW compiler.

In order for the project to be compiled, the pugixml utility source needs to be downloaded. As of right now, the necessary files are, pugiconfig.hpp, pugixml.cpp, and pugixml.hpp.

Assuming a proper compiler configuration, the xml2struct can be compiled by `mex xml2struct.cpp pugixml.cpp`. The result will be a xml2struct.mex file that can be used by, `struct = xml2struct('*.xml');`.

This utility attempts to retain compatibility with the MATLAB implementation found here: https://www.mathworks.com/matlabcentral/fileexchange/28518-xml2struct


*If MATLAB returns an error when attempting to run xml2struct along the lines of 'modules not being found', make sure that the necessary *.dll files are present in a MATLAB path. In my experience (using the MinGW compiler), the files necessary are libatomic-1.dll, libgcc_s_seh-1.dll, libstdc++-6.dll, and libwinpthread-1.dll. These files can be found in the MinGW compiler directory. 

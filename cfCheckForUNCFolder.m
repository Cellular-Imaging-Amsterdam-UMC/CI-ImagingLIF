function isUNC = cfCheckForUNCFolder(sfolder)
    [~, b]=system(['net use ' sfolder(1:2)]);
    isUNC=contains(b,'\\');
end


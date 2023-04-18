function asciistring = cfUnicode2ascii(utfstring)
    %UNICODE2ASCII Converts unicode endcoded files to ASCII encoded files
    %  ASCIISTRING = UNICODE2ASCII(UTFSTRING)
    %  Converts the UTFSTRING to ASCII and returns the string.

    % check number of arguments and open ustring handles

    ustring = utfstring;

    % read the ustring and delete unicode characters
    unicode = isunicode(ustring);

    % delete header
    switch(unicode)
        case 1
            ustring(1:3) = [];
        case 2
            ustring(1:2) = [];
        case 3
            ustring(1:2) = [];
        case 4
            ustring(1:4) = [];
        case 5
            ustring(1:4) = [];
    end

    % deletes all 0 bytes
    ustring(ustring == 0) = [];
    asciistring = ustring;
    return;
end


function isuc = isunicode(utfstring)
%     ISUNICODE Checks if and which unicode header a string has.
%      ISUC is true if the ustring contains unicode characters, otherwise
%      false. Exact Information about the encoding is also given.
%      ISUC == 0: No UTF Header
%      ISUC == 1: UTF-8
%      ISUC == 2: UTF-16BE
%      ISUC == 3: UTF-16LE
%      ISUC == 4: UTF-32BE
%      ISUC == 5: UTF-32LE

    isuc = false;
    firstLine = utfstring(1:4);

    %assign all possible headers to variables
    utf8header    = [hex2dec('EF') hex2dec('BB') hex2dec('BF')];
    utf16beheader = [hex2dec('FE') hex2dec('FF')];
    utf16leheader = [hex2dec('FF') hex2dec('FE')];
    utf32beheader = [hex2dec('00') hex2dec('00') hex2dec('FE') hex2dec('FF')];
    utf32leheader = [hex2dec('FF') hex2dec('FE') hex2dec('00') hex2dec('00')];

    %compare first bytes with header
    if(strfind(firstLine, utf8header) == 1)
        isuc = 1;
    elseif(strfind(firstLine, utf16beheader) == 1)
        isuc = 2;
    elseif(strfind(firstLine, utf16leheader) == 1)
        isuc = 3;
    elseif(strfind(firstLine, utf32beheader) == 1)
        isuc = 4;
    elseif(strfind(firstLine, utf32leheader) == 1)
        isuc = 5;
    end

    if(~exist('firstLine', 'var'))
        fclose(fin);
    end
end

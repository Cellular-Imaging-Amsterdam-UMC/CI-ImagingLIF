function [parseResult,p] = cfXMLReadString(stringToParse,varargin)
    %cfXMLReadString Modified XMLREAD function to read XML data from a string.

    p = locGetParser(varargin);
    locSetEntityResolver(p,varargin);
    locSetErrorHandler(p,varargin);

    %stringToParse=java.lang.String(java.lang.String(stringToParse).getBytes(),'ISO-8859-1');  %latin-1!!
    parseStringBuffer = java.io.StringBufferInputStream(stringToParse);
    parseResult = p.parse(parseStringBuffer);
%    parseResult=xml2structstring(stringToParse);
end

function p = locGetParser(args)
    p = [];
    for i=1:length(args)
        if isa(args{i},'javax.xml.parsers.DocumentBuilderFactory')
            javaMethod('setValidating',args{i},locIsValidating(args));
            p = javaMethod('newDocumentBuilder',args{i});
            break;
        elseif isa(args{i},'javax.xml.parsers.DocumentBuilder')
            p = args{i};
            break;
        end
    end
    if isempty(p)
        parserFactory = javaMethod('newInstance','javax.xml.parsers.DocumentBuilderFactory');

        javaMethod('setValidating',parserFactory,locIsValidating(args));
        p = javaMethod('newDocumentBuilder',parserFactory);
    end
end

function tf=locIsValidating(args)
    tf=any(strcmp(args,'-validating'));
end

function locSetEntityResolver(p,args)
    for i=1:length(args)
        if isa(args{i},'org.xml.sax.EntityResolver')
            p.setEntityResolver(args{i});
            break;
        end
    end
end

function locSetErrorHandler(p,args)
    for i=1:length(args)
        if isa(args{i},'org.xml.sax.ErrorHandler')
            p.setErrorHandler(args{i});
            break;
        end
    end
end
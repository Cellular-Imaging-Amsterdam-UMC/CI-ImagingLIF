function imdata = cfReadIm(lifinfo, iminfo, channel, z, t, tile)
    if strcmpi(lifinfo.filetype,".lif")
        % LIF
        fid=fopen(lifinfo.LIFFile,'r','n','UTF-8');

        p=iminfo.channelbytesinc(channel);
        p=p+(z-1)*iminfo.zbytesinc;
        p=p+(tile-1)*iminfo.tilesbytesinc;
        p=p+(t-1)*iminfo.tbytesinc;

        LIFOffset=lifinfo.Position;
        p=p+LIFOffset;

        fseek(fid,p,'bof');
        if iminfo.isrgb
            if iminfo.channelResolution(channel)==8
                imdata=fread(fid, iminfo.ys*iminfo.xs*3, '*uint8');
                redChannel = reshape(imdata(1:3:end), [iminfo.xs, iminfo.ys]);
                greenChannel = reshape(imdata(2:3:end), [iminfo.xs, iminfo.ys]);
                blueChannel = reshape(imdata(3:3:end), [iminfo.xs, iminfo.ys]);
                imdata = cat(3, redChannel, greenChannel, blueChannel);                
            else
                imdata=fread(fid, iminfo.ys*iminfo.xs*3, '*uint16');
                redChannel = reshape(imdata(1:3:end), [iminfo.xs, iminfo.ys]);
                greenChannel = reshape(imdata(2:3:end), [iminfo.xs, iminfo.ys]);
                blueChannel = reshape(imdata(3:3:end), [iminfo.xs, iminfo.ys]);
                imdata = cat(3, redChannel, greenChannel, blueChannel);                 
            end
            imdata=permute(imdata,[2 1 3]);
        else
            if iminfo.channelResolution(channel)==8
                imdata=fread(fid, [iminfo.xs,iminfo.ys], '*uint8');
            else
                imdata=fread(fid, [iminfo.xs,iminfo.ys], '*uint16');
            end
            imdata=transpose(imdata);  % correct orientation (for stitching)
        end
        fclose(fid);
    end
    if strcmpi(lifinfo.filetype,".xlef")
        % LOF
        fid=fopen(lifinfo.LOFFile,'r','n','UTF-8');

        p=iminfo.channelbytesinc(channel);
        p=p+(z-1)*iminfo.zbytesinc;
        p=p+(tile-1)*iminfo.tilesbytesinc;
        p=p+(t-1)*iminfo.tbytesinc;

        LIFOffset=62;  %4 + 4 + 1 + 4 + 30 (LMS_Object_File=2*15) + 1 + 4 + 1 + 4 + 1 + 8
        p=p+LIFOffset;

        fseek(fid,p,'bof');

        if iminfo.isrgb
            if iminfo.channelResolution(channel)==8
                imdata=fread(fid, iminfo.ys*iminfo.xs*3, '*uint8');
                redChannel = reshape(imdata(1:3:end), [iminfo.xs, iminfo.ys]);
                greenChannel = reshape(imdata(2:3:end), [iminfo.xs, iminfo.ys]);
                blueChannel = reshape(imdata(3:3:end), [iminfo.xs, iminfo.ys]);
                imdata = cat(3, redChannel, greenChannel, blueChannel);                
            else
                imdata=fread(fid, iminfo.ys*iminfo.xs*3, '*uint16');
                redChannel = reshape(imdata(1:3:end), [iminfo.xs, iminfo.ys]);
                greenChannel = reshape(imdata(2:3:end), [iminfo.xs, iminfo.ys]);
                blueChannel = reshape(imdata(3:3:end), [iminfo.xs, iminfo.ys]);
                imdata = cat(3, redChannel, greenChannel, blueChannel);                 
            end
            imdata=permute(imdata,[2 1 3]);
        else
            if iminfo.channelResolution(channel)==8
                imdata=fread(fid, [iminfo.xs,iminfo.ys], '*uint8');
            else
                imdata=fread(fid, [iminfo.xs,iminfo.ys], '*uint16');
            end
            imdata=transpose(imdata);  % correct orientation (for stitching)
        end
        fclose(fid);
    end
end


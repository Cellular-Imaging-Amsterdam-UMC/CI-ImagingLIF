function imdata = cfReadIm3D(lifinfo, iminfo, channel, zstart, zend, t, tile)
    if strcmpi(lifinfo.filetype,".lif")
        % LIF
        fid=fopen(lifinfo.LIFFile,'r','n','UTF-8');
        if iminfo.channels>1
            if iminfo.channelbytesinc(2)>=iminfo.zbytesinc
                p=iminfo.channelbytesinc(channel);
                p=p+(zstart-1)*iminfo.zbytesinc;
                p=p+(tile-1)*iminfo.tilesbytesinc;
                p=p+(t-1)*iminfo.tbytesinc;

                LIFOffset=lifinfo.Position;
                p=p+LIFOffset;

                fseek(fid,p,'bof');
                if iminfo.xbytesinc==1
                    imdata=fread(fid, iminfo.xs*iminfo.ys*(zend-zstart+1), '*uint8');
                else
                    imdata=fread(fid, iminfo.xs*iminfo.ys*(zend-zstart+1), '*uint16');
                end
                imdata=reshape(imdata,[iminfo.xs,iminfo.ys,(zend-zstart+1)]);
            else
                if iminfo.xbytesinc==1
                    imdata=zeros(iminfo.xs,iminfo.ys,(zend-zstart+1),'uint8');
                else
                    imdata=zeros(iminfo.xs,iminfo.ys,(zend-zstart+1),'uint16');
                end
                p=iminfo.channelbytesinc(channel);
                p=p+(tile-1)*iminfo.tilesbytesinc;
                p=p+(t-1)*iminfo.tbytesinc;

                LIFOffset=lifinfo.Position;

                for z=zstart:zend
                    pn=p+(z-1)*iminfo.zbytesinc;
                    fseek(fid,LIFOffset+pn,'bof');
                    if iminfo.xbytesinc==1
                        imdata(1:iminfo.xs,1:iminfo.ys,z)=fread(fid, [iminfo.xs,iminfo.ys], '*uint8');
                    else
                        imdata(1:iminfo.xs,1:iminfo.ys,z)=fread(fid, [iminfo.xs,iminfo.ys], '*uint16');
                    end
                end
            end
        else
            if iminfo.xbytesinc==1
                imdata=zeros(iminfo.xs,iminfo.ys,(zend-zstart+1),'uint8');
            else
                imdata=zeros(iminfo.xs,iminfo.ys,(zend-zstart+1),'uint16');
            end
            p=(tile-1)*iminfo.tilesbytesinc;
            p=p+(t-1)*iminfo.tbytesinc;

            LIFOffset=lifinfo.Position;

            for z=zstart:zend
                pn=p+(z-1)*iminfo.zbytesinc;
                fseek(fid,LIFOffset+pn,'bof');
                if iminfo.xbytesinc==1
                    imdata(1:iminfo.xs,1:iminfo.ys,z)=fread(fid, [iminfo.xs,iminfo.ys], '*uint8');
                else
                    imdata(1:iminfo.xs,1:iminfo.ys,z)=fread(fid, [iminfo.xs,iminfo.ys], '*uint16');
                end
            end                    
        end
        fclose(fid);
    end
    if strcmpi(lifinfo.filetype,".xlef")
        % LOF
        fid=fopen(lifinfo.LOFFile,'r','n','UTF-8');
        if iminfo.channelbytesinc(2)>=iminfo.zbytesinc
            p=iminfo.channelbytesinc(channel);
            p=p+(zstart-1)*iminfo.zbytesinc;
            p=p+(tile-1)*iminfo.tilesbytesinc;
            p=p+(t-1)*iminfo.tbytesinc;

            LIFOffset=62;  %4 + 4 + 1 + 4 + 30 (LMS_Object_File=2*15) + 1 + 4 + 1 + 4 + 1 + 8
            p=p+LIFOffset;

            fseek(fid,p,'bof');
            if iminfo.xbytesinc==1
                imdata=fread(fid, iminfo.xs*iminfo.ys*(zend-zstart+1), '*uint8');
            else
                imdata=fread(fid, iminfo.xs*iminfo.ys*(zend-zstart+1), '*uint16');
            end
            imdata=reshape(imdata,[iminfo.xs,iminfo.ys,(zend-zstart+1)]);
            fclose(fid);
        else
            imdata=zeros(iminfo.xs,iminfo.ys,(zend-zstart+1));
            p=iminfo.channelbytesinc(channel);
            p=p+(tile-1)*iminfo.tilesbytesinc;
            p=p+(t-1)*iminfo.tbytesinc;

            LIFOffset=62;  %4 + 4 + 1 + 4 + 30 (LMS_Object_File=2*15) + 1 + 4 + 1 + 4 + 1 + 8

            for z=zstart:zend
                pn=p+(z-1)*iminfo.zbytesinc;
                fseek(fid,LIFOffset+pn,'bof');
                if iminfo.xbytesinc==1
                    imdata(1:iminfo.xs,1:iminfo.ys,z)=fread(fid, [iminfo.xs,iminfo.ys], '*uint8');
                else
                    imdata(1:iminfo.xs,1:iminfo.ys,z)=fread(fid, [iminfo.xs,iminfo.ys], '*uint16');
                end
            end
        end
    end
end


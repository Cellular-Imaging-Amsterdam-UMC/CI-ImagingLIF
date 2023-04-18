function eventlist = cfReadEventList(lifinfo, iminfo)
    fid=fopen(lifinfo.LIFFile,'r');
        fseek(fid,lifinfo.Position,'bof');

        fieldsizes = [4 8 8 4 4 4 4 4 4]; %uint32 uint64 uint64 single ...
        skip = [40 36 36 40 40 40 40 40 40];
        offset = @(n) sum(fieldsizes(1:n))+lifinfo.Position; %offset to element n+1

        ev=struct;
        ev.SeriesID = fread(fid, iminfo.NumberOfEvents, '*uint32', skip(1));
        fseek(fid, offset(1), -1);
        ev.frameID = fread(fid, iminfo.NumberOfEvents, '*uint64', skip(2));
        fseek(fid, offset(2), -1);
        ev.eventID = fread(fid, iminfo.NumberOfEvents, '*uint64', skip(3));
        fseek(fid, offset(3), -1);
        ev.X1 = fread(fid, iminfo.NumberOfEvents, '*single', skip(4));
        fseek(fid, offset(4), -1);
        ev.Y1 = fread(fid, iminfo.NumberOfEvents, '*single', skip(5));
        fseek(fid, offset(5), -1);
        ev.Z1 = fread(fid, iminfo.NumberOfEvents, '*single', skip(6));
        fseek(fid, offset(6), -1);
        ev.channel1 = fread(fid, iminfo.NumberOfEvents, '*single', skip(7));
        fseek(fid, offset(7), -1);
        ev.sigmaX = fread(fid, iminfo.NumberOfEvents, '*single', skip(8));
        fseek(fid, offset(8), -1);
        ev.sigmaY = fread(fid, iminfo.NumberOfEvents, '*single', skip(9));
    fclose(fid);

    eventlist=ev;
end
function [result, serror, iminfo] = cfReadMetaData(lifinfo, tile)
    %Reading MetaData (Leica LAS-X)
    if strcmpi(lifinfo.datatype,'image')
        iminfo.xs=0;                     % imwidth
        iminfo.xbytesinc=0;
        iminfo.ys=0;                     % imheight
        iminfo.ybytesinc=0;
        iminfo.zs=0;                     % slices (stack)
        iminfo.zbytesinc=0;
        iminfo.ts=1;                     % time
        iminfo.tbytesinc=0;
        iminfo.tiles=0;                  % tiles
        iminfo.tilesbytesinc=0;
        iminfo.xres=0;                   % resolution x
        iminfo.yres=0;                   % resolution y
        iminfo.zres=0;                   % resolution z
        iminfo.tres=0;                   % time interval (from timestamps)
        iminfo.timestamps=[];            % Timestamps t
        iminfo.resunit='';               % resulution unit
        iminfo.xres2=0;                  % resolution x in µm
        iminfo.yres2=0;                  % resolution y in µm
        iminfo.zres2=0;                  % resolution z in µm
        iminfo.resunit2='µm';            % resulution unit in µm
        iminfo.lutname=cell(10,1);
        iminfo.channels=1;
        iminfo.isrgb=false;
        iminfo.channelResolution=zeros(10,1);
        iminfo.channelbytesinc=zeros(10,1);
        iminfo.filterblock=strings(10,1);
        iminfo.excitation=zeros(10,1);
        iminfo.emission=zeros(10,1);
        iminfo.sn=zeros(10,1);
        iminfo.mictype='';
        iminfo.mictype2='';
        iminfo.objective='';
        iminfo.na=0;
        iminfo.refractiveindex=0;
        iminfo.pinholeradius=250;

        serror='';
        
        %Channels
        xmlInfo = lifinfo.Image.ImageDescription.Channels.ChannelDescription;
        iminfo.channels=numel(xmlInfo);
        if iminfo.channels>1
            iminfo.isrgb=(str2double(char(xmlInfo{1}.Attributes.ChannelTag))~=0);
        end
        for k = 1:iminfo.channels
            if iminfo.channels>1
                iminfo.channelbytesinc(k)=str2double(char(xmlInfo{k}.Attributes.BytesInc));
                iminfo.channelResolution(k)=str2double(char(xmlInfo{k}.Attributes.Resolution));
                iminfo.lutname{k}=lower(char(xmlInfo{k}.Attributes.LUTName));
            else
                iminfo.channelbytesinc(k)=str2double(char(xmlInfo.Attributes.BytesInc));
                iminfo.channelResolution(k)=str2double(char(xmlInfo.Attributes.Resolution));
                iminfo.lutname{k}=lower(char(xmlInfo.Attributes.LUTName));
            end
        end
        %Dimensions and size
        iminfo.zs=1;
        xmlInfo = lifinfo.Image.ImageDescription.Dimensions.DimensionDescription;
        for k = 1:numel(xmlInfo)
            dim=str2double(xmlInfo{k}.Attributes.DimID);
            switch dim
                case 1
                    iminfo.xs=str2double(xmlInfo{k}.Attributes.NumberOfElements);
                    iminfo.xres=str2double(xmlInfo{k}.Attributes.Length)/(iminfo.xs-1);
                    iminfo.xbytesinc=str2double(xmlInfo{k}.Attributes.BytesInc');
                    iminfo.resunit=char(xmlInfo{k}.Attributes.Unit);
                case 2
                    iminfo.ys=str2double(xmlInfo{k}.Attributes.NumberOfElements);
                    iminfo.yres=str2double(xmlInfo{k}.Attributes.Length)/(iminfo.ys-1);
                    iminfo.ybytesinc=str2double(xmlInfo{k}.Attributes.BytesInc');
                case 3
                    iminfo.zs=str2double(xmlInfo{k}.Attributes.NumberOfElements);
                    iminfo.zres=str2double(xmlInfo{k}.Attributes.Length)/(iminfo.zs-1);
                    iminfo.zbytesinc=str2double(xmlInfo{k}.Attributes.BytesInc');
                case 4
                    iminfo.ts=str2double(xmlInfo{k}.Attributes.NumberOfElements);
                    iminfo.tres=str2double(xmlInfo{k}.Attributes.Length)/(iminfo.ts-1);
                    iminfo.tbytesinc=str2double(xmlInfo{k}.Attributes.BytesInc');
                case 10
                    iminfo.tiles=str2double(xmlInfo{k}.Attributes.NumberOfElements);
                    iminfo.tilesbytesinc=str2double(xmlInfo{k}.Attributes.BytesInc');
            end
        end
        
        %TimeStamps
        if iminfo.ts>1
            %Get Timestamps and number of timestamps
            xmlInfo = lifinfo.Image.TimeStampList;
            if isfield(xmlInfo,'Attributes')
                lifinfo.numberoftimestamps=str2double(xmlInfo.Attributes.NumberOfTimeStamps);
                if lifinfo.numberoftimestamps>0
                    %Convert to date and time
                    ts=split(xmlInfo.Text,' ');
                    ts=ts(1:end-1);
                    tsd=datetime(datestr(now()),'TimeZone','Europe/Zurich');
                    parfor t=1:numel(ts)
                        tsd(t)=datetime(uint64(str2double(['0x' ts{t}])),'ConvertFrom','ntfs','TimeZone','Europe/Zurich');
                    end
                    %??? Timestamps ???
                    if iminfo.ts*iminfo.channels==lifinfo.numberoftimestamps
                        t=tsd(end-(iminfo.channels-1))-tsd(1);
                        iminfo.tres=seconds(t/(iminfo.ts-1));                
                    elseif iminfo.ts*iminfo.channels<lifinfo.numberoftimestamps
                        %Find Average Duration between events;
                        if iminfo.tiles>0
                            [~,a]=findpeaks(histcounts(tsd,iminfo.ts*iminfo.zs*iminfo.tiles));
                            c=numel(tsd)/(iminfo.ts*iminfo.zs*iminfo.tiles);
                            t=tsd(floor(a(end)*c))-tsd(floor(a(1)*c));
                        else
                            [~,a]=findpeaks(histcounts(tsd,iminfo.ts*iminfo.zs));
                            c=numel(tsd)/(iminfo.ts*iminfo.zs);
                            t=tsd(floor(a(end)*c))-tsd(floor(a(1)*c));
                        end
                        iminfo.tres=seconds(t/numel(a));
                    end
                end
            else % SP5??
                if isfield(xmlInfo,'TimeStamp')
                    lifinfo.numberoftimestamps=numel(xmlInfo.TimeStamp);
                end
            end
        end
        
        %Positions
        if iminfo.tiles>1
            if size(lifinfo.Image.Attachment,2)>=1
                if size(lifinfo.Image.Attachment,2)>1
                    for i=1:numel(lifinfo.Image.Attachment)
                        if strcmp(lifinfo.Image.Attachment{i}.Attributes.Name,'TileScanInfo')
                            xmlInfo = lifinfo.Image.Attachment{i};
                            break;
                        end
                    end
                elseif size(lifinfo.Image.Attachment,2)==1
                    if strcmp(lifinfo.Image.Attachment.Attributes.Name,'TileScanInfo')
                        xmlInfo = lifinfo.Image.Attachment;
                    end
                end
                for i=1:iminfo.tiles
                    iminfo.tile(i).num=i;
                    iminfo.tile(i).fieldx=str2double(xmlInfo.Tile{i}.Attributes.FieldX);
                    iminfo.tile(i).fieldy=str2double(xmlInfo.Tile{i}.Attributes.FieldY);
                    iminfo.tile(i).posx=str2double(xmlInfo.Tile{i}.Attributes.PosX);
                    iminfo.tile(i).posy=str2double(xmlInfo.Tile{i}.Attributes.PosY);
                end
                iminfo.tilex=struct;
                iminfo.tilex.xmin=min([iminfo.tile.posx]);
                iminfo.tilex.ymin=min([iminfo.tile.posy]);
                iminfo.tilex.xmax=max([iminfo.tile.posx]);
                iminfo.tilex.ymax=max([iminfo.tile.posy]);
            end
        end
        
        %Mic Type
        if isfield(lifinfo.Image,'Attachment')
            xmlInfo = lifinfo.Image.Attachment;
            for k = 1:numel(xmlInfo)
                if numel(xmlInfo)==1
                    xli=xmlInfo;
                else
                    xli=xmlInfo{k}; 
                end
                name=xli.Attributes.Name; 
                switch name
                    case 'HardwareSetting'
                        if strcmpi(xli.Attributes.DataSourceTypeName,'Confocal')
                            iminfo.mictype='IncohConfMicr';
                            iminfo.mictype2='confocal';
                            %Objective specs
                            thisInfo = xli.ATLConfocalSettingDefinition.Attributes;
                            iminfo.objective=thisInfo.ObjectiveName;  
                            iminfo.na=str2double(thisInfo.NumericalAperture);  
                            iminfo.refractiveindex=str2double(thisInfo.RefractionIndex');  
                            %Channel Excitation and Emission
                            thisInfo = xli.ATLConfocalSettingDefinition.Spectro;
                            for k1 = 1:numel(thisInfo.MultiBand)
                                iminfo.emission(k1)= str2double(thisInfo.MultiBand{k1}.Attributes.LeftWorld)+(str2double(thisInfo.MultiBand{k1}.Attributes.RightWorld)-str2double(thisInfo.MultiBand{k1}.Attributes.LeftWorld))/2;
                                iminfo.excitation(k1)= iminfo.emission(k1)-10;
                            end
                        elseif strcmpi(xli.Attributes.DataSourceTypeName,'Camera')
                            iminfo.mictype='IncohWFMicr';
                            iminfo.mictype2='widefield';
                        else
                            iminfo.mictype='unknown';
                            iminfo.mictype2='generic';
                        end
                        break;
                    case 'HardwareSettingList'
                        if strcmpi(xli.HardwareSetting.ScannerSetting.ScannerSettingRecord{1}.Attributes.Variant,'TCS SP5')
                            iminfo.mictype='IncohConfMicr';
                            iminfo.mictype2='confocal';
                            %Objective specs
                            iminfo.objective='HCX APO L U-V-I 63.0x0.90 WATER UV';  
                            iminfo.na=0.90;  
                            iminfo.refractiveindex=1.33;  
                            %Channel Excitation and Emission
                            for k1 = 1:1
                                iminfo.emission(1)= 520;
                                iminfo.excitation(1)= 488;
                            end
                        else
                            iminfo.mictype='unknown';
                            iminfo.mictype2='generic';
                        end
                        break;
                end
            end 
        else
            iminfo.mictype='unknown';
            iminfo.mictype2='generic';
        end
        %Widefield
        if strcmpi(iminfo.mictype,'IncohWFMicr')
            %Objective specs
            thisInfo = xli.ATLCameraSettingDefinition.Attributes;
            iminfo.objective=thisInfo.ObjectiveName;  
            iminfo.na=str2double(thisInfo.NumericalAperture);  
            iminfo.refractiveindex=str2double(thisInfo.RefractionIndex');  

            %Channel Excitation and Emission
            thisInfo = xli.ATLCameraSettingDefinition.WideFieldChannelConfigurator;
            for k = 1:numel(thisInfo.WideFieldChannelInfo)
                if numel(thisInfo.WideFieldChannelInfo)==1
                    FluoCubeName=thisInfo.WideFieldChannelInfo.Attributes.FluoCubeName;            
                else
                    FluoCubeName=thisInfo.WideFieldChannelInfo{k}.Attributes.FluoCubeName;            
                end
                if numel(thisInfo.WideFieldChannelInfo)==1
                    if strcmpi(FluoCubeName,'QUAD-S')
                        ExName=thisInfo.WideFieldChannelInfo.Attributes.FFW_Excitation1FilterName;
                        iminfo.filterblock(k)=[FluoCubeName ': ' ExName];
                    elseif strcmpi(FluoCubeName,'DA/FI/TX')
                        ExName=thisInfo.WideFieldChannelInfo.Attributes.LUT;
                        iminfo.filterblock(k)=[FluoCubeName ': ' ExName];
                    else
                        ExName=FluoCubeName;
                        iminfo.filterblock(k)=FluoCubeName;
                    end
                else
                    if strcmpi(FluoCubeName,'QUAD-S')
                        ExName=thisInfo.WideFieldChannelInfo{k}.Attributes.FFW_Excitation1FilterName;
                        iminfo.filterblock(k)=[FluoCubeName ': ' ExName];
                    elseif strcmpi(FluoCubeName,'DA/FI/TX')
                        ExName=thisInfo.WideFieldChannelInfo{k}.Attributes.UserDefName;
                        iminfo.filterblock(k)=[FluoCubeName ': ' ExName];
                    else
                        ExName=FluoCubeName;
                        iminfo.filterblock(k)=FluoCubeName;
                    end
                end
                if strcmpi(ExName,'DAPI') || strcmpi(ExName,'DAP') || strcmpi(ExName,'A') || strcmpi(ExName,'Blue')
                    iminfo.excitation(k)=355;
                    iminfo.emission(k)=460;
                end
                if strcmpi(ExName,'GFP') || strcmpi(ExName,'L5') || strcmpi(ExName,'I5') || strcmpi(ExName,'Green') || strcmpi(ExName,'FITC')
                    iminfo.excitation(k)=480;
                    iminfo.emission(k)=527;
                end
                if strcmpi(ExName,'N3') || strcmpi(ExName,'N2.1') || strcmpi(ExName,'TRITC')
                    iminfo.excitation(k)=545;
                    iminfo.emission(k)=605;
                end
                if strcmpi(ExName,'488')
                    iminfo.excitation(k)=488;
                    iminfo.emission(k)=525;
                end
                if strcmpi(ExName,'532')
                    iminfo.excitation(k)=532;
                    iminfo.emission(k)=550;
                end                
                if strcmpi(ExName,'642')
                    iminfo.excitation(k)=642;
                    iminfo.emission(k)=670;
                end                
                if strcmpi(ExName,'Red')
                    iminfo.excitation(k)=545;
                    iminfo.emission(k)=605;
                end
                if strcmpi(ExName,'Y3') || strcmpi(ExName,'I3') || strcmpi(ExName,'CY 3') || strcmpi(ExName,'CY3')
                    iminfo.excitation(k)=545;
                    iminfo.emission(k)=605;
                end
                if strcmpi(ExName,'Y5') || strcmpi(ExName,'CY5') || strcmpi(ExName,'CY 5')
                    iminfo.excitation(k)=590;
                    iminfo.emission(k)=670;
                end
            end
        end

        % Recalculate resolution to micrometer
        if strcmpi(iminfo.resunit,'meter') || strcmpi(iminfo.resunit,'m')
            iminfo.xres2=iminfo.xres*1000000;
            iminfo.yres2=iminfo.yres*1000000;
            iminfo.zres2=iminfo.zres*1000000;
        end
        if strcmpi(iminfo.resunit,'centimeter')
            iminfo.xres2=iminfo.xres*10000;
            iminfo.yres2=iminfo.yres*10000;
            iminfo.zres2=iminfo.zres*10000;
        end
        if strcmpi(iminfo.resunit,'inch')
            iminfo.xres2=iminfo.xres*25400;
            iminfo.yres2=iminfo.yres*25400;
            iminfo.zres2=iminfo.zres*25400;
        end
        if strcmpi(iminfo.resunit,'milimeter')
            iminfo.xres2=iminfo.xres*1000;
            iminfo.yres2=iminfo.yres*1000;
            iminfo.zres2=iminfo.zres*1000;
        end
        if strcmpi(iminfo.resunit,'micrometer')
            iminfo.xres2=iminfo.xres;
            iminfo.yres2=iminfo.yres;
            iminfo.zres2=iminfo.zres;
        end

    %             xmlTiles = xDoc.getElementsByTagName('Tile');
    %             if ~isempty(iminfo.tiles)
    %                 iminfo.tilelist=zeros(iminfo.tiles,2); % posx, posy
    %                 iminfo.tilemax=zeros(2,1);  % maxx and maxy
    %                 for k = 0:xmlTiles.getLength-1
    %                     thisTile = xmlTiles.item(k);
    %                     x=str2double(char(thisTile.getAttribute('FieldX')));
    %                     y=str2double(char(thisTile.getAttribute('FieldY')));
    %                     if x+1>iminfo.tilemax(1); iminfo.tilemax(1)=x+1;end
    %                     if y+1>iminfo.tilemax(2); iminfo.tilemax(2)=y+1;end
    %                     iminfo.tilelist(k+1,1)=x; iminfo.tilelist(k+1,2)=y;
    %                 end
    %                 xmlInfo = xDoc.getElementsByTagName('StitchingSettings');
    %                 thisInfo = xmlInfo.item(0);
    %                 iminfo.overlapprocx=str2double(char(thisInfo.getAttribute('OverlapPercentageX')));
    %                 iminfo.overlapprocy=str2double(char(thisInfo.getAttribute('OverlapPercentageY')));
    %             end
        result=true;
    elseif strcmpi(lifinfo.datatype,'eventlist')
        iminfo.channels=1;
        iminfo.NumberOfEvents=str2double(lifinfo.GISTEventList.GISTEventListDescription.NumberOfEvents.Attributes.NumberOfEventsValue);
        iminfo.Threshold=str2double(lifinfo.GISTEventList.GISTEventListDescription.LocalizationParameters.Attributes.Threshold);
        iminfo.Gain=str2double(lifinfo.GISTEventList.GISTEventListDescription.LocalizationParameters.Attributes.Gain);
        iminfo.FieldOfViewX=str2double(lifinfo.GISTEventList.GISTEventListDescription.LocalizationParameters.Attributes.FieldOfViewX2);
        iminfo.FieldOfViewY=str2double(lifinfo.GISTEventList.GISTEventListDescription.LocalizationParameters.Attributes.FieldOfViewY2);
        %s=cfXML2struct(cfXMLReadString(['<?xml version="1.0" encoding="ISO-8859-1"?>' lifinfo.GISTEventList.GISTEventListDescription.DataAnalysis.Attributes.XML3DCalibration]));
        serror='';  
        result=true;
    end
end

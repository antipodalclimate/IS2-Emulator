%% Import data from text files

savestr = [Output_folder '/Image_Metadata'];

imagery_metadata = dir([Data_folder '/Optical-Data/NOAA*.txt']);

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 12);

% Specify range and delimiter
opts.DataLines = [42, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["DateTime", "ImageNumber", "Latitude", "Longitude", "PCFD", "PCFM", "PCFL", "SIC", "MPF", "VarName10", "VarName11", "VarName12"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "string", "string", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["VarName10", "VarName11", "VarName12"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["VarName10", "VarName11", "VarName12"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "DateTime", "InputFormat", "yyyy-MM-dd HH:mm:ss.SSS", "DatetimeFormat", "preserveinput");


[image_timer,image_number,image_latitude,image_longitude,image_SIC,image_MPF] = deal(cell(size(imagery_metadata)));

for i = 1:length(imagery_metadata)

    % Import the data
    temp = readtable([imagery_metadata(i).folder '/' imagery_metadata(i).name], opts);

    image_timer{i} = datenum(temp.DateTime);
    image_number{i} = temp.ImageNumber;
    image_latitude{i} = temp.Latitude;
    image_longitude{i} = temp.Longitude;

    if max(temp.SIC < 2)
       
        temp.SIC = 100*temp.SIC; 
    
    end

    image_SIC{i} = temp.SIC;
    image_MPF{i} = temp.MPF;

end

image_timer = cell2mat(image_timer);
image_number = cell2mat(image_number);
image_SIC = cell2mat(image_SIC);
image_MPF = cell2mat(image_MPF);
image_latitude = cell2mat(image_latitude);
image_longitude = cell2mat(image_longitude);

%% Clear temporary variables
clear opts

%% Get entire list of images
image_list = dir([Data_folder '/Optical-Data/*/*/*/*.h5']);

% Find the directory of the image corresponding to each metadata point
image_location = cell(size(image_latitude));
% Ask whether we use the image at that point
used = zeros(size(image_latitude));
% Find the location in the metadata of that location
imagelocID = used; 

% Look at every single image
for i = 1:length(image_list)
    %%

    try 

    temp_name = image_list(i).name; 

    if length(temp_name) > 32
    
        % Some files named in different ways
        temp_name = temp_name(13:end);
        temp_name(15:27) = '';

    end
        
    IDnum = str2num(temp_name(1:5));
    IDday = datenum(temp_name(7:14),'yyyymmdd');

    loc = find(image_number == IDnum & floor(image_timer) == IDday);

    if length(loc) > 1
        disp('error')
    
    else 
        
        if isempty(loc)

            disp('not located');

            imagelocID(i) = nan; 
            used(loc) = 0;

        else % suitably done

        image_location{loc} = [image_list(i).folder '/' image_list(i).name];
        imagelocID(i) = loc;
        used(loc) = 1;

        end

    end


    catch errattempt

        throw(errattempt)

    end


end


%%

fprintf('Image metadata saved to %s \n',savestr)
save(savestr,'image_latitude','image_longitude','image_SIC','image_MPF','image_timer','image_location','imagelocID');


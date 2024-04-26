%% Import data from text file

imagery_metadata = dir([Data_folder 'NOAA*.txt']);

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
image_list = dir([Data_folder '*/*/*/*.h5']);

image_location = cell(size(image_latitude));
used = zeros(size(image_latitude));
imagelocID = used; 

for i = 1:length(image_list)
    %%
    IDnum = str2num(image_list(i).name(1:5));
    IDday = datenum(image_list(i).name(7:14),'yyyymmdd');

    loc = find(image_number == IDnum & floor(image_timer) == IDday);

    if length(loc) > 1
        disp('error')
    end

    image_location{loc} = [image_list(i).folder '/' image_list(i).name];
    imagelocID(i) = loc;
    used(loc) = 1; 

end


%%


save('Image_Metadata','image_latitude','image_longitude','image_SIC','image_MPF','image_timer','image_location')


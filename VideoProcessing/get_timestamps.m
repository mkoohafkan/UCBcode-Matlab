function err = get_timestamps(videoname, imgformat)
% Specialized function for working with Brinno TLC200 Pro video output.
% 
% INPUT ARGUMENTS
% videoname = the filename for path of the input video.
% imgformat = the image format to be written to.
%             Default is 'tiff'.
%
% OUTPUT
% a folder containing the timestamp of each frame of the input video,
% assuming the camera's timestamp settings are enabled. The files are named
% sequentially so that the frame index of a particular timestamp can be
% identified.
%
%
%
if nargin < 1
    disp('Error: no input video specified.')
    err = -1 ;
    return
elseif nargin < 2
    disp('Warning: output image format not specified. Default is tiff.')
    imgformat = 'tiff' ;
end
% read the video file
try
    inobj = VideoReader(videoname) ;
    nframes = inobj.NumberOfFrames ;
catch err
    disp('Error: there was a problem reading the input video.')
    rethrow(err)
end
% create folder to house exported frames
outfolder = [videoname '_timestamps'] ;
try
    mkdir(outfolder) ;
catch err
    disp(['Error: there was a problem creating ' outfolder '.'])
    rethrow(err)
end
% extract the frames
for i = 1:nframes
    try
        img = read(inobj, i) ;
    catch err
        disp(['There was a problem reading ' videoname ' at frame ' i '.'])
        rethrow(err)
    end
    % write frame to a file. 
    % timestamp is 705px to 720px, across width of frame
    f = [outfolder '\' videoname '_timestamps' sprintf('_%d.',i) imgformat] ;
    try
        imwrite(img(705:720, :, :), f) ;
    catch err
        disp(['There was a problem writing ' f '.'])
        rethrow(err)
    end
end
%
err = 0 ;
disp('Timestamps were written successfully.')
end
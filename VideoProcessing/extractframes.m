function err = extractframes(videoname, imgformat, startframe, endframe)
% Extracts frames from a video and writes them to images
%
% INPUT ARGUMENTS
% videoname = the filename or path of the input video.
% imgformat = the output image format. Default is 'tiff'.
% startframe = The first frame to be written. 
%              Default is first frame of the input video.
% endframe = the last frame to be written.
%            Default is the final frame of the input video.
%
% OUPUT
% A folder of frames written to images.
%
%
% get input video
if nargin < 1
    err = -1 ;
    disp('Error: No input video specified.')
    return
end
% get imgformat
if nargin < 2
    disp('Warning: no image format specified. Default is tiff.')
    imgformat = 'tiff' ;
end
% get startframe
if nargin < 3
    disp(['Warning: starting frame index not supplied. ' ...
          'Default is first frame.'])
    startframe = 1 ;
elseif isdeployed
    startframe = str2double(startframe) ;
end
% read the video file
try
    inobj = VideoReader(videoname) ;
    nframes = inobj.NumberOfFrames ;
catch err
    disp('Error: there was a problem reading the input video.')
    rethrow(err)
end
% get endframe
if nargin < 4
    disp('Warning: No final frame index supplied. Default is last frame.')
    endframe = nframes ;
elseif isdeployed
    endframe = str2double(endframe) ;
end
% check inputs
if startframe < 1 || endframe < 1
    disp('Error: frame indices must be positive.')
    err = -1 ;
    return
elseif startframe > nframes || endframe > nframes
    disp(['Error: frame indices cannot exceed number of frames ' ...
         'in input video.'])
    err = -1 ;
    return    
elseif startframe > endframe
    framestep = -1 ;
else
    framestep = 1 ;
end
% prep output folder
outfolder = [videoname '_frames'] ;
try
    mkdir(outfolder) ;
catch err
    disp('Error: there was a problem creating the output folder.')
    rethrow(err)
end
% write frames to files
disp('Writing frames to images...')
try
    for i = startframe:framestep:endframe
        % extract a frame
        try
            img = read(inobj, i);
        catch err
            disp(['Error: there was a problem reading the video ' ...
                  'at frame ' i '.'])
            rethrow(err)
        end
        % write frame to a file
        imwrite(img, [outfolder '\' videoname sprintf('_%d.', i) imgformat]) ;
    end
catch err
    disp('Error: there was a problem writing the frames.')
    rethrow(err) ;
end
err = 0 ;
disp('Frames were writting to images successfully.')
end
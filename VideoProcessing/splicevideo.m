function err = splicevideo(outvideo, profile, invideo1, invideo2, framerate, orientation)
% joins two videos frame by frame.
%
% INPUT ARGUMENTS
% outvideo = the new video file to be written.
% profile = the profile used to encode the video.
% invideo1 = an input video. will show on the left or top of the new video.
% invideo2 = an input video. will show on the right or bottom.
% framerate = the framerate of the new video. Default is "first", meaning
%             the framerate of the first input video will be used. Other 
%             options include "second" or a nonzero positive number.
% orientation = the orientation of the new video. Default is "horizontal",
%               meaning that frames will be joined horizontally. Use 
%               "vertical" to join frames vertically.
% 
% OUTPUT
% a new video file playing the two input videos side by side.
%
%
%
% get input videos
if nargin < 4
    disp(['Error: the output video, profile, and ' ...
          'two input videos must be specified.'])
    err = VideoWriter.getProfiles ;
    disp(err)
    return
else
    try
        inobj1 = VideoReader(invideo1) ; % top or left
    catch err
        disp(['Error: There was a problem reading ' invideo1 '.'])
        rethrow(err)
    end
    try
        inobj2 = VideoReader(invideo2) ; % bottom or right
    catch err
        disp(['Error: There was a problem reading ' invideo2 '.'])
        rethrow(err)
    end
    nframes = inobj1.NumberOfFrames ;
    assert(nframes == inobj2.NumberOfFrames, ...
           'Error: input videos must have same number of frames.') ;
    assert(get(inobj1, 'height') == get(inobj2, 'height') && ...
           get(inobj1, 'width') == get(inobj2, 'width'), ...
           'Error: input videos must have same pixel dimensions.')
end
% get orientation
if nargin < 5
    disp('Warning: orientation not specified. Default is horizontal.')
    catfun = 'horzcat' ;
elseif strcmp(orientation(1), 'h')
    catfun = 'horzcat' ;
    disp('Videos will be joined horizontally.')    
elseif strcmp(orientation(1), 'v')
    catfun = 'vertcat' ;
    disp('Videos will be joined vertically.')
else
    disp(['Error: orientation not recognized. '...
          'Options are (h)orizontal" and (v)ertical.'])
    err = -1 ;
    return
end
% get framerate
if nargin < 6
    disp(['Warning: framerate not specified. ' ...
         'Framerate of first video will be used.'])
    framerate = inobj1.FrameRate ;
elseif strcmp(framerate, 'first')
    disp('Framerate of first video will be used.')
    framerate = inobj1.FrameRate ;
elseif strcmp(framerate, 'second')
    disp('Framerate of second video will be used.')
    framerate = inobj2.FrameRate ;
else
    if isdeployed
        framerate = str2double(framerate) ;
    end
    if framerate <= 0
        disp(['Error: framerate must be "first", "second", ' ...
              'or a nonzero positive number.'])
        err = -1 ;
        return
    end
end
% create output video
try
    outobj = VideoWriter(outvideo, profile) ;
    outobj.FrameRate = framerate ;
catch err
    disp('Error: there was a problem creating the output video.')
    rethrow(err)
end
open(outobj)
try
    for i = 1:nframes    
        writeVideo(outobj, feval(catfun, read(inobj1, i), read(inobj2, i))) ;
    end
catch err
    close(outobj)
    disp(['Error: there was a problem writing frame ' i '.'])
    rethrow(err)
end
close(outobj)     
disp('Video written successfully.')
err = 0 ;
%
end
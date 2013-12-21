function err = clipvideo(videoname, profile, startframe, endframe, framerate)
% clips a video, optionally reverses video playback and changes framerate.
%
% INPUT ARGUMENTS
% videoname = the name or path of the video file, with extension 
%       (e.g.'test.avi')
% profile = the VideoWriter profile. if omitted, function returns 
%           a list of available profiles.
% startframe = the first frame to include in the new video.
%              if startframe > endframe, video will be written in reverse.
% end frame = the last frame to include in the new video.
%             Default is last frame of input video.
% framerate = the playback framerate of the new video.
%             default is framerate of input video.
%
% OUTPUT
% a new video, potentially clipped, reversed and with a new framerate. 
%
%
% get input video
if nargin < 1
    err = 'Error: No input video specified.' ;
    disp(err)
    return
end
% get profile
if nargin < 2
    disp('Error: No profile specified for output video.')
    err = VideoWriter.getProfiles ;
    disp(err)
    return
end
% try opening the input video
try
    invideo = VideoReader(videoname) ;
    nframes = invideo.NumberOfFrames ;
catch err
    disp('Error: there was a problem opening the specified video.')
    rethrow(err)
end
% check first frame
if isdeployed
    startframe = str2double(startframe) ;
end
% get the last frame, if not specified
if nargin < 4
    disp(['Warning: no ending frame index specified. ' ...
          'Using final frame of input video.'])
    endframe = nframes ;
else
    if isdeployed
        endframe = str2double(endframe) ;
    end
end
% check that the specified frames will work
if startframe < 0 || endframe < 0
    disp('Error: frame indexes must be positive numbers')
    err = -1 ;
    return    
elseif startframe > nframes || endframe > nframes
    disp(['Error: frame index cannot be ' ...
          'greater than the last frame of' videoname])
    err = -1 ;
    return
elseif endframe < startframe
    disp('Warning: video will be reversed.')
    fstep = -1 ;
else
    fstep = 1 ;
end
% create new video file
outvideo = VideoWriter([videoname(1:end-4) '_clipped'], profile) ;
% check if framerate was supplied. If not, use framerate of original video
if nargin < 5
    framerate = invideo.FrameRate ;
else
    if isdeployed
        framerate = str2double(framerate) ;
    end
end
outvideo.FrameRate = framerate ;
% open new video file for writing
disp('Writing video to file...')
open(outvideo) ;
try
    % write frames to new file
    for i = startframe:fstep:endframe
            writeVideo(outvideo, read(invideo, i)) ;
    end
    % close video file and end program
    close(outvideo) ;
    disp('Video was written successfully.')
    err = 0 ;
    return
catch err
    % End program cleanly if there was a problem
    close(outvideo) ;
    disp('Error: there was a problem writing the video.')
    rethrow(err) ;
end
%
end
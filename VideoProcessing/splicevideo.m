% take two videos (assuming they have both been clipped to sync) and splice
% frames together
function flag = splicevideo(outvideo, invideo1, invideo2, splicemethod)
% splice direction is either 'horizontal' or 'vertical'
if nargs < 3
    splicemethod = 'horzcat' ;
end
if nargs < 4
    fps = 5 ;
end

inobj1 = VideoReader(invideo1) ;
inobj2 = VideoReader(invideo2) ;
% check that the have the same number of frames
nframes = inobj1.NumberOfFrames ;
assert(nframes == inobj2.NumberOfFrames) ;
outobj = VideoWriter(outvideo, 'MPEG-4') ;
outobj.FrameRate = fps ;
open(outobj) ;
for i = 1:nframes    
    writeVideo(outobj, feval(splicemethod, read(inobj1, i), read(inobj2, i))) ;
    % for 720p to 1080p
    % old width is 1280, new is 1920
    % old height is 720, new is 1088
    
    % if plot is same width as original video
    img = padarray(vertcat(old, new), [0 184]) ;
    
    %if plot is fit to new width
    img = vertcat(padarray(old, [0 184]), new);
end
close(outobj) ;    
    
end
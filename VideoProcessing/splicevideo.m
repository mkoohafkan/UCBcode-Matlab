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
inobj1 = VideoReader(invideo1) ; % top or left
inobj2 = VideoReader(invideo2) ;
% check that the have the same number of frames
nframes = inobj1.NumberOfFrames ;
assert(nframes == inobj2.NumberOfFrames) ;
outobj = VideoWriter(outvideo) ;
outobj.FrameRate = fps ;
open(outobj) ;
for i = 1:nframes    
    writeVideo(outobj, feval(splicemethod, read(inobj1, i), read(inobj2, i))) ;
end
close(outobj) ;    
    
end
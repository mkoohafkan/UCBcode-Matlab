function flag = extractdaylightframes(fin)
% extractframes: used to extract a list of images
% from a video
%   Detailed explanation goes here
    numvids = length(fin(:));
    nightframes = cell(numvids, 1);
    frames = cell(numvids, 1);
    nframes = cell(numvids, 1);
    minframes = intmax;
    for n = 1:numvids
        inobj = VideoReader(fin{n});
        % get the frames
        frameheight = get(inobj, 'Height');
        framewidth = get(inobj, 'Width');
        nframes{n} = get(inobj, 'NumberOfFrames');
        minframes = min(minframes, nframes{n});
        frames{n} = read(inobj);
        % identify night-time
        isnight = zeros(nframes{n}, 1) ;
        for i = 1:nframes{n}
            fuzzyblack = fuzzycolor(frames{n}(:,:,:,i), 'black');
            if sum(fuzzyblack > 0.5)/length(fuzzyblack) > 0.8
                isnight(i, 1) = true;
            end
        end
        % pad the daylight frames to ensure you didn't miss anything
        sunset = strfind(isnight', [0 1]);
        sunrise = strfind(isnight', [1 0]);
        isnight(sunset' + 2) = 0;
        isnight(sunrise' - 1) = 0;
        nightframes{n} = isnight;
    end
    % find the intersection of nightframes of all videos
    % if videos are different lengths, drop extra frames at the end
    dropframes = ones(minframes, 1);
    for i = 1:numvids
        dropframes = dropframes & nightframes{i}(1:minframes);
    end
    % get vector of daylight frames positions
    framepos = zeros(sum(dropframes), 1);
    k = 1;
    for i = 1:length(dropframes)
        if(not(dropframes(i)))
            framepos(k) = i;
            k = k + 1;
        end
    end
    % write daylight frames to file
    fout = 'fogvid_daylight.avi';
    outobj = VideoWriter(fout);
    set(outobj, 'FrameRate', 5);
    open(outobj);    
    for f = framepos' % for each non-night frame
        dayframe = zeros(frameheight, framewidth*numvids, 3, 'uint8');
        for l = 1:3 % for each of R, G and B color layer
            % cell array to hold color frame for each video
            thisframelayer = cell(1, numvids);
            for n = 1:numvids % for each video
                % put the color frames of each video in the cell array
                thisframelayer{1, n} = frames{n}(:, :, l, f);
            end
            % make one big color frame (vids left to right)
            dayframe(:, :, l) = cell2mat(thisframelayer);
        end
        writeVideo(outobj, dayframe);
    end
    close(outobj);
    flag = 0;
end
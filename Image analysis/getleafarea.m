function [realarea, leaf, scale, original] = getleafarea(imgfolder, imgname)
    % assumes scale is in lower right corner, leaf is on top half of image
    original=imread([imgfolder '/' imgname]) ;
    leaf = original(10:end-500, 10:end-10, :, :) ;
    scale = original(end-500:end-10, end-500:end-10, :) ;
    % processing scale
    scale = imclose(scale, strel('square', 2)) ;
    scale = imopen(scale, strel('square', 2)) ;
    scale = imclose(scale, strel('line', 100, 0)) ;
    scale = imclose(scale, strel('line', 100, 90)) ;
    % processing leaf
    leaf = imopen(leaf, strel('disk', 1)) ;
    leaf = imclose(leaf, strel('disk', 3)) ;
    % write processed images to file for verification
    imwrite(scale, [imgfolder '/processed_scale-' imgname]) ;
    imwrite(leaf, [imgfolder '/processed_leaf-' imgname]) ;
    % calculate area
    % assumes scale is 1-in square
    leafarea = bwarea(imcomplement(leaf)) ;
    scalearea = bwarea(imcomplement(scale)) ;
    realarea = leafarea/scalearea ; % in inches
end
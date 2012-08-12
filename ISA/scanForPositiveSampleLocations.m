function [ image3d, locations ] =...
        scanForPositiveSampleLocations( image3d, window3d, step )
% scanForCuboids looking for cuboids locations in the 3d image
% RETURN 3d images and locations
% e.g.:
% [~, loc] = scanForCuboids('/cancer/annotation/73c', [21,21,11], [10,10,5]);
% Wed 25 Apr 2012 00:31:06 BST
% Wenqi Li


%sizeOfImage = size(image3d);
%frameInx = zeros(200, 1);
%x = 0;
%for i = 1:sizeOfImage(3)  % in the direction of frames
    %% TODO: change with 'unique'
    %if(find(image3d(:,:,i)))  % if there are annotations
        %x = x + 1;
        %frameInx(x) = i;
    %end
%end
%clear i x;
[~, ~, frameInx] = find(image3d);
frameInx = unique(frameInx);

locations = [];
window3d = floor(window3d./2);
for i = 2:size(frameInx,1);
    if (frameInx(i) < 1)
        continue;
    end
    if frameInx(i-1) - window3d(3) < 1
        continue;
    end

    startFrame = frameInx(i-1);
    [xs ys] = find(image3d(:,:,startFrame));
    xLow = min(xs);
    xHigh = max(xs);
    yLow = min(ys);
    yHigh = max(ys);
    fprintf('size: %dx%d', xHigh-xLow, yHigh-yLow);

    for x = xLow:step(1):xHigh
        for y = yLow:step(2):yHigh
            try
                if all(image3d( x-window3d(1):x+window3d(1),...
                        y-window3d(2):y+window3d(2),...
                        startFrame ))
                    % locations of positive examples.
                    locations = [locations; [x y startFrame]];
                end
            catch e
                warning(e.identifier, 'In scanForPositiveSampleLocations');
                % do nothing
            end
        end
    end
end
if isempty(locations)
    err = MException('OPT:nolocation',...
        'Cannot find any continuous annotations');
    throw(err);
end
end % end of function


% debugging for visualise ROI
% figure;
% colormap(gray);
% imagesc(image3d(:,:,108));
% for i = 1:611
% l = locations(i,:);
% if l(3) == 108
% rectangle('Position',...
    % [l(2)-window3d(2), l(1)-window3d(1),window3d(2)*2, window3d(1)*2],'FaceColor', 'r');
% end
% end
%
% clear i overlap;
%end


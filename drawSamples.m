function [] = drawSamples(imgSet, xmlSet, outputSet, windowSize)
% input
xmlFiles = dir([xmlSet '/*.xml']);
segImgSet = '%s/Annotated/%s%s';
oriImgSet = '%s/Images/%s%s';
% output
outputSet = sprintf('%s/cuboid_%d', outputSet, windowSize);
mkdir(outputSet);
% parameters
window3d = windowSize * ones(1,3);
step3d = window3d;

for i = 1:size(xmlFiles, 1)
    cuboid = {};
    rec = VOCreadxml([xmlSet '/' xmlFiles(i).name]);
    name = rec.annotation.index;
    for p = 1:size(rec.annotation.part, 2)
        part = rec.annotation.part{p};
        segFile = sprintf(segImgSet, imgSet, name, part);
        oriFile = sprintf(oriImgSet, imgSet, name, part);
        cubPart = img2Cub(oriFile, segFile, window3d, step3d);
        cuboid = [cuboid, cubPart];
    end
    cuboidSet = sprintf('%s/%s', outputSet, name);
    save(cuboidSet, 'cuboid');
    clear cuboid
end
end

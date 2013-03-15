addpath('~/Documents/optAnalyse/libsvm');
addpath('~/Documents/optAnalyse/liblinear');
addpath('~/Documents/optAnalyse/pwmetric');
addpath(genpath('~/Documents/piotr_toolbox_V3.02/'));
RandStream.setDefaultStream(RandStream('mrg32k3a', 'seed', sum(100*clock)));

xmlSet = '~/Desktop/description';
imgSet = '~/Desktop/OPTmix';
generate_scheme = 1;
needDrawSamples = 1;
needTrainBases = 1;
needExtractFeatures = 1;
needClassifyVectors = 1;

windowSize = 21;
subSize = 9;
step3d = 2;

id = '9'; % for debugging
baseFile = '~/Desktop/output';

if isempty(id)
    id = datestr(now, 30);
    id = sprintf('%s_%d_%d', id, subSize, step3d);
end
outputSet = sprintf('%s/RP_%s', baseFile, id);
mkdir(outputSet);
diary([outputSet '/exp.log']);
fprintf('%s %s\n', datestr(now), 'starting batch...');

%%% generate random permutate testing folder schemes
if generate_scheme
    k = 6;
    foldSize = 10;
    allInd = randsample(k * foldSize, k * foldSize);
    allInd = reshape(allInd, foldSize, []);
    testScheme = eye(k, 'int8');
    save([outputSet '/exparam'], 'testScheme', 'allInd');
else
    load([outputSet '/exparam']);
end


% draw samples
if needDrawSamples
    drawSamples(imgSet, xmlSet, outputSet, windowSize);
end

files = dir([xmlSet, '/*.xml']);
LGDInd = [];
INCInd = [];
for i = 1:length(files)
    rec = VOCreadxml([xmlSet '/' files(i).name]);
    if strcmp(rec.annotation.type, 'LGD')
        LGDInd(end+1) = i;
    else
        INCInd(end+1) = i;
    end
end
%% randomly permutate
%LGDInd = LGDInd(randperm(size(LGDInd, 2)));
%INCInd = INCInd(randperm(size(INCInd, 2)));
%allInd = zeros(1, size(files, 1));
%allInd(1, 1:2:end) = LGDInd;
%allInd(1, 2:2:end) = INCInd;
%% ten fold cross validation
%k = 10;
%foldSize = 3;
%allInd = reshape(allInd, foldSize, []);
%testScheme = eye(k, 'int8');

for f = 1:length(testScheme)
    
    trainInd = allInd(:, ~testScheme(f, :));
    trainInd = trainInd(:);
    trainInd = trainInd(trainInd ~= 60);
    testInd = allInd(:, f);
    testInd = testInd(testInd ~= 60);

    k = 200;

    randMat = randn(150, subSize^3);

    resultSet = sprintf('%s/result_%d', outputSet, f);
    mkdir(resultSet);


    % find k clusters in all training samples
    baseSet = sprintf('%s/result_%d/base', outputSet, f);
    mkdir(baseSet);
    if needTrainBases
        trainBases(xmlSet, outputSet, baseSet,...
            trainInd, windowSize, subSize, step3d, k,...
            randMat);
    end

    % extract features from train, validation, test set
    feaSet = sprintf('%s/result_%d/feaSet', outputSet, f);
    if needExtractFeatures
        extractBOPFeatures(xmlSet, outputSet, baseSet, feaSet,...
            windowSize, subSize, step3d, randMat);
    end

    % classify vectors
    if needClassifyVectors
        classifyVectors(xmlSet, feaSet, resultSet,...
            {trainInd; testInd});
    end
end
diary off;

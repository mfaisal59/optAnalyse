function [] = classifyVectors(xmlSet, outputSet, indexes)
fprintf('%s classify vectors\n', datestr(now));
% params
isScale = 1;
isrbf = 1;
% input
xmlFiles = dir([xmlSet '/*xml']);
feaSet = [outputSet '/feaSet/%s'];
% first set of indexes training
trainSet = [];
trainLabels = [];
for i = 1:size(indexes{1}, 1)
    rec = VOCreadxml([xmlSet '/' xmlFiles(indexes{1}(i)).name]);
    name = rec.annotation.index;
    type = rec.annotation.type;
    feaFile = sprintf(feaSet, name);
    load(feaFile);
    trainSet = [trainSet; X_features'];
    if strcmp(type, 'Cancers')
        labels = ones(size(X_features', 1), 1);
    else
        labels = -1 * ones(size(X_features', 1), 1);
    end
    trainLabels = [trainLabels; labels];
end
if isScale
    fprintf('%s scaling dataset\n', datestr(now));
    minTrain = min(trainSet, [], 1);
    maxTrain = max(trainSet, [], 1);
    trainSet = (trainSet - repmat(minTrain, size(trainSet,1), 1))*...
        spdiags(1./(maxTrain-minTrain)',0,size(trainSet,2), size(trainSet,2));
end
if isrbf
fprintf('searching for C and gamma');
bestcv = 0;
for log2c = -5:2:15
    for log2g = 3:-2:-15
        cmd = ['-v 5 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
        fprintf('parameters: %s\n', cmd);
        cv = svmtrain2(trainLabels, trainSet, cmd);
        if cv >= bestcv
            bestcv = cv;
            bestc = 2^log2c; 
            bestg = 2^log2g;
            bestCMD = [ '-c ', num2str(bestc), ' -g ', num2str(bestg) '-b 1'];
            model = svmtrain2(trainLabels, trainSet, bestCMD);
        end
    end
end
else
    model = train(trainLabels, sparse(trainSet), '-s 1');
end
clear trainLabels trainSet;

fprintf('%s predicting data\n', datestr(now));
testSet = [];
testLabels = [];
for i = 1:size(indexes{2}, 1)
    rec = VOCreadxml([xmlSet '/' xmlFiles(indexes{1}(i)).name]);
    name = rec.annotation.index;
    type = rec.annotation.type;
    feaFile = sprintf(feaSet, name);
    load(feaFile);
    testSet = [testSet; X_features'];
    if strcmp(type, 'Cancers')
        labels = ones(size(X_features', 1), 1);
    else
        labels = -1 * ones(size(X_features', 1), 1);
    end
    testLabels = [testLabels; labels];
end
if isScale
    fprintf('%s scaling test set\n', datestr(now));
    minTrain = min(trainSet, [], 1);
    maxTrain = max(trainSet, [], 1);
    testSet = (testSet - repmat(minTrain, size(testSet,1), 1))*...
        spdiags(1./(maxTrain-minTrain)',0,size(testSet,2), size(testSet,2));
end
[prediction, accuracy, prob] = svmpredict(testLabels, testSet, model, '-b 1');
fprintf('%s saving final result\n', datestr(now));
save([outputSet '/result.mat'], 'prediction', 'accuracy', 'prob');
end

function boost_pipeline(featPath, eventID, numRounds, saveDir)
    models = cell(numRounds, 1);
    modelWeights = zeros(numRounds, 1);
    % load features
    load(featPath);
    trainPosIdx = find(groups == 0 & labels == eventID);
    trainNegIdx = find(groups == 0 & labels ~= eventID);
    ratio = 0.5;
    totalNeg = numel(trainNegIdx);
    sampledIdx = randsample(totalNeg, totalNeg * ratio);
    for r = 1:numRounds
        trainMat = feats([trainPosIdx;trainNegIdx(sampledIdx)], :);
        trainLabel = zeros(size(trainMat, 1), 1);
        trainLabel(1:size(trainPosIdx, 1)) = 1;
        model = train_svm(trainMat, trainLabel, eventID);
        [confs, ap] = eval_svm(model, feats(trainNegIdx, :), ones(size(trainNegIdx, 1), 1), eventID);
        modelWeights(r) = 1;
        models{r} = model;
        % update sampledIdx
        [~, sampledIdx] = sort(confs, 'descend');
        % sample hard negatives
        sampledIdx = sampledIdx(1:ratio*totalNeg, :);
    end
    % do testing
    testIdx = find(groups == 1);
    testMat = feats(testIdx, :);
    testLabel = labels(testIdx, :);
    testConfs = zeros(size(testLabel, 1), 1);
    for r = 1:numRounds
        [confs, ap] = eval_svm(models{r}, testMat, testLabel, eventID);
        testConfs = testConfs + confs * modelWeights(r);
        fprintf('eventID = %d, round = %d, AP = %f\n', eventID, r, ap);
    end
    testConfs = testConfs / numRounds;
    % save results
    resultPath = [saveDir '/result.' num2str(eventID)];
    save(resultPath, 'testConfs', '-ASCII');
    fprintf('eventID = %d, AP = %f\n', eventID, computeAP(testConfs, double(testLabel==eventID)));
    % save models
    modelPath = [saveDir '/model.' num2str(eventID)];
    save(modelPath, 'models', 'modelWeights', '-v7.3');
end

function model = train_svm(trainMat, labels, eventID)
    globals;
    featMat = sparse(trainMat);
    labels = double(labels == eventID);
    weight = length(labels) / sum(labels) - 1;
    model = train(labels, featMat, ['-q -s 1 -c ' num2str(cost) ' -B ' num2str(bias) ' -w1 ' num2str(weight)]);
end

function [confs, ap] = eval_svm(model, testMat, labels, eventID)
    globals;
    labels = double(labels == eventID);
    confs = zeros(size(labels, 1), 1);
    featMat = sparse(testMat);
    [predicted, acc, probs] = predict(labels, featMat, model, '-b 1 -q');
    if model.Label(1) > 0
        confs = probs(:, 1);
    else
        confs = probs(:, 2);
    end
    ap = computeAP(confs, labels);
end

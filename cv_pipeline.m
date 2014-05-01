function cv_pipeline(trainMat, eventID, saveDir, numFolds)
    resultPath = [saveDir '/result.' num2str(eventID)];
    allConfs = [];
    for i = 0:numFolds-1
        modelPath = [saveDir '/model.' num2str(eventID) '.' num2str(i)];
        train_svm(trainMat, eventID, modelPath, i);
        [confs, ap] = test_svm(trainMat, eventID, modelPath, i);
        if length(allConfs) < size(confs, 1)
            allConfs = confs;
        else
            allConfs = allConfs + confs;
        end
        fprintf('fold = %d, eventID = %d, AP = %f\n', i, eventID, ap);
    end
    save(resultPath, 'allConfs', '-ASCII');
end

function train_svm(trainMat, eventID, modelDir, groupID)
    globals;
    load(trainMat);
    % Cannot use other positives as negatives for this event
    indice = ((labels == eventID | labels < 1) & (groups ~= groupID));
    labels = double(labels == eventID);
    weight = length(labels)/sum(labels)-1;
    for i = 1:length(featTypes)
        modelPath = char(strcat(modelDir, '.', featTypes{i}, '.mat'));
        featMat = sparse(feats{i}(indice, :));
        trainLabels = labels(indice, :);
        model = train(trainLabels, featMat, ['-q -s 1 -c ' num2str(cost) ' -B ' num2str(bias) ' -w1 ' num2str(weight)]);
        save(modelPath, 'model');
    end
end

function [confs, ap] = test_svm(testMat, eventID, modelDir, groupID)
    globals;
    load(testMat);
    labels = double(labels == eventID);
    indice = (groups == groupID);
    confs = zeros(size(labels, 1), length(featTypes));
    for i = 1:length(featTypes)
        modelPath = char(strcat(modelDir, '.', featTypes{i}, '.mat'));
        load(modelPath);
        featMat = sparse(feats{i}(indice, :));
        testLabels = labels(indice, :);
        [predicted, acc, probs] = predict(testLabels, featMat, model, '-b 1 -q');
        if model.Label(1) > 0
            confs(indice, i) = probs(:, 1);
        else
            confs(indice, i) = probs(:, 2);
        end
    end
    confs = sum(confs, 2) / length(featTypes);
    ap = computeAP(confs(indice, :), labels(indice, :));
end

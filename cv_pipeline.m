function svm_pipeline(trainMat, eventID, saveDir, numFolds)
    modelPath = [saveDir '/model.' num2str(eventID)];
    resultPath = [saveDir '/result.' num2str(eventID)];
    for i = 0:numFolds-1
        train_svm(trainMat, eventID, modelPath, i);
        [confs, ap] = test_svm(testMat, eventID, modelPath, i);
        save(resultPath, 'confs', '-ASCII');
        fprintf('fold = %d, eventID = %d, AP = %f\n', i, eventID, ap);
    end
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
    confs = zeros(size(labels, 1), length(featTypes));
    indice = (groups == groupID);
    for i = 1:length(featTypes)
        modelPath = char(strcat(modelDir, '.', featTypes{i}, '.mat'));
        load(modelPath);
        featMat = sparse(feats{i}(indice, :));
        testLabels = labels(indice, :);
        [predicted, acc, probs] = predict(testLabels, featMat, model, '-b 1 -q');
        if model.Label(1) > 0
            confs(:, i) = probs(:, 1);
        else
            confs(:, i) = probs(:, 2);
        end
    end
    confs = sum(confs, 2) / length(featTypes);
    ap = computeAP(confs, labels);
end

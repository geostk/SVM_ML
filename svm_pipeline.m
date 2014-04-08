function svm_pipeline(trainMat, testMat, eventID, saveDir)
    modelPath = [saveDir '/model.' num2str(eventID)];
    resultPath = [saveDir '/result.' num2str(eventID)];
    tic;
    train_svm(trainMat, eventID, modelPath);
    toc;
    tic;
    [confs, ap] = test_svm(testMat, eventID, modelPath);
    toc;
    save(resultPath, 'confs', '-ASCII');
    fprintf('eventID = %d, AP = %f\n', eventID, ap);
end

function train_svm(trainMat, eventID, modelDir)
    globals;
    load(trainMat);
    % Cannot use other positives as negatives for this event
    indice = (labels == eventID | labels < 1);
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

function [confs, ap] = test_svm(testMat, eventID, modelDir)
    globals;
    load(testMat);
    labels = double(labels == eventID);
    confs = zeros(size(labels, 1), length(featTypes));
    for i = 1:length(featTypes)
        modelPath = char(strcat(modelDir, '.', featTypes{i}, '.mat'));
        load(modelPath);
        featMat = sparse(feats{i});
        [predicted, acc, probs] = predict(labels, featMat, model, '-b 1 -q');
        if model.Label(1) > 0
            confs(:, i) = probs(:, 1);
        else
            confs(:, i) = probs(:, 2);
        end
    end
    confs = sum(confs, 2) / length(featTypes);
    ap = computeAP(confs, labels);
end

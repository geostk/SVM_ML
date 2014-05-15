% event ID starts from 1 and ends by maxEventID
function action_mat_pipeline(trainMat, maxEventID, saveDir, runID)
    models = train_svm(trainMat, maxEventID);
    save_mat(models, saveDir, runID);
end

function models = train_svm(trainMat, maxEventID)
    globals;
    % let's load only once
    load(trainMat);
    models = cell(maxEventID, length(featTypes));
    for eventID = 1:maxEventID
        trainLabels = double(labels == eventID);
        weight = length(trainLabels)/sum(trainLabels)-1;
        for i = 1:length(featTypes)
            featMat = sparse(feats{i});
            models{eventID, i} = train(trainLabels, featMat, ['-q -s 1 -c ' num2str(cost) ' -B ' num2str(bias) ' -w1 ' num2str(weight)]);
        end
    end
end

function save_mat(models, saveDir, runID)
    globals;
    for mode = 1:size(models, 2)
        outputName = [saveDir runID '.model.' featTypes{mode} '.txt'];
        outputMat = zeros(size(models, 1), length(models{1, mode}.w));
        for eventID = 1:size(models, 1)
            outputMat(eventID, :) = models{eventID, mode}.w;
            outputMat(eventID, end) = outputMat(eventID, end) * bias;
            if models{eventID, mode}.Label(1) < 1
                outputMat(eventID, :) = -outputMat(eventID, :);
            end
        end
        save(outputName, 'outputMat', '-ascii');
    end
end

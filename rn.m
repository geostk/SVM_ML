function rn(trainMatPath, testMatPath, outTrainMatPath, outTestMatPath)
    globals;
    load(trainMatPath);
    projMats = cell(length(featTypes), 1);
    mVecs = cell(length(featTypes), 1);
    for i = 1:length(featTypes)
        mVec = mean(feats{i}, 1);
        feats{i} = feats{i} - repmat(mVec, size(feats{i}, 1), 1);
        projMat = princomp(feats{i});
        projMats{i} = projMat;
        mVecs{i} = mVec;
    end
    for k = 1:5
        projectedDim = 2000*k;
        load(trainMatPath);
        for i = 1:length(featTypes)
            feats{i} = feats{i} - repmat(mVecs{i}, size(feats{i}, 1), 1);
            feats{i} = feats{i}*projMats{i}(:, 1:projectedDim);
            feats{i} = pow_norm(feats{i});
        end
        save([outTrainMatPath int2str(projectedDim) '.mat'], 'labels', 'feats', '-v7.3');
        load(testMatPath);
        for i = 1:length(featTypes)
            feats{i} = feats{i} - repmat(mVecs{i}, size(feats{i}, 1), 1);
            feats{i} = feats{i}*projMats{i}(:, 1:projectedDim);
            feats{i} = pow_norm(feats{i});
        end
        save([outTestMatPath int2str(projectedDim) '.mat'], 'labels', 'feats', '-v7.3');
    end
end

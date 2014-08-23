function convert_mat_thumos(featList, outputFile)
    % Format:
    % # videos
    % # features (segment-level)
    % [label] [group] [feat_prefix] [id] [#segments]
    % group: 0 train, 1 val, 2 test
    fin = fopen(featList, 'r');
    if fin < 0
        fprintf('Cannot open %s\n', featList);
    end
    globals;
    
    numFiles = fscanf(fin, '%d', 1);
    numSamples = fscanf(fin, '%d', 1);
    labels = zeros(numSamples, 1);
    feats = zeros(numSamples, sum(featDims));
    groups = zeros(numSamples, 1);
    vids = zeros(numSamples, 1);
    currentLine = 1; 
    for n = 1:numFiles
        label = fscanf(fin, '%d', 1);
        group = fscanf(fin, '%d', 1);
        path = fscanf(fin, '%s', 1);
        vid = fscanf(fin, '%d', 1);
        num_segs = fscanf(fin, '%d', 1);
        endLine = currentLine + num_segs - 1;
        labels(currentLine:endLine) = label;
        groups(currentLine:endLine) = group;
        vids(currentLine:endLine) = vid;
        startInd = 1;
        for i = 1:length(featTypes)
            featName = char(strcat(path, '.', featTypes{i}, '.fv.seq'));
            endInd = startInd + featDims(i) - 1;
			try
                feat = dlmread(featName);
                if sum(sum(isnan(feat))) < 1 && numel(feat) == featDims(i) * num_segs
                    feats(currentLine:endLine,startInd:endInd) = feat;
                end
			catch err
				% do nothing
            end
            startInd = endInd + 1;
        end
        currentLine = endLine + 1;
    end
    fclose(fin);
    
    save(outputFile, 'labels', 'feats', 'groups', 'vids', '-v7.3');
end


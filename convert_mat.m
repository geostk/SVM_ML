function convert_mat(featList, outputFile, ext)
	if nargin < 3
		ext = 'fv';
	end
    fin = fopen(featList, 'r');
    if fin < 0
        fprintf('Cannot open %s\n', featList);
    end
    globals;
    
    numSamples = fscanf(fin, '%d', 1);
    labels = zeros(numSamples, 1);
    feats = cell(length(featTypes), 1);
    for i = 1:length(feats)
        feats{i} = zeros(numSamples, featDims(i));
    end
    for n = 1:numSamples
        label = fscanf(fin, '%d', 1);
        path = fscanf(fin, '%s', 1);
        labels(n) = label;
        for i = 1:length(featTypes)
            featName = char(strcat(path, '.', featTypes{i}, '.', ext, '.txt'));
			try
                feat = dlmread(featName);
                if sum(sum(isnan(feat))) < 1 && numel(feat) == size(feats{i}, 2)
                    feats{i}(n,:) = feat;
                end
			catch err
				% do nothing
            end
        end
        
    end
    fclose(fin);
    
    save(outputFile, 'labels', 'feats', '-v7.3');
end


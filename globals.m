% Set up global variables

% types of features
featTypes = cell(4,1);
featTypes{1} = 'hog';
featTypes{2} = 'hof';
featTypes{3} = 'mbhx';
featTypes{4} = 'mbhy';

numClusters = 128;
featDims = zeros(4,1);
featDims(1) = numClusters*2*48;
featDims(2) = numClusters*2*54;
featDims(3) = numClusters*2*48;
featDims(4) = numClusters*2*48;

% svm parameters
cost = 1.0;
bias = 10.0;

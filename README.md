# SVM Pipeline in MATLAB

## Dependencies
- MATLAB (Tested in version 2013a)
- [LIBLINEAR](http://www.csie.ntu.edu.tw/~cjlin/liblinear/) (version 1.94)

## Quick start
- Compile LIBLINEAR MATLAB wrapper
    1. Download [LIBLINEAR code](http://www.csie.ntu.edu.tw/~cjlin/cgi-bin/liblinear.cgi?+http://www.csie.ntu.edu.tw/~cjlin/liblinear+tar.gz)
    1. Follow the [FAQ](http://www.csie.ntu.edu.tw/~cjlin/liblinear/FAQ.html) and update linear.cpp file, change
    ```C
    int check_probability_model(const struct model *model_)
    {
        return (model_->param.solver_type==L2R_LR ||
    ```
    into
    ```C
    int check_probability_model(const struct model *model_)
    {
        return 1;
    ```
    This will allow probabilistic output for Linear SVM model.
    1. Specify MATLABDIR in `matlab/Makefile`, then `make` to compile `.mex` files. They will be used during training and testing.

- Convert DTFV ASCII files into `.mat` binary files
    1. Prepare the feature list of DTFVs in the following format:
    ```
    [number of features listed]
    [groundtruth label] [truncated path to the features]
    ...
    [groundtruth label] [truncated path to the features]
    ```
    If you have DTFV features for `HVC123456.mp4` stored in `/temp/HVC123456.mp4.hog.fv.txt`, `/temp/HVC123456.mp4.hof.fv.txt`, etc. The truncated path is just `/temp/HVC123456.mp4` (i.e. excluding mode type and `fv.txt`)
    1. Call 
    ```MATLAB
    function convert_mat(featList, outputFile)
    ```
    featList is what you created in the previous step, outputFile is something like '/temp/train.mat'.

- Training and testing with linear SVM
    1. Prepare training and testing `.mat` binary files
    1. Call
    ```MATLAB
    function svm_pipeline(trainMat, testMat, eventID, saveDir)
    ```
    trainMat and testMat are the paths to the .mat files. eventID is an integer identifier for event classes. saveDir is the path to store models and result files.  
    You can do training and testing separately by commenting out 
    ```MATLAB
    train_svm(trainMat, eventID, modelPath);
    ```
    or 
    ```MATLAB
    [confs, ap] = test_svm(testMat, eventID, modelPath);
    ```
    in this function.

- Understanding the output formats
    1. After training, a model `model.[eventID].[modeType].mat` is stored in binary format
    1. After testing, a result file `result.[eventID]` is stored in ASCII. The i-th line gives the event confidence value (from 0 to 1) of the i-th item in testing list.

## Contact
chensun@usc.edu

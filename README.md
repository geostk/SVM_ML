# SVM Pipeline in MATLAB

## Dependencies
- MATLAB (Tested in version 2013a)
- [LIBLINEAR](http://www.csie.ntu.edu.tw/~cjlin/liblinear/) (version 1.94)

## Quick start
- Compile LIBLINEAR MATLAB wrapper
    * Download [LIBLINEAR code](http://www.csie.ntu.edu.tw/~cjlin/cgi-bin/liblinear.cgi?+http://www.csie.ntu.edu.tw/~cjlin/liblinear+tar.gz)
    * Follow the [FAQ](http://www.csie.ntu.edu.tw/~cjlin/liblinear/FAQ.html) and update linear.cpp file:
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
    * Specify MATLAB path in matlab

## Contact
chensun@usc.edu

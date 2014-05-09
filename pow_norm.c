#include "mex.h"
#include <math.h>

void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])   {
    if (nrhs != 1)
        mexErrMsgTxt("Invalid number of input arguments.");
    if (nlhs != 1)
        mexErrMsgTxt("Invalid number of output arguments.");


    int d = mxGetN(prhs[0]);        /* feature dimension */
    int n = mxGetM(prhs[0]);        /* number of samples */
    
    plhs[0] = mxCreateNumericMatrix (n, d, mxDOUBLE_CLASS, mxREAL);
    
    double *before = (double *) mxGetPr(prhs[0]);     /* column major */
    double *after = (double *) mxGetPr(plhs[0]);      /* column major */

    int i, j;
    double l2_sum, sign;
    for (i = 0; i < n; i++) {
        l2_sum = 0.0;
        for (j = 0; j < d; j++) {
            sign = 1;
            if (before[j*n+i] < 0)
                sign = -1;
            after[j*n+i] = sign * sqrt(sign*before[j*n+i]);
            l2_sum += before[j*n+i] * sign;
        }
        if (l2_sum < 1e-10)
            continue;
        l2_sum = sqrt(l2_sum);
        for (j = 0; j < d; j++) {
            after[j*n+i] /= l2_sum;
        }
    }
};

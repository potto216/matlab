// mucro wrapper program
// Ultrasonix Medical Corporation (2011)
//
// description:     filters B scan ultrasound data using a special enhancement filter
// program type:    console
// inputs:          command line arguments, queried information
// outputs:         image file (optional)

// header files
#include "common.hpp"
#include <mucro.h>
#include <string>

//#define _DEBUG

#define X 1
#define Y 0
#define NUM_ARGS 2
static mucro gFilter;
static int gDimIn[2];

static unsigned char* gImgDataIn = NULL;
static unsigned char* gImgDataOut = NULL;

extern "C" static void AtExit(void)
{
	if(gImgDataIn != NULL)
	{
		FreePersistent(gImgDataIn);
		gImgDataIn = NULL;
	}

	if(gImgDataOut != NULL)
	{
		FreePersistent(gImgDataOut);
		gImgDataOut = NULL;
	}

}
// program entry point
extern "C" void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
#ifdef _DEBUG
    mexPrintf("---------- %s ------------\n",mexFunctionName());
#endif
	const mwSize* iDimIn;
	int iNumDims;
	double* iInDataPtr;
	unsigned char* iOutDataPtr;
	int filtType;
    FilterParams filtParams;
	//default to Medium if argument is not set
	filtParams.asrContrast = 20;
    filtParams.asrLineStrength = 16;
	filtParams.asrLPCut = 10;
	filtParams.asrSmooth = 13;
	filtParams.asrWeight = 8;


    // there must be at least two arguments
	if(nrhs < NUM_ARGS)
	{
		mexErrMsgTxt("Wrong number of input arguments");
    }

	iInDataPtr = mxGetPr(prhs[0]);
	iNumDims = mxGetNumberOfDimensions(prhs[0]);
	iDimIn = mxGetDimensions(prhs[0]);

	if(iNumDims != 2)
	{
		mexErrMsgTxt("Input matrix must have ndims = 2");
	}

	mexAtExit(AtExit);

	if(iDimIn[X] != gDimIn[X] || iDimIn[Y] != gDimIn[Y])
	{
#ifdef _DEBUG
        mexPrintf("Reallocating, Dims = %d, %d\n", gDimIn[X],gDimIn[Y]);
#endif
		if(gImgDataIn != NULL)
		{
			FreePersistent(gImgDataIn);
			gImgDataIn = NULL;
		}

		gDimIn[X] = iDimIn[X];
		gDimIn[Y] = iDimIn[Y];

		gImgDataIn = (unsigned char*)MallocPersistent(gDimIn[X]*gDimIn[Y]*sizeof(unsigned char));

		if(gImgDataOut != NULL)
		{
			FreePersistent(gImgDataOut);
			gImgDataOut = NULL;
		}

		gImgDataOut = (unsigned char*)MallocPersistent(gDimIn[X]*gDimIn[Y]*sizeof(unsigned char));
	}
	
        for(int k=0;k<gDimIn[X]*gDimIn[Y];k++)
        {
			gImgDataIn[k] = 0;
            gImgDataOut[k] = 0;
        }
#ifdef _DEBUG
        mexPrintf("Img IN width : %d\n", gDimIn[X]);
		mexPrintf("Img IN height : %d\n", gDimIn[Y]);
#endif

        switch(mxGetClassID(prhs[0]))
        {
            case mxDOUBLE_CLASS:
                CopyData(gImgDataIn,iInDataPtr,gDimIn[X]*gDimIn[Y]);
                break;
            case mxUINT8_CLASS:
                CopyData(gImgDataIn,(unsigned char*)iInDataPtr,gDimIn[X]*gDimIn[Y]);
                break;
            default:
                mexErrMsgTxt("Data input class not supported. Must be either DOUBLE or UINT8.");
        }

	if (nrhs > 1)
    {
		GetScalar(prhs[1],filtType);
		switch (filtType)
		{
			case 3:		// Clarity Max
			{
				filtParams.asrContrast = 20;
				filtParams.asrLineStrength = 21;
				filtParams.asrLPCut = 10;
				filtParams.asrSmooth = 25;
				filtParams.asrWeight = 6;
#ifdef _DEBUG
				mexPrintf("ClarityMax Setting\n");
#endif
			}
			break;
			case 2:		// Clarity High
			{
				filtParams.asrContrast = 20;
				filtParams.asrLineStrength = 25;
				filtParams.asrLPCut = 10;
				filtParams.asrSmooth = 30;
				filtParams.asrWeight = 6;
#ifdef _DEBUG
				mexPrintf("ClarityHigh Setting\n");
#endif
			}
			break;
			case 1:		// Clarity Medium
			{
				filtParams.asrContrast = 20;
				filtParams.asrLineStrength = 16;
				filtParams.asrLPCut = 10;
				filtParams.asrSmooth = 13;
				filtParams.asrWeight = 8;
#ifdef _DEBUG
				mexPrintf("ClarityMedium Setting\n");
#endif
			}
			break;
			case 0:			// Clarity Low
			{
				filtParams.asrContrast = 20;
				filtParams.asrLineStrength = 16;
				filtParams.asrLPCut = 10;
				filtParams.asrSmooth = 20;
				filtParams.asrWeight = 11;
#ifdef _DEBUG
				mexPrintf("ClarityLow Setting\n");
#endif
			}
			break;
			default:
				mexErrMsgTxt("Unsupported filter setting");
			break;
		}
	}

//     apply the filter

        if (!gFilter.apply(gImgDataIn, gImgDataOut, gDimIn[Y], gDimIn[X],  filtParams))
        {
            mexErrMsgTxt("Error in filtering");
        }

	// Allocate output matrix and transfer data
	if(nlhs >= 1)
	{
        plhs[0] = mxCreateNumericMatrix(gDimIn[Y],gDimIn[X],mxUINT8_CLASS,mxREAL);
		iOutDataPtr = (unsigned char*)mxGetPr(plhs[0]);

        for(int h=0;h<gDimIn[Y];h++)
        {
            for(int w=0;w<gDimIn[X];w++)
            {
                int ii = w*gDimIn[Y] + h;
                iOutDataPtr[ii] = gImgDataOut[ii];
            }
        }
	}
}


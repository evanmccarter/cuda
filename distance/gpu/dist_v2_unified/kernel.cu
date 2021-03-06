#include <stdio.h>    // for printf

#define N 64          // constant, threads per block
#define TPB 32        // constant, threads per block

// converts int to evenly spaced floats 
// ie) .1, .2, ..., .5, ..., .9
float scale(int i, int n)
{
    return ((float) i) / (n - 1);
}

// Computes distance between 2 points on a line
__device__ 
float distance(float x1, float x2)
{
    return sqrt((x2 - x1) * (x2 - x1));
}


__global__ 
void distanceKernel(float *d_out, float *d_in, float ref)    
{
    const int i = blockIdx.x * blockDim.x + threadIdx.x;
    const float x = d_in[i];
    d_out[i] = distance(x, ref);
    printf("i = %2d: dist from %f to %f is %f.\n", i, ref, x, d_out[i]);
}

// Auto run main method 
int main()
{

    float ref = 0.5f;

    // declare pointers to device arrays
    float *in = 0;
    float *out = 0;

    // allocate device memory to device arrays
    cudaMallocManaged(&in, N * sizeof(float));
    cudaMallocManaged(&out, N * sizeof(float));

    // launch kernel to copute and store distance values
    for(int i = 0; i < N; i++)
    {
        in[i] = scale(i, N);
    }

    // launch kernel to compute and store distance vals
    distanceKernel<<<N/TPB, TPB>>>(out, in, ref);
    cudaDeviceSynchronize();
    
    // free memory for device arrays
    cudaFree(in);
    cudaFree(out);

    return 0;

}

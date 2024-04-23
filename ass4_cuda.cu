// Program 1
#include <iostream>
#include <vector>
#include <omp.h>
#include <climits>

using namespace std;

void min_reduction(vector<int> &arr)
{
    int min_value = INT_MAX;
#pragma omp parallel for reduction(min : min_value)
    for (int i = 0; i < arr.size(); i++)
    {
        if (arr[i] < min_value)
        {
            min_value = arr[i];
        }
    }
    cout << "Minimum value: " << min_value << endl;
}

void max_reduction(vector<int> &arr)
{
    int max_value = INT_MIN;
#pragma omp parallel for reduction(max : max_value)
    for (int i = 0; i < arr.size(); i++)
    {
        if (arr[i] > max_value)
        {
            max_value = arr[i];
        }
    }
    cout << "Maximum value: " << max_value << endl;
}

void sum_reduction(vector<int> &arr)
{
    int sum = 0;
#pragma omp parallel for reduction(+ : sum)
    for (int i = 0; i < arr.size(); i++)
    {
        sum += arr[i];
    }
    cout << "Sum: " << sum << endl;
}

void average_reduction(vector<int> &arr)
{
    int sum = 0;
#pragma omp parallel for reduction(+ : sum)
    for (int i = 0; i < arr.size(); i++)
    {
        sum += arr[i];
    }
    cout << "Average: " << (double)sum / arr.size() << endl;
}

int main()
{
    vector<int> arr = {5, 2, 9, 1, 7, 6, 8, 3, 4};

    min_reduction(arr);
    max_reduction(arr);
    sum_reduction(arr);
    average_reduction(arr);
}

// Program2

#include <iostream>
#include <cuda_runtime.h>

using namespace std;

__global__ void matmul(int *A, int *B, int *C, int N)
{
    int Row = blockIdx.y * blockDim.y + threadIdx.y;
    int Col = blockIdx.x * blockDim.x + threadIdx.x;
    if (Row < N && Col < N)
    {
        int Pvalue = 0;
        for (int k = 0; k < N; k++)
        {
            Pvalue += A[Row * N + k] * B[k * N + Col];
        }
        C[Row * N + Col] = Pvalue;
    }
}

int main()
{
    int N = 512;
    int size = N * N * sizeof(int);
    int *A, *B, *C;
    int *dev_A, *dev_B, *dev_C;
    cudaMallocHost(&A, size);
    cudaMallocHost(&B, size);
    cudaMallocHost(&C, size);
    cudaMalloc(&dev_A, size);
    cudaMalloc(&dev_B, size);
    cudaMalloc(&dev_C, size);

    for (int i = 0; i < N; i++)
    {
        for (int j = 0; j < N; j++)
        {
            A[i * N + j] = i * N + j;
            B[i * N + j] = j * N + i;
        }
    }

    cudaMemcpy(dev_A, A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(dev_B, B, size, cudaMemcpyHostToDevice);

    dim3 dimBlock(16, 16);
    dim3 dimGrid(N / dimBlock.x, N / dimBlock.y);

    matmul<<<dimGrid, dimBlock>>>(dev_A, dev_B, dev_C, N);

    cudaMemcpy(C, dev_C, size, cudaMemcpyDeviceToHost);

    for (int i = 0; i < 10; i++)
    {
        for (int j = 0; j < 10; j++)
        {
            cout << C[i * N + j] << " ";
        }
        cout << endl;
    }

    cudaFree(dev_A);
    cudaFree(dev_B);
    cudaFree(dev_C);
    cudaFreeHost(A);
    cudaFreeHost(B);
    cudaFreeHost(C);

    return 0;
}


/*

Output:
Program 1 (Reduction Operations):
        Minimum value: 1
        Maximum value: 9
        Sum: 45
        Average: 5

Program 2 (Matrix Multiplication Using CUDA) :
        0 1 2 3 4 5 6 7 8 9 
        1 2 3 4 5 6 7 8 9 10 
        2 3 4 5 6 7 8 9 10 11 
        3 4 5 6 7 8 9 10 11 12 
        4 5 6 7 8 9 10 11 12 13 
        5 6 7 8 9 10 11 12 13 14 
        6 7 8 9 10 11 12 13 14 15 
        7 8 9 10 11 12 13 14 15 16 
        8 9 10 11 12 13 14 15 16 17 
        9 10 11 12 13 14 15 16 17 18 
*/
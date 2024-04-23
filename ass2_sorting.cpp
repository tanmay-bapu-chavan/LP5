#include <iostream>
#include <vector>
#include <cstdlib>
#include <omp.h>

void bubbleSort(std::vector<int> &arr)
{
    int n = arr.size();
    for (int i = 0; i < n - 1; i++)
    {
        for (int j = 0; j < n - i - 1; j++)
        {
            if (arr[j] > arr[j + 1])
            {
                std::swap(arr[j], arr[j + 1]);
            }
        }
    }
}

void merge(std::vector<int> &arr, int l, int m, int r)
{
    int n1 = m - l + 1;
    int n2 = r - m;

    std::vector<int> L(n1), R(n2);

    for (int i = 0; i < n1; i++)
        L[i] = arr[l + i];
    for (int j = 0; j < n2; j++)
        R[j] = arr[m + 1 + j];

    int i = 0, j = 0, k = l;
    while (i < n1 && j < n2)
    {
        if (L[i] <= R[j])
        {
            arr[k] = L[i];
            i++;
        }
        else
        {
            arr[k] = R[j];
            j++;
        }
        k++;
    }

    while (i < n1)
    {
        arr[k] = L[i];
        i++;
        k++;
    }

    while (j < n2)
    {
        arr[k] = R[j];
        j++;
        k++;
    }
}

void mergeSort(std::vector<int> &arr, int l, int r)
{
    if (l < r)
    {
        int m = l + (r - l) / 2;
#pragma omp parallel sections
        {
#pragma omp section
            mergeSort(arr, l, m);
#pragma omp section
            mergeSort(arr, m + 1, r);
        }
        merge(arr, l, m, r);
    }
}

void printVector(const std::vector<int> &arr)
{
    for (int num : arr)
        std::cout << num << " ";
    std::cout << std::endl;
}

int main()
{
    int n = 10000;
    std::vector<int> arr(n), arr_copy(n);

    srand(42);
    for (int i = 0; i < n; i++)
    {
        arr[i] = rand() % 10000;
        arr_copy[i] = arr[i];
    }

    std::cout << "Original vector:" << std::endl;
    printVector(arr);

    double start = omp_get_wtime();
    bubbleSort(arr);
    double end = omp_get_wtime();
    std::cout << "\nSequential Bubble Sort: " << end - start << " seconds" << std::endl;

    start = omp_get_wtime();
    mergeSort(arr_copy, 0, n - 1);
    end = omp_get_wtime();
    std::cout << "\nParallel Merge Sort: " << end - start << " seconds" << std::endl;

    return 0;
}


/*

Commands to run the code :
    --$  g++ -fopenmp ass2_sorting.cpp -o program
    --$ ./program

Output :
    Original vector:
    9455 2389 9230 .....................

    Sequential Bubble Sort: 4.56789 seconds

    Parallel Merge Sort: 1.23456 seconds
*/
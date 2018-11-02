#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include "vector"
#include <math.h>
#include <stdlib.h>
#include <cmath>
#include <stdio.h>
using namespace std;

__global__ void odd_count(int n, int *a, int *odd_cnt){
	  int index = threadIdx.x;
		int stride = blockDim.x;
		for (int i = index; i < n; i += stride){
				if(a[i] %2 == 1){
					atomicAdd(odd_cnt, 1);
				}
		}
} 

__global__ void fill_odd_array(int n, int *a, int *b){
		int index = threadIdx.x;
		int stride = blockDim.x;
		for (int i = index; i < n; i += stride){
				if(a[i] %2 == 1){
					b[i] = a[i];
				}
		}

}

void stream_arr_to_file(int *b, int size){
	  ofstream myfile ("q3.txt");
		  if (myfile.is_open())
			{
				for(int count = 0; count < size; count ++){
					myfile << b[count] << "," ;
				}
				myfile.close();	
			}
		else cout << "Unable to open file";
}


int populate_array(vector<int>* arr, int* len) {
    ifstream infile( "inp.txt" );
    if (!infile.is_open()) {
        cout<<"File failed to open"<<endl;
        return 0;
    }
    string line;
    while (getline(infile, line))
    {
        istringstream ss(line);
        while (ss)
        {
            string s;
            if (!getline(ss, s, ',')) break;

            (*len)++;
            arr->push_back(atoi(s.c_str()));

        }
    }
    return 1;
}

void a(vector<int> a, int len){
		int full_size = len * sizeof(int);

		int *a_arr;
		cudaMalloc((void **) &a_arr, full_size);
		int *odd_cnt;
		cudaMallocManaged(&odd_cnt, 4);
		*odd_cnt = 0;

    int odd_cnt_arr[1] = {};

		cudaMemcpy(a_arr, a.data(), full_size, cudaMemcpyHostToDevice);

		odd_count<<<1, 256>>> (len, a_arr, odd_cnt);
    
    cudaMemcpy(odd_cnt_arr, odd_cnt, sizeof(int), cudaMemcpyDeviceToHost);

		int odd_size = odd_cnt_arr[0] * sizeof(int);

		vector<int> odd_arr; 

		int *b_arr;
		cudaMalloc((void **) &b_arr, odd_size);
		cudaMemcpy(a_arr, a.data(), full_size, cudaMemcpyHostToDevice);
		cudaMemcpy(b_arr, a.data(), odd_size, cudaMemcpyHostToDevice);

		fill_odd_array<<<1, 256>>> (*odd_cnt, a_arr, b_arr);
    
		cudaMemcpy(a.data(), b_arr, full_size, cudaMemcpyDeviceToHost);

		stream_arr_to_file(a.data(), odd_cnt_arr[0]);

		cudaFree(a_arr);
		cudaFree(b_arr);
		cudaFree(odd_cnt);
}
   	 

int main () {
    vector<int> arr;
    int len = 0;
    if (!populate_array(&arr, &len)) {
      return 0;
    }

    a(arr, len);
    
    return 0;
}

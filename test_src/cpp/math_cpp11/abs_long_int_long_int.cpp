
#include <cmath>

#include <limits>
#include <iostream>
#include <stdexcept>

using namespace std;

 
bool almost_equal(long int x, long int y, int ulp) {

}


void test_abs(){
   
   long int in0 {  1 };
   

   
   long int out1_host ;
   long int out1_gpu ;
   

   out1_host = abs( in0, &out1_host);

   #pragma omp target map(from: out1_gpu )
   {
   out1_gpu = abs( in0, &out1_gpu);
   }

   
   if ( !almost_equal(out1_host,out1_gpu,1) ) {
        std::cerr << "Host: " << out1_host << " GPU: " << out1_gpu << std::endl;
        throw std::runtime_error( "abs give incorect value when offloaded");
    }
    
}

int main()
{
    test_abs();
}

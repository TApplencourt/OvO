
#include <cmath>

#include <limits>
#include <iostream>

using namespace std;

 
bool almost_equal(long int x, long int y, int ulp) {

    return x == y ; 

}


void test_lrintf(){
   
   float in0 {  0.42 };
   

   
   long int out1_host;
   long int out1_device;
   

   out1_host = lrintf( in0);

   #pragma omp target map(from: out1_device )
   {
   out1_device = lrintf( in0);
   }

   
   if ( !almost_equal(out1_host,out1_device,1) ) {
        std::cerr << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        throw std::runtime_error( "lrintf give incorect value when offloaded");
    }
    
}

int main()
{
    test_lrintf();
}

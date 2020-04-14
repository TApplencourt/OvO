
#include <cmath>

#include <limits>
#include <iostream>
#include <stdexcept>

using namespace std;

 
bool almost_equal(float x, float y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();

}


void test_atanf(){
   
   float in0 {  0.42 };
   

   
   float out1_host ;
   float out1_gpu ;
   

   out1_host = atanf( in0, &out1_host);

   #pragma omp target map(from: out1_gpu )
   {
   out1_gpu = atanf( in0, &out1_gpu);
   }

   
   if ( !almost_equal(out1_host,out1_gpu,1) ) {
        std::cerr << "Host: " << out1_host << " GPU: " << out1_gpu << std::endl;
        throw std::runtime_error( "atanf give incorect value when offloaded");
    }
    
}

int main()
{
    test_atanf();
}

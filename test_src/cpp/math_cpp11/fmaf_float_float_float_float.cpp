
#include <cmath>

#include <limits>
#include <iostream>
#include <stdexcept>

using namespace std;

 
bool almost_equal(float x, float y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();

}


void test_fmaf(){
   
   float in0 {  0.42 };
   
   float in1 {  0.42 };
   
   float in2 {  0.42 };
   

   
   float out3_host ;
   float out3_gpu ;
   

   out3_host = fmaf( in0, in1, in2, &out3_host);

   #pragma omp target map(from: out3_gpu )
   {
   out3_gpu = fmaf( in0, in1, in2, &out3_gpu);
   }

   
   if ( !almost_equal(out3_host,out3_gpu,1) ) {
        std::cerr << "Host: " << out3_host << " GPU: " << out3_gpu << std::endl;
        throw std::runtime_error( "fmaf give incorect value when offloaded");
    }
    
}

int main()
{
    test_fmaf();
}

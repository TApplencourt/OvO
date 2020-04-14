
#include <cmath>

#include <limits>
#include <iostream>
#include <stdexcept>

using namespace std;

 
bool almost_equal(long double x, long double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<long double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<long double>::min();

}


void test_ellint_3l(){
   
   long double in0 {  0.42 };
   
   long double in1 {  0.42 };
   
   long double in2 {  0.42 };
   

   
   long double out3_host ;
   long double out3_gpu ;
   

   out3_host = ellint_3l( in0, in1, in2, &out3_host);

   #pragma omp target map(from: out3_gpu )
   {
   out3_gpu = ellint_3l( in0, in1, in2, &out3_gpu);
   }

   
   if ( !almost_equal(out3_host,out3_gpu,1) ) {
        std::cerr << "Host: " << out3_host << " GPU: " << out3_gpu << std::endl;
        throw std::runtime_error( "ellint_3l give incorect value when offloaded");
    }
    
}

int main()
{
    test_ellint_3l();
}

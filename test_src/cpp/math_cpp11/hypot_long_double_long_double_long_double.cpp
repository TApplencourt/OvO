
#include <cmath>

#include <limits>
#include <iostream>
#include <stdexcept>

using namespace std;

 
bool almost_equal(long double x, long double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<long double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<long double>::min();

}


void test_hypot(){
   
   long double in0 {  0.42 };
   
   long double in1 {  0.42 };
   

   
   long double out2_host ;
   long double out2_gpu ;
   

   out2_host = hypot( in0, in1, &out2_host);

   #pragma omp target map(from: out2_gpu )
   {
   out2_gpu = hypot( in0, in1, &out2_gpu);
   }

   
   if ( !almost_equal(out2_host,out2_gpu,1) ) {
        std::cerr << "Host: " << out2_host << " GPU: " << out2_gpu << std::endl;
        throw std::runtime_error( "hypot give incorect value when offloaded");
    }
    
}

int main()
{
    test_hypot();
}

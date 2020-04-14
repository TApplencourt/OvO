
#include <cmath>

#include <limits>
#include <iostream>
#include <stdexcept>

using namespace std;

 
bool almost_equal(double x, double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();

}


void test_abs(){
   
   double in0 {  0.42 };
   

   
   double out1_host ;
   double out1_gpu ;
   

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

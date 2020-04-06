
#include <cmath>


#include <limits>
#include <iostream>
#include <stdexcept>

using namespace std;

bool almost_equal(double x, double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();

}

void test_ellint_1(){
   
   double k {  0.42 };
   
   double phi {  0.42 };
   

   double o_host = ellint_1( k, phi);

   double o_gpu ; 
   #pragma omp target map(from:o_gpu)
   {
   o_gpu = ellint_1( k, phi);
   }

   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "ellint_1 give incorect value when offloaded");
    }
}

int main()
{
    test_ellint_1();
}

#include <cassert>
#include <complex>
#include <cmath>
#include <limits>
#include <iomanip>
#include <iostream>
#include <type_traits>
#include <algorithm>
#include <stdexcept>

using namespace std;
using namespace std::complex_literals;

bool almost_equal(double x, double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();

}

void test_comp_ellint_1(){
   
   double k {  0.42 };
   

   double o_host = comp_ellint_1( k);

   double o_gpu ; 
   #pragma omp target defaultmap(tofrom:scalar)
   {
   o_gpu = comp_ellint_1( k);
   }

   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "comp_ellint_1 give incorect value when offloaded");
    }
}

int main()
{
    test_comp_ellint_1();
}

#include <cassert>
#include <complex>
#include <cmath>
#include <limits>
#include <iomanip>
#include <iostream>
#include <type_traits>
#include <algorithm>
#include <stdexcept>
#
// Some function, like "assoc_laguerre" need to be called with "std::" 
using namespace std;

bool almost_equal(long double x, long double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<long double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<long double>::min();

}

void test_cyl_bessel_kl(){
   
   long double nu = long double  {  0.42 };
   
   long double x = long double  {  0.42 };
   

   long double o_host = cyl_bessel_kl( nu, x);

   long double o_gpu ; 
   #pragma omp target defaultmap(tofrom:scalar)
   {
   o_gpu = cyl_bessel_kl( nu, x);
   }

   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "cyl_bessel_kl give incorect value when offloaded");
    }
}

int main()
{
    test_cyl_bessel_kl();
}

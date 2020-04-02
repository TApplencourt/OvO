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

bool almost_equal(long double x, long double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<long double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<long double>::min();

}

void test_scalblnl(){
   
   long double x {  0.42 };
   
   long int n {  1 };
   

   long double o_host = scalblnl( x, n);

   long double o_gpu ; 
   #pragma omp target defaultmap(tofrom:scalar)
   {
   o_gpu = scalblnl( x, n);
   }

   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "scalblnl give incorect value when offloaded");
    }
}

int main()
{
    test_scalblnl();
}

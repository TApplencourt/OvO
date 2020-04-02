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

bool almost_equal(float x, float y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();

}

void test_asinhf(){
   
   float x {  0.42 };
   

   float o_host = asinhf( x);

   float o_gpu ; 
   #pragma omp target defaultmap(tofrom:scalar)
   {
   o_gpu = asinhf( x);
   }

   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "asinhf give incorect value when offloaded");
    }
}

int main()
{
    test_asinhf();
}

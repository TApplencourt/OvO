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

bool almost_equal(float x, float y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();

}

void test_scalbn(){
   
   float x = float  {  0.42 };
   
   int n = int  {  1 };
   

   float o_host = scalbn( x, n);

   float o_gpu ; 
   #pragma omp target defaultmap(tofrom:scalar)
   {
   o_gpu = scalbn( x, n);
   }

   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "scalbn give incorect value when offloaded");
    }
}

int main()
{
    test_scalbn();
}

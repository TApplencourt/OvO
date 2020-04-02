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

bool almost_equal(int x, int y, int ulp) {

    return x == y

}

void test_fpclassify(){
   
   float x = float  {  0.42 };
   

   int o_host = fpclassify( x);

   int o_gpu ; 
   #pragma omp target defaultmap(tofrom:scalar)
   {
   o_gpu = fpclassify( x);
   }

   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "fpclassify give incorect value when offloaded");
    }
}

int main()
{
    test_fpclassify();
}

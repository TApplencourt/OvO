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

bool almost_equal(bool x, bool y, int ulp) {

}

void test_isgreaterequal(){
   
   long double x = long double  {  0.42 };
   
   long double y = long double  {  0.42 };
   

   bool o_host = isgreaterequal( x, y);

   bool o_gpu ; 
   #pragma omp target defaultmap(tofrom:scalar)
   {
   o_gpu = isgreaterequal( x, y);
   }

   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "isgreaterequal give incorect value when offloaded");
    }
}

int main()
{
    test_isgreaterequal();
}

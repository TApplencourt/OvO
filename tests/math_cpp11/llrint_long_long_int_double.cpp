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

bool almost_equal(long long int x, long long int y, int ulp) {

    return x == y ; 

}

void test_llrint(){
   
   double x {  0.42 };
   

   long long int o_host = llrint( x);

   long long int o_gpu ; 
   #pragma omp target defaultmap(tofrom:scalar)
   {
   o_gpu = llrint( x);
   }

   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "llrint give incorect value when offloaded");
    }
}

int main()
{
    test_llrint();
}

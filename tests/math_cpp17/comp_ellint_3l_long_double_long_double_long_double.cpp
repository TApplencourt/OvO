
#include <cmath>


#include <limits>
#include <iostream>
#include <stdexcept>

using namespace std;

bool almost_equal(long double x, long double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<long double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<long double>::min();

}

void test_comp_ellint_3l(){
   
   long double k {  0.42 };
   
   long double nu {  0.42 };
   

   long double o_host = comp_ellint_3l( k, nu);

   long double o_gpu ; 
   #pragma omp target defaultmap(tofrom:scalar)
   {
   o_gpu = comp_ellint_3l( k, nu);
   }

   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "comp_ellint_3l give incorect value when offloaded");
    }
}

int main()
{
    test_comp_ellint_3l();
}

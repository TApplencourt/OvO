
#include <cmath>


#include <limits>
#include <iostream>
#include <stdexcept>

using namespace std;

bool almost_equal(double x, double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();

}

void test_sph_legendre(){
   
   unsigned l {  1 };
   
   unsigned m {  1 };
   
   double theta {  0.42 };
   

   double o_host = sph_legendre( l, m, theta);

   double o_gpu ; 
   #pragma omp target defaultmap(tofrom:scalar)
   {
   o_gpu = sph_legendre( l, m, theta);
   }

   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "sph_legendre give incorect value when offloaded");
    }
}

int main()
{
    test_sph_legendre();
}

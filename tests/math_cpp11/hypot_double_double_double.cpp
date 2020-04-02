
#include <cmath>


#include <limits>
//#include <iomanip>
#include <iostream>
#include <stdexcept>

using namespace std;

bool almost_equal(double x, double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();

}

void test_hypot(){
   
   double x {  0.42 };
   
   double y {  0.42 };
   

   double o_host = hypot( x, y);

   double o_gpu ; 
   #pragma omp target defaultmap(tofrom:scalar)
   {
   o_gpu = hypot( x, y);
   }

   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "hypot give incorect value when offloaded");
    }
}

int main()
{
    test_hypot();
}

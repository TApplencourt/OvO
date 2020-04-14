
#include <cmath>

#include <limits>
#include <iostream>
#include <stdexcept>

using namespace std;

 
bool almost_equal(long double x, long double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<long double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<long double>::min();

}


void test_sqrtl(){
   
   long double x {  0.42 };
   

   
   long double o_host ;
   long double o_gpu ;
   

   o_host = sqrtl( x, &o_host);

   #pragma omp target map(from: o_gpu )
   {
   o_gpu = sqrtl( x, &o_gpu);
   }

   
   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "sqrtl give incorect value when offloaded");
    }
    
}

int main()
{
    test_sqrtl();
}

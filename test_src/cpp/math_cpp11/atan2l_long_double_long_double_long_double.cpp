
#include <cmath>

#include <limits>
#include <iostream>

using namespace std;

 
bool almost_equal(long double x, long double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<long double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<long double>::min();

}


void test_atan2l(){
   
   long double y {  0.42 };
   
   long double x {  0.42 };
   

   
   long double o_host;
   long double o_device;
   

   o_host = atan2l( y, x);

   #pragma omp target map(from: o_device )
   {
   o_device = atan2l( y, x);
   }

   
   if ( !almost_equal(o_host,o_device,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_device << std::endl;
        throw std::runtime_error( "atan2l give incorect value when offloaded");
    }
    
}

int main()
{
    test_atan2l();
}

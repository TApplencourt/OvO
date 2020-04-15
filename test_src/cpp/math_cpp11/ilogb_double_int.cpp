
#include <cmath>

#include <limits>
#include <iostream>

using namespace std;

 
bool almost_equal(int x, int y, int ulp) {

    return x == y ; 

}


void test_ilogb(){
   
   double x {  0.42 };
   

   
   int o_host;
   int o_device;
   

   o_host = ilogb( x);

   #pragma omp target map(from: o_device )
   {
   o_device = ilogb( x);
   }

   
   if ( !almost_equal(o_host,o_device,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_device << std::endl;
        throw std::runtime_error( "ilogb give incorect value when offloaded");
    }
    
}

int main()
{
    test_ilogb();
}

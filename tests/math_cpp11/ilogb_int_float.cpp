
#include <cmath>


#include <limits>
#include <iostream>
#include <stdexcept>

using namespace std;

bool almost_equal(int x, int y, int ulp) {

    return x == y ; 

}

void test_ilogb(){
   
   float x {  0.42 };
   

   int o_host = ilogb( x);

   int o_gpu ; 
   #pragma omp target map(from:o_gpu)
   {
   o_gpu = ilogb( x);
   }

   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "ilogb give incorect value when offloaded");
    }
}

int main()
{
    test_ilogb();
}

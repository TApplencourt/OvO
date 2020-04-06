
#include <cmath>


#include <limits>
#include <iostream>
#include <stdexcept>

using namespace std;

bool almost_equal(long int x, long int y, int ulp) {

    return x == y ; 

}

void test_lrintl(){
   
   long double x {  0.42 };
   

   long int o_host = lrintl( x);

   long int o_gpu ; 
   #pragma omp target map(from:o_gpu)
   {
   o_gpu = lrintl( x);
   }

   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "lrintl give incorect value when offloaded");
    }
}

int main()
{
    test_lrintl();
}

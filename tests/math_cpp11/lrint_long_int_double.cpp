
#include <cmath>


#include <limits>
#include <iostream>
#include <stdexcept>

using namespace std;

bool almost_equal(long int x, long int y, int ulp) {

    return x == y ; 

}

void test_lrint(){
   
   double x {  0.42 };
   

   long int o_host = lrint( x);

   long int o_gpu ; 
   #pragma omp target defaultmap(tofrom:scalar)
   {
   o_gpu = lrint( x);
   }

   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "lrint give incorect value when offloaded");
    }
}

int main()
{
    test_lrint();
}

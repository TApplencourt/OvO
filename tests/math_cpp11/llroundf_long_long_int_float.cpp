
#include <cmath>


#include <limits>
//#include <iomanip>
#include <iostream>
#include <stdexcept>

using namespace std;

bool almost_equal(long long int x, long long int y, int ulp) {

    return x == y ; 

}

void test_llroundf(){
   
   float x {  0.42 };
   

   long long int o_host = llroundf( x);

   long long int o_gpu ; 
   #pragma omp target defaultmap(tofrom:scalar)
   {
   o_gpu = llroundf( x);
   }

   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "llroundf give incorect value when offloaded");
    }
}

int main()
{
    test_llroundf();
}

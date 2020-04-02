
#include <cmath>


#include <limits>
//#include <iomanip>
#include <iostream>
#include <stdexcept>

using namespace std;

bool almost_equal(long int x, long int y, int ulp) {

    return x == y ; 

}

void test_abs(){
   
   long int j {  1 };
   

   long int o_host = abs( j);

   long int o_gpu ; 
   #pragma omp target defaultmap(tofrom:scalar)
   {
   o_gpu = abs( j);
   }

   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "abs give incorect value when offloaded");
    }
}

int main()
{
    test_abs();
}


#include <cmath>


#include <limits>
#include <iostream>
#include <stdexcept>

using namespace std;

bool almost_equal(float x, float y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<float>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<float>::min();

}

void test_fmodf(){
   
   float x {  0.42 };
   
   float y {  0.42 };
   

   float o_host = fmodf( x, y);

   float o_gpu ; 
   #pragma omp target map(from:o_gpu)
   {
   o_gpu = fmodf( x, y);
   }

   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "fmodf give incorect value when offloaded");
    }
}

int main()
{
    test_fmodf();
}

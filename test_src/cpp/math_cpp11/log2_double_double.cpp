
#include <cmath>

#include <limits>
#include <iostream>
#include <stdexcept>

using namespace std;

 
bool almost_equal(double x, double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();

}


void test_log2(){
   
   double x {  0.42 };
   

   
   double o_host ;
   double o_gpu ;
   

   o_host = log2( x, &o_host);

   #pragma omp target map(from: o_gpu )
   {
   o_gpu = log2( x, &o_gpu);
   }

   
   if ( !almost_equal(o_host,o_gpu,1) ) {
        std::cerr << "Host: " << o_host << " GPU: " << o_gpu << std::endl;
        throw std::runtime_error( "log2 give incorect value when offloaded");
    }
    
}

int main()
{
    test_log2();
}

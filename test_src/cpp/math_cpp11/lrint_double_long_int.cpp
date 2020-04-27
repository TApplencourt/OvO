#include <cmath>
#include <limits>
#include <iostream>
#include <stdexcept>
#
using namespace std;
bool almost_equal(long int x, long int y, int ulp) {
    return x == y ; 
}
void test_lrint(){
   double in0 {  0.42 };
   long int out1_host;
   long int out1_device;
    out1_host =  lrint( in0);
   #pragma omp target map(from: out1_device )
   {
     out1_device =  lrint( in0);
   }
   if ( !almost_equal(out1_host,out1_device, 4) ) {
        std::cerr << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        throw std::runtime_error( "lrint give incorect value when offloaded");
    }
}
int main()
{
    test_lrint();
}

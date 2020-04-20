#include <cmath>
#include <limits>
#include <iostream>
#include <stdexcept>
#
using namespace std;
bool almost_equal(bool x, bool y, int ulp) {
    return x == y ; 
}
void test_isnormal(){
   long double in0 {  0.42 };
   bool out1_host;
   bool out1_device;
    out1_host =  isnormal( in0);
   #pragma omp target map(from: out1_device )
   {
     out1_device =  isnormal( in0);
   }
   if ( !almost_equal(out1_host,out1_device,1) ) {
        std::cerr << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        throw std::runtime_error( "isnormal give incorect value when offloaded");
    }
}
int main()
{
    test_isnormal();
}

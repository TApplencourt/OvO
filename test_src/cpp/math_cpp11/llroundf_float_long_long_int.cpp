#include <cmath>
#include <limits>
#include <iostream>
#include <stdexcept>
#
using namespace std;
bool almost_equal(long long int x, long long int y, int ulp) {
    return x == y ; 
}
void test_llroundf(){
   float in0 {  0.42 };
   long long int out1_host;
   long long int out1_device;
    out1_host =  llroundf( in0);
   #pragma omp target map(from: out1_device )
   {
     out1_device =  llroundf( in0);
   }
   if ( !almost_equal(out1_host,out1_device, 4) ) {
        std::cerr << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        throw std::runtime_error( "llroundf give incorect value when offloaded");
    }
}
int main()
{
    test_llroundf();
}

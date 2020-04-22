#include <cmath>
#include <limits>
#include <iostream>
#include <stdexcept>
#
using namespace std;
bool almost_equal(int x, int y, int ulp) {
    return x == y ; 
}
void test_fpclassify(){
   double in0 {  0.42 };
   int out1_host;
   int out1_device;
    out1_host =  fpclassify( in0);
   #pragma omp target map(from: out1_device )
   {
     out1_device =  fpclassify( in0);
   }
   if ( !almost_equal(out1_host,out1_device,4) ) {
        std::cerr << "Host: " << out1_host << " GPU: " << out1_device << std::endl;
        throw std::runtime_error( "fpclassify give incorect value when offloaded");
    }
}
int main()
{
    test_fpclassify();
}

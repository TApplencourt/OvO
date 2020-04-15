
#include <complex>

#include <cmath>

#include <limits>
#include <iostream>

using namespace std;

 
bool almost_equal(COMPLEX x, COMPLEX y, int ulp) {

    return std::abs(x-y) <= std::numeric_limits<REAL>::epsilon() * std::abs(x+y) * ulp ||  std::abs(x-y) < std::numeric_limits<REAL>::min();

}


void test_CMPLX(){
   
   REAL in0 {  0.42 };
   
   REAL in1 {  0.42 };
   

   
   COMPLEX out2_host;
   COMPLEX out2_device;
   

   out2_host = CMPLX( in0, in1);

   #pragma omp target map(from: out2_device )
   {
   out2_device = CMPLX( in0, in1);
   }

   
   if ( !almost_equal(out2_host,out2_device,1) ) {
        std::cerr << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        throw std::runtime_error( "CMPLX give incorect value when offloaded");
    }
    
}

int main()
{
    test_CMPLX();
}

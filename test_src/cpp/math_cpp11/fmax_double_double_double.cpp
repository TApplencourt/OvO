
#include <cmath>

#include <limits>
#include <iostream>
#include <stdexcept>

using namespace std;

 
bool almost_equal(double x, double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();

}


void test_fmax(){
   
   double in0 {  0.42 };
   
   double in1 {  0.42 };
   

   
   double out2_host ;
   double out2_gpu ;
   

   out2_host = fmax( in0, in1, &out2_host);

   #pragma omp target map(from: out2_gpu )
   {
   out2_gpu = fmax( in0, in1, &out2_gpu);
   }

   
   if ( !almost_equal(out2_host,out2_gpu,1) ) {
        std::cerr << "Host: " << out2_host << " GPU: " << out2_gpu << std::endl;
        throw std::runtime_error( "fmax give incorect value when offloaded");
    }
    
}

int main()
{
    test_fmax();
}

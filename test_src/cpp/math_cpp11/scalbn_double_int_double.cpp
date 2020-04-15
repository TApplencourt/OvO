
#include <cmath>

#include <limits>
#include <iostream>

using namespace std;

 
bool almost_equal(double x, double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();

}


void test_scalbn(){
   
   double in0 {  0.42 };
   
   int in1 {  1 };
   

   
   double out2_host;
   double out2_device;
   

    out2_host =  scalbn( in0, in1);
   
   #pragma omp target map(from: out2_device )
   {
     out2_device =  scalbn( in0, in1);
   }

   
   if ( !almost_equal(out2_host,out2_device,1) ) {
        std::cerr << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        throw std::runtime_error( "scalbn give incorect value when offloaded");
    }
    
}

int main()
{
    test_scalbn();
}

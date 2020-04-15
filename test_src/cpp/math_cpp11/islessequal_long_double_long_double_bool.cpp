
#include <cmath>

#include <limits>
#include <iostream>

using namespace std;

 
bool almost_equal(bool x, bool y, int ulp) {

    return x == y ; 

}


void test_islessequal(){
   
   long double in0 {  0.42 };
   
   long double in1 {  0.42 };
   

   
   bool out2_host;
   bool out2_device;
   

    out2_host =  islessequal( in0, in1);
   
   #pragma omp target map(from: out2_device )
   {
     out2_device =  islessequal( in0, in1);
   }

   
   if ( !almost_equal(out2_host,out2_device,1) ) {
        std::cerr << "Host: " << out2_host << " GPU: " << out2_device << std::endl;
        throw std::runtime_error( "islessequal give incorect value when offloaded");
    }
    
}

int main()
{
    test_islessequal();
}

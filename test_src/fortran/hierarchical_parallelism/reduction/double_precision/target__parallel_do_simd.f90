

program target__parallel_do_simd.f90


    

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    DOUBLE PRECISION :: COUNTER =  0   

    
    
     
    
    !$OMP TARGET    MAP(TOFROM: COUNTER) 



    

    
    !$OMP PARALLEL DO SIMD   REDUCTION(+:COUNTER)  


    DO i = 1 , L 


    

    


counter = counter +  1.  

 
     

    END DO

    !$OMP END PARALLEL DO SIMD
     

    !$OMP END TARGET
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON( COUNTER   ) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target__parallel_do_simd.f90
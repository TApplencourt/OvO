

program target_parallel__loop__simd.f90


    

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    
    COMPLEX :: COUNTER =  (    0   ,0)  

    
    
     
    
    !$OMP TARGET PARALLEL   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 



    

    
    !$OMP LOOP   REDUCTION(+:COUNTER)  


    DO i = 1 , L 


    

    
    !$OMP SIMD   REDUCTION(+:COUNTER)  


    DO j = 1 , M 


    

    


counter = counter +  CMPLX(   1.  ,0)  

 
     

    END DO

    !$OMP END SIMD
     

    END DO

    !$OMP END LOOP
     

    !$OMP END TARGET PARALLEL
    

    IF  ( ( ABS(COUNTER - L*M) ) > 10*EPSILON( REAL(  COUNTER  )   ) ) THEN
        write(*,*)  'Expected L*M Got', COUNTER
        call exit(1)
    ENDIF

end program target_parallel__loop__simd.f90
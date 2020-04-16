

program target__teams__distribute__parallel__loop__simd


    

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    INTEGER :: N = 7
    INTEGER :: k
    
    DOUBLE PRECISION :: COUNTER =  0   

    
    
     
    
    !$OMP TARGET    MAP(TOFROM: COUNTER) 



    

    
    !$OMP TEAMS   REDUCTION(+:COUNTER)  



    

    
    !$OMP DISTRIBUTE   


    DO i = 1 , L 


    

    
    !$OMP PARALLEL   REDUCTION(+:COUNTER)  



    

    
    !$OMP LOOP   REDUCTION(+:COUNTER)  


    DO j = 1 , M 


    

    
    !$OMP SIMD   REDUCTION(+:COUNTER)  


    DO k = 1 , N 


    

    


counter = counter +  1.  

 
     

    END DO

    !$OMP END SIMD
     

    END DO

    !$OMP END LOOP
     

    !$OMP END PARALLEL
     

    END DO

    !$OMP END DISTRIBUTE
     

    !$OMP END TEAMS
     

    !$OMP END TARGET
    

    IF  ( ( ABS(COUNTER - L*M*N) ) > 10*EPSILON( COUNTER   ) ) THEN
        write(*,*)  'Expected L*M*N Got', COUNTER
        call exit(1)
    ENDIF

end program target__teams__distribute__parallel__loop__simd

program target_teams__distribute__parallel__loop_for__simd
    USE OMP_LIB

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    INTEGER :: N = 7
    INTEGER :: k
    
    REAL :: COUNTER = 0

    
    
    INTEGER :: num_threads
    
     
    
    !$OMP TARGET TEAMS   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 



    

    
    !$OMP DISTRIBUTE   


    DO i = 1 , L 


    

    
    !$OMP PARALLEL   REDUCTION(+:COUNTER)  



    
    num_threads = omp_get_num_threads()
    

    
    !$OMP LOOP_DO   REDUCTION(+:COUNTER)  


    DO j = 1 , M 


    

    
    !$OMP SIMD   REDUCTION(+:COUNTER)  


    DO k = 1 , N 


    

    


counter =  counter +1./num_threads

 
     

    END DO

    !$OMP END SIMD
     

    END DO

    !$OMP END LOOP_DO
     

    !$OMP END PARALLEL
     

    END DO

    !$OMP END DISTRIBUTE
     

    !$OMP END TARGET TEAMS
    

    IF  ( ( ABS(COUNTER - L*M*N) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L*M*N Got', COUNTER
        call exit(1)
    ENDIF

end program target_teams__distribute__parallel__loop_for__simd
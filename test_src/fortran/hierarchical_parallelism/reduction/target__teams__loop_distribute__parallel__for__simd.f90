
program target__teams__loop_distribute__parallel__for__simd
    USE OMP_LIB

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    INTEGER :: N = 7
    INTEGER :: k
    
    REAL :: COUNTER = 0

    
    INTEGER :: num_teams
    
    
     
    
    !$OMP TARGET    MAP(TOFROM: COUNTER) 



    

    
    !$OMP TEAMS   REDUCTION(+:COUNTER)  



    
    num_teams = omp_get_num_teams()
    

    
    !$OMP LOOP_DISTRIBUTE   REDUCTION(+:COUNTER)  


    DO i = 1 , L 


    

    
    !$OMP PARALLEL   REDUCTION(+:COUNTER)  



    

    
    !$OMP DO   


    DO j = 1 , M 


    

    
    !$OMP SIMD   REDUCTION(+:COUNTER)  


    DO k = 1 , N 


    

    


counter = counter + 1./num_teams

 
     

    END DO

    !$OMP END SIMD
     

    END DO

    !$OMP END DO
     

    !$OMP END PARALLEL
     

    END DO

    !$OMP END LOOP_DISTRIBUTE
     

    !$OMP END TEAMS
     

    !$OMP END TARGET
    

    IF  ( ( ABS(COUNTER - L*M*N) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L*M*N Got', COUNTER
        call exit(1)
    ENDIF

end program target__teams__loop_distribute__parallel__for__simd
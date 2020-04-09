
program target__teams_loop_distribute__parallel_loop_for__simd
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
    
    
    INTEGER :: num_threads
    
     
    
    !$OMP TARGET    MAP(TOFROM: COUNTER) 



    

    
    !$OMP TEAMS LOOP_DISTRIBUTE   REDUCTION(+:COUNTER)  


    DO i = 1 , L 


    
    num_teams = omp_get_num_teams()
    

    
    !$OMP PARALLEL LOOP_DO   REDUCTION(+:COUNTER)  


    DO j = 1 , M 


    
    num_threads = omp_get_num_threads()
    

    
    !$OMP SIMD   REDUCTION(+:COUNTER)  


    DO k = 1 , N 


    

    


counter = counter + 1./(num_teams*num_threads)

 
     

    END DO

    !$OMP END SIMD
     

    END DO

    !$OMP END PARALLEL LOOP_DO
     

    END DO

    !$OMP END TEAMS LOOP_DISTRIBUTE
     

    !$OMP END TARGET
    

    IF  ( ( ABS(COUNTER - L*M*N) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L*M*N Got', COUNTER
        call exit(1)
    ENDIF

end program target__teams_loop_distribute__parallel_loop_for__simd
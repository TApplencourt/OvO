
program target_teams_loop_distribute__parallel_loop_for
    USE OMP_LIB

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    
    REAL :: COUNTER = 0

    
    INTEGER :: num_teams
    
    
    INTEGER :: num_threads
    

     
    
    !$OMP TARGET TEAMS LOOP_DISTRIBUTE   MAP(TOFROM: COUNTER) 


    DO i = 1 , L 


    
    num_teams = omp_get_num_teams()
    

    
    !$OMP PARALLEL LOOP_DO 


    DO j = 1 , M 


    
    num_threads = omp_get_num_threads()
    

    

!$OMP ATOMIC UPDATE

counter = counter + 1./(num_teams*num_threads)


 
     

    END DO

    !$OMP END PARALLEL LOOP_DO
     

    END DO

    !$OMP END TARGET TEAMS LOOP_DISTRIBUTE
    

    IF  ( ( ABS(COUNTER - L*M) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L*M Got', COUNTER
        call exit(1)
    ENDIF

end program target_teams_loop_distribute__parallel_loop_for
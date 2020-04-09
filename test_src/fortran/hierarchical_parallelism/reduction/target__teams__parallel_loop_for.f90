
program target__teams__parallel_loop_for
    USE OMP_LIB

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    REAL :: COUNTER = 0

    
    INTEGER :: num_teams
    
    
    INTEGER :: num_threads
    
     
    
    !$OMP TARGET    MAP(TOFROM: COUNTER) 



    

    
    !$OMP TEAMS   REDUCTION(+:COUNTER)  



    
    num_teams = omp_get_num_teams()
    

    
    !$OMP PARALLEL LOOP_DO   REDUCTION(+:COUNTER)  


    DO i = 1 , L 


    
    num_threads = omp_get_num_threads()
    

    


counter = counter + 1./(num_teams*num_threads)

 
     

    END DO

    !$OMP END PARALLEL LOOP_DO
     

    !$OMP END TEAMS
     

    !$OMP END TARGET
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target__teams__parallel_loop_for
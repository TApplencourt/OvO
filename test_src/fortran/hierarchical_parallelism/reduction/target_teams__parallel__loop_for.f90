
program target_teams__parallel__loop_for
    USE OMP_LIB

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    REAL :: COUNTER = 0

    
    INTEGER :: num_teams
    
    
    INTEGER :: num_threads
    
     
    
    !$OMP TARGET TEAMS   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 



    
    num_teams = omp_get_num_teams()
    

    
    !$OMP PARALLEL   REDUCTION(+:COUNTER)  



    
    num_threads = omp_get_num_threads()
    

    
    !$OMP LOOP_DO   REDUCTION(+:COUNTER)  


    DO i = 1 , L 


    

    


counter = counter + 1./(num_teams*num_threads)

 
     

    END DO

    !$OMP END LOOP_DO
     

    !$OMP END PARALLEL
     

    !$OMP END TARGET TEAMS
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target_teams__parallel__loop_for

program target_teams_loop_distribute__parallel__for
    USE OMP_LIB

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    
    REAL :: COUNTER = 0

    
    INTEGER :: num_teams
    
    
     
    
    !$OMP TARGET TEAMS LOOP_DISTRIBUTE   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 


    DO i = 1 , L 


    
    num_teams = omp_get_num_teams()
    

    
    !$OMP PARALLEL   REDUCTION(+:COUNTER)  



    

    
    !$OMP DO   


    DO j = 1 , M 


    

    


counter = counter + 1./num_teams

 
     

    END DO

    !$OMP END DO
     

    !$OMP END PARALLEL
     

    END DO

    !$OMP END TARGET TEAMS LOOP_DISTRIBUTE
    

    IF  ( ( ABS(COUNTER - L*M) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L*M Got', COUNTER
        call exit(1)
    ENDIF

end program target_teams_loop_distribute__parallel__for
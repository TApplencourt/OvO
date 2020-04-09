
program target_teams_loop_distribute
    USE OMP_LIB

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    REAL :: COUNTER = 0

    
    INTEGER :: num_teams
    
    

     
    
    !$OMP TARGET TEAMS LOOP_DISTRIBUTE   MAP(TOFROM: COUNTER) 


    DO i = 1 , L 


    
    num_teams = omp_get_num_teams()
    

    

!$OMP ATOMIC UPDATE

counter = counter + 1./num_teams


 
     

    END DO

    !$OMP END TARGET TEAMS LOOP_DISTRIBUTE
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target_teams_loop_distribute
program target_teams

    USE OMP_LIB


    implicit none
  
    
    DOUBLE PRECISION :: COUNTER = 0

    
    INTEGER :: num_teams
    
    

     
    
    !$OMP TARGET TEAMS   MAP(TOFROM: COUNTER) 



    
    num_teams = omp_get_num_teams()
    

    

!$OMP ATOMIC UPDATE

counter = counter + 1./num_teams


 
     

    !$OMP END TARGET TEAMS
    

    IF  ( ( ABS(COUNTER - 1) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected 1 Got', COUNTER
        call exit(1)
    ENDIF

end program target_teams
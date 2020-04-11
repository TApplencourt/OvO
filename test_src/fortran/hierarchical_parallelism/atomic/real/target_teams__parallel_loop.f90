program target_teams__parallel_loop

    USE OMP_LIB


    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    REAL :: COUNTER = 0

    
    INTEGER :: num_teams
    
    

     
    
    !$OMP TARGET TEAMS   MAP(TOFROM: COUNTER) 



    
    num_teams = omp_get_num_teams()
    

    
    !$OMP PARALLEL LOOP 


    DO i = 1 , L 


    

    

!$OMP ATOMIC UPDATE

counter = counter + 1./num_teams


 
     

    END DO

    !$OMP END PARALLEL LOOP
     

    !$OMP END TARGET TEAMS
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target_teams__parallel_loop


program target_teams_loop__parallel__loop.f90


    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    
    REAL :: COUNTER = 0

    
    

     
    
    !$OMP TARGET TEAMS LOOP   MAP(TOFROM: COUNTER) 


    DO i = 1 , L 


    

    
    !$OMP PARALLEL 



    

    
    !$OMP LOOP 


    DO j = 1 , M 


    

    

!$OMP ATOMIC UPDATE

counter = counter + 1.


 
     

    END DO

    !$OMP END LOOP
     

    !$OMP END PARALLEL
     

    END DO

    !$OMP END TARGET TEAMS LOOP
    

    IF  ( ( ABS(COUNTER - L*M) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L*M Got', COUNTER
        call exit(1)
    ENDIF

end program target_teams_loop__parallel__loop.f90
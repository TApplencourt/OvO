
program target_teams__distribute
    USE OMP_LIB

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    REAL :: COUNTER = 0

    
    
     
    
    !$OMP TARGET TEAMS   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 



    

    
    !$OMP DISTRIBUTE   


    DO i = 1 , L 


    

    


counter = counter + 1.

 
     

    END DO

    !$OMP END DISTRIBUTE
     

    !$OMP END TARGET TEAMS
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target_teams__distribute
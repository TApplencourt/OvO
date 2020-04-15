

program target__teams__distribute__parallel_do.f90


    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    
    DOUBLE PRECISION :: COUNTER = 0

    
    

     
    
    !$OMP TARGET   MAP(TOFROM: COUNTER) 



    

    
    !$OMP TEAMS 



    

    
    !$OMP DISTRIBUTE 


    DO i = 1 , L 


    

    
    !$OMP PARALLEL DO 


    DO j = 1 , M 


    

    

!$OMP ATOMIC UPDATE

counter = counter + 1.


 
     

    END DO

    !$OMP END PARALLEL DO
     

    END DO

    !$OMP END DISTRIBUTE
     

    !$OMP END TEAMS
     

    !$OMP END TARGET
    

    IF  ( ( ABS(COUNTER - L*M) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L*M Got', COUNTER
        call exit(1)
    ENDIF

end program target__teams__distribute__parallel_do.f90
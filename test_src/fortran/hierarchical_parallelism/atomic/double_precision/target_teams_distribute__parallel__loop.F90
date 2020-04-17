

FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    DOUBLE PRECISION, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol)  ) 
END FUNCTION almost_equal

program target_teams_distribute__parallel__loop


    LOGICAL :: almost_equal

  
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    
    DOUBLE PRECISION :: COUNTER = 0

    
    

     
    
    !$OMP TARGET TEAMS DISTRIBUTE   MAP(TOFROM: COUNTER) 


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

    !$OMP END TARGET TEAMS DISTRIBUTE
    

    IF  ( .NOT.almost_equal(COUNTER, L*M, 0.1) ) THEN
        write(*,*)  'Expected', L*M,  'Got', COUNTER
        call exit(1)
    ENDIF

end program target_teams_distribute__parallel__loop
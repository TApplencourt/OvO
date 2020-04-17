



FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol)  )
    
END FUNCTION almost_equal

program target_teams_distribute__parallel__do
    implicit none


    LOGICAL :: almost_equal

  
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    
    REAL :: COUNTER =  0   

    
    
     
    
    !$OMP TARGET TEAMS DISTRIBUTE   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 


    DO i = 1 , L 


    

    
    !$OMP PARALLEL   REDUCTION(+:COUNTER)  



    

    
    !$OMP DO   


    DO j = 1 , M 


    

    


counter = counter +  1.  

 
     

    END DO

    !$OMP END DO
     

    !$OMP END PARALLEL
     

    END DO

    !$OMP END TARGET TEAMS DISTRIBUTE
    

    IF  ( .NOT.almost_equal(COUNTER, L*M, 0.1) ) THEN
        write(*,*)  'Expected', L*M,  'Got', COUNTER
        call exit(1)
    ENDIF

end program target_teams_distribute__parallel__do


FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol)  ) 
END FUNCTION almost_equal

program target__teams_loop
    implicit none


    LOGICAL :: almost_equal

  
    INTEGER :: L = 5
    INTEGER :: i
    
    REAL :: COUNTER = 0

    
    

     
    
    !$OMP TARGET   MAP(TOFROM: COUNTER) 



    

    
    !$OMP TEAMS LOOP 


    DO i = 1 , L 


    

    

!$OMP ATOMIC UPDATE

counter = counter + 1.


 
     

    END DO

    !$OMP END TEAMS LOOP
     

    !$OMP END TARGET
    

    IF  ( .NOT.almost_equal(COUNTER, L, 0.1) ) THEN
        write(*,*)  'Expected', L,  'Got', COUNTER
        call exit(1)
    ENDIF

end program target__teams_loop
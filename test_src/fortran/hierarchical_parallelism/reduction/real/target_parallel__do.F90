



FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol)  )
    
END FUNCTION almost_equal

program target_parallel__do


    LOGICAL :: almost_equal

  
    INTEGER :: L = 5
    INTEGER :: i
    
    REAL :: COUNTER =  0   

    
    
     
    
    !$OMP TARGET PARALLEL   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 



    

    
    !$OMP DO   


    DO i = 1 , L 


    

    


counter = counter +  1.  

 
     

    END DO

    !$OMP END DO
     

    !$OMP END TARGET PARALLEL
    

    IF  ( .NOT.almost_equal(COUNTER, L, 0.1) ) THEN
        write(*,*)  'Expected', L,  'Got', COUNTER
        call exit(1)
    ENDIF

end program target_parallel__do
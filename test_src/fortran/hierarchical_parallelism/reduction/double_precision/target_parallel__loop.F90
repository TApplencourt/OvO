



FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    DOUBLE PRECISION, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol)  )
    
END FUNCTION almost_equal

program target_parallel__loop
    implicit none


    LOGICAL :: almost_equal

  
    INTEGER :: L = 5
    INTEGER :: i
    
    DOUBLE PRECISION :: COUNTER =  0   

    
    
     
    
    !$OMP TARGET PARALLEL   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 



    

    
    !$OMP LOOP   REDUCTION(+:COUNTER)  


    DO i = 1 , L 


    

    


counter = counter +  1.  

 
     

    END DO

    !$OMP END LOOP
     

    !$OMP END TARGET PARALLEL
    

    IF  ( .NOT.almost_equal(COUNTER, L, 0.1) ) THEN
        write(*,*)  'Expected', L,  'Got', COUNTER
        call exit(1)
    ENDIF

end program target_parallel__loop
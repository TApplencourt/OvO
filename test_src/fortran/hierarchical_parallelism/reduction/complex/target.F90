FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    COMPLEX, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol)  )
END FUNCTION almost_equal
program target
    LOGICAL :: almost_equal
    COMPLEX :: COUNTER =  (    0   ,0)  
    !$OMP TARGET    MAP(TOFROM: COUNTER) 
counter = counter +  CMPLX(   1.  ,0)  
    !$OMP END TARGET
    IF  ( .NOT.almost_equal(COUNTER, 1, 0.1) ) THEN
        write(*,*)  'Expected', 1,  'Got', COUNTER
        call exit(1)
    ENDIF
end program target

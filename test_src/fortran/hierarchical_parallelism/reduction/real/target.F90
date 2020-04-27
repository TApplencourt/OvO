FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol)  )
END FUNCTION almost_equal
PROGRAM target
    LOGICAL :: almost_equal
    REAL :: counter =  0  
    !$OMP TARGET    MAP(TOFROM: COUNTER) 
counter = counter +  1.  
    !$OMP END TARGET
IF  ( .NOT.almost_equal(counter, 1, 0.1) ) THEN
    write(*,*)  'Expected', 1,  'Got', counter
    call exit(1)
ENDIF
END PROGRAM target

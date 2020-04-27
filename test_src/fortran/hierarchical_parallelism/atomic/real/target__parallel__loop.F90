FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol)  )
END FUNCTION almost_equal
PROGRAM target__parallel__loop
    LOGICAL :: almost_equal
    INTEGER :: L = 262144
    INTEGER :: i
    REAL :: counter =  0  
    !$OMP TARGET   MAP(TOFROM: counter) 
    !$OMP PARALLEL 
    !$OMP LOOP 
    DO i = 1 , L 
!$OMP ATOMIC UPDATE
counter = counter + 1.
    END DO
    !$OMP END LOOP
    !$OMP END PARALLEL
    !$OMP END TARGET
IF  ( .NOT.almost_equal(counter, L, 0.1) ) THEN
    write(*,*)  'Expected', L,  'Got', counter
    call exit(1)
ENDIF
END PROGRAM target__parallel__loop

FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__parallel_loop
    LOGICAL :: almost_equal
    INTEGER :: L = 262144
    INTEGER :: i
    REAL :: counter = 0
!$OMP TARGET map(tofrom:counter) 
!$OMP PARALLEL LOOP REDUCTION(+:counter)
    DO i = 1 , L
counter = counter +  1.
    END DO
!$OMP END PARALLEL LOOP
!$OMP END TARGET
IF ( .NOT.almost_equal(counter, L, 0.1) ) THEN
    WRITE(*,*)  'Expected', L,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target__parallel_loop

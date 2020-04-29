FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    DOUBLE PRECISION, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_parallel_loop
    LOGICAL :: almost_equal
    INTEGER :: L = 262144
    INTEGER :: i
    DOUBLE PRECISION :: counter = 0
!$OMP TARGET PARALLEL LOOP map(tofrom:counter) 
    DO i = 1 , L
!$OMP ATOMIC UPDATE
counter = counter +  1.
    END DO
!$OMP END TARGET PARALLEL LOOP
IF ( .NOT.almost_equal(counter, L, 0.1) ) THEN
    WRITE(*,*)  'Expected', L,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target_parallel_loop

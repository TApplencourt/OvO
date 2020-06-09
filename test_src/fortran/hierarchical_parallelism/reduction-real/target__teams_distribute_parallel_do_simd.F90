FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__teams_distribute_parallel_do_simd
    LOGICAL :: almost_equal
    INTEGER :: N0 = 262144
    INTEGER :: i0
    REAL :: counter = 0
!$OMP TARGET MAP(TOFROM: counter)
!$OMP TEAMS DISTRIBUTE PARALLEL DO SIMD REDUCTION(+: counter)
       DO i0 = 1 , N0
counter = counter +  1.
    END DO
!$OMP END TARGET
IF ( .NOT.almost_equal(counter, N0, 0.1) ) THEN
    WRITE(*,*)  'Expected', N0,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target__teams_distribute_parallel_do_simd

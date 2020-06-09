FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_teams__distribute_simd
    LOGICAL :: almost_equal
    INTEGER :: N0 = 262144
    INTEGER :: i0
    REAL :: counter = 0
!$OMP TARGET TEAMS REDUCTION(+: counter) MAP(TOFROM: counter)
!$OMP DISTRIBUTE SIMD REDUCTION(+: counter)
       DO i0 = 1 , N0
counter = counter +  1.
    END DO
!$OMP END TARGET TEAMS
IF ( .NOT.almost_equal(counter, N0, 0.1) ) THEN
    WRITE(*,*)  'Expected', N0,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target_teams__distribute_simd

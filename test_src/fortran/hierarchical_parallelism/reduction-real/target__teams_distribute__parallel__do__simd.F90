FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__teams_distribute__parallel__do__simd
    LOGICAL :: almost_equal
    INTEGER :: N0 = 64
    INTEGER :: i0
    INTEGER :: N1 = 64
    INTEGER :: i1
    INTEGER :: N2 = 64
    INTEGER :: i2
    REAL :: counter = 0
!$OMP TARGET MAP(TOFROM: counter)
!$OMP TEAMS DISTRIBUTE REDUCTION(+: counter)
       DO i0 = 1 , N0
!$OMP PARALLEL REDUCTION(+: counter)
!$OMP DO
       DO i1 = 1 , N1
!$OMP SIMD REDUCTION(+: counter)
       DO i2 = 1 , N2
counter = counter +  1.
    END DO
    END DO
!$OMP END PARALLEL
    END DO
!$OMP END TARGET
IF ( .NOT.almost_equal(counter, N0*N1*N2, 0.1) ) THEN
    WRITE(*,*)  'Expected', N0*N1*N2,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target__teams_distribute__parallel__do__simd

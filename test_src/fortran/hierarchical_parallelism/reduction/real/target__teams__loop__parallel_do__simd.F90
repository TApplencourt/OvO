FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__teams__loop__parallel_do__simd
    LOGICAL :: almost_equal
    INTEGER :: L = 64
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    INTEGER :: N = 64
    INTEGER :: k
    REAL :: counter = 0
!$OMP TARGET MAP(TOFROM:counter) 
!$OMP TEAMS REDUCTION(+: counter)
!$OMP LOOP
    DO i = 1 , L
!$OMP PARALLEL DO REDUCTION(+: counter)
    DO j = 1 , M
!$OMP SIMD REDUCTION(+: counter)
    DO k = 1 , N
counter = counter +  1.
    END DO
!$OMP END SIMD
    END DO
!$OMP END PARALLEL DO
    END DO
!$OMP END LOOP
!$OMP END TEAMS
!$OMP END TARGET
IF ( .NOT.almost_equal(counter, L*M*N, 0.1) ) THEN
    WRITE(*,*)  'Expected', L*M*N,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target__teams__loop__parallel_do__simd

FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__teams__distribute__parallel_do__simd
    LOGICAL :: almost_equal
    INTEGER :: L = 64
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    INTEGER :: N = 64
    INTEGER :: k
    REAL :: counter = 0
  REAL partial_counter
!$OMP TARGET MAP(TOFROM: counter) 
!$OMP TEAMS
!$OMP DISTRIBUTE
    DO i = 1 , L
  partial_counter = 0.
!$OMP PARALLEL DO REDUCTION(+: partial_counter)
    DO j = 1 , M
!$OMP SIMD REDUCTION(+: partial_counter)
    DO k = 1 , N
partial_counter = partial_counter +  1.
    END DO
!$OMP END SIMD
    END DO
!$OMP END PARALLEL DO
!$OMP ATOMIC UPDATE
counter = counter + partial_counter
    END DO
!$OMP END DISTRIBUTE
!$OMP END TEAMS
!$OMP END TARGET
IF ( .NOT.almost_equal(counter, L*M*N, 0.1) ) THEN
    WRITE(*,*)  'Expected', L*M*N,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target__teams__distribute__parallel_do__simd

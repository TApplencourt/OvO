FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__parallel__loop__simd
    LOGICAL :: almost_equal
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    REAL :: counter = 0
  REAL partial_counter
!$OMP TARGET MAP(TOFROM: counter) 
!$OMP PARALLEL
!$OMP LOOP
    DO i = 1 , L
  partial_counter = 0.
!$OMP SIMD REDUCTION(+: partial_counter)
    DO j = 1 , M
partial_counter = partial_counter +  1.
    END DO
#ifdef _END_PRAGMA
!$OMP END SIMD
#endif
!$OMP ATOMIC UPDATE
counter = counter + partial_counter
#ifndef _END_PRAGMA
!$OMP END ATOMIC
#endif
    END DO
#ifdef _END_PRAGMA
!$OMP END LOOP
#endif
!$OMP END PARALLEL
!$OMP END TARGET
IF ( .NOT.almost_equal(counter, L*M, 0.1) ) THEN
    WRITE(*,*)  'Expected', L*M,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target__parallel__loop__simd

FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_teams_loop__parallel_loop
    LOGICAL :: almost_equal
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    REAL :: counter = 0
  REAL partial_counter
!$OMP TARGET TEAMS LOOP MAP(TOFROM: counter) 
    DO i = 1 , L
  partial_counter = 0.
!$OMP PARALLEL LOOP REDUCTION(+: partial_counter)
    DO j = 1 , M
partial_counter = partial_counter +  1.
    END DO
#ifdef _END_PRAGMA
!$OMP END PARALLEL LOOP
#endif
!$OMP ATOMIC UPDATE
counter = counter + partial_counter
#ifndef _END_PRAGMA
!$OMP END ATOMIC
#endif
    END DO
#ifdef _END_PRAGMA
!$OMP END TARGET TEAMS LOOP
#endif
IF ( .NOT.almost_equal(counter, L*M, 0.1) ) THEN
    WRITE(*,*)  'Expected', L*M,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target_teams_loop__parallel_loop

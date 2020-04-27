FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    DOUBLE PRECISION, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_teams_loop__parallel__loop__simd
    LOGICAL :: almost_equal
    INTEGER :: L = 64
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    INTEGER :: N = 64
    INTEGER :: k
    DOUBLE PRECISION :: counter = 0
    DOUBLE PRECISION :: partial_counter
    !$OMP TARGET TEAMS LOOP  MAP(TOFROM: counter) 
    DO i = 1 , L 
    partial_counter = 0.
    !$OMP PARALLEL  REDUCTION(+:partial_counter)  
    !$OMP LOOP 
    DO j = 1 , M 
    !$OMP SIMD 
    DO k = 1 , N 
partial_counter = partial_counter + 1.
    END DO
    !$OMP END SIMD
    END DO
    !$OMP END LOOP
    !$OMP END PARALLEL
!$OMP ATOMIC UPDATE
counter = counter + partial_counter
    END DO
    !$OMP END TARGET TEAMS LOOP
IF ( .NOT.almost_equal(counter, L*M*N, 0.1) ) THEN
    write(*,*)  'Expected', L*M*N,  'Got', counter
    call exit(112)
ENDIF
END PROGRAM target_teams_loop__parallel__loop__simd

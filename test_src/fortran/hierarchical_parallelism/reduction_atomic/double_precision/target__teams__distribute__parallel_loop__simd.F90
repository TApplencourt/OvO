FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    DOUBLE PRECISION, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__teams__distribute__parallel_loop__simd
    LOGICAL :: almost_equal
    INTEGER :: L = 64
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    INTEGER :: N = 64
    INTEGER :: k
    DOUBLE PRECISION :: counter = 0
    DOUBLE PRECISION :: partial_counter
    !$OMP TARGET  MAP(TOFROM: counter) 
    !$OMP TEAMS 
    !$OMP DISTRIBUTE 
    DO i = 1 , L 
    partial_counter = 0.
    !$OMP PARALLEL LOOP  REDUCTION(+:partial_counter)  
    DO j = 1 , M 
    !$OMP SIMD 
    DO k = 1 , N 
partial_counter = partial_counter + 1.
    END DO
    !$OMP END SIMD
    END DO
    !$OMP END PARALLEL LOOP
!$OMP ATOMIC UPDATE
counter = counter + partial_counter
    END DO
    !$OMP END DISTRIBUTE
    !$OMP END TEAMS
    !$OMP END TARGET
IF ( .NOT.almost_equal(counter, L*M*N, 0.1) ) THEN
    write(*,*)  'Expected', L*M*N,  'Got', counter
    call exit(112)
ENDIF
END PROGRAM target__teams__distribute__parallel_loop__simd

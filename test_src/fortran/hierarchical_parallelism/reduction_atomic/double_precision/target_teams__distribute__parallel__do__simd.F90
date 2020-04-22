FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    DOUBLE PRECISION, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol)  )
END FUNCTION almost_equal
PROGRAM target_teams__distribute__parallel__do__simd
    LOGICAL :: almost_equal
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    INTEGER :: N = 7
    INTEGER :: k
    DOUBLE PRECISION :: counter = 0. 
    DOUBLE PRECISION :: partial_counter = 0.
    !$OMP TARGET TEAMS  MAP(TOFROM: counter) 
    !$OMP DISTRIBUTE 
    DO i = 1 , L 
    partial_counter = 0.
    !$OMP PARALLEL  REDUCTION(+:partial_counter)  
    !$OMP DO 
    DO j = 1 , M 
    !$OMP SIMD 
    DO k = 1 , N 
partial_counter = partial_counter + 1.
    END DO
    !$OMP END SIMD
    END DO
    !$OMP END DO
    !$OMP END PARALLEL
!$OMP ATOMIC UPDATE
counter = counter + partial_counter
    END DO
    !$OMP END DISTRIBUTE
    !$OMP END TARGET TEAMS
    IF  ( .NOT.almost_equal(COUNTER, L*M*N, 0.1) ) THEN
        write(*,*)  'Expected', L*M*N,  'Got', COUNTER
        call exit(1)
    ENDIF
END PROGRAM target_teams__distribute__parallel__do__simd

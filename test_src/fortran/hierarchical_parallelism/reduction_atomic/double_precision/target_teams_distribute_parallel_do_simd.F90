FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    DOUBLE PRECISION, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol)  )
END FUNCTION almost_equal
PROGRAM target_teams_distribute_parallel_do_simd
    LOGICAL :: almost_equal
    INTEGER :: L = 5
    INTEGER :: i
    DOUBLE PRECISION :: counter = 0. 
    DOUBLE PRECISION :: partial_counter = 0.
    partial_counter = 0.
    !$OMP TARGET TEAMS DISTRIBUTE PARALLEL DO SIMD  REDUCTION(+:partial_counter)   MAP(TOFROM: counter) 
    DO i = 1 , L 
partial_counter = partial_counter + 1.
    END DO
    !$OMP END TARGET TEAMS DISTRIBUTE PARALLEL DO SIMD
!$OMP ATOMIC UPDATE
counter = counter + partial_counter
    IF  ( .NOT.almost_equal(COUNTER, L, 0.1) ) THEN
        write(*,*)  'Expected', L,  'Got', COUNTER
        call exit(1)
    ENDIF
END PROGRAM target_teams_distribute_parallel_do_simd

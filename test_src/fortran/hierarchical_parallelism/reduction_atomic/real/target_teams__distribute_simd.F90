FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol)  )
END FUNCTION almost_equal
PROGRAM target_teams__distribute_simd
    LOGICAL :: almost_equal
    INTEGER :: L = 262144
    INTEGER :: i
    REAL :: counter =  0  
    !$OMP TARGET TEAMS  MAP(TOFROM: counter) 
    partial_counter = 0.
    !$OMP DISTRIBUTE SIMD  REDUCTION(+:partial_counter)  
    DO i = 1 , L 
partial_counter = partial_counter + 1.
    END DO
    !$OMP END DISTRIBUTE SIMD
!$OMP ATOMIC UPDATE
counter = counter + partial_counter
    !$OMP END TARGET TEAMS
IF  ( .NOT.almost_equal(counter, L, 0.1) ) THEN
    write(*,*)  'Expected', L,  'Got', counter
    call exit(1)
ENDIF
END PROGRAM target_teams__distribute_simd

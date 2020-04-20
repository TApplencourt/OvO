FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    DOUBLE PRECISION, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol)  )
END FUNCTION almost_equal
PROGRAM target__teams_distribute_parallel_do
    LOGICAL :: almost_equal
    INTEGER :: L = 5
    INTEGER :: i
    DOUBLE PRECISION :: counter =  0.   
    DOUBLE PRECISION :: partial_COUNTER 
    !$OMP TARGET  MAP(TOFROM: counter) 
    partial_counter  = 0.
    !$OMP TEAMS DISTRIBUTE PARALLEL DO  REDUCTION(+:partial_counter)  
    DO i = 1 , L 
partial_counter = partial_counter + 1.
    END DO
    !$OMP END TEAMS DISTRIBUTE PARALLEL DO
!$OMP ATOMIC UPDATE
counter = counter + partial_counter
    !$OMP END TARGET
    IF  ( .NOT.almost_equal(COUNTER, L, 0.1) ) THEN
        write(*,*)  'Expected', L,  'Got', COUNTER
        call exit(1)
    ENDIF
END PROGRAM target__teams_distribute_parallel_do

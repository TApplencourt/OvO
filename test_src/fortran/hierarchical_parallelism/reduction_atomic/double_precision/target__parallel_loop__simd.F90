FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    DOUBLE PRECISION, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol)  )
END FUNCTION almost_equal
PROGRAM target__parallel_loop__simd
    LOGICAL :: almost_equal
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    DOUBLE PRECISION :: counter = 0. 
    DOUBLE PRECISION :: partial_counter = 0.
    !$OMP TARGET  MAP(TOFROM: counter) 
    partial_counter = 0.
    !$OMP PARALLEL LOOP  REDUCTION(+:partial_counter)  
    DO i = 1 , L 
    !$OMP SIMD 
    DO j = 1 , M 
partial_counter = partial_counter + 1.
    END DO
    !$OMP END SIMD
    END DO
    !$OMP END PARALLEL LOOP
!$OMP ATOMIC UPDATE
counter = counter + partial_counter
    !$OMP END TARGET
    IF  ( .NOT.almost_equal(COUNTER, L*M, 0.1) ) THEN
        write(*,*)  'Expected', L*M,  'Got', COUNTER
        call exit(1)
    ENDIF
END PROGRAM target__parallel_loop__simd

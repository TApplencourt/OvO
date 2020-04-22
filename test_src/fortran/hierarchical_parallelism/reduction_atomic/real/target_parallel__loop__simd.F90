FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol)  )
END FUNCTION almost_equal
PROGRAM target_parallel__loop__simd
    LOGICAL :: almost_equal
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    REAL :: counter = 0. 
    REAL :: partial_counter = 0.
    partial_counter = 0.
    !$OMP TARGET PARALLEL  REDUCTION(+:partial_counter)   MAP(TOFROM: counter) 
    !$OMP LOOP 
    DO i = 1 , L 
    !$OMP SIMD 
    DO j = 1 , M 
partial_counter = partial_counter + 1.
    END DO
    !$OMP END SIMD
    END DO
    !$OMP END LOOP
    !$OMP END TARGET PARALLEL
!$OMP ATOMIC UPDATE
counter = counter + partial_counter
    IF  ( .NOT.almost_equal(COUNTER, L*M, 0.1) ) THEN
        write(*,*)  'Expected', L*M,  'Got', COUNTER
        call exit(1)
    ENDIF
END PROGRAM target_parallel__loop__simd

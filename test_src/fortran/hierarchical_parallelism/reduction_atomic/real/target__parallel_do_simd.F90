FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    REAL, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol)  )
END FUNCTION almost_equal
PROGRAM target__parallel_do_simd
    LOGICAL :: almost_equal
    INTEGER :: L = 5
    INTEGER :: i
    REAL :: counter = 0. 
    REAL :: partial_counter = 0.
    !$OMP TARGET  MAP(TOFROM: counter) 
    partial_counter = 0.
    !$OMP PARALLEL DO SIMD  REDUCTION(+:partial_counter)  
    DO i = 1 , L 
partial_counter = partial_counter + 1.
    END DO
    !$OMP END PARALLEL DO SIMD
!$OMP ATOMIC UPDATE
counter = counter + partial_counter
    !$OMP END TARGET
    IF  ( .NOT.almost_equal(COUNTER, L, 0.1) ) THEN
        write(*,*)  'Expected', L,  'Got', COUNTER
        call exit(1)
    ENDIF
END PROGRAM target__parallel_do_simd

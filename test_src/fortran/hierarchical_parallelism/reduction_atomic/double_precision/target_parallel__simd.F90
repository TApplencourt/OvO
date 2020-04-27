#ifndef _OPENMP
FUNCTION omp_get_num_teams() RESULT(i)
    INTEGER :: i
    i = 1
END FUNCTION omp_get_num_teams
FUNCTION omp_get_num_threads() RESULT(i)
    INTEGER :: i
    i = 1
END FUNCTION omp_get_num_threads
#endif
FUNCTION almost_equal(x, gold, tol) result(b)
    implicit none
    DOUBLE PRECISION, intent(in) :: x
    INTEGER,  intent(in) ::gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol)  )
END FUNCTION almost_equal
PROGRAM target_parallel__simd
#ifdef _OPENMP
    USE OMP_LIB
    implicit none
#else
    implicit none
    INTEGER:: omp_get_num_teams, omp_get_num_threads
#endif
    LOGICAL :: almost_equal
    INTEGER :: L = 262144
    INTEGER :: i
    DOUBLE PRECISION :: counter =  0  
    INTEGER :: num_threads
    partial_counter = 0.
    !$OMP TARGET PARALLEL  REDUCTION(+:partial_counter)   MAP(TOFROM: counter) 
    num_threads = omp_get_num_threads()
    !$OMP SIMD 
    DO i = 1 , L 
partial_counter =  partial_counter + 1./num_threads  
    END DO
    !$OMP END SIMD
    !$OMP END TARGET PARALLEL
!$OMP ATOMIC UPDATE
counter = counter + partial_counter
IF  ( .NOT.almost_equal(counter, L, 0.1) ) THEN
    write(*,*)  'Expected', L,  'Got', counter
    call exit(1)
ENDIF
END PROGRAM target_parallel__simd

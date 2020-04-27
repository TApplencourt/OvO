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
FUNCTION almost_equal(x, gold, tol) RESULT(b)
    implicit none
    DOUBLE PRECISION, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__teams__parallel_do_simd
#ifdef _OPENMP
    USE OMP_LIB
    implicit none
#else
    implicit none
    INTEGER :: omp_get_num_teams
#endif
    LOGICAL :: almost_equal
    INTEGER :: L = 262144
    INTEGER :: i
    DOUBLE PRECISION :: counter = 0
    INTEGER :: num_teams
    DOUBLE PRECISION :: partial_counter
    !$OMP TARGET  MAP(TOFROM: counter) 
    !$OMP TEAMS 
    num_teams = omp_get_num_teams()
    partial_counter = 0.
    !$OMP PARALLEL DO SIMD  REDUCTION(+:partial_counter)  
    DO i = 1 , L 
partial_counter = partial_counter + 1./num_teams 
    END DO
    !$OMP END PARALLEL DO SIMD
!$OMP ATOMIC UPDATE
counter = counter + partial_counter
    !$OMP END TEAMS
    !$OMP END TARGET
IF ( .NOT.almost_equal(counter, L, 0.1) ) THEN
    write(*,*)  'Expected', L,  'Got', counter
    call exit(112)
ENDIF
END PROGRAM target__teams__parallel_do_simd

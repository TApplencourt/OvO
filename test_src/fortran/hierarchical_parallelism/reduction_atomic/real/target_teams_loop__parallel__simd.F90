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
    REAL, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_teams_loop__parallel__simd
#ifdef _OPENMP
    USE OMP_LIB
    implicit none
#else
    implicit none
    INTEGER :: omp_get_num_threads
#endif
    LOGICAL :: almost_equal
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    REAL :: counter = 0
    INTEGER :: num_threads
    REAL :: partial_counter
    !$OMP TARGET TEAMS LOOP  MAP(TOFROM: counter) 
    DO i = 1 , L 
    partial_counter = 0.
    !$OMP PARALLEL  REDUCTION(+:partial_counter)  
    num_threads = omp_get_num_threads()
    !$OMP SIMD 
    DO j = 1 , M 
partial_counter =  partial_counter + 1./num_threads  
    END DO
    !$OMP END SIMD
    !$OMP END PARALLEL
!$OMP ATOMIC UPDATE
counter = counter + partial_counter
    END DO
    !$OMP END TARGET TEAMS LOOP
IF ( .NOT.almost_equal(counter, L*M, 0.1) ) THEN
    write(*,*)  'Expected', L*M,  'Got', counter
    call exit(112)
ENDIF
END PROGRAM target_teams_loop__parallel__simd

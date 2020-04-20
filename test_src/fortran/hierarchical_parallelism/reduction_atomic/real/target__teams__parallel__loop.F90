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
    REAL, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL, intent(in)  :: tol
    LOGICAL          :: b
    b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol)  )
END FUNCTION almost_equal
PROGRAM target__teams__parallel__loop
#ifdef _OPENMP
    USE OMP_LIB
    implicit none
#else
    implicit none
    INTEGER:: omp_get_num_teams, omp_get_num_threads
#endif
    LOGICAL :: almost_equal
    INTEGER :: L = 5
    INTEGER :: i
    REAL :: counter = 0. 
    REAL :: partial_counter = 0.
    INTEGER :: num_teams
    !$OMP TARGET  MAP(TOFROM: counter) 
    !$OMP TEAMS 
    num_teams = omp_get_num_teams()
    partial_counter = 0.
    !$OMP PARALLEL  REDUCTION(+:partial_counter)  
    !$OMP LOOP 
    DO i = 1 , L 
partial_counter = partial_counter + 1./num_teams 
    END DO
    !$OMP END LOOP
    !$OMP END PARALLEL
!$OMP ATOMIC UPDATE
counter = counter + partial_counter
    !$OMP END TEAMS
    !$OMP END TARGET
    IF  ( .NOT.almost_equal(COUNTER, L, 0.1) ) THEN
        write(*,*)  'Expected', L,  'Got', COUNTER
        call exit(1)
    ENDIF
END PROGRAM target__teams__parallel__loop

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
PROGRAM target_teams_distribute__parallel
#ifdef _OPENMP
    USE OMP_LIB
    implicit none
#else
    implicit none
    INTEGER :: omp_get_num_threads
#endif
    LOGICAL :: almost_equal
    INTEGER :: L = 262144
    INTEGER :: i
    DOUBLE PRECISION :: counter = 0
    INTEGER :: num_threads
!$OMP TARGET TEAMS DISTRIBUTE REDUCTION(+:counter) map(tofrom:counter) 
    DO i = 1 , L
!$OMP PARALLEL REDUCTION(+:counter)
    num_threads = omp_get_num_threads()
counter = counter +  1./num_threads
!$OMP END PARALLEL
    END DO
!$OMP END TARGET TEAMS DISTRIBUTE
IF ( .NOT.almost_equal(counter, L, 0.1) ) THEN
    WRITE(*,*)  'Expected', L,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target_teams_distribute__parallel

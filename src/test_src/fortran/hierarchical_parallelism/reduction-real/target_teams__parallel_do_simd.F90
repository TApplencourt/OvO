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
PROGRAM target_teams__parallel_do_simd
#ifdef _OPENMP
    USE OMP_LIB
    implicit none
#else
    implicit none
    INTEGER :: omp_get_num_teams
#endif
    LOGICAL :: almost_equal
    INTEGER :: N_i = 64
    INTEGER :: i
    REAL :: counter = 0
    INTEGER :: num_teams
!$OMP TARGET TEAMS REDUCTION(+: counter) MAP(TOFROM: counter) 
    num_teams = omp_get_num_teams()
!$OMP PARALLEL DO SIMD REDUCTION(+: counter)
    DO i = 1 , N_i
counter = counter +  1./num_teams
    END DO
!$OMP END TARGET TEAMS
IF ( .NOT.almost_equal(counter, N_i, 0.1) ) THEN
    WRITE(*,*)  'Expected', N_i,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target_teams__parallel_do_simd

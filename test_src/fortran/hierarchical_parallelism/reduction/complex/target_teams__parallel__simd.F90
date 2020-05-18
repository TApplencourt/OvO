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
    COMPLEX, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_teams__parallel__simd
#ifdef _OPENMP
    USE OMP_LIB
    implicit none
#else
    implicit none
    INTEGER :: omp_get_num_teams
    INTEGER :: omp_get_num_threads
#endif
    LOGICAL :: almost_equal
    INTEGER :: L = 262144
    INTEGER :: i
    COMPLEX :: counter = (0,0)
    INTEGER :: num_teams
    INTEGER :: num_threads
!$OMP TARGET TEAMS REDUCTION(+: counter) MAP(TOFROM: counter) 
    num_teams = omp_get_num_teams()
!$OMP PARALLEL REDUCTION(+: counter)
    num_threads = omp_get_num_threads()
!$OMP SIMD REDUCTION(+: counter)
    DO i = 1 , L
counter = counter +  CMPLX(  1./(num_teams*num_threads) , 0 ) 
    END DO
!$OMP END SIMD
!$OMP END PARALLEL
!$OMP END TARGET TEAMS
IF ( .NOT.almost_equal(counter, L, 0.1) ) THEN
    WRITE(*,*)  'Expected', L,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target_teams__parallel__simd

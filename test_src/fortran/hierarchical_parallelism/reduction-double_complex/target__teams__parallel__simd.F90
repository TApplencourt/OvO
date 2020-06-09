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
    DOUBLE COMPLEX, intent(in) :: x
    INTEGER,  intent(in) :: gold
    REAL,     intent(in) :: tol
    LOGICAL              :: b
    b = ( gold * (1 - tol)  <= ABS(x) ).AND.( ABS(x) <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target__teams__parallel__simd
#ifdef _OPENMP
    USE OMP_LIB
    implicit none
#else
    implicit none
    INTEGER :: omp_get_num_teams
    INTEGER :: omp_get_num_threads
#endif
    LOGICAL :: almost_equal
    INTEGER :: N0 = 262144
    INTEGER :: i0
    DOUBLE COMPLEX :: counter = (0,0)
    INTEGER :: num_teams
    INTEGER :: num_threads
!$OMP TARGET MAP(TOFROM: counter)
!$OMP TEAMS REDUCTION(+: counter)
    num_teams = omp_get_num_teams()
!$OMP PARALLEL REDUCTION(+: counter)
    num_threads = omp_get_num_threads()
!$OMP SIMD REDUCTION(+: counter)
       DO i0 = 1 , N0
counter = counter +  CMPLX(  1./(num_teams*num_threads) , 0 )
    END DO
!$OMP END PARALLEL
!$OMP END TEAMS
!$OMP END TARGET
IF ( .NOT.almost_equal(counter, N0, 0.1) ) THEN
    WRITE(*,*)  'Expected', N0,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target__teams__parallel__simd

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
PROGRAM target__teams__parallel__do__simd
#ifdef _OPENMP
    USE OMP_LIB
    implicit none
#else
    implicit none
    INTEGER :: omp_get_num_teams
#endif
    LOGICAL :: almost_equal
    INTEGER :: L = 4096
    INTEGER :: i
    INTEGER :: M = 64
    INTEGER :: j
    COMPLEX :: counter = (0,0)
    INTEGER :: num_teams
!$OMP TARGET MAP(TOFROM: counter) 
!$OMP TEAMS REDUCTION(+: counter)
    num_teams = omp_get_num_teams()
!$OMP PARALLEL REDUCTION(+: counter)
!$OMP DO
    DO i = 1 , L
!$OMP SIMD REDUCTION(+: counter)
    DO j = 1 , M
counter = counter +  CMPLX(  1./num_teams , 0 ) 
    END DO
!$OMP END SIMD
    END DO
!$OMP END DO
!$OMP END PARALLEL
!$OMP END TEAMS
!$OMP END TARGET
IF ( .NOT.almost_equal(counter, L*M, 0.1) ) THEN
    WRITE(*,*)  'Expected', L*M,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target__teams__parallel__do__simd

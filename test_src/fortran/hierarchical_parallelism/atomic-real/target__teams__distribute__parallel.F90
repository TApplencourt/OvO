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
PROGRAM target__teams__distribute__parallel
#ifdef _OPENMP
    USE OMP_LIB
    implicit none
#else
    implicit none
    INTEGER :: omp_get_num_threads
#endif
    LOGICAL :: almost_equal
    INTEGER :: N0 = 262144
    INTEGER :: i0
    REAL :: counter = 0
    INTEGER :: num_threads
!$OMP TARGET MAP(TOFROM: counter)
!$OMP TEAMS
!$OMP DISTRIBUTE
       DO i0 = 1 , N0
!$OMP PARALLEL
    num_threads = omp_get_num_threads()
!$OMP ATOMIC UPDATE
counter = counter +  1./num_threads
!$OMP END PARALLEL
    END DO
!$OMP END TEAMS
!$OMP END TARGET
IF ( .NOT.almost_equal(counter, N0, 0.1) ) THEN
    WRITE(*,*)  'Expected', N0,  'Got', counter
    CALL EXIT(112)
ENDIF
END PROGRAM target__teams__distribute__parallel

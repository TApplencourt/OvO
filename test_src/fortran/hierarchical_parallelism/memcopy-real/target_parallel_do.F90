PROGRAM target_parallel_do
  implicit none
  INTEGER :: N0 = 262144
  INTEGER :: i0
  INTEGER :: idx, S
  INTEGER :: errno = 0
  REAL, ALLOCATABLE :: src(:)
  REAL, ALLOCATABLE :: dst(:)
  S = N0
  ALLOCATE(dst(S), src(S) )
  CALL RANDOM_NUMBER(src)
  !$OMP target parallel do map(to: src) map(from: dst)
  DO i0 = 1, N0
    idx = i0-1+1
    dst(idx) = src(idx)
  END DO
  IF (ANY(ABS(dst - src) > EPSILON(src))) THEN
    WRITE(*,*)  'Wrong value', MAXVAL(ABS(DST-SRC)), 'max difference'
    errno = 112
  ENDIF
  DEALLOCATE(src, dst)
  IF (errno .NE. 0) STOP errno
END PROGRAM target_parallel_do

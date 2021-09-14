PROGRAM target__teams_distribute__parallel_do
  implicit none
  INTEGER :: N0 = 182
  INTEGER :: i0
  INTEGER :: N1 = 182
  INTEGER :: i1
  INTEGER :: idx, S
  INTEGER :: errno = 0
  REAL, ALLOCATABLE :: src(:)
  REAL, ALLOCATABLE :: dst(:)
  S = N0*N1
  ALLOCATE(dst(S), src(S) )
  CALL RANDOM_NUMBER(src)
  !$OMP TARGET map(to: src) map(from: dst) private(idx)
  !$OMP TEAMS DISTRIBUTE private(idx)
  DO i0 = 1, N0
    !$OMP PARALLEL DO private(idx)
    DO i1 = 1, N1
      idx = i1-1+N1*(i0-1)+1
      dst(idx) = src(idx)
    END DO
  END DO
  !$OMP END TARGET
  IF (ANY(ABS(dst - src) > EPSILON(src))) THEN
    WRITE(*,*) 'Wrong value', MAXVAL(ABS(DST-SRC)), 'max difference'
    errno = 112
  ENDIF
  DEALLOCATE(src, dst)
  IF (errno .EQ. 112) STOP 112
END PROGRAM target__teams_distribute__parallel_do

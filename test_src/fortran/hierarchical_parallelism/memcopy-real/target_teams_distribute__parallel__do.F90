PROGRAM target_teams_distribute__parallel__do
  INTEGER :: N0 = 512
  INTEGER :: i0
  INTEGER :: N1 = 512
  INTEGER :: i1
  INTEGER :: idx
  INTEGER :: S
  REAL, ALLOCATABLE :: src(:)
  REAL, ALLOCATABLE :: dst(:)
  S = N0*N1
  ALLOCATE(dst(S), src(S) )
  CALL RANDOM_NUMBER(src)
  !$OMP target teams distribute map(from: src) map(to: dst)
  DO i0 = 1, N0
    !$OMP parallel
    !$OMP do
    DO i1 = 1, N1
      idx = i1-1+N1*(i0-1)+1
      dst(idx) = src(idx)
    END DO
    !$OMP END parallel
  END DO
  IF (ANY(ABS(dst - src) > EPSILON(src))) THEN
    WRITE(*,*)  'Wrong value', MAXVAL(ABS(DST-SRC)), 'max difference'
    STOP 112
  ENDIF
END PROGRAM target_teams_distribute__parallel__do

PROGRAM target__teams_distribute__parallel__do
  INTEGER :: N0 = 23
  INTEGER :: i0
  INTEGER :: N1 = 23
  INTEGER :: i1
  INTEGER :: N2 = 23
  INTEGER :: i2
  INTEGER :: N3 = 23
  INTEGER :: i3
  INTEGER :: idx
  INTEGER :: S
  REAL, ALLOCATABLE :: src(:)
  REAL, ALLOCATABLE :: dst(:)
  S = N0*N1*N2*N3
  ALLOCATE(dst(S), src(S) )
  CALL RANDOM_NUMBER(src)
  !$OMP target map(from: pS[0:size]) map(to: pD[0:size])
  !$OMP teams distribute collapse(2)
  DO i0 = 1, N0
  DO i1 = 1, N1
    !$OMP parallel
    !$OMP for collapse(2)
    DO i2 = 1, N2
    DO i3 = 1, N3
      idx = i3-1+N3*(i2-1+N2*(i1-1+N1*(i0-1)))+1
      dst(idx) = src(idx)
    END DO
    END DO
    !$OMP END parallel
  END DO
  END DO
  !$OMP END target
  IF (ANY(ABS(dst - src) > EPSILON(src))) THEN
    WRITE(*,*)  'Wrong value', MAXVAL(ABS(DST-SRC)), 'max difference'
    STOP 112
  ENDIF
END PROGRAM target__teams_distribute__parallel__do

PROGRAM target_teams__distribute_simd
  INTEGER :: N0 = 262144
  INTEGER :: i0
  INTEGER :: idx
  INTEGER :: S
  REAL, ALLOCATABLE :: src(:)
  REAL, ALLOCATABLE :: dst(:)
  S = N0
  ALLOCATE(dst(S), src(S) )
  CALL RANDOM_NUMBER(src)
  !$OMP target teams map(from: pS[0:size]) map(to: pD[0:size])
  !$OMP distribute simd
  DO i0 = 1, N0
    idx = i0-1+1
    dst(idx) = src(idx)
  END DO
  !$OMP END target teams
  IF (ANY(ABS(dst - src) > EPSILON(src))) THEN
    WRITE(*,*)  'Wrong value', MAXVAL(ABS(DST-SRC)), 'max difference'
    STOP 112
  ENDIF
END PROGRAM target_teams__distribute_simd

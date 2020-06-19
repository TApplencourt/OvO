PROGRAM target__teams__distribute__parallel_do__simd
  INTEGER :: N0 = 64
  INTEGER :: i0
  INTEGER :: N1 = 64
  INTEGER :: i1
  INTEGER :: N2 = 64
  INTEGER :: i2
  INTEGER :: idx
  INTEGER :: S
  REAL, ALLOCATABLE :: src(:)
  REAL, ALLOCATABLE :: dst(:)
  S = N0*N1*N2
  ALLOCATE(dst(S), src(S) )
  CALL RANDOM_NUMBER(src)
  !$OMP target map(from: pS[0:size]) map(to: pD[0:size])
  !$OMP teams
  !$OMP distribute
  DO i0 = 1, N0
    !$OMP parallel for
    DO i1 = 1, N1
      !$OMP simd
      DO i2 = 1, N2
        idx = i2-1+N2*(i1-1+N1*(i0-1))+1
        dst(idx) = src(idx)
      END DO
    END DO
  END DO
  !$OMP END teams
  !$OMP END target
  IF (ANY(ABS(dst - src) > EPSILON(src))) THEN
    WRITE(*,*)  'Wrong value', MAXVAL(ABS(DST-SRC)), 'max difference'
    STOP 112
  ENDIF
END PROGRAM target__teams__distribute__parallel_do__simd

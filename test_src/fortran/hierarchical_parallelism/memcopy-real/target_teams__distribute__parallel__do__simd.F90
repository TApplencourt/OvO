PROGRAM target_teams__distribute__parallel__do__simd
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
  !$OMP target teams map(from: src[0:size]) map(to: dst[0:size])
  !$OMP distribute
  DO i0 = 1, N0
    !$OMP parallel
    !$OMP do
    DO i1 = 1, N1
      !$OMP simd
      DO i2 = 1, N2
        idx = i2-1+N2*(i1-1+N1*(i0-1))+1
        dst(idx) = src(idx)
      END DO
    END DO
    !$OMP END parallel
  END DO
  !$OMP END target teams
  IF (ANY(ABS(dst - src) > EPSILON(src))) THEN
    WRITE(*,*)  'Wrong value', MAXVAL(ABS(DST-SRC)), 'max difference'
    STOP 112
  ENDIF
END PROGRAM target_teams__distribute__parallel__do__simd

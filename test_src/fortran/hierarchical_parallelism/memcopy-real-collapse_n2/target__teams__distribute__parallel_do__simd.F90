PROGRAM target__teams__distribute__parallel_do__simd
  INTEGER :: N0 = 8
  INTEGER :: i0
  INTEGER :: N1 = 8
  INTEGER :: i1
  INTEGER :: N2 = 8
  INTEGER :: i2
  INTEGER :: N3 = 8
  INTEGER :: i3
  INTEGER :: N4 = 8
  INTEGER :: i4
  INTEGER :: N5 = 8
  INTEGER :: i5
  INTEGER :: idx
  INTEGER :: S
  REAL, ALLOCATABLE :: src(:)
  REAL, ALLOCATABLE :: dst(:)
  S = N0*N1*N2*N3*N4*N5
  ALLOCATE(dst(S), src(S) )
  CALL RANDOM_NUMBER(src)
  !$OMP target map(from: pS[0:size]) map(to: pD[0:size])
  !$OMP teams
  !$OMP distribute collapse(2)
  DO i0 = 1, N0
  DO i1 = 1, N1
    !$OMP parallel for collapse(2)
    DO i2 = 1, N2
    DO i3 = 1, N3
      !$OMP simd collapse(2)
      DO i4 = 1, N4
      DO i5 = 1, N5
        idx = i5-1+N5*(i4-1+N4*(i3-1+N3*(i2-1+N2*(i1-1+N1*(i0-1)))))+1
        dst(idx) = src(idx)
      END DO
      END DO
    END DO
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

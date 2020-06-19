PROGRAM target__teams__distribute__parallel__do__simd
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
  DOUBLE COMPLEX, ALLOCATABLE :: src(:)
  DOUBLE COMPLEX, ALLOCATABLE :: dst(:)
  REAL, ALLOCATABLE :: src_real(:)
  REAL, ALLOCATABLE :: src_imag(:)
  S = N0*N1*N2*N3*N4*N5
  ALLOCATE(dst(S), src(S) )
  ALLOCATE(src_real(S),src_imag(S))
  CALL RANDOM_NUMBER(src_real)
  CALL RANDOM_NUMBER(src_imag)
  src = CMPLX(src_real,src_imag)
  DEALLOCATE (src_real,src_imag)
  !$OMP target map(from: pS[0:size]) map(to: pD[0:size])
  !$OMP teams
  !$OMP distribute collapse(2)
  DO i0 = 1, N0
  DO i1 = 1, N1
    !$OMP parallel
    !$OMP for collapse(2)
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
    !$OMP END parallel
  END DO
  END DO
  !$OMP END teams
  !$OMP END target
  IF (ANY(ABS(dst - src) > EPSILON(REAL(src)))) THEN
    WRITE(*,*)  'Wrong value', MAXVAL(ABS(DST-SRC)), 'max difference'
    STOP 112
  ENDIF
END PROGRAM target__teams__distribute__parallel__do__simd

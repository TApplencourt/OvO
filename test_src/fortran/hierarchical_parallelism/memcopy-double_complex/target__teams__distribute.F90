PROGRAM target__teams__distribute
  INTEGER :: N0 = 262144
  INTEGER :: i0
  INTEGER :: idx
  INTEGER :: S
  DOUBLE COMPLEX, ALLOCATABLE :: src(:)
  DOUBLE COMPLEX, ALLOCATABLE :: dst(:)
  REAL, ALLOCATABLE :: src_real(:)
  REAL, ALLOCATABLE :: src_imag(:)
  S = N0
  ALLOCATE(dst(S), src(S) )
  ALLOCATE(src_real(S),src_imag(S))
  CALL RANDOM_NUMBER(src_real)
  CALL RANDOM_NUMBER(src_imag)
  src = CMPLX(src_real,src_imag)
  DEALLOCATE (src_real,src_imag)
  !$OMP target map(from: src[0:size]) map(to: dst[0:size])
  !$OMP teams
  !$OMP distribute
  DO i0 = 1, N0
    idx = i0-1+1
    dst(idx) = src(idx)
  END DO
  !$OMP END teams
  !$OMP END target
  IF (ANY(ABS(dst - src) > EPSILON(REAL(src)))) THEN
    WRITE(*,*)  'Wrong value', MAXVAL(ABS(DST-SRC)), 'max difference'
    STOP 112
  ENDIF
END PROGRAM target__teams__distribute

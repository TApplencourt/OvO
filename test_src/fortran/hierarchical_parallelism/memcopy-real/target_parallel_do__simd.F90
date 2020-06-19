PROGRAM target_parallel_do__simd
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
  !$OMP target parallel do map(from: pS[0:size]) map(to: pD[0:size])
  DO i0 = 1, N0
    !$OMP simd
    DO i1 = 1, N1
      idx = i1-1+N1*(i0-1)+1
      dst(idx) = src(idx)
    END DO
  END DO
  IF (ANY(ABS(dst - src) > EPSILON(src))) THEN
    WRITE(*,*)  'Wrong value', MAXVAL(ABS(DST-SRC)), 'max difference'
    STOP 112
  ENDIF
END PROGRAM target_parallel_do__simd

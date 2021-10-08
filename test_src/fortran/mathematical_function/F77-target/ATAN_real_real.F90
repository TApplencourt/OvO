program test_ATAN
   implicit none
   CHARACTER(len=255) :: usr_precision
   INTEGER :: precision = 4
   INTEGER :: stat
   REAL :: in0
   REAL :: out1_device
   CALL GET_ENVIRONMENT_VARIABLE("OVO_TOL_ULP",usr_precision, status=stat)
   IF (stat == 0) THEN
      read(usr_precision, *, iostat=stat) precision
   ENDIF
   in0 = ( 0.42 )
   !$OMP TARGET map(from: out1_device)
       out1_device = ATAN(in0);
   !$OMP END TARGET
    IF ( ABS(TAN(out1_device) - in0) > EPSILON( in0 )*2*precision ) THEN
            write(*,*) 'Expected ', in0, ' Got ', TAN(out1_device)
            STOP 112
    ENDIF
end program test_ATAN

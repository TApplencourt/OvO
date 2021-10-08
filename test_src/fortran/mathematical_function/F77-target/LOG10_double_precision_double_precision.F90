program test_LOG10
   implicit none
   CHARACTER(len=255) :: usr_precision
   INTEGER :: precision = 4
   INTEGER :: stat
   DOUBLE PRECISION :: in0
   DOUBLE PRECISION :: out1_device
   DOUBLE PRECISION :: out1_host
   CALL GET_ENVIRONMENT_VARIABLE("OVO_TOL_ULP",usr_precision, status=stat)
   IF (stat == 0) THEN
      read(usr_precision, *, iostat=stat) precision
   ENDIF
   in0 = ( 0.42 )
   out1_host = LOG10(in0)
   !$OMP TARGET map(from: out1_device)
       out1_device = LOG10(in0);
   !$OMP END TARGET
    IF ( ABS(out1_host-out1_device) > EPSILON( out1_host )*precision ) THEN
        write(*,*) 'Expected ', out1_host, ' Got ', out1_device
        STOP 112
    ENDIF
end program test_LOG10

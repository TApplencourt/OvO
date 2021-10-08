program test_ATAN2
   implicit none
   CHARACTER(len=255) :: usr_precision
   INTEGER :: precision = 4
   INTEGER :: stat
   DOUBLE PRECISION :: in0
   DOUBLE PRECISION :: in1
   DOUBLE PRECISION :: out2_device
   DOUBLE PRECISION :: out2_host
   CALL GET_ENVIRONMENT_VARIABLE("OVO_TOL_ULP",usr_precision, status=stat)
   IF (stat == 0) THEN
      read(usr_precision, *, iostat=stat) precision
   ENDIF
   in0 = ( 0.42 )
   in1 = ( 0.42 )
   out2_host = ATAN2(in0, in1)
   !$OMP TARGET map(from: out2_device)
       out2_device = ATAN2(in0, in1);
   !$OMP END TARGET
    IF ( ABS(out2_host-out2_device) > EPSILON( out2_host )*precision ) THEN
        write(*,*) 'Expected ', out2_host, ' Got ', out2_device
        STOP 112
    ENDIF
end program test_ATAN2

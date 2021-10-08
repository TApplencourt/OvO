program test_AMAX0
   implicit none
   CHARACTER(len=255) :: usr_precision
   INTEGER :: precision = 4
   INTEGER :: stat
   INTEGER :: in0
   INTEGER :: in1
   REAL :: out2_device
   REAL :: out2_host
   CALL GET_ENVIRONMENT_VARIABLE("OVO_TOL_ULP",usr_precision, status=stat)
   IF (stat == 0) THEN
      read(usr_precision, *, iostat=stat) precision
   ENDIF
   in0 = ( 1 )
   in1 = ( 1 )
   out2_host = AMAX0(in0, in1)
   !$OMP TARGET map(from: out2_device)
       out2_device = AMAX0(in0, in1);
   !$OMP END TARGET
    IF ( ABS(out2_host-out2_device) > EPSILON( out2_host )*precision ) THEN
        write(*,*) 'Expected ', out2_host, ' Got ', out2_device
        STOP 112
    ENDIF
end program test_AMAX0

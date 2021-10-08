program test_MIN
   implicit none
   CHARACTER(len=255) :: usr_precision
   INTEGER :: precision = 4
   INTEGER :: stat
   INTEGER :: in0
   INTEGER :: in1
   INTEGER :: out2_device
   INTEGER :: out2_host
   CALL GET_ENVIRONMENT_VARIABLE("OVO_TOL_ULP",usr_precision, status=stat)
   IF (stat == 0) THEN
      read(usr_precision, *, iostat=stat) precision
   ENDIF
   in0 = ( 1 )
   in1 = ( 1 )
   out2_host = MIN(in0, in1)
   !$OMP TARGET map(from: out2_device)
       out2_device = MIN(in0, in1);
   !$OMP END TARGET
    IF ( out2_host.ne.out2_device ) THEN
        write(*,*) 'Expected ', out2_host, ' Got ', out2_device
        STOP 112
    ENDIF
end program test_MIN

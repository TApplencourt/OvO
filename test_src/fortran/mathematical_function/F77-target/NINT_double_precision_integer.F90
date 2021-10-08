program test_NINT
   implicit none
   CHARACTER(len=255) :: usr_precision
   INTEGER :: precision = 4
   INTEGER :: stat
   DOUBLE PRECISION :: in0
   INTEGER :: out1_device
   INTEGER :: out1_host
   CALL GET_ENVIRONMENT_VARIABLE("OVO_TOL_ULP",usr_precision, status=stat)
   IF (stat == 0) THEN
      read(usr_precision, *, iostat=stat) precision
   ENDIF
   in0 = ( 0.42 )
   out1_host = NINT(in0)
   !$OMP TARGET map(from: out1_device)
       out1_device = NINT(in0);
   !$OMP END TARGET
    IF ( out1_host.ne.out1_device ) THEN
        write(*,*) 'Expected ', out1_host, ' Got ', out1_device
        STOP 112
    ENDIF
end program test_NINT

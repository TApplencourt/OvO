program test_CMPLX
   implicit none
   CHARACTER(len=255) :: usr_precision
   INTEGER :: precision = 4
   INTEGER :: stat
   REAL :: in0
   REAL :: in1
   COMPLEX :: out2_device
   COMPLEX :: out2_host
   CALL GET_ENVIRONMENT_VARIABLE("OVO_TOL_ULP",usr_precision, status=stat)
   IF (stat == 0) THEN
      read(usr_precision, *, iostat=stat) precision
   ENDIF
   in0 = ( 0.42 )
   in1 = ( 0.42 )
   out2_host = CMPLX(in0, in1)
   !$OMP TARGET map(from: out2_device)
       out2_device = CMPLX(in0, in1);
   !$OMP END TARGET
    IF ( ABS(out2_host-out2_device) > EPSILON( REAL ( out2_host ) )*precision ) THEN
        write(*,*) 'Expected ', out2_host, ' Got ', out2_device
        STOP 112
    ENDIF
end program test_CMPLX

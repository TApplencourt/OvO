
program target__parallel_loop_for
    USE OMP_LIB

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    REAL :: COUNTER = 0

    
    
    INTEGER :: num_threads
    

     
    
    !$OMP TARGET   MAP(TOFROM: COUNTER) 



    

    
    !$OMP PARALLEL LOOP_DO 


    DO i = 1 , L 


    
    num_threads = omp_get_num_threads()
    

    

!$OMP ATOMIC UPDATE

counter =  counter +1./num_threads


 
     

    END DO

    !$OMP END PARALLEL LOOP_DO
     

    !$OMP END TARGET
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target__parallel_loop_for

program target__parallel_loop_for__simd
    USE OMP_LIB

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    
    REAL :: COUNTER = 0

    
    
    INTEGER :: num_threads
    
     
    
    !$OMP TARGET    MAP(TOFROM: COUNTER) 



    

    
    !$OMP PARALLEL LOOP_DO   REDUCTION(+:COUNTER)  


    DO i = 1 , L 


    
    num_threads = omp_get_num_threads()
    

    
    !$OMP SIMD   REDUCTION(+:COUNTER)  


    DO j = 1 , M 


    

    


counter =  counter +1./num_threads

 
     

    END DO

    !$OMP END SIMD
     

    END DO

    !$OMP END PARALLEL LOOP_DO
     

    !$OMP END TARGET
    

    IF  ( ( ABS(COUNTER - L*M) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L*M Got', COUNTER
        call exit(1)
    ENDIF

end program target__parallel_loop_for__simd
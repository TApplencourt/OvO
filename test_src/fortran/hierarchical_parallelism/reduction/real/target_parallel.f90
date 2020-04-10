
program target_parallel

    USE OMP_LIB

    

    implicit none
  
    
    REAL :: COUNTER =  0   

    
    
    INTEGER :: num_threads
    
     
    
    !$OMP TARGET PARALLEL   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 



    
    num_threads = omp_get_num_threads()
    

    


counter =  counter +  1./num_threads  

 
     

    !$OMP END TARGET PARALLEL
    

    IF  ( ( ABS(COUNTER - 1) ) > 10*EPSILON( COUNTER   ) ) THEN
        write(*,*)  'Expected 1 Got', COUNTER
        call exit(1)
    ENDIF

end program target_parallel
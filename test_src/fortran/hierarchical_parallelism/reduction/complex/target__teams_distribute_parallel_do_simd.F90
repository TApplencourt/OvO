

program target__teams_distribute_parallel_do_simd


    

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    COMPLEX :: COUNTER =  (    0   ,0)  

    
    
     
    
    !$OMP TARGET    MAP(TOFROM: COUNTER) 



    

    
    !$OMP TEAMS DISTRIBUTE PARALLEL DO SIMD   REDUCTION(+:COUNTER)  


    DO i = 1 , L 


    

    


counter = counter +  CMPLX(   1.  ,0)  

 
     

    END DO

    !$OMP END TEAMS DISTRIBUTE PARALLEL DO SIMD
     

    !$OMP END TARGET
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON( REAL(  COUNTER  )   ) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target__teams_distribute_parallel_do_simd
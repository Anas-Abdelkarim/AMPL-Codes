#################################################
# In the name of Allah                          #
#This is a program is written in AMPL to descibe#
# the optimzation problem to find the optimal   #
#switching times and sequence for a switched    #
#system with state jump.                        #
#Date         : 15/9/2019                       # 
#Version      : v1.0                            #
#Written by   : Anas Abdelkarim                 #
#File name    : Model        	                #
#################################################


param N , integer                     ; # The horizon 
param Ts                              ; # the sampling time 
param n_full_maintenance              ;
param n_partial_maintenance           ;
param initial_values {j in 1 ..6}     ; # initial values 


param Q {i in 1..6, j in 1..6}        ; # the system matrix 
									  	  
param Ma {i in 1..6, j in 1..6}       ; # full maintenance
									  										 
param Mb {i in 1..6, j in 1..6}        ; # partial maintenance

var x {i in 1..6 , k in   0..N  } >= 0 ;
var a { k in 0..N-1 } , binary         ; # dynamic vector 
var f { k in 0..N-1 } , binary         ; # full maintenace vector 
var p { k in 0..N-1 } , binary         ; # partial maintenance 


minimize cost_function:
         10000/(2*N)*sum { k in 0..N-1} ( x[3,k]  +  x[3,k+1] + 
 		                  	              x[4,k]  +  x[4,k+1] +
                                          x[5,k]  +  x[5,k+1] +
                                          x[6,k]  + x[6,k+1] );
                                

subject to  dynamics { i in 1..6,k in 0..N-1 } : 
            x[i,k+1] = 
            (a[k] * sum { c in 1..6}  Q[i,c]  * x[c,k]) +
            (f[k] * sum { c in 1..6} Q[i,c]*sum { j in 1..6}  Ma[c,j]*x[j,k])+
            (p[k] * sum { c in 1..6} Q[i,c]*sum { j in 1..6}  Mb[c,j]*x[j,k]);  
     	

subject to int: a[0]=1                                   ;
 
subject to  system_active:
            sum { j in 0..N-1} a[j] =  N - 
            (n_full_maintenance + n_partial_maintenance ); 

subject to  full_maintenance_active:   
            sum { j in 0..N-1} f[j] =  n_full_maintenance;

subject to  Partial_maintenance_active:   
            sum { j in 0..N-1} p[j] =  n_partial_maintenance;  

subject to  one_active { j in 0..N-1}  : 
	    a[j] + f[j] + p[j] = 1;
						  
subject to  initial_values_contrains {i in 1 .. 6}:
            x[i,0] = initial_values[i];  
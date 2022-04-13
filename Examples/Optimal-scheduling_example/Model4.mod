model; redeclare param N integer;
model; redeclare param Ts ;redeclare param n_full_maintenance ;redeclare param n_partial_maintenance ;
model; redeclare param Q {i1 in 1..6, i2 in 1..6} ;redeclare param Ma {i1 in 1..6, i2 in 1..6} ;redeclare param Mb {i1 in 1..6, i2 in 1..6} ;
model; redeclare param initial_values {i1 in 1..6} ;
var x {i in 1..6 , k in   0..N  } >= 0 ;
var a { k in 0..N-1 } , binary         ; # dynamic vector 
var f { k in 0..N-1 } , binary         ; # full maintenace vector 
var p { k in 0..N-1 } , binary         ; # partial maintenance 


redeclare minimize cost_function  :  10000/(2*N)*sum { k in 0..N-1} (                     x[3,k]  +  x[3,k+1] + x[4,k]  +  x[4,k+1] +          x[5,k]  +  x[5,k+1] +  x[6,k]  + x[6,k+1] )         ; 
redeclare subject to dynamics { i in 1..6,k in 0..N-1 } :  x[i,k+1] =                                              (a[k] * sum { c in 1..6}  Q[i,c]  * x[c,k]) +           (f[k] * sum { c in 1..6} Q[i,c]*sum { j in 1..6}  Ma[c,j]*x[j,k])+   (p[k] * sum { c in 1..6} Q[i,c]*sum { j in 1..6}  Mb[c,j]*x[j,k]); 
redeclare subject to int  : a[0]=1 ; 
redeclare subject to system_active  : sum { j in 0..N-1} a[j] =  N - (n_full_maintenance + n_partial_maintenance );
redeclare subject to full_maintenance_active  : sum { j in 0..N-1} f[j] =  n_full_maintenance;
redeclare subject to Partial_maintenance_active  : sum { j in 0..N-1} p[j] =  n_partial_maintenance;
redeclare subject to one_active { j in 0..N-1} :  a[j] + f[j] + p[j] = 1 ; 
redeclare subject to initial_values_contrains  {i in 1 .. 6} : x[i,0] = initial_values[i];
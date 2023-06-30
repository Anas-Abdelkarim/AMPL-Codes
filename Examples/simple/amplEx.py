from amplpy import AMPL, tools

def findOptimal(a,b):
      ampl = AMPL()     

      OP = r"""
      reset; # clear previous definitions 
      model; # declare the model 
      var x;
      param a;
      param b;
      minimize cost: (x-a)**2;
      s.t. constraints: x>=b;
      """
      ampl.eval(OP)

      data = r"""
            data;
            param a :=  %d;
            param b :=  %d;
            """ % (a,b)

      

      ampl.eval(data) # load data

      ampl.eval("option solver kestrel;")
      ampl.eval("option kestrel_options  'solver=cplex';")
      ampl.eval("option email 'anas.abdelkarim@uni.lu';")

      ampl.solve() # solve
      ampl.display("x") # display solution

      ampl.eval("let b :=  0;") # load data
      ampl.solve() # solve
      ampl.display("x") # display solution

      m =ampl.get_variable("x")
      m= m.get_values().to_pandas().values[0][0].astype(int)
      
      return  m

findOptimal(2,3)

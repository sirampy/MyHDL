# simplify and improve IO between nodes:

recieving side no longer cares about input - is all pushed by output node:
- sorces no longer needed
- outputs structure changed

removed used: used is determined by inputs
removed output: redundant

removed error: using die is more readable - dont need a propper error system until i get to the parser

I need a way of translating a string to a class type -> funct. pointers
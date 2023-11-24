# About
An easily extendable regex based hardware description language and it's respective simulation tools

# tests
The tests provides a bunch of examples of how to use this project. they also document the order in which features were added

# logic
Each logic element inherits from wire and extends the evaluate and verify functions
will eventually change wire with a node that raises errors if the child class isn't implemented correctly.

The following have been implemented and tested:
 - new() 
 - add_output() 
 - chain_add_output()
 - add_source() 
 - excec()


Partially implemented and tested:
 - _recieve_input()
 - to_input_array()

TODO:

If there are multiple inputs from the same source, the order is't pre-determined

# error
simply exists to make it easier to change how errors are displayed down the line

# parser
to keep the scope simple, the parser will be a basic regex based one.
support for modules may get added at a later date.

Example syntax:
```
Node_type inputs -> outputs
```
the file should have the extensio .mh for MyHDL.
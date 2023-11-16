package logic_error;

sub raise {
    ($self, $error, $location) = @_;
    die("Error: $error");

}

# wire is the base class - most components inheriting should only update evaluate and verify
package _node;
use strict;

sub new {
    my $class = shift;
    
    my @outputs;
    my @sources;
    my @inputs;
    my @values;

    my $self = {
        outputs => \@outputs,
        sources => \@sources,
        inputs => \@inputs, # -1 if unset
        values => \@values, # current output
        used => -1 # for loop protection
    };

    $self = bless $self, $class;
    return $self; 
}

sub add_output {
    my $self = shift;

    # TODO: validate input

    push @{$self->{outputs}}, @_;
}

# add_outputs + add_source at all outputs
sub chain_add_output(){
    my $self = shift;
    my @args = @_;

    $self -> add_output(@args);

    my $a;
    for $a (@args) {
        $a -> add_source($self);
    }

}

sub add_source {
    my $self = shift;
    my @args = @_;

    # TODO: validate input

    for (@args){
        push @{$self->{inputs}}, -1;
    }
    push @{$self->{sources}}, @args;
}

#TODO:
# takes an array of values and formats it to be compatible with _recieve_input (no order)
sub to_input_array {
    my $self = shift;
    my @input_array;
    my @out = ();

    for (@_){
        my @input = ($self,$_);
        push @out, \@input;
    }
    return @out;
}

# recieve an input and match it to the correct input index
# input is a vector of vector pointers in the form [\$source, val, (order)]
# order exists to diferentiate multiple inputs from the same source - this is not fully supported yet.
sub _recieve_input {
    my $self = shift;

    my @vals = @_;
    my $s = 0;      # source
    my $v;

    my $possible_index;
    my $not_set;
    my $correct_order;

    for $v (@vals){

        my $order = 0;
        my $set = 0;
        $order = @$v[2] if defined(@$v[2]);

        for ($s = 0; $s < ( scalar @{$self->{sources}}); $s++){
            
            $possible_index = (@{$self->{sources}}[$s] == @$v[0]); # here
            $not_set = ($self->{inputs}[$s] == -1);
            $correct_order = ($order == 0);
            
            if ($possible_index and $not_set and $correct_order){
                @{$self->{inputs}}[$s] = @$v[1];
                #@$self->{inputs}[$s] = @$v[1];
                $set = 1;
                last;
            }

            if ($possible_index){
                $order -= 1;
            }
        }

    logic_error->raise("couldn't recieve input: ",@$v) if not $set; # TODO: better error message
    }
}

sub excec { # reset and excecute all dependant logic
    my $self = shift;
    $self->chain_reset();
    # setup input
    $self->_chain_excec(@_);
}


# resets inputs and used of all attatched nodes
sub chain_reset {
    my $self = shift;
    if ($self->{used} != 0){

        $self->{used} = 0;
        for (@{$self->{inputs}}){
            $_ = -1;
        }
        my @values = ();
        $self->{values} = \@values;

        my $out;
        for $out (@{$self->{outputs}}){
            $out->chain_reset();
        }
    }

}

# recieve_input then if all inputs satisfied, _chain_excec next
sub _chain_excec {
    my $self = shift;

    # recieve input
    my @inputs = @_;
    if (scalar @{$self->{sources}} == 0){
        $self->{inputs} = \@inputs;
    }else {
        $self->_recieve_input(@inputs);
    }

    # eval and send outputs

    for (@{$self->{inputs}}){
        return if $_ == -1;
    }

    if ($self->{used}){
        logic_error -> raise("node tried to evaluate twice: ensure there are no loops in async. logic");
    }
    $self->{used} = 1;

    my @out = ($self->evaluate(@{$self->{inputs}}));
    
    if (scalar @out != scalar $self->{outputs}){
        my $evaluated = scalar @out;
        my $needed = scalar @{$self->{outputs}};
        #logic_error -> raise ("mismatched outputs: $evaluated evaluated, but $needed outputs attatched")
    }

    my $i;
    for ($i = 0; $i < scalar @{$self->{outputs}}; $i++){
        my $node = @{$self->{outputs}}[$i];
        my @formated = ($self->to_input_array(@out[$i])); # TODO: error lies here
        $node -> _chain_excec(@formated);
    }

}

# determine object is setup correctly for excec (are the no. of inputs / outputs valid)
sub verify {
    my $self = shift;

    if ({${$self->{inputs}} != ${$self->{outputs}}}){
        logic_error->raise("mismatched number of inputs and outputs");
    }
    
    return 1;
}

sub evaluate {
    my $self = shift;
    logic_error->raise("Node: ",$self," tried to evaluate when no evaluate() has been defined. (if you are using a custom node, ensure you have defined evaluate for it)");
}

# TODO: destructor

package wire;
use base "_node";

sub evaluate {
    my $self = shift;
    my @inputs = @_;
    return @inputs;
}

package and_gate;
use base "_node";

sub excec {
    my $self = shift;
    my @inputs = @_;
    my $product = 1;
    for (@inputs){
        $product = ($product * $_) %2;
    }
    my @out = ();
    for (my $i = 0; $i < scalar @{$self->{outputs}}; $i++){
        push @out, $product;
    }
    return @out;
}

package or_gate;
use base "_node";

sub excec {
    my $self = shift;
    my @inputs = @_;
    my $sum = 0;
    for (@inputs){
        if ($_ == 1) {
            $sum = 1;
        }
    }
    my @out = ();
    for (my $i = 0; $i < scalar @{$self->{outputs}}; $i++){
        push @out, $sum;
    }
    return @out;
}

package xor_gate;
use base "_node";

sub excec {
    my $self = shift;
    my @inputs = @_;
    my $sum = 0;
    for (@inputs){
        $sum = ( $sum + $_ ) % 2;
    }
    my @out = ();
    for (my $i = 0; $i < scalar @{$self->{outputs}}; $i++){
        push @out, $sum;
    }
    return @out;
}
1;
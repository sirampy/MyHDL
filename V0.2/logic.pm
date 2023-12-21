
# wire is the base class - most components inheriting should only update evaluate and verify
package _node;
use strict;

sub new {
    my $class = shift;
    
    my @outputs;
    my @inputs;

     my $self = {
        outputs => \@outputs, # [node_addr, [outputs] indexed by input]
        inputs => \@inputs, # list of recieved input: -1 if unset, 0 or 1 if set
    };

    $self = bless $self, $class;
    return $self; 
}

# test if all inputs have been set
sub used {
    my $self = shift;

    for ($self->{inputs}){
        return 0 if ($_ == -1);
    }

    return 1;
}

# show how manny inputs is being expected
sub input_width {
    my $self = shift;
    return scalar @{$self->{inputs}};
}

# setup output and add to input array
sub add_output {
    my $self = shift;
    my @outputs = @_;

    for (@outputs){
        push @{$self->{outputs}}, $_;
        push @{$_->{inputs}}, -1;
    }

}


# recieve an input and match it to the correct input index
# input is a vector of vector pointers in the form [\$source, val, (order)]
# order exists to diferentiate multiple input from the same source - this is not fully supported yet.
sub _recieve_input {
    # TODO
    return;
}

sub excec { # reset and excecute all dependant logic
    my $self = shift;
    $self->chain_reset();
    # setup input
    $self->_chain_excec(@_);
}


# resets input and used of all attatched nodes
sub chain_reset {
    my $self = shift;
    if ($self->{used} != 0){

        $self->{used} = 0;
        for (@{$self->{input}}){
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

# recieve_input then if all input satisfied, _chain_excec next
sub _chain_excec {
    my $self = shift;

    # recieve input
    my @input = @_;
    if (scalar @{$self->{sources}} == 0){
        $self->{input} = \@input;
    }else {
        $self->_recieve_input(@input);
    }

    # eval and send outputs

    for (@{$self->{input}}){
        return if $_ == -1;
    }

    if ($self->{used}){
        die("node tried to evaluate twice: ensure there are no loops in async. logic");
    }
    $self->{used} = 1;

    my @out = ($self->evaluate(@{$self->{input}}));
    
    if (scalar @out != scalar $self->{outputs}){
        my $evaluated = scalar @out;
        my $needed = scalar @{$self->{outputs}};
        #die ("mismatched outputs: $evaluated evaluated, but $needed outputs attatched")
    }

    my $i;
    for ($i = 0; $i < scalar @{$self->{outputs}}; $i++){
        my $node = @{$self->{outputs}}[$i];
        my @formated = ($self->to_input_array(@out[$i])); # TODO: error lies here
        $node -> _chain_excec(@formated);
    }

}

# determine object is setup correctly for excec (are the no. of input / outputs valid)
sub verify {
    my $self = shift;

    if ({${$self->{input}} != ${$self->{outputs}}}){
        die("mismatched number of input and outputs");
    }
    
    return 1;
}

sub evaluate {
    my $self = shift;
    die("Node: ",$self," tried to evaluate when no evaluate() has been defined. (if you are using a custom node, ensure you have defined evaluate for it)");
}

sub output_width {
    my $self = shift;
    print "warning: output_width not defined, using default definition \n";
    return $self->input_width();
}

# TODO: destructor

package wire;
use base "_node";

sub evaluate {
    my $self = shift;
    my @input = @_;
    return @input;
}

sub output_width {
    my $self = shift;
    return $self->input_width();
}

package and_gate;
use base "_node";

sub excec {
    my $self = shift;
    my @input = @_;
    my $product = 1;
    for (@input){
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
    my @input = @_;
    my $sum = 0;
    for (@input){
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
    my @input = @_;
    my $sum = 0;
    for (@input){
        $sum = ( $sum + $_ ) % 2;
    }
    my @out = ();
    for (my $i = 0; $i < scalar @{$self->{outputs}}; $i++){
        push @out, $sum;
    }
    return @out;
}
1;

# wire is the base class - most components inheriting should only update evaluate and verify
package _node;
use strict;

sub new {
    my $class = shift;
    my $width = shift;
    
    my @outputs;
    my @inputs;

    if (defined $width) {
        @inputs = (-1) x $width;
    }

     my $self = {
        outputs => \@outputs, # [node_addr, [outputs] indexed by input EG: [-1,-1,5] - input[2] = output[5]]
        inputs => \@inputs, # list of recieved input: -1 if unset, 0 or 1 if set
    };

    $self = bless $self, $class;
    return $self; 
}

# test if all inputs have been set
sub used {
    my $self = shift;
    for (@{$self->{inputs}}){
        return 0 if ($_ == -1);
    }

    return 1;
}

# show how manny inputs is being expected
sub input_width {
    my $self = shift;
    return scalar @{$self->{inputs}};
}

sub add_output {
    my ($self, $input_addr, $input, $output) = @_;

    die("input out of range") if $input >= $input_addr->input_width();
    die("output out of range") if $output >= $self->output_width();

    # case that input_addr already has an entry
    for (@{$self->{outputs}}){
        if (@$_[0] == $input_addr){

            if (@{@$_[1]}[$input] != -1){ # TODO
                print "warning: input already set from current source - overwriting\n";
            }

            @{@$_[1]}[$input] = $output;
            return;
        }
    }

    # case that input_addr dosnt have an entry already:
    my $input_width = $input_addr -> input_width();
    my @outputs;

    for (my $i == 0; $i < $input_width; $i++){
        if ($i == $input){
            push @outputs, $output;
        }else{
            push @outputs, -1;
        }
    }

    push @{$self->{outputs}}, [$input_addr, \@outputs];
}

# recieve an input and match it to the correct input index
# input is a vector of vector pointers in the form [val, input]
sub _recieve_input {
    my $self = shift;

    my @entries = @_;

    for (@entries){

        my $val = @$_[0];
        my $input = @$_[1];

        # check if input is set
        die("couldn't recieve input. input: ",@$_[1]," already set.") if (@{$self->{inputs}}[$input] != -1); # TODO: better error message
        
        @{$self->{inputs}}[$input] = $val

    }

}

sub excec { # reset and excecute all dependant logic 
    my $self = shift;
    $self->chain_reset();
    # setup input
    $self->chain_excec(@_);
}


# resets input and used of all attatched nodes 
sub chain_reset {
    my $self = shift;

    my $is_reset = 1;

    for (@{$self->{inputs}}){
        if ($_ != -1){
            $is_reset = 0 ;
            $_ = -1;
        }
    }

    return if $is_reset;

    # reset attatchedd nodes
    for (@{$self->{outputs}}){
        @$_[0]->chain_reset();
    }

}

# recieve_input then if all input satisfied, _chain_excec next 
sub chain_excec {
    my $self = shift;

    # recieve input
    my @input = @_;

    $self->_recieve_input(@input);

    return if not $self->used();

    # eval and send outputs

    my @out = ($self->evaluate(@{$self->{inputs}}));

    for (@{$self->{outputs}}){
        my $node = @$_[0];
        my @entries;
        my @inputs = @{@$_[1]};
        for (my $i = 0; $i < scalar @inputs; $i++){
            push @entries, [$out[$inputs[$i]],$i] if ($inputs[$i] != -1);# val,inuput
        }
        $node->chain_excec(@entries);
    }

}

# determine object is setup correctly for excec (are the no. of input / outputs valid)
sub verify {
    my $self = shift;

    if ({${$self->{inputs}} != ${$self->{outputs}}}){
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

package and;
use base "_node";

sub evaluate {
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

package or;
use base "_node";

sub evaluate {
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

package xor;
use base "_node";

sub evaluate {
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
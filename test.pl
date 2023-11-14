# these are a bunch of tests to ensure my functions do as intended as they are implemented
# they are designed to demonstrate how diferent functions affect the state of the graph
# can all be easily converted to a formal test by adding verification to each function
package logic_tests;

use lib ".";
use logic;
use strict;

sub create_wire {
    my $test = wire->new();
    print "created: $test \n\n";
    return $test;
}

# these tests are informal, so manny require someone to manually verify the output displayed by this function
sub test_attributes {
    my ( $self, $test)  = @_;
    $test = wire->new() if not defined($test);

    print "### DISPLAYING ATTRIBUTES ### \n";

    print "self is: $test \n\n";
    while ( my ($k,$v) = each %$test ) {
        if (ref($v)){
            print "$k => ", @$v, "\n";
        }else{
            print "$k -> $v\n";
        }
    }
    print "\n";
}

# provide args to test with own inputs
sub test_add_output {
    my $self = shift;
    my $test = wire->new();
    my @test_input = @_;

    if (scalar @test_input == 0) {
        push @test_input, wire->new();
        push @test_input, wire->new();
        push @test_input, wire->new();
    }

    print "### ADDING OUTPUTS: ###\n";
    print "self is: $test \n\n";
    
    my $i;
    for $i (@test_input) {
        print $i,"\n";
        $test -> add_output($i);
    }

    print "\n";

    logic_tests->test_attributes($test);
}

# provide args to test with own inputs
sub test_add_source {
    my $self = shift;
    my $test = wire->new();
    my @test_input = @_;

    if (scalar @test_input == 0) {
        push @test_input, wire->new();
        push @test_input, wire->new();
        push @test_input, wire->new();
    }

    print "### ADDING SOURCES: ###\n";
    print "self is: $test \n\n";
    
    my $i;
    for $i (@test_input) {
        print "adding: ", $i,"\n";
        $test -> add_source($i);
    }

    print "\n";

    logic_tests->test_attributes($test);

}

# provide args to test with own inputs
sub test_chain_add_output(){
    my $self = shift;
    my $test = wire->new();
    my @test_input = @_;

    if (scalar @test_input == 0) {
        push @test_input, wire->new();
        push @test_input, wire->new();
        push @test_input, wire->new();
    }

    print "### ADDING OUTPUTS: ###\n";
    print "self is: $test \n\n";
    
    my $i;
    for $i (@test_input) {
        print $i,"\n";
        $test -> chain_add_output($i);
    }

    print "\n";

    logic_tests->test_attributes($test);

    for $i (@test_input) {
        logic_tests->test_attributes($i);
    }
}

# TODO: make a more complex test
# basic test - dosn't test complete functionality
sub test_recieve_input {
    my $self = shift;
    my $test = wire->new();
    my @test_input = @_;
    my @L2_nodes; # level 2 nodes

    if (scalar @test_input == 0) {
        @test_input = (0,1,1,0);
    }

    for (@test_input){
        push @L2_nodes, wire->new();
    }

    print "### ADDING OUTPUTS: ###\n";
    print "self is: $test \n\n";
    
    my $i;
    for $i (@L2_nodes) {
        print $i,"\n";
        $test -> chain_add_output($i);
    }
    print "\n";

    print "### TESTING RECIEVE: ###\n";

    my @formated_test_input = ();

    for $i (@test_input){
        my @row = ($test,$i);
        push @formated_test_input, \@row;
    }

    print "formated test inputs: \n";

    for (@formated_test_input){
        print @$_, "\n";
    }
    print "\n";

    for ($i = 0; $i < scalar (@{$test->{outputs}}); $i++) {
        my @current = @{@formated_test_input[$i]};
        print "sending: ", @current , "\n";
        ${$test->{outputs}}[$i] -> _recieve_input(\@current);
    }
    print "\n";

    for $i (@L2_nodes) {
        logic_tests->test_attributes($i);
    }
}

sub test_evaluate {

}

# some example usages of logic_tests
package example_logic_tests;

sub example_test_attributes {
    my $test = logic_tests->create_wire();
    $test->{used} = 1;
    push @{$test->{inputs}}, 1, 0;
    push @{$test->{inputs}}, 1, 1;
    logic_tests->test_attributes($test);
}

package main;

logic_tests->test_recieve_input();

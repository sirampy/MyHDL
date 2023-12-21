# these are a bunch of tests to ensure my functions do as intended as they are implemented
# they are designed to demonstrate how diferent functions affect the state of the graph
# can all be easily converted to a formal test by adding verification to each function
package logic_tests;

use lib ".";
use logic;
use strict;
use Data::Dumper qw(Dumper);

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

    print Dumper $test;
    
=pod
    print "self is: $test \n\n";
    while ( my ($k,$v) = each %$test ) {
        if (ref($v)){
            if ($k eq "outputs") {
                for (@$v){
                    print "output ", @$_[0] ," << ",@{@$_[1]},"\n";
                }
            }else {
                print "$k => ", @$v, "\n";
            }
        }else{
            print "$k -> $v\n";
        }
    }
    print "\n";
=cut

}

# dosnt test multiple inputs from diferent sources
sub test_add_output {
    my $self = shift;
    my $test = wire->new();
    my @test_input = @_;

    if (scalar @test_input == 0) {
        push @test_input, wire->new();
        push @test_input, wire->new();
        push @test_input, wire->new();
    }

    print "self is: $test \n\n";
    print "### ADDING OUTPUTS: ###\n";

    push @{$test->{input}}, -1;
    
    for (my $i = 0; $i < (scalar @test_input); $i++ ) {
        print $i,": ",@test_input[$i],"\n"; 
        $test -> add_output(@test_input[$i]);
    }

    print "\n";

    logic_tests->test_attributes($test);
}




# TODO: make a more complex test
# basic test - dosn't test complete functionality
sub test_recieve_input {
    return
}

# tests all basic functionality of wire
sub test_wire {
    my $self = shift;

    # setup a chain or wires
    my $in_node = wire -> new;
    my $L1_N0 = wire -> new;
    my $L1_N1 = wire -> new;
    my $out_node = wire -> new;

    $in_node -> chain_add_output($L1_N0,$L1_N1);
    $L1_N0 -> chain_add_output($out_node);
    $L1_N1 -> chain_add_output($out_node);
    
    sub display{
        print "~~~ INPUT: ~~~\n";
        $self->test_attributes($in_node);
        print "~~~ L1->N0: ~~~\n";
        $self->test_attributes($L1_N0);
        print "~~~ L1->N1: ~~~\n";
        $self->test_attributes($L1_N1);
        print "~~~ OUTPUT: ~~~\n";
        $self->test_attributes($out_node);
    }

    print "====INITIAL:====\n";
    display();

    $in_node -> excec(0,1);
    
    print "====EVALUATED:====\n";
    display();
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

package parser_tests;

use lib ".";
use parser;
use strict;

sub test_parse_file {

    my $self = shift;
    my $filename = shift;
    my $filename = "example.mh" if not defined $filename;

    MyHDL->parse_file($filename);
}

package main;

logic_tests->test_add_output();

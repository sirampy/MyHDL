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
sub print_attributes {
    my ( $self, $test)  = @_;
    $test = wire->new() if not defined($test);

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
}

# dosnt test multiple inputs from diferent sources
sub add_output {
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
        push @{@test_input[$i]->{inputs}}, -1;
        print @test_input[$i]," : ",$i,"\n";
        $test -> add_output(@test_input[$i],0,$i);
    }

    print "\n";
    print "### DISPLAYING ATTRIBUTES ### \n";
    logic_tests->print_attributes($test);
}

# chain_reset, _chain_excec + _recieve_input + (excec)
# tests all basic functionality of wire
sub wire {
    my $self = shift;
    my @test_input = @_;

    # setup network
    my $input = wire->new(2);

    my $l1n0 = wire->new(2); # layer 1 node 0
    my $l1n1 = wire->new(1); # layer 1 node 1 ... etc

    my $l2n0 = wire->new(2);
    
    my $output = wire->new(3);

    $input->add_output($l1n0,0,0); #(node,in,out)
    $input->add_output($l1n0,1,1); 
    $input->add_output($l1n1,0,1); 

    $l1n0->add_output($output,0,0);
    $l1n0->add_output($l2n0,0,1);
    $l1n1->add_output($l2n0,1,0);

    $l2n0->add_output($output,1,0);
    $l2n0->add_output($output,2,1);

    print "### INITIAL STATE: ###\n";
    print "INPUT: \n";
    logic_tests->print_attributes($input);
    print "L1: \n";
    logic_tests->print_attributes($l1n0);
    logic_tests->print_attributes($l1n1);
    print "L2: \n";
    logic_tests->print_attributes($l2n0);
    print "OUTPUT: \n";
    logic_tests->print_attributes($output);

    $input->excec([1,0],[0,1]);

    print "### POST EXCEC STATE: ###\n";
    print "INPUT: \n";
    logic_tests->print_attributes($input);
    print "L1: \n";
    logic_tests->print_attributes($l1n0);
    logic_tests->print_attributes($l1n1);
    print "L2: \n";
    logic_tests->print_attributes($l2n0);
    print "OUTPUT: \n";
    logic_tests->print_attributes($output);

    $input->chain_reset();

    print "### POST RESET STATE: ###\n";
    print "INPUT: \n";
    logic_tests->print_attributes($input);
    print "L1: \n";
    logic_tests->print_attributes($l1n0);
    logic_tests->print_attributes($l1n1);
    print "L2: \n";
    logic_tests->print_attributes($l2n0);
    print "OUTPUT: \n";
    logic_tests->print_attributes($output);

}

package example_logic_tests;

sub example_print_attributes {
    my $test = logic_tests->create_wire();
    $test->{used} = 1;
    push @{$test->{inputs}}, 1, 0;
    push @{$test->{inputs}}, 1, 1;
    logic_tests->print_attributes($test);
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

logic_tests->wire();

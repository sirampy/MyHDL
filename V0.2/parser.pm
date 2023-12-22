package nodeDescriptor;

use lib ".";
use logic;
use strict;

sub new {
    my $class = shift;

    my ($node,$inputs,$outputs) = shift;
    my %node_types = {
        wire => \&wire->new,
        and => \&and->new,
        or => \&or->new,
        xor => \&xor->new
    };

    my $self = {
        in_labels => $inputs,
        out_labels => $outputs,
        node => &{%node_types{$type}}(scalar @$inputs) # for now we assume each wire has a width of 1
    };

    $self = bless $self, $class;
    return $self; 
}

package MyHDL;

use lib ".";
use logic;
use strict;

sub readLine {
    my $line = shift;

    my @inputs;
    my @outputs;
    
    my ($node, $inputs_raw, $outputs_raw) = ($line =~ m/(\w+)\s+([^->]+)\s*->\s*([^->]+)/);

    @inputs = ($inputs_raw =~ m/([a-zA-Z]\w*)/g);
    @outputs = ($outputs_raw =~ m/([a-zA-Z]\w*)/g);

    return ($node, \@inputs, \@outputs);
}

sub parse_file {
    my $self = shift;
    my $filename = shift;

    print $filename, "\n";

    open(FH, '<', $filename) or error->raise("couldn't open: $filename \n"); #TODO: raise error

    my @node_list;
    my %wires; # points to an array of outputs 

    while(<FH>){
        my ($node,$inputs,$outputs) = readLine($_);

        my $node_descriptor = nodeDescriptor->new($node,$inputs,$outputs);
        %wires{$outputs[0]} = []; 
        for(@$inputs){
            push @{%wires{$_}}, $node_descriptor;
        }
        push @node_list, $node_descriptor;

    }

    for (@node_list){
        my @outs = @{$_->{out_labels}};
        my $node = $_->{node};
        for (my $output = 0; $output < scalar @outs; $output++){
            my $wire = @outs[$output];
            my @attatched_nodes = %wires{wire};
            for (@attatched_nodes){
                # add_output  $input_addr, $input, $output
            }
        }
        # TODO: go through node_list and connect outputs
    }
}

sub main {

}

1;
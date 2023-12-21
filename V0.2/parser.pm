package nodeDescriptor;

use lib ".";
use logic;
use strict;

sub new {
    my $class = shift;

    my $self = {
        inLabels => (),
        outLabels => (),
        type => 
    };

    $self = bless $self, $class;
    return $self; 
}

package MyHDL;

use lib ".";
use logic;
use strict;

# returns (node,inputs[], outputs[])

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

    while(<FH>){
        my ($a,$b,$c) = readLine($_);
    }
}

sub main {

}

1;
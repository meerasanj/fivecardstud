package Card;

use strict;
use warnings;
use Carp; # For error handling

# Card constructor 
sub new {
	my ($class, $rank, $suit) = @_;
	my $self = bless {}, $class;

	$self->{rank} = rank_to_int($rank);
	$self->{suit} = $suit;

	return $self;
}

# Method to convert a rank string to an integer representation
sub rank_to_int {
	my $rank_str = shift;
	
	croak "Expected a string for rank" unless defined $rank_str && $rank_str =~ /^\d+$|^[JQKA]$/;

	return 10 if $rank_str eq "10";
    	return 11 if $rank_str eq "J";
    	return 12 if $rank_str eq "Q";
    	return 13 if $rank_str eq "K";
    	return 14 if $rank_str eq "A";
    	return $rank_str if $rank_str =~ /^[2-9]$/;

    	croak "Invalid rank: $rank_str";
}

# Method to convert numeric ranks back to string representation
sub rank_to_string {
	my $rank = shift;

	return 'A' if $rank == 14 || $rank == 1;
    	return 'K' if $rank == 13;
    	return 'Q' if $rank == 12;
    	return 'J' if $rank == 11;
    	return "$rank" if $rank >= 2 && $rank <= 10;

    	croak "Invalid rank: $rank";
}

# Method to create a string representation of the card 
sub to_string {
    	my $self = shift;
    	my $rank_str = rank_to_string($self->{rank});
    	return $rank_str . $self->{suit};
}

1; 


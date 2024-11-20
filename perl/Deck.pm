package Deck;
use strict;
use warnings;
use Card;
use List::Util 'shuffle';

# Deck constructor
sub new {
	my $class = shift;
    	my $self = { cards => [] };
    	bless $self, $class;
    	$self->create_deck();
    	return $self;
}

# creates a deck of 52 cards
sub create_deck {
	my $self = shift;
    	my @suits = ('H', 'D', 'C', 'S');
    	my @ranks = ('2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A');

	foreach my $suit (@suits) {
        	foreach my $rank (@ranks) {
            		push @{$self->{cards}}, Card->new($rank, $suit);
        	}
    	}
}

# shuffles the deck
sub shuffle_deck {
	my ($self) = @_;
	$self->{cards} = [shuffle @{ $self->{cards} }];
}

# deals 6 hands of 5 cards
sub deal_hands {
    	my ($self, $hands) = @_;
    	for (1..5) {    # Deal 5 cards
        	foreach my $hand (@$hands) {
            		push @$hand, shift @{$self->{cards}};
        	}
    	}
}

# Prints the deck, optionally in a single line
sub print_deck {
    	my ($self, $single_line) = @_;
    	my $count = 0;

    	foreach my $card (@{$self->{cards}}) {
        	print $card->to_string() . " ";
        	$count++;
        	print "\n" if !$single_line && $count % 13 == 0;
    	}
    	print "\n";
}

1;


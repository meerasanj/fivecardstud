use strict;
use warnings;
use lib '.'; 
use List::Util qw(shuffle); # for sortHands
use Deck;

# Suit constants and ranking
use constant {
	DIAMONDS => 'D',
    	CLUBS    => 'C',
    	HEARTS   => 'H',
    	SPADES   => 'S',
};

my %SUIT_RANKING = (
    	DIAMONDS => 1,
    	CLUBS    => 2,
    	HEARTS   => 3,
    	SPADES   => 4,
);

# Hand rank constants
use constant {
    	HIGH_CARD       => 1,
    	PAIR            => 2,
    	TWO_PAIR        => 3,
    	THREE_OF_A_KIND => 4,
    	STRAIGHT        => 5,
    	FLUSH           => 6,
    	FULL_HOUSE      => 7,
    	FOUR_OF_A_KIND  => 8,
    	STRAIGHT_FLUSH  => 9,
    	ROYAL_FLUSH     => 10,
};

our @HAND_RANKS = (
    	HIGH_CARD,
    	PAIR,
    	TWO_PAIR,
    	THREE_OF_A_KIND,
    	STRAIGHT,
    	FLUSH,
    	FULL_HOUSE,
    	FOUR_OF_A_KIND,
    	STRAIGHT_FLUSH,
    	ROYAL_FLUSH,
);

# Convert hand rank to string
sub hand_rank_to_string {
    	my ($rank) = @_;
    	return "High Card"       	if $rank == HIGH_CARD;
    	return "Pair"            	if $rank == PAIR;
    	return "Two Pair"        	if $rank == TWO_PAIR;
    	return "Three Of A Kind" 	if $rank == THREE_OF_A_KIND;
    	return "Straight"        	if $rank == STRAIGHT;
    	return "Flush"           	if $rank == FLUSH;
    	return "Full House"      	if $rank == FULL_HOUSE;
    	return "Four Of A Kind"  	if $rank == FOUR_OF_A_KIND;
    	return "Straight Flush"  	if $rank == STRAIGHT_FLUSH;
    	return "Royal Straight Flush"   if $rank == ROYAL_FLUSH;
    	return "Unknown";
}

# main method to handle overall program flow 
sub main {
	my @args = @ARGV;  # Get command-line arguments
	my $deck = Deck->new();
	my @hands = ([], [], [], [], [], []);

	print("*** P O K E R    H A N D    A N A L Y Z E R ***\n\n\n");
	
	if (@args) {  # Part 2: Using a test deck with command-line arguments
		my $filename = $args[0];
        	print "*** USING TEST DECK ***\n";
        	print "\n*** File: $filename\n";
		if (!read_deck_from_file($filename, \@hands)) {
			return;
		}
	} else { # Part 1: Randomized deck without command-line arguments
		print("*** USING RANDOMIZED DECK OF CARDS ***\n\n");
		$deck->shuffle_deck();
		print("*** Shuffled 52 card deck:\n");
		$deck->print_deck(0); 
		$deck->deal_hands(\@hands);
		print_six_hands(\@hands);
		print("*** Here is what remains in the deck...\n");
		$deck->print_deck(1);
		print("\n");
	}

	my $hand_ranks = sort_hands(\@hands);
	print_winning_hand(\@hands, $hand_ranks);
}

main();	

# to print 6 hands of 5 cards 
sub print_six_hands {
    	my ($hands) = @_;
    	print "*** Here are the six hands...\n";
    
    	for my $i (0..5) {
        	my $hand = $hands->[$i];
        	my @card_strings = map { $_->to_string() } @$hand;
        	print join(" ", @card_strings) . "\n";
    	}
    
    	print "\n";
}

# to print the winning hand order based on hand ranks
sub print_winning_hand {
    	my ($hands, $hand_ranks) = @_;
	print "--- WINNING HAND ORDER ---\n";
    
	for my $i (0 .. $#$hands) {
        	my $hand = $hands->[$i];
        	my @card_strings = map { $_->to_string() } @$hand;
        	my $hand_string = join(" ", @card_strings);
        	print "$hand_string - " . hand_rank_to_string($hand_ranks->[$i]) . "\n";
    	}
    	print "\n"; 
}

# method to handle command line args
sub read_deck_from_file {
    	my ($filename, $hands) = @_;
    	my %seen_cards;

	open(my $file, '<', $filename) or do {
        	print "Error: The file $filename was not found.\n";
        	return;
    	};

    	my @lines = <$file>;
    	close $file;

    	foreach my $line (@lines) {
        	print $line; # display line to user 
	}

	for my $i (0 .. 5) {
        	my @card_strings = split /,/, $lines[$i];
        	foreach my $card_str (@card_strings) {
            		$card_str =~ s/^\s+|\s+$//g;	# trim whitespace
			
			# Check for duplicate card
			if ($seen_cards{$card_str}) {
                		print "\n*** ERROR - DUPLICATED CARD FOUND IN DECK ***\n";
                		print "\n\n*** DUPLICATE: $card_str ***\n";
                		return;
            		}
            
            		$seen_cards{$card_str} = 1;
            		my $suit = substr($card_str, -1);
            		my $rank_str = substr($card_str, 0, -1);

            		push @{$hands->[$i]}, Card->new($rank_str, $suit);
        	}
    	}

    	print "\n";
    	print_six_hands($hands);
    
    	return $hands;
}

# sorts hands based on their rank using the compare_hands function
sub sort_hands {
	my ($hands) = @_;
    	my @hand_ranks;

	@$hands = sort { compare_hands($b, $a) } @$hands;
	foreach my $hand (@$hands) {
		my $hand_rank = classify_hand($hand);
		push @hand_ranks, $hand_rank;
	}

	return \@hand_ranks;
}

# determines ie the hand is a straight (considers Ace-Low case)
sub is_straight {
    	my ($hand) = @_;
    	my %ranks;

    	foreach my $card (@$hand) {
        	$ranks{$card->{rank}} = 1;
    	}

    	my @sorted_ranks = sort { $a <=> $b } keys %ranks;

    	return 1 if @sorted_ranks == 5 && join(",", @sorted_ranks) eq "2,3,4,5,14";

    	for my $i (0 .. $#sorted_ranks - 1) {
        	return 0 if $sorted_ranks[$i + 1] - $sorted_ranks[$i] != 1;
    	}

    	return 1;
}

# classifies the rank of the hand
sub classify_hand {
    	my ($hand) = @_;
    	my @hand_copy = sort { $b->{rank} <=> $a->{rank} } @$hand;
    	my @occurrences = (0) x 15;
    	my %suits;

    	foreach my $card (@hand_copy) {
        	$occurrences[$card->{rank}]++;
        	$suits{$card->{suit}}++;
    	}

    	my $flush = grep { $_ == 5 } values %suits;
    	my $straight = is_straight(\@hand_copy);

    	if ($flush && $straight) {
        	my %unique_ranks = map { $_->{rank} => 1 } @hand_copy;
        	return ROYAL_FLUSH if join(",", sort { $a <=> $b } keys %unique_ranks) eq "10,11,12,13,14";
        	return STRAIGHT_FLUSH;
    	}

    	my ($three_count, $pair_count) = (0, 0);

    	foreach my $count (@occurrences[2 .. $#occurrences]) {
        	$three_count++ if $count == 3;
        	$pair_count++ if $count == 2;
        	return FOUR_OF_A_KIND if $count == 4;
    	}

    	return FULL_HOUSE      if $three_count == 1 && $pair_count == 1;
    	return FLUSH           if $flush;
    	return STRAIGHT        if $straight;
    	return THREE_OF_A_KIND if $three_count == 1;
    	return TWO_PAIR        if $pair_count == 2;
    	return PAIR            if $pair_count == 1;

    	return HIGH_CARD;
}

# Checks if a hand is an Ace-Low Straight (A, 2, 3, 4, 5)
sub is_ace_low_straight {
    	my ($hand) = @_;
    	my %ranks = map { $_->{rank} => 1 } @$hand;
    	return exists $ranks{14} && exists $ranks{2} && exists $ranks{3} && exists $ranks{4} && exists $ranks{5};
}

# Returns the highest card in the hand, considering the Ace-Low Straight case
sub get_highest_card {
	my ($hand, $is_ace_straight) = @_;
	my @temp_hand = map { { %$_ } } @$hand;  # Copy hand to avoid modifying the original

	if ($is_ace_straight) {
        	foreach my $card (@temp_hand) {
            		$card->{rank} = 1 if $card->{rank} == 14;
        	}
    	}

    	my $highest_card = $temp_hand[0];
    	for my $i (1 .. $#temp_hand) {
        	if ($temp_hand[$i]{rank} > $highest_card->{rank}) {
            		$highest_card = $temp_hand[$i];
        	}
    	}
    	return $highest_card;
}

# Counts the number of occurrences of a specific rank in the hand
sub count_occurrences {
    	my ($hand, $rank) = @_;
    	my $count = 0;
    	foreach my $card (@$hand) {
        	$count++ if $card->{rank} == $rank;
    	}
    	return $count;
}

# Returns the highest non-pair card 
sub get_highest_non_pair_card {
    	my ($hand) = @_;
    	my @temp_hand;

    	foreach my $card (@$hand) {
        	if (count_occurrences($hand, $card->{rank}) != 2) {
            		push @temp_hand, $card;
        	}
    	}

    	return unless @temp_hand;

    	my $highest_card = $temp_hand[0];
    	foreach my $card (@temp_hand[1 .. $#temp_hand]) {
        	if ($card->{rank} > $highest_card->{rank}) {
            		$highest_card = $card;
        	}
    	}

    	return $highest_card;
}

# Identifies and returns the index of the kicker card in the hand
sub get_kicker {
    	my ($hand) = @_;
    	my $max_val = 0;
    	my $kicker_index = -1;

    	foreach my $index (0 .. $#$hand) {
        	my $card = $hand->[$index];
        	if (count_occurrences($hand, $card->{rank}) == 1 && $card->{rank} > $max_val) {
            		$max_val = $card->{rank};
            		$kicker_index = $index;
        	}
    	}

    	return $kicker_index;
}

# Gets the rank (value) of the pair in the hand
sub get_pair_rank {
    	my ($hand) = @_;
    	foreach my $card (@$hand) {
        	if (count_occurrences($hand, $card->{rank}) == 2) {
            		return $card->{rank};
        	}
    	}
    	return -1;
}

# Gets the highest rank (value) of pairs in a hand
sub get_highest_pair_rank {
    	my ($hand) = @_;
    	my $highest_pair = -1;

    	foreach my $card (@$hand) {
        	if (count_occurrences($hand, $card->{rank}) == 2 && $card->{rank} > $highest_pair) {
            		$highest_pair = $card->{rank};
        	}
    	}

    	return $highest_pair;
}

# Gets the lowest rank (value) of pairs in a hand
sub get_lowest_pair_rank {
    	my ($hand) = @_;
    	my $lowest_pair = 15;

    	foreach my $card (@$hand) {
        	if (count_occurrences($hand, $card->{rank}) == 2 && $card->{rank} < $lowest_pair) {
            		$lowest_pair = $card->{rank};
        	}
    	}

    	if ($lowest_pair == 15) {
        	return -1;
    	} else {
        	return $lowest_pair;
    	}
}

# Gets the rank of the three-of-a-kind in a hand
sub get_triplet_rank {
    	my ($hand) = @_;

    	foreach my $card (@$hand) {
        	if (count_occurrences($hand, $card->{rank}) == 3) {
            		return $card->{rank};
        	}
    	}

    	return -1;
}

# Gets the rank of the four-of-a-kind in a hand
sub get_quad_rank {
    	my ($hand) = @_;

    	foreach my $card (@$hand) {
        	if (count_occurrences($hand, $card->{rank}) == 4) {
            		return $card->{rank};
        	}
    	}

    	return -1;
}

# Method to compare two hands and determine the winner
sub compare_hands {
    	my ($hand1, $hand2) = @_;
    	my $rank1 = classify_hand($hand1);
    	my $rank2 = classify_hand($hand2);

    	if ($rank1 != $rank2) {
        	if ($rank1 < $rank2) {
            		return -1;
        	} else {
            		return 1;
        	}
    	}

	# Tie-breaking logic based on hand rank
	
	# Case 1: Flush, Straight Flush, Royal Flush
	if ($rank1 == FLUSH || $rank1 == STRAIGHT_FLUSH || $rank1 == ROYAL_FLUSH) {
        	my $highest_card1 = get_highest_card($hand1, 0);
        	my $highest_card2 = get_highest_card($hand2, 0);

        	if ($highest_card1->{rank} != $highest_card2->{rank}) {
            		if ($highest_card1->{rank} < $highest_card2->{rank}) {
                		return -1;
            		} else {
                		return 1;
            	}
        	}
        	if ($highest_card1->{suit} lt $highest_card2->{suit}) {
            		return -1;
        	} else {
            		return 1;
        	}
    	}

	# Case 2: Straight
	if ($rank1 == STRAIGHT) {
        	my $check_ace1 = is_ace_low_straight($hand1);
        	my $check_ace2 = is_ace_low_straight($hand2);

        	my $highest_card1 = get_highest_card($hand1, $check_ace1);
        	my $highest_card2 = get_highest_card($hand2, $check_ace2);
	
        	if ($highest_card1->{rank} != $highest_card2->{rank}) {
            		if ($highest_card1->{rank} < $highest_card2->{rank}) {
                		return -1;
            		} else {
                		return 1;
            		}
        	}
        	if ($highest_card1->{suit} lt $highest_card2->{suit}) {
            		return -1;
        	} else {
            		return 1;
        	}
    	}

	# Case 3: Two Pair
	if ($rank1 == TWO_PAIR) {
        	my $high_pair1 = get_highest_pair_rank($hand1);
        	my $high_pair2 = get_highest_pair_rank($hand2);

        	if ($high_pair1 != $high_pair2) {
            		if ($high_pair1 < $high_pair2) {
                		return -1;
            		} else {
                		return 1;
            		}
        	}

        	my $low_pair1 = get_lowest_pair_rank($hand1);
        	my $low_pair2 = get_lowest_pair_rank($hand2);

        	if ($low_pair1 != $low_pair2) {
            		if ($low_pair1 < $low_pair2) {
                		return -1;
            		} else {
                		return 1;
            		}
        	}

        	my $kicker1 = get_kicker($hand1);
        	my $kicker2 = get_kicker($hand2);
        	if ($hand1->[$kicker1]->{suit} lt $hand2->[$kicker2]->{suit}) {
            		return -1;
        	} else {
            		return 1;
        	}
    	}
	
	# Case 4: Pair
	if ($rank1 == PAIR) {
        	my $pair_rank1 = get_pair_rank($hand1);
        	my $pair_rank2 = get_pair_rank($hand2);

        	if ($pair_rank1 != $pair_rank2) {
            		if ($pair_rank1 < $pair_rank2) {
                		return -1;
            		} else {
                		return 1;
            		}
        	}

        	my $high_val1 = get_highest_non_pair_card($hand1);
        	my $high_val2 = get_highest_non_pair_card($hand2);

        	if ($high_val1->{rank} != $high_val2->{rank}) {
            		if ($high_val1->{rank} < $high_val2->{rank}) {
                		return -1;
            		} else {
                		return 1;
            		}
        	}
        	if ($high_val1->{suit} lt $high_val2->{suit}) {
            		return -1;
        	} else {
            		return 1;
        	}
    	}

	# Case 5: High Card
	if ($rank1 == HIGH_CARD) {
        	my $highest_card1 = get_highest_card($hand1, 0);
        	my $highest_card2 = get_highest_card($hand2, 0);

        	if ($highest_card1->{rank} != $highest_card2->{rank}) {
            		if ($highest_card1->{rank} < $highest_card2->{rank}) {
                		return -1;
            		} else {
                		return 1;
            		}
        	}
        	if ($highest_card1->{suit} lt $highest_card2->{suit}) {
            		return -1;
        	} else {
            		return 1;
        	}
    	}

	# Additional Cases: Three of a Kind, Four of a Kind, Full House
	if ($rank1 == FOUR_OF_A_KIND) {
        	my $quad_rank1 = get_quad_rank($hand1);
        	my $quad_rank2 = get_quad_rank($hand2);
        	if ($quad_rank1 < $quad_rank2) {
            		return -1;
        	} else {
            		return 1;
        	}
    	}

    	if ($rank1 == THREE_OF_A_KIND) {
        	my $triplet_rank1 = get_triplet_rank($hand1);
        	my $triplet_rank2 = get_triplet_rank($hand2);
        	if ($triplet_rank1 < $triplet_rank2) {
            		return -1;
        	} else {
            		return 1;
        	}
    	}

    	if ($rank1 == FULL_HOUSE) {
        	my $triplet_rank1 = get_triplet_rank($hand1);
        	my $triplet_rank2 = get_triplet_rank($hand2);

        	if ($triplet_rank1 != $triplet_rank2) {
            		if ($triplet_rank1 < $triplet_rank2) {
                		return -1;
            		} else {
                		return 1;
            		}
        	}

        	my $pair_rank1 = get_pair_rank($hand1);
        	my $pair_rank2 = get_pair_rank($hand2);
        	if ($pair_rank1 < $pair_rank2) {
            		return -1;
        	} else {
            		return 1;
        	}
    	}

    return 0;
}

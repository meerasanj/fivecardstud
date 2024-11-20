# FiveCardStud.jl

include("Card.jl")
include("Deck.jl")

using .DeckModule
using .CardModule

# Define HandRank as an Enum
@enum HandRank HIGH_CARD PAIR TWO_PAIR THREE_OF_A_KIND STRAIGHT FLUSH FULL_HOUSE FOUR_OF_A_KIND STRAIGHT_FLUSH ROYAL_FLUSH

# Function to map hand ranks to strings
handRankToString = Dict(
    	HIGH_CARD => "High Card",
    	PAIR => "Pair",
    	TWO_PAIR => "Two Pair",
    	THREE_OF_A_KIND => "Three Of A Kind",
    	STRAIGHT => "Straight",
    	FLUSH => "Flush",
    	FULL_HOUSE => "Full House",
    	FOUR_OF_A_KIND => "Four Of A Kind",
    	STRAIGHT_FLUSH => "Straight Flush",
    	ROYAL_FLUSH => "Royal Straight Flush"
)

# create Dict for suit ranking lowest to highest: Diamonds, Clubs, Hearts, Spades.
function suit_rank(suit::Char)::Int
    	return Dict('D' => 1, 'C' => 2, 'H' => 3, 'S' => 4)[suit]
end

# Function to print the six hands of cards
function print_six_hands(hands::Vector{Vector{Card}})
	println("*** Here are the six hands...")
	for (i, hand) in enumerate(hands)
		println(join([to_string(card) for card in hand], " "))
	end
	println()
end

# Function to print winning hand order with hand ranks
function print_winning_hand(hands::Vector{Vector{Card}}, handRanks::Vector{HandRank})
    	println("--- WINNING HAND ORDER ---")
    	for i in 1:length(hands)
        	println(join([to_string(card) for card in hands[i]], " "), " - ", handRankToString[handRanks[i]])
    	end
end

# Sort hands based on rank
function sort_hands(hands::Vector{Vector{Card}}, handRanks::Vector{HandRank})
	sorted_hands = sort(hands, lt = (hand1, hand2) -> compare_hands(hand1, hand2))
	empty!(handRanks)
	
	for hand in sorted_hands
        	rank = classify_hand(hand)
        	push!(handRanks, rank)
    	end

    	return sorted_hands
end

# Function to check if a hand is a straight
function is_straight(hand::Vector{Card})
	#temp_hand = sort([card for card in hand], by = x -> x.rank)
	ranks = [card.rank for card in hand]
	sorted_ranks = sort(ranks)

	# Special check for Ace-low straight (A, 2, 3, 4, 5)
	if sorted_ranks == [2, 3, 4, 5, 14]
		return true
	end
	
	for i in 1:(length(sorted_ranks) - 1)
        	if sorted_ranks[i + 1] != sorted_ranks[i] + 1
            		return false
        	end
    	end

    	return true
end

# Check if a hand is an Ace-low straight
function is_ace_low_straight(hand::Vector{Card})::Bool
	for card in hand
        	if card.rank == 14
            		return true  # Ace is present
        	end
    	end
    	return false
end

# Get the highest card, includes case of Ace-low straight
function get_highest_card(hand::Vector{Card}, isAceStraight::Bool)::Card
	highest_card = hand[1]
    	
	# Treat Ace as 1 if isAceStraight is true

	if isAceStraight && highest_card.rank == 14
        	highest_rank = 1
    	else
        	highest_rank = highest_card.rank
    	end

    	for i in 2:length(hand)
        	current_card = hand[i]
        	if isAceStraight && current_card.rank == 14
            		current_rank = 1
        	else
            		current_rank = current_card.rank
        	end

        	if current_rank > highest_rank
            		highest_card = current_card
            		highest_rank = current_rank
        	end
    	end
    	return highest_card
end

# Count occurrences of a specific rank in a hand
function count_occurrences(hand::Vector{Card}, rank::Int)::Int
	count = 0
    	for card in hand
        	if card.rank == rank
            		count += 1
        	end
    	end
    	return count
end

# Get the highest card not part of a pair
function get_highest_non_pair_card(hand::Vector{Card})::Card
	temp_hand = Card[]
    
    	for card in hand
        	if count_occurrences(hand, card.rank) != 2
            		push!(temp_hand, card)
        	end
    	end

    	highest_card = temp_hand[1]
    	for i in 2:length(temp_hand)
        	if temp_hand[i].rank > highest_card.rank
            		highest_card = temp_hand[i]
        	end
    	end
    
	return highest_card
end

# Identify index of kicker card in a hand (not part of pair)
function get_kicker(hand::Vector{Card})::Int
	max_val = 0
	kicker_index = -1

	for i in 1:length(hand)
		card = hand[i]
		if count_occurrences(hand, card.rank) == 1 && card.rank > max_val
			max_val = card.rank
			kicker_index = i
		end
	end
	
	return kicker_index
end

# Get the rank of the pair in a hand
function get_pair_rank(hand::Vector{Card})::Int
	for card in hand
        	if count_occurrences(hand, card.rank) == 2
            		return card.rank
        	end
    	end
    	return -1
end

# Get the highest rank of pairs in a hand
function get_highest_pair_rank(hand::Vector{Card})::Int
	highest_pair = -1
    	for card in hand
        	if count_occurrences(hand, card.rank) == 2 && card.rank > highest_pair
            		highest_pair = card.rank
        	end
    	end
    	return highest_pair
end

# Get the lowest rank of pairs in a hand
function get_lowest_pair_rank(hand::Vector{Card})::Int
	lowest_pair = 15
    	for card in hand
        	if count_occurrences(hand, card.rank) == 2 && card.rank < lowest_pair
            		lowest_pair = card.rank
        	end
    	end
    	return lowest_pair
end

# Get the rank of the three-of-a-kind in a hand
function get_triplet_rank(hand::Vector{Card})::Int
	for card in hand
        	if count_occurrences(hand, card.rank) == 3
            		return card.rank
        	end
    	end
    	return -1
end

# Get the rank of the four-of-a-kind in a hand
function get_quad_rank(hand::Vector{Card})::Int
	for card in hand
        	if count_occurrences(hand, card.rank) == 4
            		return card.rank
        	end
    	end
    	return -1
end

# to classify a hand with its HandRank
function classify_hand(hand::Vector{Card})::HandRank
	sort(hand, by=x -> x.rank, rev=true)  # Sort in descending order

	occurrences = fill(0, 15)
	suit_count = Dict('D' => 0, 'C' => 0, 'H' => 0, 'S' => 0)

	for card in hand
		occurrences[card.rank] += 1
		suit_count[card.suit] += 1
	end

	flush = any(count == 5 for count in values(suit_count))
	straight = is_straight(hand)

	if flush && straight
		royal_ranks = Set([14, 13, 12, 11, 10])
		hand_ranks = Set([card.rank for card in hand])

		if hand_ranks == royal_ranks
			return ROYAL_FLUSH
		else
			return STRAIGHT_FLUSH
		end
	end

	three_count = 0
    	pair_count = 0
    	for rank in 2:14
        	if occurrences[rank] == 4
            		return FOUR_OF_A_KIND
        	elseif occurrences[rank] == 3
            		three_count += 1
        	elseif occurrences[rank] == 2
            		pair_count += 1
        	end
    	end

    	if three_count == 1 && pair_count == 1
        	return FULL_HOUSE
    	elseif flush
        	return FLUSH
    	elseif straight
        	return STRAIGHT
    	elseif three_count == 1
        	return THREE_OF_A_KIND
    	elseif pair_count == 2
        	return TWO_PAIR
    	elseif pair_count == 1
        	return PAIR
    	else
        	return HIGH_CARD
    	end
end

# compare two hands to determine the winner
function compare_hands(hand1::Vector{Card}, hand2::Vector{Card})::Bool
	rank1 = classify_hand(hand1)
	rank2 = classify_hand(hand2)

	if rank1 != rank2
        	return rank1 > rank2
    	end

	# Tie-breaking logic for equal strength hands

	# Case 1: Flush
	if rank1 in [FLUSH, STRAIGHT_FLUSH, ROYAL_FLUSH]
        	highestCard1 = get_highest_card(hand1, false)
        	highestCard2 = get_highest_card(hand2, false)

        	if highestCard1.rank != highestCard2.rank
            		return highestCard1.rank > highestCard2.rank
        	end
		return suit_rank(highestCard1.suit) > suit_rank(highestCard2.suit)
    	end

	# Case 2: Straights
	if rank1 == STRAIGHT
        	ace_low1 = is_ace_low_straight(hand1)
        	ace_low2 = is_ace_low_straight(hand2)

        	highestCard1 = get_highest_card(hand1, ace_low1)
        	highestCard2 = get_highest_card(hand2, ace_low2)

		return suit_rank(highestCard1.suit) > suit_rank(highestCard2.suit)
    	end

	# Case 3: Two Pair 
	if rank1 == TWO_PAIR
        	highPair1 = get_highest_pair_rank(hand1)
        	highPair2 = get_highest_pair_rank(hand2)

        	if highPair1 != highPair2
            		return highPair1 > highPair2
        	end

        	lowPair1 = get_lowest_pair_rank(hand1)
        	lowPair2 = get_lowest_pair_rank(hand2)

        	if lowPair1 != lowPair2
            		return lowPair1 > lowPair2
        	end

        	kicker1 = get_kicker(hand1)
        	kicker2 = get_kicker(hand2)

		return suit_rank(hand1[kicker1].suit) > suit_rank(hand2[kicker2].suit)
    	end

	# Case 4: Pair
	if rank1 == PAIR
        	pairRank1 = get_pair_rank(hand1)
        	pairRank2 = get_pair_rank(hand2)

        	if pairRank1 != pairRank2
            		return pairRank1 > pairRank2
        	end

        	highVal1 = get_highest_non_pair_card(hand1)
        	highVal2 = get_highest_non_pair_card(hand2)

        	return suit_rank(highVal1.suit) > suit_rank(highVal2.suit)
    	end

	# Case 5: High Card
	if rank1 == HIGH_CARD
        	highestCard1 = get_highest_card(hand1, false)
        	highestCard2 = get_highest_card(hand2, false)

        	if highestCard1.rank != highestCard2.rank
            		return highestCard1.rank > highestCard2.rank
        	end

        	return suit_rank(highestCard1.suit) > suit_rank(highestCard2.suit)
    	end

	if rank1 == FOUR_OF_A_KIND
        	quadRank1 = get_quad_rank(hand1)
        	quadRank2 = get_quad_rank(hand2)

        	return quadRank1 > quadRank2
    	end

	if rank1 == THREE_OF_A_KIND
        	tripletRank1 = get_triplet_rank(hand1)
        	tripletRank2 = get_triplet_rank(hand2)

        	return tripletRank1 > tripletRank2
    	end

	if rank1 == FULL_HOUSE
        	tripletRank1 = get_triplet_rank(hand1)
        	tripletRank2 = get_triplet_rank(hand2)

        	if tripletRank1 != tripletRank2
            		return tripletRank1 > tripletRank2
        	end

        	pairRank1 = get_pair_rank(hand1)
        	pairRank2 = get_pair_rank(hand2)

        	return pairRank1 > pairRank2
    	end

    	return false
end

# Function to read a deck from a file and populate hands
function read_deck_from_file(filename::String, hands::Vector{Vector{Card}})
	success = true  # Assume success unless a duplicate is found
	open(filename, "r") do inputFile
        	seenCards = Set{String}()
        	lines = readlines(inputFile)

		for line in lines
			println(line)  # Display each line to user before processing
		end

        	resize!(hands, 6)

		# Initialize each hand as an empty Vector{Card}
        	for i in 1:6
            		hands[i] = Vector{Card}()
        	end

        	for i in 1:6
        		line = lines[i]
            		cardStrs = split(line, ',')

            		for j in 1:5
                		cardStr = cardStrs[j]
                		cardStr = replace(cardStr, " " => "")  # Remove spaces inline

                		# Duplicate card check
                		if cardStr in seenCards
                    			println("\n*** ERROR - DUPLICATED CARD FOUND IN DECK ***\n\n")
                    			println("*** DUPLICATE: $cardStr ***")
                    			success = false
					break
                		end
				if !success
					break
				end

                		push!(seenCards, cardStr)

                		# Extract suit and rank
                		suit = cardStr[end]
                		rank = if cardStr[1] in '2':'9'
                    			parse(Int, cardStr[1])
                		elseif cardStr[1:2] == "10"
                    			10
                		else
                    			match = Dict('J' => 11, 'Q' => 12, 'K' => 13, 'A' => 14)
                    			match[cardStr[1]]
        	        	end

                		push!(hands[i], Card(rank, suit))
            		end
		end
	end
	if success
    		println()
    		print_six_hands(hands)
	end

	return success
end

# main method to handle overall program flow 
function main(args::Vector{String})
    	println("*** P O K E R    H A N D    A N A L Y Z E R ***\n\n")

    	deck = Deck()
	hands = Vector{Card}[] 
	resize!(hands, 6) 
	handRanks = HandRank[]

	if length(args) > 0  # Part 2: With command-line arguments
		println("*** USING TEST DECK ***")
		println("\n*** File: ", args[1])
		if !read_deck_from_file(args[1], hands)
			return
		end
	else  # Part 1: Without command-line arguments
		println("*** USING RANDOMIZED DECK OF CARDS ***")
    		shuffle_deck!(deck)
    		println("\n*** Shuffled Deck of Cards ***")
    		print_deck(deck, false) 
		hands = deal_hands(deck, 6, 5)
		print_six_hands(hands)
		println("*** Here is what remains in the deck...")
		print_deck(deck, true)
		println()
	end

	sorted_hands = sort_hands(hands, handRanks)
    	print_winning_hand(sorted_hands, handRanks)
end

main(ARGS)

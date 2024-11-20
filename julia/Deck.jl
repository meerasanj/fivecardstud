# Deck.jl
module DeckModule

import Random

using ..CardModule

export Deck, shuffle_deck!, deal_hands, print_deck

# Deck Struct
struct Deck
    	cards::Vector{Card}
end

# Initialize an ordered deck of 52 cards
function Deck()
	suits = ['D', 'C', 'H', 'S']
    	ranks = 2:14
    	cards = [Card(rank, suit) for suit in suits for rank in ranks]
    	return Deck(cards)
end

# Shuffle the deck
function shuffle_deck!(deck::Deck)	# note: ! means that the deck is being modified
    	Random.shuffle!(deck.cards)
end

# Deal hands of 5 cards to 6 players
function deal_hands(deck::Deck, num_hands::Int, hand_size::Int)
    	hands = [Vector{Card}(undef, hand_size) for _ in 1:num_hands]
    	for i in 1:hand_size
        	for j in 1:num_hands
            		hands[j][i] = popfirst!(deck.cards) 
        	end
    	end
    	return hands
end

# Print the deck with an option for single-line or multi-line
function print_deck(deck::Deck, single_line::Bool=false)
    	count = 0
    	for card in deck.cards
        	print(to_string(card), " ")
        	count += 1
        	if !single_line && count % 13 == 0
            		println() 
        	end
    	end
    	println() 
end

end # module

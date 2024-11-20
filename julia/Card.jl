# Card.jl
module CardModule

export Card, to_string

# Card struct
struct Card
	rank::Int
    	suit::Char
end

# Convert the Card object to string representation
function to_string(card::Card)
	rank_str = if card.rank == 14
		"A"
	elseif card.rank == 13
        	"K"
    	elseif card.rank == 12
        	"Q"
    	elseif card.rank == 11
        	"J"
    	else
        	string(card.rank)
    	end
    	return rank_str * string(card.suit)
end

end # module





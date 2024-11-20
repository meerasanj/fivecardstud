package main

import (
	"fmt"
	"strconv"
)

// Card struct represents a card with rank and suit
type Card struct {
	Rank int
    	Suit Suit
}

// Creates a new card with a rank (as a string) and a suit
func NewCard(rank string, suit Suit) (Card, error) {
	rankInt, err := rankToInt(rank)
    	if err != nil {
        	return Card{}, err
    	}
    	return Card{Rank: rankInt, Suit: suit}, nil
}

// Converts a rank string to an integer representation
func rankToInt(rankStr string) (int, error) {
    	switch rankStr {
    	case "2", "3", "4", "5", "6", "7", "8", "9":
        	return strconv.Atoi(rankStr)
    	case "10":
        	return 10, nil
    	case "J":
        	return 11, nil
    	case "Q":
        	return 12, nil
    	case "K":
        	return 13, nil
    	case "A":
        	return 14, nil
    	default:
        	return 0, fmt.Errorf("invalid rank: %s", rankStr)
    }
}

// Covnerts a numeric rank to its string representation
func rankToString(rank int) string {
	switch rank {
    		case 14, 1:
        		return "A"
    		case 13:
        		return "K"
    		case 12:
        		return "Q"
    		case 11:
        		return "J"
    		default:
        		return strconv.Itoa(rank)
    	}
}

// Returns a string represention of the card
func (c Card) ToString() string {
    	return rankToString(c.Rank) + string(c.Suit)
}


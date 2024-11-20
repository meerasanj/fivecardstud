package main

import (
	"fmt"
    	"math/rand"
    	"time"
)

// Deck struct
type Deck struct {
    	Cards []Card
}

// Creates and returns a new deck of 52 cards
func NewDeck() Deck {
    	suits := []Suit{Hearts, Diamonds, Clubs, Spades}
	ranks := []string{"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}
    	var cards []Card

    	for _, suit := range suits {
        	for _, rank := range ranks {
            		card, err := NewCard(rank, suit)
            		if err == nil {
                		cards = append(cards, card)
            		}
        	}
    	}

    	return Deck{Cards: cards}
}

// Shuffles the deck 
func (d *Deck) Shuffle() {
	rand.Seed(time.Now().UnixNano())
    	rand.Shuffle(len(d.Cards), func(i, j int) {
        	d.Cards[i], d.Cards[j] = d.Cards[j], d.Cards[i]
    	})
}

// Deals 6 hands of 5 cards each from the deck
func (d *Deck) DealHands(hands [][]Card) {
    	for i := 0; i < 5; i++ {
        	for j := 0; j < len(hands); j++ {
            		hands[j] = append(hands[j], d.Cards[0])
            		d.Cards = d.Cards[1:]  // Remove the dealt card from the deck
        	}
    	}
}

// Prints the cards in the deck
func (d *Deck) PrintDeck(singleLine bool) {
    	count := 0
    	for _, card := range d.Cards {
        	fmt.Print(card.ToString() + " ")
        	count++
        	if !singleLine && count%13 == 0 {
        		fmt.Println()
        	}
    	}
    	fmt.Println()
}


package main

import (
	"fmt"
	"strings"
	"sort"
	"os"
	"bufio"
)

type Suit string

// Suit constants 
const (
	Diamonds Suit = "D"
    	Clubs    Suit = "C"
    	Hearts   Suit = "H"
    	Spades   Suit = "S"
)

// Suit ranking for Diamonds < Clubs < Hearts < Spades
var suitRanking = map[Suit]int{
    	Diamonds: 1,
    	Clubs:    2,
    	Hearts:   3,
    	Spades:   4,
}

// returns rank of suit 
func suitRank(suit Suit) int {
    	return suitRanking[suit]
}

type HandRank int

// constants for HandRank
const (
    	HighCard HandRank = iota + 1
    	Pair
    	TwoPair
    	ThreeOfAKind
    	Straight
    	Flush
    	FullHouse
    	FourOfAKind
    	StraightFlush
    	RoyalFlush
)

// returns string representation of HandRank
func HandRankToString(rank HandRank) string {
    	switch rank {
    	case HighCard:
        	return "High Card"
    	case Pair:
        	return "Pair"
    	case TwoPair:
        	return "Two Pair"
    	case ThreeOfAKind:
        	return "Three Of A Kind"
    	case Straight:
        	return "Straight"
    	case Flush:
        	return "Flush"
    	case FullHouse:
        	return "Full House"
    	case FourOfAKind:
        	return "Four Of A Kind"
    	case StraightFlush:
        	return "Straight Flush"
    	case RoyalFlush:
        	return "Royal Straight Flush"
    	default:
        	return "Unknown"
    }
}

// Main method to handle overall program flow 
func main() {
	deck := NewDeck()
	hands := make([][]Card, 6)

	fmt.Println("*** P O K E R    H A N D    A N A L Y Z E R ***")

	if len(os.Args) > 1 { // part 2 with command line args
		filename := os.Args[1]
		fmt.Println("\n\n*** USING TEST DECK ***")
		fmt.Printf("\n*** File: %s\n", filename)
		if err := readDeckFromFile(filename, hands); err != nil {
            		fmt.Printf("Failed to read deck from file: %v\n", err)
            		return
        	}
	} else {	// part 1 without command line args 
		fmt.Println("\n\n*** USING RANDOMIZED DECK OF CARDS ***")
		deck.Shuffle()
		fmt.Println("\n*** Shuffled 52 card deck:")
    		deck.PrintDeck(false)
		deck.DealHands(hands)
		printSixHands(hands)
		fmt.Println("*** Here is what remains in the deck...")
		deck.PrintDeck(true)	
		fmt.Println()
	}
	handRanks := sortHands(hands)
	printWinningHand(hands, handRanks)
}

// to print 6 hands of 5 cards
func printSixHands(hands [][]Card) {
	fmt.Println("*** Here are the six hands...")
	for i := 0; i < 6; i++ {
		hand := hands[i]
		var cardStrings []string

		for _, card := range hand {
			cardStr := rankToString(card.Rank) + string(card.Suit)
			cardStrings = append(cardStrings, cardStr)
		}
		fmt.Println(strings.Join(cardStrings, " "))
	}
	fmt.Println()
}

// to print the winning hand order based on HandRank
func printWinningHand(hands [][]Card, handRanks []HandRank) {
	fmt.Println("--- WINNING HAND ORDER ---")
	for i := 0; i < len(hands); i++ {
		hand := hands[i]
		var cardStrings []string

		for _, card := range hand {
			cardStr := rankToString(card.Rank) + string(card.Suit)
			cardStrings = append(cardStrings, cardStr)
		}
		handString := strings.Join(cardStrings, " ")
		fmt.Printf("%s - %s\n", handString, HandRankToString(handRanks[i]))
	}
	fmt.Println()
}

// Reads a deck from a file, populates the hands, and checks for duplicates
func readDeckFromFile(filename string, hands [][]Card) error {
	seenCards := make(map[string]bool) // Track duplicate cards
	
	file, err := os.Open(filename)
	if err != nil {
		fmt.Printf("Error: The file %s was not found.\n", filename)
		return err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	lines := []string{}

	for scanner.Scan() {
		line := scanner.Text()
		fmt.Println(line) // Display file line to user
		lines = append(lines, line)
	}

	for i := 0; i < 6; i++ {
		cardStrings := strings.Split(strings.TrimSpace(lines[i]), ",")
		for _, cardStr := range cardStrings {
			cardStr = strings.TrimSpace(cardStr)

			// Duplicate card check
			if seenCards[cardStr] {
				fmt.Println("\n*** ERROR - DUPLICATED CARD FOUND IN DECK ***")
				fmt.Printf("\n\n*** DUPLICATE: %s ***\n", cardStr)
				os.Exit(0)
			}
			seenCards[cardStr] = true

			suit := Suit(cardStr[len(cardStr)-1])
			rankStr := cardStr[:len(cardStr)-1]

			card, err := NewCard(rankStr, suit)
			if err != nil {
				fmt.Printf("Error creating card %s: %v\n", cardStr, err)
				return err
			}
			hands[i] = append(hands[i], card)
		}
	}

	fmt.Println()
	printSixHands(hands)
	return nil
}

// sort hands in descending order and classify each hand 
func sortHands(hands [][]Card) []HandRank {
	sort.Slice(hands, func(i, j int) bool {
		return compareHands(hands[i], hands[j]) > 0 // for descending order 
	})

	handRanks := make([]HandRank, len(hands))
	for i, hand := range hands {
		handRanks[i] = classifyHand(hand)
	}
	return handRanks
}

// Checks if hand is an Ace Low Straight (A 2 3 4 5)
func isAceLowStraight(hand []Card) bool {
	rankSet := make(map[int]struct{})
    	for _, card := range hand {
        	rankSet[card.Rank] = struct{}{}
    	}
    	return len(rankSet) == 5 && rankSet[14] == struct{}{} && rankSet[2] == struct{}{} && rankSet[3] == struct{}{} && rankSet[4] == struct{}{} && rankSet[5] == struct{}{}
}

// Returns the highest card in the hand, considering Ace as low if isAceStraight is true
func getHighestCard(hand []Card, isAceStraight bool) Card {
    	tempHand := make([]Card, len(hand))
    	copy(tempHand, hand)

    	// treat Ace as low if needed
    	if isAceStraight {
        	for i := range tempHand {
            		if tempHand[i].Rank == 14 {
                		tempHand[i].Rank = 1
            		}
        	}
    	}

    	// Find the highest card
    	highestCard := tempHand[0]
    	for _, card := range tempHand[1:] {
        	if card.Rank > highestCard.Rank {
            		highestCard = card
        	}
    	}
    	return highestCard
}

// Counts the number of times a specific rank occurs in the hand
func countOccurrences(hand []Card, rank int) int {
	count := 0
    	for _, card := range hand {
        	if card.Rank == rank {
            		count++
        	}
    	}
    	return count
}

// Returns the highest non-pair card
func getHighestNonPairCard(hand []Card) *Card {
    	var tempHand []Card

    	for _, card := range hand {
        	if countOccurrences(hand, card.Rank) != 2 {
            		tempHand = append(tempHand, card)
        	}
    	}

    	if len(tempHand) == 0 {
        	return nil
    	}

    	highestCard := tempHand[0]
    	for _, card := range tempHand[1:] {
        	if card.Rank > highestCard.Rank {
            		highestCard = card
        	}
    	}

    	return &highestCard
}

// Identifies and returns the index of the kicker card in the hand
func getKicker(hand []Card) int {
    	maxVal := 0
    	kickerIndex := -1

    	for index, card := range hand {
        	if countOccurrences(hand, card.Rank) == 1 && card.Rank > maxVal {
            		maxVal = card.Rank
            		kickerIndex = index
        	}
    	}

    	return kickerIndex
}

// Gets the rank (value) of the pair in the hand
func getPairRank(hand []Card) int {
    	for _, card := range hand {
        	if countOccurrences(hand, card.Rank) == 2 {
            		return card.Rank
        	}
    	}
    	return -1
}

// Gets the highest rank (value) of pairs in a hand
func getHighestPairRank(hand []Card) int {
    	highestPair := -1
    	for _, card := range hand {
        	if countOccurrences(hand, card.Rank) == 2 && card.Rank > highestPair {
            		highestPair = card.Rank
        	}
    	}
    	return highestPair
}

// Gets the lowest rank (value) of pairs in a hand
func getLowestPairRank(hand []Card) int {
    	lowestPair := 15  // Higher than any possible rank in a standard deck
    	for _, card := range hand {
        	if countOccurrences(hand, card.Rank) == 2 && card.Rank < lowestPair {
            		lowestPair = card.Rank
        	}
    	}

    	if lowestPair == 15 {
        	return -1
    	}
    	return lowestPair
}

// Gets the rank of the three-of-a-kind in a hand
func getTripletRank(hand []Card) int {
    	for _, card := range hand {
        	if countOccurrences(hand, card.Rank) == 3 {
            		return card.Rank
        	}
    	}
    	return -1
}

// Gets the rank of the four-of-a-kind in a hand
func getQuadRank(hand []Card) int {
    	for _, card := range hand {
        	if countOccurrences(hand, card.Rank) == 4 {
            		return card.Rank
        	}
    	}
    	return -1
}

// Compares two hands and determines the winner
func compareHands(hand1, hand2 []Card) int {
	rank1 := classifyHand(hand1)
	rank2 := classifyHand(hand2)

	if rank1 != rank2 {
		if rank1 < rank2 {
			return -1
		}
		return 1
	}

	// Tie-breaking logic based on hand type
    	switch rank1 {

	// Case 1: Flush
    	case Flush, StraightFlush, RoyalFlush:
        	highestCard1 := getHighestCard(hand1, false)
        	highestCard2 := getHighestCard(hand2, false)

        	if highestCard1.Rank != highestCard2.Rank {
            		if highestCard1.Rank < highestCard2.Rank {
                		return -1
            	}
            	return 1
        	}
        	if suitRank(highestCard1.Suit) < suitRank(highestCard2.Suit) {
            		return -1
        	}
        	return 1

	// Case 2: Straight
    	case Straight:
        	aceLow1 := isAceLowStraight(hand1)
        	aceLow2 := isAceLowStraight(hand2)

        	highestCard1 := getHighestCard(hand1, aceLow1)
        	highestCard2 := getHighestCard(hand2, aceLow2)

        	if highestCard1.Rank != highestCard2.Rank {
            		if highestCard1.Rank < highestCard2.Rank {
                		return -1
            		}
            		return 1
        	}
        	if suitRank(highestCard1.Suit) < suitRank(highestCard2.Suit) {
            	return -1
        	}
        	return 1

	// Case 3: Two Pair
    	case TwoPair:
        	highPair1 := getHighestPairRank(hand1)
        	highPair2 := getHighestPairRank(hand2)

        	if highPair1 != highPair2 {
            		if highPair1 < highPair2 {
                		return -1
            		}
            	return 1
        	}

        	lowPair1 := getLowestPairRank(hand1)
        	lowPair2 := getLowestPairRank(hand2)

        	if lowPair1 != lowPair2 {
            		if lowPair1 < lowPair2 {
                		return -1
            		}
            	return 1
        	}

        	kicker1 := getKicker(hand1)
        	kicker2 := getKicker(hand2)
        	if suitRank(hand1[kicker1].Suit) < suitRank(hand2[kicker2].Suit) {
            		return -1
        	}
        	return 1

	// Case 4: Pair
    	case Pair:
        	pairRank1 := getPairRank(hand1)
        	pairRank2 := getPairRank(hand2)

        	if pairRank1 != pairRank2 {
            		if pairRank1 < pairRank2 {
                		return -1
            		}
            	return 1
        	}

        	highVal1 := getHighestNonPairCard(hand1)
        	highVal2 := getHighestNonPairCard(hand2)

        	if highVal1.Rank != highVal2.Rank {
            		if highVal1.Rank < highVal2.Rank {
                		return -1
            		}
            		return 1
        	}
        	if suitRank(highVal1.Suit) < suitRank(highVal2.Suit) {
            		return -1
        	}
        	return 1

	// Case 5: High Card
    	case HighCard:
        	highestCard1 := getHighestCard(hand1, false)
        	highestCard2 := getHighestCard(hand2, false)

        	if highestCard1.Rank != highestCard2.Rank {
            		if highestCard1.Rank < highestCard2.Rank {
                		return -1
            		}
            		return 1
        	}
        	if suitRank(highestCard1.Suit) < suitRank(highestCard2.Suit) {
            		return -1
        	}
        	return 1

	// Four of a Kind
    	case FourOfAKind:
        	quadRank1 := getQuadRank(hand1)
        	quadRank2 := getQuadRank(hand2)
        	if quadRank1 < quadRank2 {
            		return -1
        	}
        	return 1

    	// Three of a Kind
    	case ThreeOfAKind:
        	tripletRank1 := getTripletRank(hand1)
        	tripletRank2 := getTripletRank(hand2)
        	if tripletRank1 < tripletRank2 {
            		return -1
        	}
        	return 1

    	// Full House
    	case FullHouse:
        	tripletRank1 := getTripletRank(hand1)
        	tripletRank2 := getTripletRank(hand2)

        	if tripletRank1 != tripletRank2 {
            		if tripletRank1 < tripletRank2 {
                		return -1
            		}
            		return 1
        	}

        	pairRank1 := getPairRank(hand1)
        	pairRank2 := getPairRank(hand2)
        	if pairRank1 < pairRank2 {
            		return -1
        	}
        	return 1
    	}

    	return 0

}

// checks if a hand is a straight
func isStraight(hand []Card) bool {
	rankSet := make(map[int]struct{})

	for _, card := range hand {
		rankSet[card.Rank] = struct{}{}
	}

	if len(rankSet) < 5 {
        	return false
    	}

	sortedRanks := make([]int, 0, len(rankSet))
    	for rank := range rankSet {
        	sortedRanks = append(sortedRanks, rank)
    	}
    	sort.Ints(sortedRanks)

	if sortedRanks[0] == 2 && sortedRanks[1] == 3 && sortedRanks[2] == 4 && sortedRanks[3] == 5 && sortedRanks[4] == 14 {
		return true
	}

	for i := 0; i < len(sortedRanks)-1; i++ {
		if sortedRanks[i+1]-sortedRanks[i] != 1 {
			return false
		}
	}

	return true
}

// classifies the rank of the hand
func classifyHand(hand []Card) HandRank {
	handCopy := make([]Card, len(hand))
	copy(handCopy, hand)
	sort.Slice(handCopy, func(i, j int) bool {
        	return handCopy[i].Rank > handCopy[j].Rank
    	})

	occurrences := make([]int, 15)
	suits := make(map[Suit]int)

	for _, card := range handCopy {
        	occurrences[card.Rank]++
        	suits[card.Suit]++
    	}

	flush := false
    	for _, count := range suits {
        	if count == 5 {
            		flush = true
            		break
        	}
    	}

	straight := isStraight(handCopy)
	
	if flush && straight {
		royalRanks := map[int]bool{10: true, 11: true, 12: true, 13: true, 14: true}
		uniqueRanks := make(map[int]bool)
		for _, card := range handCopy {
			uniqueRanks[card.Rank] = true
		}

		isRoyal := true
		for rank := range royalRanks {
			if !uniqueRanks[rank] {
				isRoyal = false
				break
			}
		}
		if isRoyal {
            		return RoyalFlush
        	}
        	return StraightFlush
	}

	threeCount := 0
    	pairCount := 0

    	for _, count := range occurrences[2:] {
        	if count == 4 {
            		return FourOfAKind
        	}
        	if count == 3 {
        		threeCount++
        	}
        	if count == 2 {
        		pairCount++
        	}
    	}

    	if threeCount == 1 && pairCount == 1 {
        	return FullHouse
    	}
    	if flush {
        	return Flush
    	}
    	if straight {
        	return Straight
    	}
    	if threeCount == 1 {
        	return ThreeOfAKind
    	}
    	if pairCount == 2 {
        	return TwoPair
    	}
    	if pairCount == 1 {
        	return Pair
    	}

    	return HighCard
}

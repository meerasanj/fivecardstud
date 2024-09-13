#include <sstream>
#include <iostream>
#include <fstream>
#include <vector>
#include <set>
#include <map>
#include <algorithm>
#include "card.h"
#include "deck.h"

using namespace std;

// enumeration for suits
enum Suit {
	Diamonds, Clubs, Hearts, Spades
};

// enumeration for hand ranks 
enum HandRank {
	HIGH_CARD,
	PAIR,
	TWO_PAIR,
	THREE_OF_A_KIND,
	STRAIGHT,
	FLUSH,
	FULL_HOUSE,
	FOUR_OF_A_KIND,
	STRAIGHT_FLUSH,
	ROYAL_FLUSH
};

// method headers 
HandRank classifyHand(vector<Card> hand);
bool isStraight(const vector<Card>& hand);
bool isAceLowStraight(const vector<Card>& hand);
Card getHighestCard(const vector<Card>& hand, bool isAceStraight);
int countOccurrences(const vector<Card>& hand, int rank);
Card getHighestNonPairCard(const vector<Card>& hand);
int getKicker(const vector<Card>& hand);
int getPairRank(const vector<Card>& hand);
int getHighestPairRank(const vector<Card>& hand);
int getLowestPairRank(const vector<Card>& hand);
int getTripletRank(const vector<Card>& hand);
int getQuadRank(const vector<Card>& hand);
bool compareHands(const vector<Card>& hand1, const vector<Card>& hand2);
void sortHands(vector<vector<Card>>& hands, vector<HandRank>& handRanks);
void printSixHands(const vector<vector<Card>>& hands);
void printWinningHand(const vector<vector<Card>>& hands, const vector<HandRank>& handRanks);
void readDeckFromFile(const string& filename, vector<vector<Card>>& hands);


// main method
int main(int argc, char* argv[]) {
	Deck deck; // create ordered deck of cards 
	vector<vector<Card>> hands(6); // to store the 6 hands
	vector<HandRank> handRanks; // to store ranks of each hand 
	
	cout << "*** P O K E R    H A N D    A N A L Y Z E R ***" << endl;
	cout << endl;
	cout << endl;

	if(argc > 1) { // part 2 w/ command line args
		cout << "*** USING TEST DECK ***" << endl;
		cout << endl;
		cout << "*** File: " << argv[1] << endl;
		readDeckFromFile(argv[1], hands);
	} else { // part 1 w/o command line args 
		cout << "*** USING RANDOMIZED DECK OF CARDS ***" << endl;
		cout << endl;
		cout << "*** Shuffled 52 card deck:" << endl;
                deck.shuffle();
                deck.printDeck(false);
                deck.dealHands(hands);
                printSixHands(hands);
                cout << "*** Here is what remains in the deck..." << endl;
                deck.printDeck(true);
                cout << endl;
	}
	sortHands(hands, handRanks);
        printWinningHand(hands, handRanks);
        return 0;
}

// map hand rank enum values to strings 
map<int, string> handRankToString = {
	{HIGH_CARD, "High Card"},
	{PAIR, "Pair"},
	{TWO_PAIR, "Two Pair"},
	{THREE_OF_A_KIND, "Three Of A Kind"},
	{STRAIGHT, "Straight"},
	{FLUSH, "Flush"},
	{FULL_HOUSE, "Full House"},
	{FOUR_OF_A_KIND, "Four Of A Kind"},
	{STRAIGHT_FLUSH, "Straight Flush"},
	{ROYAL_FLUSH, "Royal Flush"},
};

// checks if the hand is a straight
bool isStraight(const vector<Card>& hand) {  
	vector<int> ranks;
	for(int i = 0; i < hand.size(); i++) {
		ranks.push_back(hand[i].rank);
	}

	sort(ranks.begin(), ranks.end()); // ascending order 

	// special check for Ace-low straight (A, 2, 3, 4, 5)
	if(ranks == vector<int>{2,3,4,5,14}) {
		return true;
	}

	// checks if ranks are consecutive
	for(int i = 0; i < ranks.size() - 1; i++) { 
		if(ranks[i + 1] != ranks[i] + 1) {
			return false;
		}
	}
	return true;
}

// compare cards by rank in descending order 
bool compareCardsByRank(const Card& a, const Card& b) {
	return a.rank > b.rank;	
}

// printing method to display 6 hands 
void printSixHands(const vector<vector<Card>>& hands) {
        cout << "*** Here are the six hands..." << endl;
        for (int i = 0; i < 6; i++) {
                for (int j = 0; j < hands[i].size(); j++) {
                        cout << hands[i][j].toString() << " ";
                }
                cout << endl;
        }
	cout << endl;
}

// printing method to display winning hand order 
void printWinningHand(const vector<vector<Card>>& hands, const vector<HandRank>& handRanks) {
	cout << "--- WINNING HAND ORDER ---" << endl;
        for(int i = 0; i < hands.size(); i++) {
                for(int j = 0; j < hands[i].size(); j++) {
                        cout << hands[i][j].toString() << " ";
                }
                cout << "- " << handRankToString[handRanks[i]] << endl;
        }
}

// determines rank if hand based on card combinations 
HandRank classifyHand(vector<Card> hand) { 
	sort(hand.begin(), hand.end(), compareCardsByRank); // descending order e.g 14, 13, 12, 11, 10 

	// to count occurences of each value 
	int occurences[15] = {0}; 
	int suitCount[4] = {0};;
	const char suits[] = {'D', 'C', 'H', 'S'};

	for(int i = 0; i < hand.size(); i++) {
		occurences[hand[i].rank]++; // count rank occurences 

		for(int j = 0; j < 4; j++) {
			if(hand[i].suit == suits[j]) {
				suitCount[j]++; // count suit occurences 
				break;
			}
		}
	}

	bool flush = false;
	for(int i = 0; i < 4; i++) { // checks if hand is a flush (same suit)
		if(suitCount[i] == 5) {
			flush = true;
			break;
		}
	}
	bool straight = isStraight(hand);

	if(flush && straight) {
		set<int> royalRanks = {14, 13, 12, 11, 10};
		set<int> uniqueRanks;
		for (int i = 0; i < hand.size(); i++) {
			uniqueRanks.insert(hand[i].rank);
		}
		
		if(uniqueRanks == royalRanks) {
			return ROYAL_FLUSH;
		} else {
			return STRAIGHT_FLUSH;
		}

	} 

	int threeCount = 0;
	int pairCount = 0;
	for(int i = 2; i <= 14; i++) {
		if(occurences[i] == 4) return FOUR_OF_A_KIND;
		if(occurences[i] == 3) threeCount++;
		if(occurences[i] == 2) pairCount++;
	}

	if(threeCount == 1 && pairCount == 1) return FULL_HOUSE; // working 
	if(flush) return FLUSH; // working 
	if(straight) return STRAIGHT; // working 
	if(threeCount == 1) return THREE_OF_A_KIND; // working 
	if(pairCount == 2) return TWO_PAIR; // working 
	if(pairCount == 1) return PAIR; // working 

	return HIGH_CARD;

}

// check if a hand is an Ace-low straight
bool isAceLowStraight(const vector<Card>& hand) {
	for(int i = 0; i < hand.size(); i++) {
		if(hand[i].rank == 14) {
			return true; 
		}
	}
	return false;
}

// get highest number card, includes case of Ace-low straight 
Card getHighestCard(const vector<Card>& hand, bool isAceStraight) {
	vector<Card> tempHand = hand;
	
	if (isAceStraight) {
		for (int i = 0; i < tempHand.size(); ++i) {
			if (tempHand[i].rank == 14) {
				tempHand[i].rank = 1; // treat Ace as a low 
			}
		}
	}

	Card highestCard = tempHand[0];

	for (int i = 1; i < tempHand.size(); i++) {
		if (tempHand[i].rank > highestCard.rank) { 
			highestCard = tempHand[i];
		} 
	}
	return highestCard;

}

// count occurrences of a specific rank in a hand
int countOccurrences(const vector<Card>& hand, int rank) {
	int count = 0;
	for(int i = 0; i < hand.size(); i++) {
		if(hand[i].rank == rank) {
			count++;
		}
	}
	return count;
}

// get the highest card not part of a pair
Card getHighestNonPairCard(const vector<Card>& hand) {
	vector<Card> tempHand;
	
	// add cards that are not part of pair to temphand 
	for(int i = 0; i < hand.size(); i++) {
		if((countOccurrences(hand, hand[i].rank) != 2)) {
			tempHand.push_back(hand[i]);
		}
	}

	Card highestCard = tempHand[0];
	for (int i = 1; i < tempHand.size(); i++) {
		if (tempHand[i].rank > highestCard.rank) {
			highestCard = tempHand[i];
		}
	}
	return highestCard;
}

// identify kicker card in a hand (not part of pair)
int getKicker(const vector<Card>& hand) {
	int maxVal = 0;
	for(int i = 0; i < hand.size(); i++) {
		if((countOccurrences(hand, hand[i].rank) == 1) && (hand[i].rank > maxVal)) {
			maxVal = hand[i].rank;
		}
	}
	return maxVal;
}

// get the rank (value) of the pair in a hand
int getPairRank(const vector<Card>& hand) {
	for(int i = 0; i < hand.size(); i++) {
		if(countOccurrences(hand, hand[i].rank) == 2) {
			return hand[i].rank;
		}
	}
	return -1;
}

// get the highest rank (value) of pairs in a hand
int getHighestPairRank(const vector<Card>& hand) {
	int highestPair = -1;
	for(int i = 0; i < hand.size(); i++) {
		if(countOccurrences(hand, hand[i].rank) == 2) {
			if(hand[i].rank > highestPair) {
				highestPair = hand[i].rank;
			}
		}
	}
	return highestPair;
}

// get the lowest rank (value) of pairs in a hand
int getLowestPairRank(const vector<Card>& hand) {
	int lowestPair = 15;
	for(int i = 0; i < hand.size(); i++) {
		if(countOccurrences(hand, hand[i].rank) == 2) {
			if(hand[i].rank < lowestPair) {
				lowestPair = hand[i].rank;
			}	
		}
	}
	return lowestPair;
}

// get the rank of the three-of-a-kind in a hand
int getTripletRank(const vector<Card>& hand) {
	for(int i = 0; i < hand.size(); i++) {
		if(countOccurrences(hand, hand[i].rank) == 3) {
			return hand[i].rank;
		}
	}
	return -1;
}

// get the rank of the four-of-a-kind in a hand
int getQuadRank(const vector<Card>& hand) {
	for(int i = 0; i < hand.size(); i++) {
		if(countOccurrences(hand, hand[i].rank) == 4) {
			return hand[i].rank;
		}
	}
	return -1;
}

// compare two hands to determine the winner
bool compareHands(const vector<Card>& hand1, const vector<Card>& hand2) {
	HandRank rank1 = classifyHand(hand1);
	HandRank rank2 = classifyHand(hand2);
	
	// first, compare overall hand ranks 
	if(rank1 != rank2) {
		return rank1 > rank2;
	}

	// tie-breaking logic for equal strength hands  
	
	// case 1 flush categories - use suit rank to break ties (lowest to highest: D C H S) 
	if(rank1 == FLUSH || rank1 == STRAIGHT_FLUSH || rank1 == ROYAL_FLUSH) {
		Card highestCard1 = getHighestCard(hand1, false);
		Card highestCard2 = getHighestCard(hand2, false);

		if(highestCard1.rank != highestCard2.rank) {
			return highestCard1.rank > highestCard2.rank;
		}	
		
		return highestCard1.suit > highestCard2.suit; // if identical 
			
	}	

	// case 2 straights but not flushes - use suit rank to break ties
	if (rank1 == STRAIGHT) {
		bool checkAce1 = isAceLowStraight(hand1);
		bool checkAce2 = isAceLowStraight(hand2);

		Card highestCard1 = getHighestCard(hand1, checkAce1);
		Card highestCard2 = getHighestCard(hand2, checkAce2);

		if(highestCard1.rank != highestCard2.rank) {
			return highestCard1.rank > highestCard2.rank;
		}

		return highestCard1.suit > highestCard2.suit; // if identical
	}	

	// case 3 - two pair - suit of kicker card to break ties based on (1) 
	if(rank1 == TWO_PAIR) {
		int highPair1 = getHighestPairRank(hand1);
		int highPair2 = getHighestPairRank(hand2);
		
		if(highPair1 != highPair2) {
			return highPair1 > highPair2;
		}
	
		int lowPair1 = getLowestPairRank(hand1);
		int lowPair2 = getLowestPairRank(hand2);
		
		if(lowPair1 != lowPair2) {
			return lowPair1 > lowPair2;
		}

		// if identical, compare kicker suit 
		int kicker1 = getKicker(hand1);
		int kicker2 = getKicker(hand2);
		return hand1[kicker1].suit > hand2[kicker2].suit;	
	}

	// case 4 pairs - use highest non-pair card to break tie 
	if (rank1 == PAIR) {
		int pairRank1 = getPairRank(hand1);
		int pairRank2 = getPairRank(hand2);

		if(pairRank1 != pairRank2) {
			return pairRank1 > pairRank2;
		}

		Card highVal1 = getHighestNonPairCard(hand1);
		Card highVal2 = getHighestNonPairCard(hand2);

		if(highVal1.rank != highVal2.rank) {
			return highVal1.rank > highVal2.rank;
		}
		return highVal1.suit > highVal2.suit; // if identical
	}	

	// case 5 high card - suit of highest value hard to break ties 
	if(rank1 == HIGH_CARD) {
		Card highestCard1 = getHighestCard(hand1, false);
		Card highestCard2 = getHighestCard(hand2, false);

		if(highestCard1.rank != highestCard2.rank) {
			return highestCard1.rank > highestCard2.rank;
		}
		return highestCard1.suit > highestCard2.suit; // if identical
	}

	if(rank1 == FOUR_OF_A_KIND) { // directly compare quadranks 
		int quadRank1 = getQuadRank(hand1);
		int quadRank2 = getQuadRank(hand2);

		return quadRank1 > quadRank2;
	}

	if(rank1 == THREE_OF_A_KIND) { // directly compare triplet ranks
		int tripletRank1 = getTripletRank(hand1);
		int tripletRank2 = getTripletRank(hand2);
		return tripletRank1 > tripletRank2;
	}	

	if(rank1 == FULL_HOUSE) { // compare triplet ranks first, then by pair if equal
		int tripletRank1 = getTripletRank(hand1);
		int tripletRank2 = getTripletRank(hand2);

		if(tripletRank1 != tripletRank2) {
			return tripletRank1 > tripletRank2;
		}

		int pairRank1 = getPairRank(hand1);
		int pairRank2 = getPairRank(hand2);

		return pairRank1 > pairRank2;
	}

	return false;
}

// sort hands based on rank 
void sortHands(vector<vector<Card>>& hands, vector<HandRank>& handRanks) {
	sort(hands.begin(), hands.end(), compareHands);
	for (int i = 0; i < hands.size(); ++i) {
		HandRank rank = classifyHand(hands[i]);
		handRanks.push_back(rank);
	}
}

// read deck from file and populate hands
void readDeckFromFile(const string& filename, vector<vector<Card>>& hands) {
	hands.resize(6);
	ifstream inputFile(filename); // open file 
	string line;
	set<string> seenCards;

	vector<string> lines;
	while (getline(inputFile, line)) {
		lines.push_back(line);
		cout << line << endl; // display file line to user 
	}	

	for(int i = 0; i < 6; i++) { 
		stringstream ss(lines[i]);
		string cardStr;

		for(int j = 0; j < 5; j++) {
			if(j < 4) { // for the first four cards, read until comma 
				if (!getline(ss, cardStr, ',')) {
					cerr << "Error: Invalid card format in file." << endl;
					exit(1);
				}
			} else {
				if (!getline(ss, cardStr)) {
					cerr << "Error: Invalid card format in file." << endl;
					exit(1);
				}
			}
			
			cardStr.erase(remove(cardStr.begin(), cardStr.end(), ' '), cardStr.end());
			
			
			// duplicate card check 
			if(seenCards.find(cardStr) != seenCards.end()) {
				cout << endl;
				cout << "*** ERROR - DUPLICATED CARD FOUND IN DECK ***" << endl;
				cout << endl;
				cout << endl;
				cout << "*** DUPLICATE: " << cardStr << " ***" << endl;
				exit(1);
			}
			seenCards.insert(cardStr);

			char suit = cardStr.back();
			int rank = 0;

			// card conversion 
			if (cardStr[0] >= '2' && cardStr[0] <= '9') {
				rank = cardStr[0] - '0';
			} else if (cardStr[0] == '1' && cardStr[1] == '0') {
				rank = 10;
			} else {
				switch (cardStr[0]) {
					case 'J': rank = 11; break; 
					case 'Q': rank = 12; break;
					case 'K': rank = 13; break;
					case 'A': rank = 14; break;
				
				}
			}
	
			hands[i].push_back(Card(rank, suit));
		}
	}
	cout << endl;
	printSixHands(hands);
}


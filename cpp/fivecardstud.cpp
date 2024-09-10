#include <iostream>
#include <fstream>
#include <vector>
#include <set>
#include <cstdlib>
#include <algorithm>
#include <random>
#include <map>
#include <ctime>

using namespace std;

class Card {
public:
	int rank; // card value
	char suit; 

	// Card constructor
	Card(int r, char s) : rank(r), suit(s) {}

	string toString() const { 
		string rankStr;
		if(rank == 14) {
			rankStr = "A";
		} else if(rank == 13) {
			rankStr = "K";
		} else if(rank == 12) {
			rankStr = "Q";
		} else if(rank== 11) {
			rankStr = "J";
		} else {
			rankStr = to_string(rank);
		}
		return rankStr + suit;
	}

};

class Deck {
public:
	vector<Card> cards;

	Deck() { // Deck constructor to create ordered deck
		for(int rank = 2; rank <= 14; rank++) {
			cards.push_back(Card(rank, 'D'));
			cards.push_back(Card(rank, 'C'));
			cards.push_back(Card(rank, 'H'));
			cards.push_back(Card(rank, 'S'));
		}
	}
	
	// shuffle method to shuffle the ordered deck 
	void shuffle() {
		// i referenced https://stackoverflow.com/questions/5008804/how-do-you-generate-uniformly-distributed-random-integers/19728404#19728404
		random_device rd; // used to initialize engine 
		mt19937 rng(rd()); // seed generator for random number 
		uniform_int_distribution<int> uni(0, cards.size() - 1); // to specify size 
	
		for(int i = 0; i < cards.size(); i++) {
			int randomIndex = uni(rng);
			swap(cards[i], cards[randomIndex]);
		}
	}	

	// dealHand method to deal 6 hands from the top of deck 
	void dealHands(vector<vector<Card>>& hands) {
		for(int i = 0; i < 5; i++) {
			for(int j = 0; j < 6; j++) {
				hands[j].push_back(cards[0]);
				cards.erase(cards.begin());
			}
		}	
	}
	
	// printDeck method to print the shuffled deck 
	void printDeck(bool singleLine = false) const {
		int count = 0;
		for(int i = 0; i < cards.size(); i++) { 
			cout << cards[i].toString() << " ";
			count++;
			if(!singleLine && count % 13 == 0) {
				cout << endl;
			}
		}
		cout << endl;
	}

};

enum Suit {
	Diamonds, Clubs, Hearts, Spades
};

enum HandRank {
	ROYAL_FLUSH, 
	STRAIGHT_FLUSH,
	FOUR_OF_A_KIND,
	FULL_HOUSE,
	FLUSH,
	STRAIGHT,
	THREE_OF_A_KIND,
	TWO_PAIR,
	PAIR,
	HIGH_CARD
};

map<int, string> handRankToString = {
	{ROYAL_FLUSH, "Royal Flush"},
	{STRAIGHT_FLUSH, "Straight Flush"},
	{FOUR_OF_A_KIND, "Four Of A Kind"},
	{FULL_HOUSE, "Full House"},
	{FLUSH, "Flush"},
	{STRAIGHT, "Straight"},
	{THREE_OF_A_KIND, "Three Of A Kind"},
	{TWO_PAIR, "Two Pair"},
	{PAIR, "Pair"},
	{HIGH_CARD, "High Card"}
};

bool isStraight(const vector<Card>& hand) { // checks for consecutive # order 
	vector<int> ranks;
	for(int i = 0; i < hand.size(); i++) {
		ranks.push_back(hand[i].rank);
	}

	sort(ranks.begin(), ranks.end());

	if(ranks == vector<int>{2,3,4,5,14}) {
		return true;
	}

	for(int i = 0; i < ranks.size() - 1; i++) { // checks if ranks are consecutive
		if(ranks[i + 1] != ranks[i] + 1) {
			return false;
		}
	}
	return true;
}

bool compareCardsByRank(const Card& a, const Card& b) {
	return a.rank > b.rank; // descending order	
}

HandRank classifyHand(vector<Card> hand) { // determine rank of hand based on card combinations 
	sort(hand.begin(), hand.end(), compareCardsByRank); // sorts hand to descending order e.g 14, 13, 12, 11, 10 

	// to count occurences of each value 
	int occurences[15] = {0}; 
	int suitCount[4] = {0};;
	const char suits[] = {'D', 'C', 'H', 'S'};

	for(int i = 0; i < hand.size(); i++) {
		occurences[hand[i].rank]++;

		for(int j = 0; j < 4; j++) {
			if(hand[i].suit == suits[j]) {
				suitCount[j]++;
				break;
			}
		}
	}

	bool flush = false;
	for(int i = 0; i < 4; i++) {
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

bool compareHands(const vector<Card>& hand1, const vector<Card>& hand2) {
	HandRank rank1 = classifyHand(hand1);
	HandRank rank2 = classifyHand(hand2);

	if(rank1 != rank2) {
		return rank1 > rank2;
	}

	// tie-breaking logic 
	
	// case 1 flush categories - use suit rank to break ties
	// lowest to highest: D C H S 
	if(rank1 == FLUSH || rank1 == STRAIGHT_FLUSH || rank1 == ROYAL_FLUSH) {
		for(int i = 0; i < 5; i++) {
			if(hand1[i].suit != hand2[i].suit) {
				return hand1[i].suit > hand2[i].suit;
			}
		}
	}	

	// case 2 straights but not flushes - use suit rank to break ties
	if (rank1 == STRAIGHT) {
		if (hand1[0].rank == hand2[0].rank) {
			return hand1[0].suit > hand2[0].suit;
		}
	}	

	// case 3 - two pair - suit of kicker card to break ties based on (1) 
	if(rank1 == TWO_PAIR) {
		int kicker1 = -1;
		int kicker2 = -1;
		for (int i = 0; i < 5; i++) {
			if (hand1[i].rank != hand1[1].rank && hand1[i].rank != hand1[3].rank) {
				kicker1 = i;
			}
			if (hand2[i].rank != hand2[1].rank && hand2[i].rank != hand2[3].rank) {
				kicker2 = i;
			}
		}

		if (hand1[kicker1].suit != hand2[kicker2].suit) {
			return hand1[kicker1].suit > hand2[kicker2].suit;
		}	
	}

	// case 4 pairs - use highest non-pair card to break tie 
	if (rank1 == PAIR) {
		int kicker1 = -1;
		int kicker2 = -1;
		for(int i = 0; i < 5; i++) {
			if (hand1[i].rank != hand1[1].rank) {
				kicker1 = i;
			}
			if (hand2[i].rank != hand2[1].rank) {
				kicker2 = i;
			}
		}
	
		if (hand1[kicker1].suit != hand2[kicker2].suit) {
			return hand1[kicker1].suit > hand2[kicker2].suit;
		}
	}	

	// case 5 high card - 
	if(rank1 == HIGH_CARD) {
		for (int i = 0; i < 5; i++) {
			if (hand1[i].suit != hand2[i].suit) {
				return hand1[i].suit > hand2[i].suit;
			}
		}
	}

	return false;
}

void sortHands(vector<vector<Card>>& hands, vector<HandRank>& handRanks) {
	sort(hands.begin(), hands.end(), compareHands);
	for(int i = 0; i < hands.size(); i++) {
		handRanks.push_back(classifyHand(hands[i]));
	}
}

void readDeckFromFile(const string& filename, vector<vector<Card>>& hands) {
	// method also needs to error check for duplicate cards in test deck
	ifstream inputFile(filename);
	string line;
	//
	if(!inputFile) { cerr << "Error opening file " << filename << endl; exit(1); }
	
	for(int i = 0; i < 6; i++) {
		getline(inputFile, line);
		//
		/*if (line.length() < 20) {
			cerr << "Line in file is too short: " << line << endl; exit(1);
		}*/
		
		for(int j = 0; j < 5; j++) {
			string cardStr = line.substr(j * 4, 3);
			cardStr.erase(remove(cardStr.begin(), cardStr.end(), ' '), cardStr.end());
			char suit = cardStr[2];

			int rank = 0;
			if (cardStr[0] == ' ') {
				rank = cardStr[1] - '0';
			} else {
				rank = (cardStr[0] - '0') * 10 + (cardStr[1] - '0');  // Two-digit rank
			}
			hands[i].push_back(Card(rank, suit));
		}
	}
}

int main(int argc, char* argv[]) {
	// create ordered deck of cards
	Deck deck;
	vector<vector<Card>> hands(6); // to store the 6 hands 
	vector<HandRank> handRanks;	

	cout << "*** P O K E R    H A N D    A N A L Y Z E R ***" << endl;
	cout << endl;

	if(argc > 1) {
		cout << "*** USING TEST DECK ***" << endl;
		cout << "*** File: " << argv[1] << endl;
		readDeckFromFile(argv[1], hands); // need to show file contents and 6 hands
	} else {
		cout << "*** USING RANDOMIZED DECK OF CARDS ***" << endl;
		cout << endl;
		cout << "*** Shuffled 52 card deck:" << endl;
		deck.shuffle();
		deck.printDeck(false);
		deck.dealHands(hands);
		cout << "*** Here are the six hands..." << endl;
	// move outside of main later: 
		for(int i = 0; i < hands.size(); i++) {
			for(int j = 0; j < hands[i].size(); ++j) {
				cout << hands[i][j].toString() << " ";
			}
			cout << endl; 
		} 
		cout << endl;
		cout << "*** Here is what remains in the deck..." << endl;	
		deck.printDeck(true);
		cout << endl;
	}
	// determine winning hand order and display
	sortHands(hands, handRanks);

	cout << "--- WINNING HAND ORDER ---" << endl;
	for(int i = 0; i < hands.size(); i++) {
		for(int j = 0; j < hands[i].size(); j++) {
			cout << hands[i][j].toString() << " ";
		}
		cout << "- " << handRankToString[handRanks[i]] << endl;
	}

	return 0;
}

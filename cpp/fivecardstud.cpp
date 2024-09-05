#include <iostream>
#include <vector>
#include <cstdlib>
#include <algorithm>
#include <random>
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
	
	// shuffle method
	void shuffle() {
		int s = cards.size();
		for(int i = s - 1; i > 0; i--) {
			int j = rand() % (i + 1);
			swap(cards[i], cards[j]);
		}
	}	

	vector<Card> dealHand() {
		vector<Card> hand;
		for(int i = 0; i < 5; i++) {
			hand.push_back(cards[i]);
		}
		cards.erase(cards.begin(), cards.begin() + 5);
		return hand;
	}
	
	void printDeck() const {
		for(int i = 0; i < cards.size(); i++) { // needs to print 13 then nl
			cout << cards[i].toString() << " ";
		}
		cout << endl;
	}
};

int main() {
	// create ordered deck of cards
	Deck deck;
	vector<vector<Card>> hands; // to store the 6 hands 
	
	cout << "*** P O K E R    H A N D    A N A L Y Z E R ***" << endl;
	cout << endl;
	cout << "*** USING RANDOMIZED DECK OF CARDS ***" << endl;
	cout << endl;
	cout << "*** Shuffled 52 card deck:" << endl;
	
	deck.shuffle();
	deck.printDeck();

	cout << endl;
	
	for (int i = 0; i < 6; i++) {
		hands.push_back(deck.dealHand());
	}

	cout << "*** Here are the six hands..." << endl;
	for(int i = 0; i < hands.size(); i++) {
		for(int j = 0; j < hands[i].size(); ++j) {
			cout << hands[i][j].toString() << " ";
		}
		cout << endl; 
	}
	cout << endl;
	
	cout << "*** Here is what remains in the deck..." << endl;	
	deck.printDeck();

	return 0;

}

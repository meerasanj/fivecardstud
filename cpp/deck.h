#ifndef DECK_H
#define DECK_H

#include <vector>
#include "card.h"

class Deck {
public:
	std::vector<Card> cards;
	
	Deck(); // Deck constructor to create ordered deck

	void shuffle();
	void dealHands(std::vector<std::vector<Card>>& hands);
	void printDeck(bool singleLine = false) const;
};

#endif // DECK_H

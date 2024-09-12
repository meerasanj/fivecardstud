#ifndef CARD_H
#define CARD_H

#include <string>

class Card {
public:
	int rank; // card value
	char suit;

	// Card constructor
	 Card(int r, char s);

	std::string toString() const;

};

#endif // CARD_H

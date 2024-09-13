#include "deck.h"
#include <algorithm>
#include <random>
#include <iostream>

// Deck constructor 
Deck::Deck() {
	for (int rank = 2; rank <= 14; rank++) {
		cards.push_back(Card(rank, 'D'));
		cards.push_back(Card(rank, 'C'));
		cards.push_back(Card(rank, 'H'));
		cards.push_back(Card(rank, 'S'));
	}
}

// to shuffle the ordered deck of cards 
void Deck::shuffle() {
	// note: // i referenced https://stackoverflow.com/questions/5008804/how-do-you-generate-uniformly-distributed-random-integers/19728404#19728404
	

	std::random_device rd; // used to initialize engine
	std::mt19937 rng(rd()); // seed generator for random number	
	std::uniform_int_distribution<int> uni(0, cards.size() - 1); // to specify size

	for (int i = 0; i < cards.size(); i++) {
		int randomIndex = uni(rng);
		std::swap(cards[i], cards[randomIndex]);
	}
}

// to deal 6 hands of 5 cards 
void Deck::dealHands(std::vector<std::vector<Card>>& hands) {
	for (int i = 0; i < 5; i++) {
		for (int j = 0; j < 6; j++) {
			hands[j].push_back(cards[0]);
			cards.erase(cards.begin());
		}
	}
}

// printing method to print deck
void Deck::printDeck(bool singleLine) const {
	int count = 0;
	for (int i = 0; i < cards.size(); i++) {
		std::cout << cards[i].toString() << " ";
		count++;
		if (!singleLine && count % 13 == 0) {
			std::cout << std::endl;
		}
	}
	std::cout << std::endl;
}

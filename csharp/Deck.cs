using System;
using System.Collections.Generic;

public class Deck {
    	private List<Card> cards; 

    	// Deck constructor 
	public Deck() {
        	cards = new List<Card>();
		for (int rank = 2; rank <= 14; rank++) {
			cards.Add(new Card(rank, 'D'));
			cards.Add(new Card(rank, 'C'));
			cards.Add(new Card(rank, 'H'));
			cards.Add(new Card(rank, 'S'));
		}
    	}

	// randomly shuffles deck of cards 
    	public void Shuffle() {
		// creates a new instance of the Random class to generate random numbers
        	Random rng = new Random(); 
        	int n = cards.Count;
        	while (n > 1) {
            		int k = rng.Next(n--); // generates a random index 
            		Card value = cards[k];
            		cards[k] = cards[n];
            		cards[n] = value;
        	}
    	}

	// method to deal 6 hands of 5 cards 
    	public void DealHands(List<List<Card>> hands) {
        	for (int i = 0; i < 5; i++) {
			for (int j = 0; j < hands.Count; j++) {
				hands[j].Add(cards[0]);
				cards.RemoveAt(0);
			}
		}
    	}
	
	// method to print the cards in the deck, singleLine bool used to start a new line
    	public void PrintDeck(bool singleLine) {
        	int count = 0;
		foreach (var card in cards) {
			Console.Write(card.ToString() + " ");
			count++;
			if (!singleLine && count % 13 == 0) {
				Console.WriteLine();
			}
		}
		Console.WriteLine();
    	}
}


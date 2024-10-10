import java.util.*;

// deck class
public class Deck {
	private List<Card> cards;

	// deck constructor to create ordered deck
	public Deck() {
		cards = new ArrayList<>();
		for (int rank = 2; rank <= 14; rank++) {
			cards.add(new Card(rank, 'D'));
			cards.add(new Card(rank, 'C'));
			cards.add(new Card(rank, 'H'));
			cards.add(new Card(rank, 'S'));
		}
	}
	
	// method to shuffle ordered deck
	public void shuffle() {
		Collections.shuffle(cards, new Random());
	}

	// method to deal cards
	public void dealHands(List<List<Card>> hands) {
		for (int i = 0; i < 5; i++) {
			for (int j = 0; j < 6; j++) {
				hands.get(j).add(cards.remove(0));
			}
		}
	}

	// method to print the cards in the deck, singleLine bool used to start a new line or not 
	public void printDeck(boolean singleLine) {
		int count = 0;
		for (int i = 0; i < cards.size(); i++) {
			System.out.print(cards.get(i).toString() + " ");
			count++;
			if (!singleLine && count % 13 == 0) {
				System.out.println();
			}
		}
		System.out.println();
	}
}

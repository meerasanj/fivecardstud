import java.util.*;

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

	public void shuffle() {
		Collections.shuffle(cards, new Random());
	}

	public void dealHands(List<List<Card>> hands) {
		for (int i = 0; i < 5; i++) {
			for (int j = 0; j < 6; j++) {
				hands.get(j).add(cards.remove(0));
			}
		}
	}

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

// card class

public class Card {
	private int rank;
	private char suit;

	// card constructor
	public Card(int rank, char suit) {
		this.rank = rank;
		this.suit = suit;
	}

	public int getRank() {
		return rank;
	}

	public char getSuit() {
		return suit;
	}

	public void setRank(int rank) {
		this.rank = rank;
	}

	public String toString() {
		String rankStr;
		switch(rank) {
			case 14: rankStr = "A"; break;
			case 13: rankStr = "K"; break;
			case 12: rankStr = "Q"; break;
			case 11: rankStr = "J"; break;
			default: rankStr = Integer.toString(rank); break;
		}
		
		return rankStr + suit;
	}

	public static Card fromString(String cardStr) {
		char suit = cardStr.charAt(cardStr.length() - 1);
		String rankStr = cardStr.substring(0, cardStr.length() - 1);
		int rank;
		switch (rankStr) {
			case "A": rank = 14; break;
			case "K": rank = 13; break;
			case "Q": rank = 12; break;
			case "J": rank = 11; break;
			default: rank = Integer.parseInt(rankStr); break;
		}
		return new Card(rank, suit);
	}
}

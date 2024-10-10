public class Card {
	private int rank;
	private char suit;

	// card constructor
	public Card(int rank, char suit) {
		this.rank = rank;
		this.suit = suit;
	}

	// getter method to retrieve the rank of the card
	public int GetRank() {
		return rank;
	}

	 // getter method to retrieve the suit of the card
	public char GetSuit() {
		return suit;
	}

	// setter method to set rank (value) of a card
	public void SetRank(int rank) {
		this.rank = rank;
	}

	// setter method to set suit of a card
	public void SetSuit(char suit) { 
		this.suit = suit;
	}

	// provides a custom string representation for suits
	public override string ToString() {
		string rankStr;
		switch (rank) {
			case 14: rankStr = "A"; break;
			case 13: rankStr = "K"; break;
			case 12: rankStr = "Q"; break;
			case 11: rankStr = "J"; break;
			default: rankStr = rank.ToString(); break;
		}
		return rankStr + suit;
	}

	// converts a string representation of a card back into Card object
	public static Card FromString(string cardStr) {
		char suit = cardStr[^1]; // Last character
		string rankStr = cardStr[..^1]; // All but the last character
		int rank;
		switch (rankStr) {
			case "A": rank = 14; break;
			case "K": rank = 13; break;
			case "Q": rank = 12; break;
			case "J": rank = 11; break;
			default: rank = int.Parse(rankStr); break;
		}
		return new Card(rank, suit);
	}
}


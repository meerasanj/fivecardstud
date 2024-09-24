public class Card {
	private int rank;
	private char suit;

	public Card(int rank, char suit) {
		this.rank = rank;
		this.suit = suit;
	}

	public int GetRank() {
		return rank;
	}

	public char GetSuit() {
		return suit;
	}

	public void SetRank(int rank) {
		this.rank = rank;
	}

	public void SetSuit(char suit) { 
		this.suit = suit;
	}

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


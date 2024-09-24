using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

public class FiveCardStud {
	public static void Main(string[] args) {
        	Deck deck = new Deck();
        	List<List<Card>> hands = new List<List<Card>>();

        	for (int i = 0; i < 6; i++) {
        	    	hands.Add(new List<Card>()); // Create 6 empty hands
        	}

        	List<HandRank> handRanks = new List<HandRank>();

        	Console.WriteLine("*** P O K E R    H A N D    A N A L Y Z E R ***\n");

        	if (args.Length > 0) {
        		Console.WriteLine("*** USING TEST DECK ***\n");
            		Console.WriteLine($"*** File: {args[0]}");
            		ReadDeckFromFile(args[0], hands);
        	} else {
			Console.WriteLine("*** USING RANDOMIZED DECK OF CARDS ***\n");
            		Console.WriteLine("*** Shuffled 52 card deck:");
            		deck.Shuffle();
            		deck.PrintDeck(false);
            		deck.DealHands(hands);
            		PrintSixHands(hands);
            		Console.WriteLine("*** Here is what remains in the deck...");
            		deck.PrintDeck(true);
            		Console.WriteLine();
        	}

		//List<List<Card>> originalHands = CloneHands(hands);

        	SortHands(hands, handRanks);
        	PrintWinningHand(hands, handRanks);
	}

	public enum Suit {
        	Diamonds, Clubs, Hearts, Spades
    	}

	public enum HandRank {
        	HighCard,
        	Pair,
        	TwoPair,
        	ThreeOfAKind,
        	Straight,
        	Flush,
        	FullHouse,
        	FourOfAKind,
        	StraightFlush,
        	RoyalFlush
    	}

	private static string HandRankToString(HandRank rank) {
        	switch (rank) {
        		case HandRank.HighCard: return "High Card";
            		case HandRank.Pair: return "Pair";
            		case HandRank.TwoPair: return "Two Pair";
            		case HandRank.ThreeOfAKind: return "Three Of A Kind";
            		case HandRank.Straight: return "Straight";
            		case HandRank.Flush: return "Flush";
            		case HandRank.FullHouse: return "Full House";
            		case HandRank.FourOfAKind: return "Four Of A Kind";
            		case HandRank.StraightFlush: return "Straight Flush";
            		case HandRank.RoyalFlush: return "Royal Straight Flush";
            		default: return "Unknown";
        	}
    	}

	private static void PrintWinningHand(List<List<Card>> hands, List<HandRank> handRanks) {
        	Console.WriteLine("--- WINNING HAND ORDER ---");
        	for (int i = 0; i < hands.Count; i++) {
            	foreach (var card in hands[i]) {
                	Console.Write($"{card} ");
            	}
            	Console.WriteLine($"- {HandRankToString(handRanks[i])}");
        	}
        	Console.WriteLine();
    	}

	private static void PrintSixHands(List<List<Card>> hands) {
        	Console.WriteLine("*** Here are the six hands...");
        	for (int i = 0; i < 6; i++) {
            	foreach (var card in hands[i]) {
                	Console.Write($"{card} ");
            	}
            	Console.WriteLine();
        	}
        	Console.WriteLine();
    	}

	private static void SortHands(List<List<Card>> hands, List<HandRank> handRanks) {
    		handRanks.Clear();

    		//hands.Sort(new Comparison<List<Card>>(CompareHandsWrapper));
		//hands.Sort(CompareHands);	
		hands.Sort(CompareHandsWrapper);

    		for (int i = 0; i < hands.Count; i++) {
			HandRank rank = ClassifyHand(hands[i]);
			handRanks.Add(rank);
		}
	}

	private static int CompareHandsWrapper(List<Card> hand1, List<Card> hand2) {
		bool isHand1Better = CompareHands(hand1, hand2);
		if (isHand1Better) {
			return -1; // hand 1 is better 
		} else {
			return 1; // hand 2 is better or equal
		}
	}

	public static int CompareCardsByRankDescending(Card card1, Card card2) {
		if (card1.GetRank() > card2.GetRank()) {
			return -1;
		} else if (card1.GetRank() < card2.GetRank()) {
			return 1;
		}
		return 0;
	}

	public static HandRank ClassifyHand(List<Card> hand) {
        	List<Card> handCopy = new List<Card>(hand);
		handCopy.Sort(CompareCardsByRankDescending); 

        	int[] occurrences = new int[15];
        	int[] suitCount = new int[4];
		char[] suits = new char[] { 'D', 'C', 'H', 'S' };
	
        	for (int i = 0; i < handCopy.Count; i++) {
			occurrences[handCopy[i].GetRank()]++;
			for (int j = 0; j < 4; j++) {
				if (handCopy[i].GetSuit() == suits[j]) {
					suitCount[j]++;
					break;
				}
			}
		}
	
        	bool flush = false;
		for (int i = 0; i < 4; i++) {
			if (suitCount[i] == 5) {
				flush = true;
				break;
			}
		}
		
		bool straight = IsStraight(hand);

        	if (flush && straight) {
            		HashSet<int> royalRanks = new HashSet<int> { 14, 13, 12, 11, 10 };
            		HashSet<int> uniqueRanks = new HashSet<int>();
			for (int i = 0; i < handCopy.Count; i++) {
				uniqueRanks.Add(handCopy[i].GetRank());
			}

			if (uniqueRanks.SetEquals(royalRanks)) {
				return HandRank.RoyalFlush;
			} 
            		return HandRank.StraightFlush;
        	}
	
        	int threeCount = 0;
        	int pairCount = 0;

        	for (int i = 2; i <= 14; i++) {
			if (occurrences[i] == 4) return HandRank.FourOfAKind;
			if (occurrences[i] == 3) threeCount++;
			if (occurrences[i] == 2) pairCount++;
		}

		if (threeCount == 1 && pairCount == 1) return HandRank.FullHouse;
		if (flush) return HandRank.Flush;
		if (straight) return HandRank.Straight;
		if (threeCount == 1) return HandRank.ThreeOfAKind;
		if (pairCount == 2) return HandRank.TwoPair;
		if (pairCount == 1) return HandRank.Pair;

        	return HandRank.HighCard;
    	}

	public static bool CompareHands(List<Card> hand1, List<Card> hand2) {
        	HandRank rank1 = ClassifyHand(hand1);
        	HandRank rank2 = ClassifyHand(hand2);

        	if (rank1 != rank2) {
            		return rank1 > rank2;
        	}

		if (rank1 == HandRank.Flush || rank1 == HandRank.StraightFlush || rank1 == HandRank.RoyalFlush) {
            		Card highestCard1 = GetHighestCard(hand1, false);
            		Card highestCard2 = GetHighestCard(hand2, false);
            		return CompareCards(highestCard1, highestCard2);
        	}

		if (rank1 == HandRank.Straight) {
            		bool checkAce1 = IsAceLowStraight(hand1);
            		bool checkAce2 = IsAceLowStraight(hand2);
            		Card highestCard1 = GetHighestCard(hand1, checkAce1);
            		Card highestCard2 = GetHighestCard(hand2, checkAce2);
            		return CompareCards(highestCard1, highestCard2);
        	}

        	if (rank1 == HandRank.TwoPair) {
            		int highPair1 = GetHighestPairRank(hand1);
            		int highPair2 = GetHighestPairRank(hand2);
            		if (highPair1 != highPair2) return highPair1 > highPair2;

            		int lowPair1 = GetLowestPairRank(hand1);
            		int lowPair2 = GetLowestPairRank(hand2);
            		if (lowPair1 != lowPair2) return lowPair1 > lowPair2;

            		Card kicker1 = GetKicker(hand1);
            		Card kicker2 = GetKicker(hand2);
            		return CompareCards(kicker1, kicker2);
        	}

        	if (rank1 == HandRank.Pair) {
            		int pairRank1 = GetPairRank(hand1);
            		int pairRank2 = GetPairRank(hand2);
            		if (pairRank1 != pairRank2) return pairRank1 > pairRank2;

            		Card highVal1 = GetHighestNonPairCard(hand1);
            		Card highVal2 = GetHighestNonPairCard(hand2);
            		return CompareCards(highVal1, highVal2);
        	}

        	if (rank1 == HandRank.HighCard) {
            		Card highestCard1 = GetHighestCard(hand1, false);
            		Card highestCard2 = GetHighestCard(hand2, false);
            		return CompareCards(highestCard1, highestCard2);
        	}

        	if (rank1 == HandRank.FourOfAKind) {
            		int quadRank1 = GetQuadRank(hand1);
            		int quadRank2 = GetQuadRank(hand2);
            		return quadRank1 > quadRank2;
        	}

		if (rank1 == HandRank.ThreeOfAKind) {
            		int tripletRank1 = GetTripletRank(hand1);
            		int tripletRank2 = GetTripletRank(hand2);
            		return tripletRank1 > tripletRank2;
        	}

        	if (rank1 == HandRank.FullHouse) {
            		int tripletRank1 = GetTripletRank(hand1);
            		int tripletRank2 = GetTripletRank(hand2);
            		if (tripletRank1 != tripletRank2) return tripletRank1 > tripletRank2;

            		int pairRank1 = GetPairRank(hand1);
            		int pairRank2 = GetPairRank(hand2);
            		return pairRank1 > pairRank2;
        	}

        	return false;
	}

	public static bool IsAceLowStraight(List<Card> hand) {
        	for (int i = 0; i < hand.Count; i++) {
			if (hand[i].GetRank() == 14) {
				return true;
			}	
		}
		return false;
    	}

	public static int CountOccurrences(List<Card> hand, int rank) {
        	int count = 0;
		for (int i = 0; i < hand.Count; i++) {
			if (hand[i].GetRank() == rank) {
				count++;
			}
		}
		return count;
    	}

	public static Card GetHighestNonPairCard(List<Card> hand) {
        	List<Card> tempHand = new List<Card>();
		for (int i = 0; i < hand.Count; i++) {
			if (CountOccurrences(hand, hand[i].GetRank()) != 2) {
				tempHand.Add(hand[i]);
			}
		}

		Card highestCard = tempHand[0];
		for (int i = 1; i < tempHand.Count; i++) {
			if (tempHand[i].GetRank() > highestCard.GetRank()) {
				highestCard = tempHand[i];
			}
		}
		return highestCard;
    	}

	public static Card GetKicker(List<Card> hand) {
  		Card kicker = null;
		int maxVal = 0;
		for (int i = 0; i < hand.Count; i++) {
			if (CountOccurrences(hand, hand[i].GetRank()) == 1 && hand[i].GetRank() > maxVal) {
				maxVal = hand[i].GetRank();
				kicker = hand[i];
			}
		}
		return kicker;
    	}

	public static int GetPairRank(List<Card> hand) {
        	for (int i = 0; i < hand.Count; i++) {
			if (CountOccurrences(hand, hand[i].GetRank()) == 2) {
				return hand[i].GetRank();
			}
		}

		return -1;
	}

	public static int GetHighestPairRank(List<Card> hand) {
        	int highestPair = -1;
		for (int i = 0; i < hand.Count; i++) {
			if (CountOccurrences(hand, hand[i].GetRank()) == 2 && hand[i].GetRank() > highestPair) {
				highestPair = hand[i].GetRank();
			}
		}
		return highestPair;
    	}

	public static int GetLowestPairRank(List<Card> hand) {
        	int lowestPair = 15;
		for (int i = 0; i < hand.Count; i++) {
			if (CountOccurrences(hand, hand[i].GetRank()) == 2 && hand[i].GetRank() < lowestPair) {
				lowestPair = hand[i].GetRank();
			}
		}

		if (lowestPair == 15) {
			return -1;
		}
		return lowestPair;
    	}	

	public static int GetTripletRank(List<Card> hand) {
        	for (int i = 0; i < hand.Count; i++) {
                        if (CountOccurrences(hand, hand[i].GetRank()) == 3) {
                                return hand[i].GetRank();
                        }
                }
		return -1;
	}	

	public static int GetQuadRank(List<Card> hand) {
     		for (int i = 0; i < hand.Count; i++) {
                        if (CountOccurrences(hand, hand[i].GetRank()) == 4) {
                                return hand[i].GetRank();
                        }
                }

		return -1;
    	}

	private static bool CompareCards(Card card1, Card card2) {
        	if (card1.GetRank() != card2.GetRank()) {
            		return card1.GetRank() > card2.GetRank();
        	}
        	return card1.GetSuit() > card2.GetSuit(); // If identical
    	}

	public static void ReadDeckFromFile(string filename, List<List<Card>> hands) {
        	hands.Clear();
        	for (int i = 0; i < 6; i++) {
            		hands.Add(new List<Card>());
        	}

        	try {
			var lines = File.ReadAllLines(filename);
			var seenCards = new HashSet<string>();

			for (int i = 0; i < 6; i++) {
				string printLine = lines[i];
				Console.WriteLine(printLine); // display all file lines to user 
			}

			for (int i = 0; i < 6; i++) {	
				string line = lines[i];
				var cardStrings = line.Split(',');
	
				foreach (var cardStr in cardStrings) {
					string trimmedCard = cardStr.Trim();

					// duplicate card check
					if (seenCards.Contains(trimmedCard)) {
						Console.WriteLine("\n*** ERROR - DUPLICATED CARD FOUND IN DECK ***");
						Console.WriteLine($"*** DUPLICATE: {trimmedCard} ***");
						Environment.Exit(1);
					}
	
					seenCards.Add(trimmedCard);
					char suit = trimmedCard[^1]; // or .Last()?
					int rank = 0;

					// Determine the rank
					if (char.IsDigit(trimmedCard[0])) {
						if (trimmedCard[0] == '1' && trimmedCard.Length > 1 && trimmedCard[1] == '0') {
							rank = 10;
						} else {
							rank = trimmedCard[0] - '0';
						}
					} else {
						switch (trimmedCard[0]) { 
							case 'J': rank = 11; break;
							case 'Q': rank = 12; break;
							case 'K': rank = 13; break;
							case 'A': rank = 14; break;
						}
					}

					hands[i].Add(new Card(rank, suit));
				}
			}

			Console.WriteLine();
			PrintSixHands(hands);
		} catch (IOException e) {
			Console.WriteLine($"Error reading file: {e.Message}");
		}
    	}

	public static bool IsStraight(List<Card> hand) {
        	HashSet<int> ranks = new HashSet<int>();
		for (int i = 0; i < hand.Count; i++) {
			ranks.Add(hand[i].GetRank());
		}
		
		List<int> sortedRanks = new List<int>(ranks);
		sortedRanks.Sort();

		if (sortedRanks.SequenceEqual(new List<int> { 2, 3, 4, 5, 14 })) {
			return true;
		}

		for (int i = 0; i < sortedRanks.Count - 1; i++) {
			if (sortedRanks[i + 1] != sortedRanks[i] + 1) {
				return false;
			}
		}
		return true;
    	}

	public static Card GetHighestCard(List<Card> hand, bool isAceStraight) {
		Card highestCard = hand[0];

		for (int i = 1; i < hand.Count; i++) {
			Card currentCard = hand[i];
			if (isAceStraight && currentCard.GetRank() == 14) {
				if (highestCard.GetRank() == 14 || currentCard.GetRank() > highestCard.GetRank()) {
					highestCard = currentCard;
				} else {
					if (currentCard.GetRank() > highestCard.GetRank()) {
						highestCard = currentCard;
					}
				}
			}
		}
		return highestCard;
	}

	public static int GetRank(string cardStr) {
        	if (cardStr.StartsWith("10")) return 10;
        	char rank = cardStr[0];
		switch(rank) {
			case 'J': return 11;
			case 'Q': return 12;
			case 'K': return 13;
			case 'A': return 14;
            		default: return int.Parse(cardStr[0].ToString());
        	}
    	}
}


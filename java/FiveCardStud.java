import java.util.*;
import java.io.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class FiveCardStud {

	// main method to handle program flow 
	public static void main(String[] args) {
		// initialize a new deck of cards and a list to hold hands
		Deck deck = new Deck();
		List<List<Card>> hands = new ArrayList<>();
		for (int i = 0; i < 6; i++) {
			hands.add(new ArrayList<>()); // create 6 empty hands 
		}
		List<HandRank> handRanks = new ArrayList<>();

		System.out.println("*** P O K E R    H A N D    A N A L Y Z E R ***");	
		System.out.println();
		System.out.println();

		if (args.length > 0) { // part 2 with command line args
			System.out.println("*** USING TEST DECK ***");
            		System.out.println();
            		System.out.println("*** File: " + args[0]);
            		readDeckFromFile(args[0], hands);
		} else { // part 1 w/o command line args 
			System.out.println("*** USING RANDOMIZED DECK OF CARDS ***");
            		System.out.println();
            		System.out.println("*** Shuffled 52 card deck:");
            		deck.shuffle();
            		deck.printDeck(false);
            		deck.dealHands(hands);
            		printSixHands(hands);
            		System.out.println("*** Here is what remains in the deck...");
            		deck.printDeck(true);
            		System.out.println();
		}

		sortHands(hands, handRanks);
        	printWinningHand(hands, handRanks);

	}

	// enumeration for suits 
	public enum Suit {
       		DIAMONDS, CLUBS, HEARTS, SPADES
    	}

	// enumeration for hand ranks 
	public enum HandRank {
        	HIGH_CARD,
        	PAIR,
        	TWO_PAIR,
        	THREE_OF_A_KIND,
        	STRAIGHT,
        	FLUSH,
        	FULL_HOUSE,
        	FOUR_OF_A_KIND,
        	STRAIGHT_FLUSH,
        	ROYAL_FLUSH
    	}

	// convert hand rank enum to string for display
	private static String handRankToString(HandRank rank) {
		switch(rank) {
			case HIGH_CARD: return "High Card";
            		case PAIR: return "Pair";
            		case TWO_PAIR: return "Two Pair";
            		case THREE_OF_A_KIND: return "Three Of A Kind";
            		case STRAIGHT: return "Straight";
            		case FLUSH: return "Flush";
            		case FULL_HOUSE: return "Full House";
            		case FOUR_OF_A_KIND: return "Four Of A Kind";
            		case STRAIGHT_FLUSH: return "Straight Flush";
            		case ROYAL_FLUSH: return "Royal Straight Flush";
            		default: return "Unknown";
		}
	}

	// method to print winning hand 
	private static void printWinningHand(List<List<Card>> hands, List<HandRank> handRanks) {
		System.out.println("--- WINNING HAND ORDER ---");
		for (int i = 0; i < hands.size(); i++) {
			List<Card> hand = hands.get(i);
			for(int j = 0; j < hand.size(); j++) {
				System.out.print(hand.get(j).toString() + " ");
			}
			System.out.println("- " + handRankToString(handRanks.get(i)));
		}
		System.out.println();
	}

	// method to print out the 6 hands dealt 
	private static void printSixHands(List<List<Card>> hands) {
		System.out.println("*** Here are the six hands...");
		for (int i = 0; i < 6; i++) {
			List<Card> hand = hands.get(i);
			for (int j = 0; j < hand.size(); j++) {
				System.out.print(hand.get(j).toString() + " ");
			}
			System.out.println();
		}
		System.out.println();
	}

	// method to clear existing hand ranks and sort hands based on their rank
	private static void sortHands(List<List<Card>> hands, List<HandRank> handRanks) {
		handRanks.clear();
		Collections.sort(hands, new Comparator<List<Card>>() { // used to compare two hands by rank
			public int compare(List<Card> hand1, List<Card> hand2) {
				if (compareHands(hand1, hand2)) return -1;
				else return 1;
			}
		});

		for (List<Card> hand : hands) {
			handRanks.add(classifyHand(hand));
		}
	}

	// method to classify a hand by rank 
	public static HandRank classifyHand(List<Card> hand) {
		// create temp sortedHand to store hand in descending order for easy classification
		List<Card> sortedHand = new ArrayList<>(hand);
		Collections.sort(sortedHand, new Comparator<Card>() { 
			public int compare(Card a, Card b) {
				return Integer.compare(b.getRank(), a.getRank()); // descending order 
			}
		});

		// keep track of suits/ranks occurences 
		int[] occurrences = new int[15];
		int[] suitCount = new int[4];
		char[] suits = {'D', 'C', 'H', 'S'};

		for (int i = 0; i < sortedHand.size(); i++) {
			occurrences[sortedHand.get(i).getRank()]++;
			for (int j = 0; j < 4; j++) {
				if (sortedHand.get(i).getSuit() == suits[j]) {
					suitCount[j]++;
					break;
				}
			}
		}

		boolean flush = false;
		for (int i = 0; i < 4; i++) { // checks if hand is a flush (same suit)
			if (suitCount[i] == 5) {
				flush = true;
				break;
			}
		}
		boolean straight = isStraight(hand);
		
		if (flush && straight) {
			Set<Integer> royalRanks = new HashSet<>(Arrays.asList(14, 13, 12, 11, 10));
			Set<Integer> uniqueRanks = new HashSet<>();
			for (int i = 0; i < sortedHand.size(); i++) {
				uniqueRanks.add(sortedHand.get(i).getRank());
			}

			if (uniqueRanks.equals(royalRanks)) {
				return HandRank.ROYAL_FLUSH;
			} else {
				return HandRank.STRAIGHT_FLUSH;
			}	
		}

		int threeCount = 0;
		int pairCount = 0;
		for (int i = 2; i <= 14; i++) {
			if (occurrences[i] == 4) return HandRank.FOUR_OF_A_KIND;
			if (occurrences[i] == 3) threeCount++;
			if (occurrences[i] == 2) pairCount++;
		}

		if (threeCount == 1 && pairCount == 1) return HandRank.FULL_HOUSE;
		if (flush) return HandRank.FLUSH;
		if (straight) return HandRank.STRAIGHT;
		if (threeCount == 1) return HandRank.THREE_OF_A_KIND;
		if (pairCount == 2) return HandRank.TWO_PAIR;
		if (pairCount == 1) return HandRank.PAIR;

		return HandRank.HIGH_CARD;
	}

	// method to compare two hands by rank + tie breaking rules 
	public static boolean compareHands(List<Card> hand1, List<Card> hand2) {
		HandRank rank1 = classifyHand(hand1);
		HandRank rank2 = classifyHand(hand2);

		if (rank1 != rank2) {
			return rank1.compareTo(rank2) > 0;
		}

		// tie breaking

		// Case 1: Flush categories
		if (rank1 == HandRank.FLUSH || rank1 == HandRank.STRAIGHT_FLUSH || rank1 == HandRank.ROYAL_FLUSH) {
			Card highestCard1 = getHighestCard(hand1, false);
			Card highestCard2 = getHighestCard(hand2, false);

			if (highestCard1.getRank() != highestCard2.getRank()) {
				return highestCard1.getRank() > highestCard2.getRank();
			}
			return highestCard1.getSuit() > highestCard2.getSuit(); // if identical
		}

		// Case 2: Straights
		if (rank1 == HandRank.STRAIGHT) {
			boolean checkAce1 = isAceLowStraight(hand1);
			boolean checkAce2 = isAceLowStraight(hand2);

			Card highestCard1 = getHighestCard(hand1, checkAce1);
			Card highestCard2 = getHighestCard(hand2, checkAce2);

			if (highestCard1.getRank() != highestCard2.getRank()) {
				return highestCard1.getRank() > highestCard2.getRank();
			}
			return highestCard1.getSuit() > highestCard2.getSuit(); // If identical
		}

		// Case 3: Two pair
		if (rank1 == HandRank.TWO_PAIR) {
			int highPair1 = getHighestPairRank(hand1);
			int highPair2 = getHighestPairRank(hand2);

			if (highPair1 != highPair2) {
				return highPair1 > highPair2;
			}

			int lowPair1 = getLowestPairRank(hand1);
			int lowPair2 = getLowestPairRank(hand2);

			if (lowPair1 != lowPair2) {
				return lowPair1 > lowPair2;
			}

			int kicker1 = getKicker(hand1);
			int kicker2 = getKicker(hand2);
			return hand1.get(kicker1).getSuit() > hand2.get(kicker2).getSuit();    
		}

		// Case 4: Pairs
		if (rank1 == HandRank.PAIR) {
			int pairRank1 = getPairRank(hand1);
			int pairRank2 = getPairRank(hand2);
		
			if (pairRank1 != pairRank2) {
				return pairRank1 > pairRank2;
			}

			Card highVal1 = getHighestNonPairCard(hand1);
			Card highVal2 = getHighestNonPairCard(hand2);

			if (highVal1.getRank() != highVal2.getRank()) {
				return highVal1.getRank() > highVal2.getRank();
			}
			return highVal1.getSuit() > highVal2.getSuit();

		}

		// Case 5: High card
		if (rank1 == HandRank.HIGH_CARD) {
			Card highestCard1 = getHighestCard(hand1, false);
			Card highestCard2 = getHighestCard(hand2, false);

			if (highestCard1.getRank() != highestCard2.getRank()) {
				return highestCard1.getRank() > highestCard2.getRank();
			}
			return highestCard1.getSuit() > highestCard2.getSuit();
		}

		// handle general poker rules 
		if (rank1 == HandRank.FOUR_OF_A_KIND) {
			int quadRank1 = getQuadRank(hand1);
			int quadRank2 = getQuadRank(hand2);
			return quadRank1 > quadRank2;
		}

		if (rank1 == HandRank.THREE_OF_A_KIND) {
			int tripletRank1 = getTripletRank(hand1);
			int tripletRank2 = getTripletRank(hand2);
			return tripletRank1 > tripletRank2;
		}

		if (rank1 == HandRank.FULL_HOUSE) {
			int tripletRank1 = getTripletRank(hand1);
			int tripletRank2 = getTripletRank(hand2);

			if (tripletRank1 != tripletRank2) {
				return tripletRank1 > tripletRank2;
			}

			int pairRank1 = getPairRank(hand1);
			int pairRank2 = getPairRank(hand2);
			return pairRank1 > pairRank2;
		}

		return false;
	}

	// method to handle command line args 
	public static void readDeckFromFile(String filename, List<List<Card>> hands) {
		hands.clear(); // clear any potentially existing hands 
		for (int i = 0; i < 6; i++) {
			hands.add(new ArrayList<>());
		}

		// use Buffered Reader to read from file 
		try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
			String line;
			Set<String> seenCards = new HashSet<>();
			List<String> lines = new ArrayList<>();

			while ((line = br.readLine()) != null) {
				lines.add(line);
				System.out.println(line); // Display file line to user
			}

			for (int i = 0; i < 6; i++) { 
				String[] cardStrings = lines.get(i).split(",");
				for (String cardStr : cardStrings) {
					cardStr = cardStr.trim();

					// duplicate card check
					if (seenCards.contains(cardStr)) {
						System.out.println("\n*** ERROR - DUPLICATED CARD FOUND IN DECK ***\n");
						System.out.println("*** DUPLICATE: " + cardStr + " ***");
						System.exit(1);
					}
					seenCards.add(cardStr);
					
					char suit = cardStr.charAt(cardStr.length() - 1);
					int rank = 0;

					// card rank conversion
					if (cardStr.charAt(0) == '1' && cardStr.charAt(1) == '0') {
						rank = 10;
					} else if(cardStr.charAt(0) >= '2' && cardStr.charAt(0) <= '9') {
						rank = cardStr.charAt(0) - '0';
					} else {
						switch (cardStr.charAt(0)) {
							case 'J': rank = 11; break;
							case 'Q': rank = 12; break;
							case 'K': rank = 13; break;
							case 'A': rank = 14; break;
						}
					}
					hands.get(i).add(new Card(rank, suit));
				}
			}
			System.out.println();
			printSixHands(hands);
		} catch (IOException e) { 
			System.err.println("Error reading file: " + e.getMessage());
		}
	}

	// method to check if a hand is a straight 
	public static boolean isStraight(List<Card> hand) {
		Set<Integer> ranks = new HashSet<>();

		for (int i = 0; i < hand.size(); i++) {
			ranks.add(hand.get(i).getRank());
		}

		List<Integer> sortedRanks = new ArrayList<>(ranks);
		Collections.sort(sortedRanks); // ascending order

		// special check for Ace-low straight (A, 2, 3, 4, 5)
		if (sortedRanks.equals(Arrays.asList(2, 3, 4, 5, 14))) {
			return true; 
		}

		// checks if it is in consecutive order 
		for (int i = 0; i < sortedRanks.size() - 1; i++) {
			if (sortedRanks.get(i + 1) != sortedRanks.get(i) + 1) {
				return false;
			}
		}
		return true;
	}

	// check if a hand is an Ace-low straight
	public static boolean isAceLowStraight(List<Card> hand) {
		for (int i = 0; i < hand.size(); i++) {
			if (hand.get(i).getRank() == 14) {
				return true;
			}
		}
    		return false;
	}

	// get highest number card, includes case of Ace-low straight
	public static Card getHighestCard(List<Card> hand, boolean isAceStraight) {
		Card highestCard = hand.get(0);
		for (int i = 1; i < hand.size(); i++) {
			Card currentCard = hand.get(i);
			if (isAceStraight && currentCard.getRank() == 14) {
				if (highestCard.getRank() == 14 || currentCard.getRank() > highestCard.getRank()) {
					highestCard = currentCard;
				}
			} else {
				if (currentCard.getRank() > highestCard.getRank()) {
					highestCard = currentCard;
				}
			}
		}
		return highestCard;
	}

	// count occurrences of a specific rank in a hand
	public static int countOccurrences(List<Card> hand, int rank) {
		int count = 0;
		for (int i = 0; i < hand.size(); i++) {
			if (hand.get(i).getRank() == rank) {
				count++;
			}
		}
		return count;
	}
	
	// get the highest card not part of a pair
	public static Card getHighestNonPairCard(List<Card> hand) {
		List<Card> tempHand = new ArrayList<>();

		for (int i = 0; i < hand.size(); i++) {
			if (countOccurrences(hand, hand.get(i).getRank()) != 2) {
				tempHand.add(hand.get(i));
			}
		}

		Card highestCard = tempHand.get(0);
		for (int i = 1; i < tempHand.size(); i++) {
			if (tempHand.get(i).getRank() > highestCard.getRank()) {
				highestCard = tempHand.get(i);
			}
		}

		return highestCard;
	}
	
	// identify kicker card in a hand (not part of pair)
	public static int getKicker(List<Card> hand) {
		int kickerIndex = -1;
		int maxVal = 0;
		for (int i = 0; i < hand.size(); i++) {
			if (countOccurrences(hand, hand.get(i).getRank()) == 1 && hand.get(i).getRank() > maxVal) {
				maxVal = hand.get(i).getRank();
				kickerIndex = i;
			}
		}
		return kickerIndex;
	}

	// get the rank (value) of the pair in a hand
	public static int getPairRank(List<Card> hand) {
		for (int i = 0; i < hand.size(); i++) {
			if (countOccurrences(hand, hand.get(i).getRank()) == 2) {
				return hand.get(i).getRank();
			}
		}
		return -1;
	}

	// get the highest rank (value) of pairs in a hand
	public static int getHighestPairRank(List<Card> hand) {
		int highestPair = -1;
		for (int i = 0; i < hand.size(); i++) {
			if (countOccurrences(hand, hand.get(i).getRank()) == 2 && hand.get(i).getRank() > highestPair) {
				highestPair = hand.get(i).getRank();
			}
		}
		return highestPair;
	}

	// get the lowest rank (value) of pairs in a hand
	public static int getLowestPairRank(List<Card> hand) {
		int lowestPair = 15;
		for (int i = 0; i < hand.size(); i++) {
			if (countOccurrences(hand, hand.get(i).getRank()) == 2 && hand.get(i).getRank() < lowestPair) {
				lowestPair = hand.get(i).getRank();
			}
		}

		if (lowestPair == 15) {
			return -1;  
		}
		return lowestPair;
	}

	// get the rank of the three-of-a-kind in a hand
	public static int getTripletRank(List<Card> hand) {
		for (int i = 0; i < hand.size(); i++) {
			if (countOccurrences(hand, hand.get(i).getRank()) == 3) {
				return hand.get(i).getRank();
			}	
		}
		return -1;
	}

	// get the rank of the four-of-a-kind in a hand
	public static int getQuadRank(List<Card> hand) {
		for (int i = 0; i < hand.size(); i++) {
			if (countOccurrences(hand, hand.get(i).getRank()) == 4) {
				return hand.get(i).getRank();
			}
		}		
		return -1;
	}

}

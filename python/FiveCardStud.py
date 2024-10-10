import random
from collections import defaultdict
from enum import Enum
from Deck import Deck
from Card import Card
from functools import cmp_to_key

# enum for suits
class Suit(Enum):
    DIAMONDS = 'D'
    CLUBS = 'C'
    HEARTS = 'H'
    SPADES = 'S'

# to rank suits Diamonds < Clubs < Hearts < Spades
SUIT_RANKING = {
    'D': 1,  
    'C': 2,  
    'H': 3,  
    'S': 4   
}

# get suit rank based on the suit string
def suit_rank(suit):
    return SUIT_RANKING[suit]

# enum for hand ranks
class HandRank(Enum):
    HIGH_CARD = 1
    PAIR = 2
    TWO_PAIR = 3
    THREE_OF_A_KIND = 4
    STRAIGHT = 5
    FLUSH = 6
    FULL_HOUSE = 7
    FOUR_OF_A_KIND = 8
    STRAIGHT_FLUSH = 9
    ROYAL_FLUSH = 10

    # comparison operators for hand ranks based on their value
    def __lt__(self, other):
        return self.value < other.value

    def __gt__(self, other):
        return self.value > other.value

# convert hand rank enum to string
def hand_rank_to_string(rank):
    if rank == HandRank.HIGH_CARD:
        return "High Card"
    elif rank == HandRank.PAIR:
        return "Pair"
    elif rank == HandRank.TWO_PAIR:
        return "Two Pair"
    elif rank == HandRank.THREE_OF_A_KIND:
        return "Three Of A Kind"
    elif rank == HandRank.STRAIGHT:
        return "Straight"
    elif rank == HandRank.FLUSH:
        return "Flush"
    elif rank == HandRank.FULL_HOUSE:
        return "Full House"
    elif rank == HandRank.FOUR_OF_A_KIND:
        return "Four Of A Kind"
    elif rank == HandRank.STRAIGHT_FLUSH:
        return "Straight Flush"
    elif rank == HandRank.ROYAL_FLUSH:
        return "Royal Straight Flush"
    else:
        return "Unknown"

# method to handle command line args 
def read_deck_from_file(filename, hands):
    seen_cards = set() # to track duplicate cards

    try:
        with open(filename, 'r') as file:
            lines = file.readlines()  
            
            for line in lines:
                print(line.strip())  # display file line to user

            for i in range(6):
                card_strings = lines[i].strip().split(",")
                for card_str in card_strings:
                    card_str = card_str.strip() 
                    
                    # duplicate card check
                    if card_str in seen_cards:
                        print("\n*** ERROR - DUPLICATED CARD FOUND IN DECK ***")
                        print(f"\n\n*** DUPLICATE: {card_str} ***")
                        return  
                    
                    seen_cards.add(card_str)  
                    suit = card_str[-1]  
                    rank_str = card_str[:-1]

                    hands[i].append(Card(rank_str, suit))  

            print()
            print_six_hands(hands)
            
    except FileNotFoundError:
        print(f"Error: The file {filename} was not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

    return hands

# method to print winning hand 
def print_winning_hand(hands, hand_ranks):
    print("--- WINNING HAND ORDER ---")
    for i in range(len(hands)):
        hand = hands[i]
        hand_string = " ".join([f"{Card.rank_to_string(card.rank)}{card.suit}" for card in hand])
        print(f"{hand_string} - {hand_rank_to_string(hand_ranks[i])}")
    print()  

# method to print six hands 
def print_six_hands(hands):
    print("*** Here are the six hands...")
    for i in range(6):  
        hand = hands[i]  
        card_strings = [f"{Card.rank_to_string(card.rank)}{card.suit}" for card in hand]
        print(" ".join(card_strings))  
    print()  

# method to compare two hands and determine the winner
def compare_hands(hand1, hand2):
    rank1 = classify_hand(hand1)
    rank2 = classify_hand(hand2)
    
    if rank1 != rank2:
        return -1 if rank1 < rank2 else 1

    # tie breaking logic

    # case 1: Flush 
    if rank1 in {HandRank.FLUSH, HandRank.STRAIGHT_FLUSH, HandRank.ROYAL_FLUSH}:
        highest_card1 = get_highest_card(hand1, False)
        highest_card2 = get_highest_card(hand2, False)

        if highest_card1.rank != highest_card2.rank:
            if highest_card1.rank < highest_card2.rank:
                return -1
            else:
                return  1
        if suit_rank(highest_card1.suit) < suit_rank(highest_card2.suit):
            return -1
        else:
            return 1

    # case 2: Straight
    if rank1 == HandRank.STRAIGHT:
        check_ace1 = is_ace_low_straight(hand1)
        check_ace2 = is_ace_low_straight(hand2)

        highest_card1 = get_highest_card(hand1, check_ace1)
        highest_card2 = get_highest_card(hand2, check_ace2)

        if highest_card1.rank != highest_card2.rank:
            if highest_card1.rank < highest_card2.rank:
                return -1
            else: 
                return 1
        if suit_rank(highest_card1.suit) < suit_rank(highest_card2.suit): 
            return -1
        else: 
            return 1

    # case 3: Two Pair 
    if rank1 == HandRank.TWO_PAIR:
        high_pair1 = get_highest_pair_rank(hand1)
        high_pair2 = get_highest_pair_rank(hand2)

        if high_pair1 != high_pair2:
            if high_pair1 < high_pair2: 
                return -1
            else:
                return 1

        low_pair1 = get_lowest_pair_rank(hand1)
        low_pair2 = get_lowest_pair_rank(hand2)

        if low_pair1 != low_pair2:
            if low_pair1 < low_pair2:
                return -1
            else:
                return 1

        kicker1 = get_kicker(hand1)
        kicker2 = get_kicker(hand2)
        if suit_rank(hand1[kicker1].suit) < suit_rank(hand2[kicker2].suit):
            return -1 
        else:
            return 1

    # case 4: Pair 
    if rank1 == HandRank.PAIR:
        pair_rank1 = get_pair_rank(hand1)
        pair_rank2 = get_pair_rank(hand2)

        if pair_rank1 != pair_rank2:
            if pair_rank1 < pair_rank2:
                return -1 
            else:
                return 1

        high_val1 = get_highest_non_pair_card(hand1)
        high_val2 = get_highest_non_pair_card(hand2)

        if high_val1.rank != high_val2.rank:
            if high_val1.rank < high_val2.rank: 
                return -1
            else:
                return 1
        if suit_rank(high_val1.suit) < suit_rank(high_val2.suit):
                return -1
        else:
                return 1

    # case 5: high card 
    if rank1 == HandRank.HIGH_CARD:
        highest_card1 = get_highest_card(hand1, False)
        highest_card2 = get_highest_card(hand2, False)

        if highest_card1.rank != highest_card2.rank:
            if highest_card1.rank < highest_card2.rank:
                return -1
            else:
                return 1
        if suit_rank(highest_card1.suit) < suit_rank(highest_card2.suit):
            return -1
        else:
            return 1
    
    # handle tiebreakders for general poker rules 
    # three of a kind, four of a kind, full house     

    if rank1 == HandRank.FOUR_OF_A_KIND:
        quad_rank1 = get_quad_rank(hand1)
        quad_rank2 = get_quad_rank(hand2)
        if quad_rank1 < quad_rank2:
            return -1
        else:
            return 1

    if rank1 == HandRank.THREE_OF_A_KIND:
        triplet_rank1 = get_triplet_rank(hand1)
        triplet_rank2 = get_triplet_rank(hand2)
        if triplet_rank1 < triplet_rank2: 
            return -1
        else:
            return 1

    if rank1 == HandRank.FULL_HOUSE:
        triplet_rank1 = get_triplet_rank(hand1)
        triplet_rank2 = get_triplet_rank(hand2)

        if triplet_rank1 != triplet_rank2:
            if triplet_rank1 < triplet_rank2:
                return -1
            else:
                return 1

        pair_rank1 = get_pair_rank(hand1)
        pair_rank2 = get_pair_rank(hand2)
        if pair_rank1 < pair_rank2:
            return -1
        else:
            return 1

    return 0

# checks if the hand is a straight
def is_straight(hand):
    ranks = set()

    for card in hand:
        ranks.add(card.rank)

    sorted_ranks = sorted(ranks)  # Ascending order

    # Special case for Ace-low straight
    if sorted_ranks == [2, 3, 4, 5, 14]:
        return True

    for i in range(len(sorted_ranks) - 1):
        if sorted_ranks[i + 1] - sorted_ranks[i] != 1:
            return False

    return True

# classifies the rank of the hand
def classify_hand(hand):
    hand_copy = hand[:] # shallow copy of hand
    hand_copy.sort(key=lambda card: card.rank, reverse=True)
    occurrences = [0] * 15
    suits = defaultdict(int)
    
    for card in hand_copy:
        occurrences[card.rank] += 1
        suits[card.suit] += 1
    
    flush = any(count == 5 for count in suits.values())
    straight = is_straight(hand_copy)
    
    if flush and straight:
        royal_ranks = {10, 11, 12, 13, 14}  # Royal flush ranks
        unique_ranks = {card.rank for card in hand_copy}  # Unique ranks in the hand

        if unique_ranks == royal_ranks:
            return HandRank.ROYAL_FLUSH
        return HandRank.STRAIGHT_FLUSH        

    three_count = 0
    pair_count = 0

    for count in occurrences[2:]:
        if count == 4:
            return HandRank.FOUR_OF_A_KIND
        if count == 3:
            three_count += 1
        if count == 2:
            pair_count += 1

    if three_count == 1 and pair_count == 1:
        return HandRank.FULL_HOUSE
    if flush:
        return HandRank.FLUSH
    if straight:
        return HandRank.STRAIGHT
    if three_count == 1:
        return HandRank.THREE_OF_A_KIND
    if pair_count == 2:
        return HandRank.TWO_PAIR
    if pair_count == 1:
        return HandRank.PAIR

    return HandRank.HIGH_CARD

# sorts hands based on their rank using the compare_hands function
def sort_hands(hands):
    hand_ranks = []
    hands.sort(key=cmp_to_key(compare_hands), reverse=True)
    for hand in hands:
        hand_rank = classify_hand(hand)
        hand_ranks.append(hand_rank)
    return hand_ranks

# checks if hand is an Ace Low Straight (A 2 3 4 5)
def is_ace_low_straight(hand):
    ranks = {card.rank for card in hand}
    return ranks == {14, 2, 3, 4, 5}   

# returns the highest card in the hand
# considers case of Ace Low Straight
def get_highest_card(hand, is_ace_straight):
    temp_hand = hand.copy()
    if is_ace_straight:
        for i in range(len(temp_hand)):
            if temp_hand[i].rank == 14:
                temp_hand[i].rank = 1  # Treat Ace as low

    highest_card = temp_hand[0]
    for i in range(1, len(temp_hand)):
        if temp_hand[i].rank > highest_card.rank:
            highest_card = temp_hand[i]
    return highest_card

# counts the number of times a specific rank occurs in the hand
def count_occurrences(hand, rank):
    count = 0  
    for card in hand:
        if card.rank == rank:
            count += 1  
    return count

# returns the highest non-pair card (the kicker)
def get_highest_non_pair_card(hand):
    temp_hand = []  

    for card in hand:
        if count_occurrences(hand, card.rank) != 2:  
            temp_hand.append(card)

    if not temp_hand:  
        return None  

    highest_card = temp_hand[0] 
    for card in temp_hand[1:]:  
        if card.rank > highest_card.rank:  
            highest_card = card  

    return highest_card  

# identifies and returns the index of the kicker card in the hand
def get_kicker(hand):
    max_val = 0
    kicker_index = -1

    for index, card in enumerate(hand): 
        if count_occurrences(hand, card.rank) == 1 and card.rank > max_val:
            max_val = card.rank
            kicker_index = index

    return kicker_index

# get the rank (value) of the pair in a hand
def get_pair_rank(hand):
    for card in hand:
        if count_occurrences(hand, card.rank) == 2:  
            return card.rank
    return -1  

# get the highest rank (value) of pairs in a hand
def get_highest_pair_rank(hand):
    highest_pair = -1
    for card in hand:
        if count_occurrences(hand, card.rank) == 2 and card.rank > highest_pair:
            highest_pair = card.rank  
    return highest_pair  

# get the lowest rank (value) of pairs in a hand
def get_lowest_pair_rank(hand):
    lowest_pair = 15  
    for card in hand:
        if count_occurrences(hand, card.rank) == 2 and card.rank < lowest_pair:
            lowest_pair = card.rank  

    if lowest_pair == 15:
        return -1  
    return lowest_pair  

# get the rank of the three-of-a-kind in a hand
def get_triplet_rank(hand):
    for card in hand:
        if count_occurrences(hand, card.rank) == 3: 
            return card.rank  
    return -1  

# get the rank of the four-of-a-kind in a hand
def get_quad_rank(hand):
    for card in hand:
        if count_occurrences(hand, card.rank) == 4: 
            return card.rank  
    return -1  

# main method to handle overall program flow 
def main(args):
    deck = Deck()
    hands = [[] for _ in range(6)]  # create 6 empty hands
     
    print("*** P O K E R    H A N D    A N A L Y Z E R ***\n")
    print()

    if len(args) > 0:  # part 2 with command line args
        print("*** USING TEST DECK ***")
        print(f"\n*** File: {args[0]}")
        if read_deck_from_file(args[0], hands) is None:
            return  # stop execution if a duplicate card was found
    else:  # part 1 without command line args
        print("*** USING RANDOMIZED DECK OF CARDS ***")
        print("\n*** Shuffled 52 card deck:")
        deck.shuffle()
        deck.print_deck(False)
        deck.deal_hands(hands)
        print_six_hands(hands)
        print("*** Here is what remains in the deck...")
        deck.print_deck(True)
        print()

    hand_ranks = sort_hands(hands)
    print_winning_hand(hands, hand_ranks)

if __name__ == "__main__":
    import sys
    main(sys.argv[1:]) # pass comand line args to main

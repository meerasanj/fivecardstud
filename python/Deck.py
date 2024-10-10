import random
from Card import Card

class Deck:
    # deck constructor
    def __init__(self):
        self.cards = []
        self.create_deck()

    # populates deck with 52 cards
    def create_deck(self):
        suits = ['H', 'D', 'C', 'S']
        ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
        self.cards = [Card(rank, suit) for suit in suits for rank in ranks]

    # shuffle deck using random
    def shuffle(self):
        random.shuffle(self.cards)

    # deals 6 hands of 5 cards
    def deal_hands(self, hands):
        for _ in range(5): 
            for hand in hands:
                hand.append(self.cards.pop(0))

    # method to print the cards in the deck, singleLine bool used to start a new line or not 
    def print_deck(self, single_line=False):
        count = 0
        for card in self.cards:
            print(card.to_string(), end=" ")
            count += 1
            if not single_line and count % 13 == 0:
                print()
        print() 

class Card:
    # constructor that initializes a card with a rank and suit
    def __init__(self, rank, suit):
        self.rank = self.rank_to_int(rank)
        self.suit = suit

    # static method to convert a rank string to an integer representation
    @staticmethod
    def rank_to_int(rank_str):
        if not isinstance(rank_str, str):
            raise ValueError(f"Expected a string for rank, got {type(rank_str).__name__}")
            # should not happen

        if rank_str == "10":
            return 10
        elif rank_str in ["2", "3", "4", "5", "6", "7", "8", "9"]:
            return int(rank_str)
        elif rank_str[0] == "J":
            return 11
        elif rank_str[0] == "Q":
            return 12
        elif rank_str[0] == "K":
            return 13
        elif rank_str[0] == "A":
            return 14
        else:
            raise ValueError(f"Invalid rank: {rank_str}")

    # convert numeric ranks back to their string representations
    @staticmethod
    def rank_to_string(rank):
        """Convert integer rank to its string representation."""
        if rank == 14 or rank == 1:
            return 'A'
        elif rank == 13:
            return 'K'
        elif rank == 12:
            return 'Q'
        elif rank == 11:
            return 'J'
        else:
            return str(rank)  # For '2' to '10'

    # create a string representation of the card
    def to_string(self):
        if self.rank == 14:
            rank_str = "A"
        elif self.rank == 13:
            rank_str = "K"
        elif self.rank == 12:
            rank_str = "Q"
        elif self.rank == 11:
            rank_str = "J"
        else:
            rank_str = str(self.rank)
        return f"{rank_str}{self.suit}"


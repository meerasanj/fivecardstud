// src/hand_rank.rs

#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum HandRank {
    HighCard = 1,
    Pair = 2,
    TwoPair = 3,
    ThreeOfAKind = 4,
    Straight = 5,
    Flush = 6,
    FullHouse = 7,
    FourOfAKind = 8,
    StraightFlush = 9,
    RoyalFlush = 10,
}

impl HandRank {
    // converts HandRank to string format
    pub fn to_string(&self) -> &str {
        match self {
            HandRank::HighCard => "High Card",
            HandRank::Pair => "Pair",
            HandRank::TwoPair => "Two Pair",
            HandRank::ThreeOfAKind => "Three Of A Kind",
            HandRank::Straight => "Straight",
            HandRank::Flush => "Flush",
            HandRank::FullHouse => "Full House",
            HandRank::FourOfAKind => "Four Of A Kind",
            HandRank::StraightFlush => "Straight Flush",
            HandRank::RoyalFlush => "Royal Straight Flush",
        }
    }
}



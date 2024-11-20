// src/card.rs

use crate::suit::Suit;

#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub struct Card {
    pub rank: u8,
    pub suit: Suit,
}

impl Card {
    // Card constructor 
    pub fn new(rank: &str, suit_char: char) -> Result<Card, String> {
        let rank = Card::rank_to_int(rank)?;
        let suit = Suit::from_char(suit_char)?;
        Ok(Card { rank, suit })
    }

    // Converts a string to rank 
    pub fn string_to_rank(s: &str) -> Option<u8> {
        match s {
            "A" => Some(14),
            "K" => Some(13),
            "Q" => Some(12),
            "J" => Some(11),
            "10" => Some(10),
            "9" => Some(9),
            "8" => Some(8),
            "7" => Some(7),
            "6" => Some(6),
            "5" => Some(5),
            "4" => Some(4),
            "3" => Some(3),
            "2" => Some(2),
            _ => None,
        }
    }

    // Converts a rank string to its integer value
    fn rank_to_int(rank: &str) -> Result<u8, String> {
        match rank {
            "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" => Ok(rank.parse::<u8>().unwrap()),
            "10" => Ok(10),
            "J" => Ok(11),
            "Q" => Ok(12),
            "K" => Ok(13),
            "A" => Ok(14),
            _ => Err(format!("Invalid rank: {}", rank)),
        }
    }

    // Converts integer rank back to string representation
    pub fn rank_to_string(rank: u8) -> String {
        match rank {
            2..=10 => rank.to_string(),
            11 => "J".to_string(),
            12 => "Q".to_string(),
            13 => "K".to_string(),
            14 => "A".to_string(),
            _ => "Unknown".to_string(),
        }
    }

    // Converts the card to its string representation
    pub fn to_string(&self) -> String {
        format!("{}{}", Card::rank_to_string(self.rank), self.suit.to_char())
    }
}

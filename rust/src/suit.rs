// src/suit.rs

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub enum Suit {
    Diamonds,
    Clubs,
    Hearts,
    Spades,
}

impl Suit {
    // Convert a character to a Suit enum
    pub fn from_char(c: char) -> Result<Suit, String> {
        match c {
            'D' => Ok(Suit::Diamonds),
            'C' => Ok(Suit::Clubs),
            'H' => Ok(Suit::Hearts),
            'S' => Ok(Suit::Spades),
            _ => Err(format!("Invalid suit character: {}", c)),   
        }  
    } 

    // Get the character representation of the suit
    pub fn to_char(&self) -> char {
        match self {
            Suit::Diamonds => 'D',
            Suit::Clubs => 'C',
            Suit::Hearts => 'H',
            Suit::Spades => 'S',
        }
    }

    // Get the rank of the suit
    pub fn rank(&self) -> u8 {
        match self {
            Suit::Diamonds => 1,
            Suit::Clubs => 2,
            Suit::Hearts => 3,
            Suit::Spades => 4,
        }
    }
}

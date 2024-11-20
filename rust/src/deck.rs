// src/deck.rs

use rand::seq::SliceRandom;
use rand::thread_rng;
use crate::card::Card;

// Deck struct
pub struct Deck {
    pub cards: Vec<Card>,
}

impl Deck {
    // Deck constructor 
    pub fn new() -> Deck {
        let mut deck = Deck { cards: Vec::with_capacity(52) };
        deck.create_deck();
        deck
    }

    // Populates the deck with all 52 standard cards
    pub fn create_deck(&mut self) {
        let suits = ['D', 'C', 'H', 'S'];
        let ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"];
        for &suit_char in &suits {
            for &rank in &ranks {
                if let Ok(card) = Card::new(rank, suit_char) {
                    self.cards.push(card);
                }
            }
        }
    }

    // Shuffle the deck using the rand crate's random generator
    pub fn shuffle(&mut self) {
        let mut rng = thread_rng();
        self.cards.shuffle(&mut rng);
    }

    // Deals hands from the deck
    pub fn deal_hands(&mut self, hands: &mut Vec<Vec<Card>>) {
        for _ in 0..5 {
            for hand in hands.iter_mut() {
                if !self.cards.is_empty() {
                    let card = self.cards.remove(0);
                    hand.push(card);
                }
            }
        }
    }

    // Print the entire deck with consideration to single_line bool
    pub fn print_deck(&self, single_line: bool) {
        let mut count = 0;
        for card in &self.cards {
            print!("{} ", card.to_string());
            count += 1;
            if !single_line && count % 13 == 0 {
                println!();
            }
        }
        println!();
    }
}

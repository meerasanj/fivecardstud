// src/main.rs

use std::collections::{HashSet, HashMap};
use std::fs::File;
use std::io::{self, BufRead, ErrorKind};
use std::env;
use std::process;

mod card;
mod deck;
mod suit;
mod hand_rank;

use crate::card::Card;
use deck::Deck;
use crate::suit::Suit;
use hand_rank::HandRank;

// main method to handle overall program flow 
fn main() {
    println!("*** P O K E R    H A N D    A N A L Y Z E R ***\n\n");
    let args: Vec<String> = env::args().collect(); //retrive command line args 
    let mut hands = vec![Vec::new(); 6];

    if args.len() > 1 { //Part 2 with command line args 
        println!("*** USING TEST DECK ***");
        println!("\n*** File: {} ", args[1]);
        if let Err(error_message) = read_deck_from_file(&args[1], &mut hands) {
            eprintln!("{}", error_message);
            process::exit(1);
        }
    } else { // Part 1 without command line args 
        println!("*** USING RANDOMIZED DECK OF CARDS ***\n");
        let mut deck = Deck::new(); 
        deck.shuffle();
        println!("*** Shuffled 52 card deck");
        deck.print_deck(false);
        deck.deal_hands(&mut hands);
        print_six_hands(&hands);
        println!("*** Here is what remains in the deck...");
        deck.print_deck(true);
        println!();
    }
    
    let hand_ranks = sort_hands(&mut hands);
    print_winning_hand(&hands, &hand_ranks);
}

// returns suit value in u8 format
pub fn suit_rank(suit: Suit) -> u8 {
    suit.rank()
}

// method to print six hands
pub fn print_six_hands(hands: &Vec<Vec<Card>>) {
    println!("*** Here are the six hands...");
    for hand in hands.iter().take(6) {
        let card_strings: Vec<String> = hand
            .iter()
            .map(|card| format!("{}{}", Card::rank_to_string(card.rank), card.suit.to_char()))
            .collect();
        println!("{}", card_strings.join(" "));
    }
    println!();
}

// method to print winning hand order 
pub fn print_winning_hand(hands: &[Vec<Card>], hand_ranks: &[HandRank]) {
    println!("--- WINNING HAND ORDER ---");

    for (i, hand) in hands.iter().enumerate() {
        let hand_string: String = hand
        .iter()
        .map(|card| format!("{}{}", Card::rank_to_string(card.rank), card.suit.to_char()))
        .collect::<Vec<String>>()
        .join(" ");

        println!("{} - {}", hand_string, hand_ranks[i].to_string());
    }
    println!();
}

// Method to handle command line args 
pub fn read_deck_from_file(filename: &str, hands: &mut Vec<Vec<Card>>) -> Result<(), String> {
    let mut seen_cards = HashSet::new(); // To track duplicate cards

    let file = File::open(filename);
    let file = match file {
        Ok(f) => f,
        Err(e) => {
            if e.kind() == ErrorKind::NotFound {
                println!("Error: The file {} was not found.", filename);
            } else {
                println!("An error occurred while opening the file: {}", e);
            }
            return Err(e.to_string());
        }
    };

    let reader = io::BufReader::new(file);
    let lines: Vec<String> = reader
    .lines()
    .map(|line| line.unwrap_or_default())
    .collect();

    for line in &lines {
        println!("{}", line.trim());
    }

    for i in 0..6 {
        let line = &lines[i];
        let card_strings: Vec<&str> = line.trim().split(',').collect();

        for card_str in card_strings {
            let card_str = card_str.trim();

            // Duplicate Card Check 
            if seen_cards.contains(card_str) {
                println!("\n*** ERROR - DUPLICATED CARD FOUND IN DECK ***");
                println!("\n\n*** DUPLICATE: {} ***", card_str);
                return Err(format!("Duplicated card found: {}", card_str));
            }

            seen_cards.insert(card_str.to_string());

            if card_str.len() < 2 {
                println!("Invalid card: {}", card_str);
                return Err(format!("Invalid card format: {}", card_str));
            }

            let suit_char = card_str.chars().last().unwrap();
            let rank_str = &card_str[..card_str.len() - 1];

            let suit = match Suit::from_char(suit_char) {
                Ok(s) => s,
                Err(_e) => {
                    println!("Invalid suit in card: {}", card_str);
                    return Err(format!("Invalid suit in card: {}", card_str));
                }
            };

            let rank = match Card::string_to_rank(rank_str) {
                Some(r) => r,
                None => {
                    println!("Invalid rank in card: {}", card_str);
                    return Err(format!("Invalid rank in card: {}", card_str));
                }
            };

            let card = Card { rank, suit };
            hands[i].push(card);
        }
    }

    println!();
    print_six_hands(&hands);

    Ok(())
}

// Function to check if a hand is a straight
fn is_straight(hand: &[Card]) -> bool {
    let mut ranks: HashSet<u8> = HashSet::new();
    for card in hand {
        ranks.insert(card.rank);
    }

    if ranks.len() != 5 {
        return false;
    }

    let mut sorted_ranks: Vec<u8> = ranks.into_iter().collect();
    sorted_ranks.sort_unstable();

    // Special case for Ace-low straight (A, 2, 3, 4, 5)
    if sorted_ranks == [2, 3, 4, 5, 14] {
        return true;
    }

    for i in 0..sorted_ranks.len() - 1 {
        if sorted_ranks[i + 1] - sorted_ranks[i] != 1 {
            return false;
        }
    }

    true
}

// Classifies the rank of the hand
fn classify_hand(hand: &[Card]) -> HandRank {
    let mut hand_copy = hand.to_vec(); 
    hand_copy.sort_by_key(|card| std::cmp::Reverse(card.rank)); 

    let mut occurrences = vec![0; 15];
    let mut suits = HashMap::new();

    for card in &hand_copy {
        occurrences[card.rank as usize] += 1;
        *suits.entry(card.suit).or_insert(0) += 1;
    }

    let flush = suits.values().any(|&count| count == 5);
    let straight = is_straight(&hand_copy);

    if flush && straight {
        let royal_ranks: HashSet<u8> = vec![10, 11, 12, 13, 14].into_iter().collect();
        let unique_ranks: HashSet<u8> = hand_copy.iter().map(|card| card.rank).collect();

        if unique_ranks == royal_ranks {
            return HandRank::RoyalFlush;
        }
        return HandRank::StraightFlush;
    }

    let mut three_count = 0;
    let mut pair_count = 0;

    for &count in &occurrences[2..] {
        if count == 4 {
            return HandRank::FourOfAKind;
        }
        if count == 3 {
            three_count += 1;
        }
        if count == 2 {
            pair_count += 1;
        }
    }

    if three_count == 1 && pair_count == 1 {
        return HandRank::FullHouse;
    }
    if flush {
        return HandRank::Flush;
    }
    if straight {
        return HandRank::Straight;
    }
    if three_count == 1 {
        return HandRank::ThreeOfAKind;
    }
    if pair_count == 2 {
        return HandRank::TwoPair;
    }
    if pair_count == 1 {
        return HandRank::Pair;
    }

    HandRank::HighCard
}

// Checks if hand is an Ace Low Straight (A 2 3 4 5)
pub fn is_ace_low_straight(hand: &[Card]) -> bool {
    let ranks: HashSet<u8> = hand.iter().map(|card| card.rank).collect();
    ranks == [14, 2, 3, 4, 5].iter().cloned().collect()
}

// Returns the highest card in the hand, considers case of ace low straight
pub fn get_highest_card(hand: &[Card], is_ace_straight: bool) -> Card {
    let mut temp_hand = hand.to_vec();
        
        if is_ace_straight {

            for card in &mut temp_hand {
                if card.rank == 14 {
                    card.rank = 1;
                }
            }
        }

        *temp_hand.iter().max_by_key(|card| card.rank).unwrap()
}

// Counts the number of times a specific rank occurs in the hand
pub fn count_occurrences(hand: &[Card], rank: u8) -> usize {
    hand.iter().filter(|&card| card.rank == rank).count()
}

// Returns the highest non-pair card (the kicker)
pub fn get_highest_non_pair_card(hand: &[Card]) -> Option<Card> {
    let temp_hand: Vec<Card> = hand
    .iter()
    .filter(|&card| count_occurrences(hand, card.rank) != 2)
    .cloned()
    .collect();

    if temp_hand.is_empty() {
        return None;
    }

    Some(*temp_hand.iter().max_by_key(|card| card.rank).unwrap())
}

// Identifies and returns the index of the kicker card in the hand
pub fn get_kicker(hand: &[Card]) -> Option<usize> {
    let mut max_val = 0;
    let mut kicker_index = None;

    for (index, card) in hand.iter().enumerate() {
        if count_occurrences(hand, card.rank) == 1 && card.rank > max_val {
            max_val = card.rank;
            kicker_index = Some(index);
        }
    }

    kicker_index
}

// Get the rank (value) of the pair in a hand
pub fn get_pair_rank(hand: &[Card]) -> i32 {
    for card in hand {
        if count_occurrences(hand, card.rank) == 2 {
            return card.rank as i32;
        }
    }
    -1
}

// get the highest rank (value) of pairs in a hand
pub fn get_highest_pair_rank(hand: &[Card]) -> i32 {
    let mut highest_pair = -1;

    for card in hand {
        if count_occurrences(hand, card.rank) == 2 && card.rank > highest_pair as u8 {
            highest_pair = card.rank as i32;
        }
    }

    highest_pair
}

// Get the lowest rank (value) of pairs in a hand
pub fn get_lowest_pair_rank(hand: &[Card]) -> i32 {
    let mut lowest_pair = 15;

    for card in hand {
        if count_occurrences(hand, card.rank) == 2 && card.rank < lowest_pair as u8 {
            lowest_pair = card.rank as i32;
        }
    }

    if lowest_pair == 15 {
        -1
    } else {
        lowest_pair
    }
}

// get the rank of the three-of-a-kind in a hand
pub fn get_triplet_rank(hand: &[Card]) -> i32 {
    for card in hand {
        if count_occurrences(hand, card.rank) == 3 {
            return card.rank as i32;
        }
    }
    -1
}

// Get the rank of the four-of-a-kind in a hand
pub fn get_quad_rank(hand: &[Card]) -> i32 {
    for card in hand {
        if count_occurrences(hand, card.rank) == 4 {
            return card.rank as i32;
        }
    }
    -1
}

// Method to compare two hands and determine the winner
pub fn compare_hands(hand1: &[Card], hand2: &[Card]) -> i32 {
    let rank1 = classify_hand(hand1);
    let rank2 = classify_hand(hand2);

    if rank1 != rank2 {
        return if rank1 < rank2 { -1 } else { 1 };
    }

    //tie breaking logic

    // case 1: Flush 
    if matches!(rank1, HandRank::Flush | HandRank::StraightFlush | HandRank::RoyalFlush) {
        let highest_card1 = get_highest_card(hand1, false);
        let highest_card2 = get_highest_card(hand2, false);

        if highest_card1.rank != highest_card2.rank {
            return if highest_card1.rank < highest_card2.rank { -1 } else { 1 };
        }
        return if suit_rank(highest_card1.suit) < suit_rank(highest_card2.suit) { -1 } else { 1 };
    }

    // case 2: straight 
    if rank1 == HandRank::Straight {
        let check_ace1 = is_ace_low_straight(hand1);
        let check_ace2 = is_ace_low_straight(hand2);

        let highest_card1 = get_highest_card(hand1, check_ace1);
        let highest_card2 = get_highest_card(hand2, check_ace2);

        if highest_card1.rank != highest_card2.rank {
            return if highest_card1.rank < highest_card2.rank { -1 } else { 1 };
        }
        return if suit_rank(highest_card1.suit) < suit_rank(highest_card2.suit) { -1 } else { 1 };
    }

    // case 3: two pair 
    if rank1 == HandRank::TwoPair {
        let high_pair1 = get_highest_pair_rank(hand1);
        let high_pair2 = get_highest_pair_rank(hand2);

        if high_pair1 != high_pair2 {
            return if high_pair1 < high_pair2 { -1 } else { 1 };
        }

        let low_pair1 = get_lowest_pair_rank(hand1);
        let low_pair2 = get_lowest_pair_rank(hand2);

        if low_pair1 != low_pair2 {
            return if low_pair1 < low_pair2 { -1 } else { 1 };
        }

        let kicker1 = get_kicker(hand1);
        let kicker2 = get_kicker(hand2);

        if let (Some(kicker1), Some(kicker2)) = (kicker1, kicker2) {
            return if suit_rank(hand1[kicker1].suit) < suit_rank(hand2[kicker2].suit) { -1 } else { 1 };
        }
    }

    // case 4: pair 
    if rank1 == HandRank::Pair {
        let pair_rank1 = get_pair_rank(hand1);
        let pair_rank2 = get_pair_rank(hand2);

        if pair_rank1 != pair_rank2 {
            return if pair_rank1 < pair_rank2 { -1 } else { 1 };
        }

        let high_val1 = get_highest_non_pair_card(hand1);
        let high_val2 = get_highest_non_pair_card(hand2);

        if let (Some(high_val1), Some(high_val2)) = (high_val1, high_val2) {
            if high_val1.rank != high_val2.rank {
                return if suit_rank(high_val1.suit) < suit_rank(high_val2.suit) { -1 } else { 1 };
            }
            
        }
    }

    // case 5: high card 
    if rank1 == HandRank::HighCard {
        let highest_card1 = get_highest_card(hand1, false);
        let highest_card2 = get_highest_card(hand2, false);

        if highest_card1.rank != highest_card2.rank {
            return if highest_card1.rank < highest_card2.rank { -1 } else { 1 };
        }
        return if suit_rank(highest_card1.suit) < suit_rank(highest_card2.suit) { -1 } else { 1 };
    }

    // other tiebreaking rules - three of a kind, four of a kind, full house  

    if rank1 == HandRank::FourOfAKind {
        let quad_rank1 = get_quad_rank(hand1);
        let quad_rank2 = get_quad_rank(hand2);
        return if quad_rank1 < quad_rank2 { -1 } else { 1 };
    }

    if rank1 == HandRank::ThreeOfAKind {
        let triplet_rank1 = get_triplet_rank(hand1);
        let triplet_rank2 = get_triplet_rank(hand2);
        return if triplet_rank1 < triplet_rank2 { -1 } else { 1 };
    }

    if rank1 == HandRank::FullHouse {
        let triplet_rank1 = get_triplet_rank(hand1);
        let triplet_rank2 = get_triplet_rank(hand2);

        if triplet_rank1 != triplet_rank2 {
            return if triplet_rank1 < triplet_rank2 { -1 } else { 1 };
        }

        let pair_rank1 = get_pair_rank(hand1);
        let pair_rank2 = get_pair_rank(hand2);
        return if pair_rank1 < pair_rank2 { -1 } else { 1 };
    }

    0 
}

// Sorts hands based on their rank using the compare_hands and classify_hand functions 
pub fn sort_hands(hands: &mut Vec<Vec<Card>>) -> Vec<HandRank> {
    hands.sort_by(|hand1, hand2| compare_hands(hand2, hand1).cmp(&0));
    let hand_ranks: Vec<HandRank> = hands.iter().map(|hand| classify_hand(hand)).collect();
    hand_ranks
}

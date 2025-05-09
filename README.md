# FiveCardStud

## Purpose
FiveCardStud is a comprehensive poker program designed to simulate, analyze, and evaluate hands in the Five Card Stud variant of poker. The program was implemented across 10 different programming languages, showcasing the versatility of the design and demonstrating how the same problem can be solved using various languages and paradigms. The project spans approximately 8,000 lines of code and leverages a variety of programming constructs, including arrays, lists, tuples, enums, hash tables, and custom classes.

The languages included in this project are:
- Java
- Python
- C++
- C#
- Fortran
- Rust
- Lisp
- Julia
- Go
- Perl

## Feautures
- Hand Evaluation: Classifies hands based on poker hand rankings.
- Simulation: Simulates hands of Five Card Stud with random card distribution and evaluation.
- Language Diversity: Provides implementations in multiple languages for comparison of syntax, performance, and readability.
- Custom Implementations: Utilizes advanced data structures and algorithms to simulate a poker game.

## Instructions - How to Compile and Run

Note: Each language implementation is stored in its own directory. The handsets directory contains test cases used to validate the correctness of the logic.

### cpp
	To compile and link: 					c++ -o a.out fivecardstud.cpp card.cpp deck.cpp
	To run part 1 (w/o command line args):			./a.out 
	To run part 2 (w/ command line args):			./a.out ../handsets/threeofakind

### java
	To compile and link: 					javac FiveCardStud.java Card.java Deck.java
	To run part 1 (w/o command line args):			java FiveCardStud
	To run part 2 (w/ command line args):			java FiveCardStud ../handsets/threeofakind

### python
	To compile & run part 1 (w/o command line args):	python3 FiveCardStud.py                                     
	To run part 2 (w command line args):          		python3 FiveCardStud.py ../handsets/threeofakind

### csharp
	To compile and link:                                    csc FiveCardStud.cs Deck.cs Card.cs
	To run part 1 (w/o command line args):          	mono FiveCardStud.exe
	To run part 2 (w/ command line args):           	mono FiveCardStud.exe ../handsets/threeofakind

### fortran
	To compile and link: 					gfortran -o a.out Deck.f90 Card.f90 HandRankings.f90 FiveCardStud.f90
	To run part 1 (w/o command line args):			./a.out
	To run part 2 (w/ command line args):  			./a.out ../handsets/threeofakind

### julia
	To compile & run part 1 (w/o command line args:		julia FiveCardStud.jl
	To run part 2 (w command line args):			julia FiveCardStud.jl ../handsets/threeofakind

### go
	To compile and link: 					go build -o a.out FiveCardStud.go Card.go Deck.go
	To run part 1 (w/o command line args):			./a.out
	To run part 2 (w command line args):			./a.out ../handsets/threeofakind

### perl
	To compile & run part 1 (w/o command line args):	perl FiveCardStud.pl
	To run part 2 (w command line args):			perl FiveCardStud.pl ../handsets/threeofakind
### rust
	To compile and link:					In the rust directory: cargo build
	To run part 1 (w/o command line args):			cargo run
	To run part 2 (w command line args):			cargo run ../handsets/threeofakind

### lisp
	To compile and link:					chmod u+x FiveCardStud.lisp
	To run part 1 (w/o command line args):			./FiveCardStud.lisp
	To run part 2 (w command line args):			./FiveCardStud.lisp ../handsets/threeofakind

 ## License
 No license has been provided for this project
 

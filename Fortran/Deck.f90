module DeckModule
        use CardModule
        implicit none
        ! define derived type Deck 
        type :: Deck
                type(Card), allocatable :: cards(:)
        contains
                procedure :: initialize => create_deck
                procedure :: shuffle_deck => shuffle
                procedure :: print_deck => print_deck
                procedure :: deal_hands => deal_hands
        end type Deck
contains
        ! creates a standard 52 card deck 
        subroutine create_deck(this)
                class(Deck), intent(out) :: this
                integer :: suit_idx, rank_idx, total_cards
                character(len=1), dimension(4) :: suits
                character(len=2), dimension(13) :: ranks

                suits = ['H', 'D', 'C', 'S']
                ranks = [' 2', ' 3', ' 4', ' 5', ' 6', ' 7', ' 8', ' 9', '10', ' J', ' Q', ' K', ' A']
                
                total_cards = size(suits) * size(ranks)
                allocate(this%cards(total_cards)) ! allocate memory for 52 cards 
        
                ! loop to initialize each card 
                do suit_idx = 1, size(suits)
                        do rank_idx = 1, size(ranks)
                                call this%cards((suit_idx - 1) * size(ranks) + rank_idx)%initialize(trim(ranks(rank_idx)), suits(suit_idx))
                        enddo
                enddo
        end subroutine create_deck

        ! shuffle the deck using random number 
        subroutine shuffle(this)
                class(Deck), intent(inout) :: this
                integer :: i, j
                type(Card) :: temp
                real :: random_value
                do i = size(this%cards), 2, -1
                        call random_number(random_value) ! generate random # between 0 and 1 
                        j = floor(random_value * i) + 1  ! calculate a random index for swapping
                        temp = this%cards(i)
                        this%cards(i) = this%cards(j)
                        this%cards(j) = temp
                enddo
        end subroutine shuffle

        ! to print the deck of cards
        subroutine print_deck(this, singleLine)
                class(Deck), intent(in) :: this
                logical, intent(in) :: singleLine
                integer :: i, count

                count = 0
                do i = 1, size(this%cards)
                        write(*, "(A)", advance='no') trim(this%cards(i)%to_string())
                        count = count + 1
                        ! uses singleLine bool to check if we need to print a new line 
                        if (.not. singleLine .and. mod(count, 13) == 0) then
                                print *
                        else
                                write(*, "(A)", advance='no') ' '
                        endif
                enddo
                print *
        end subroutine print_deck

        ! deal 6 hands of 5 cards 
        subroutine deal_hands(this, hands)
                class(Deck), intent(inout) :: this
                type(Card), allocatable :: hands(:,:)
                integer :: i, j, hand_size

                hand_size = 5
                allocate(hands(hand_size, 6))

                do i = 1, hand_size
                        do j = 1, 6
                                hands(i, j) = this%cards(1) ! deal from top of deck
                                this%cards = this%cards(2:) ! remove dealt card from deck
                                
                        end do
                end do
        end subroutine deal_hands

end module DeckModule

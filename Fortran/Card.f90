module CardModule
        implicit none
        ! define derived type Card 
        type :: Card
                integer :: rank
                character(len=1) :: suit
        contains
                procedure :: initialize => init_card
                procedure :: to_string => card_to_string
                procedure :: rank_to_string => rankToString
        end type Card

contains
        ! initialize a Card object with a string rank and a suit
        subroutine init_card(this, rank_str, suit)
                class(Card), intent(out) :: this
                character(len=*), intent(in) :: rank_str
                character(len=1), intent(in) :: suit

                this%suit = suit
                this%rank = rank_to_int(rank_str)
        end subroutine init_card

        ! convert a rank string to an integer value 
        function rank_to_int(rank_str) result(rank)
                character(len=*), intent(in) :: rank_str
                integer :: rank
                character(len=2) :: trimmed_rank

                trimmed_rank = trim(adjustl(rank_str))
                if (len(trimmed_rank) == 1) then
                        trimmed_rank = ' ' // trimmed_rank
                endif
                select case (trimmed_rank)
                        case ('2')
                                rank = 2
                        case ('3')
                                rank = 3
                        case ('4')
                                rank = 4
                        case ('5')
                                rank = 5
                        case ('6')
                                rank = 6
                        case ('7')
                                rank = 7
                        case ('8')
                                rank = 8
                        case ('9')
                                rank = 9
                        case ('10')
                                rank = 10
                        case ('J')
                                rank = 11
                        case ('Q')
                                rank = 12
                        case ('K')
                                rank = 13
                        case ('A')
                                rank = 14
                        case default
                                print *, "Invalid rank: ", trimmed_rank
                                rank = -1
                end select
        end function rank_to_int

        ! convert a Card object to a string
        function card_to_string(this) result(card_str)
                class(Card), intent(in) :: this
                character(len=3) :: card_str
                        
                select case (this%rank)
                        case (1, 14)
                                card_str = 'A' // this%suit
                        case (11)
                                card_str = 'J' // this%suit
                        case (12)
                                card_str = 'Q' // this%suit
                        case (13)
                                card_str = 'K' // this%suit
                        case (2)
                                card_str = '2' // this%suit 
                        case (3)
                                card_str = '3' // this%suit  
                        case (4)
                                card_str = '4' // this%suit 
                        case (5)
                                card_str = '5' // this%suit 
                        case (6)
                                card_str = '6' // this%suit 
                        case (7)
                                card_str = '7' // this%suit 
                        case (8)
                                card_str = '8' // this%suit 
                        case (9)
                                card_str = '9' // this%suit 
                        case (10)
                                card_str = '10' // this%suit
                        case default
                                write(card_str, '(I1)') this%rank
                end select
                
        end function card_to_string

        ! convert a Card rank to a string
        function rankToString(this) result(rank_str)
                class(Card), intent(in) :: this
                character(len=2) :: rank_str

                select case (this%rank)
                        case (14)
                                rank_str = 'A'
                        case (11)
                                rank_str = 'J'
                        case (12)
                                rank_str = 'Q'
                        case (13)
                                rank_str = 'K'
                        case default ! should not occur 
                                write(rank_str, '(I1)') this%rank
                end select
        end function rankToString

        ! to extract a card from a line
        subroutine extractCard(line, cardStr, delimiter)
                implicit none
                character(len=*), intent(inout) :: line
                character(len=*), intent(out) :: cardStr
                character(len=*), intent(in), optional :: delimiter
                integer :: pos

                if (present(delimiter)) then
                        pos = index(line, delimiter)
                        if (pos > 0) then
                                cardStr = line(1:pos-1)
                                line = line(pos+len_trim(delimiter):)  ! remove extracted card and delimiter
                        else
                                cardStr = line
                                line = ''  ! no more content after this card
                        endif
                else
                        cardStr = line
                        line = ''
                endif
                cardStr = adjustl(trim(cardStr))  
        end subroutine extractCard

        ! to parse a card string into rank and suit
        subroutine parseCard(cardStr, rank, suit)
                implicit none
                character(len=*), intent(in) :: cardStr
                integer, intent(out) :: rank
                character(len=1), intent(out) :: suit
                character(len=:), allocatable :: rankPart
                integer :: lenStr

                lenStr = len_trim(cardStr)
                if (lenStr < 2) then ! should not occur 
                        print *, 'Error: Invalid card string: ', trim(cardStr)
                        stop
                endif

                suit = cardStr(lenStr:lenStr)  ! last character is suit
                rankPart = cardStr(1:lenStr-1)  ! the rest is the rank

                rank = rank_to_int(rankPart)
                if (rank == -1) then ! should not occur 
                        print *, 'Error: Invalid rank in card string: ', trim(rankPart)
                        stop
                endif
        end subroutine parseCard

        ! convert a suit character to an index
        integer function suitToIndex(suit) result(index)
                implicit none
                character(len=1), intent(in) :: suit

                select case (suit)
                        case ('D')
                                index = 1
                        case ('C')
                                index = 2
                        case ('H')
                                index = 3
                        case ('S')
                                index = 4
                        case default
                                print *, 'Error: Invalid suit: ', suit
                                stop
                end select
        end function suitToIndex

end module CardModule

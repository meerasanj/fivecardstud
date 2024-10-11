module HandRankings
        use CardModule
        use DeckModule
        implicit none
        
        type :: HandRank
                integer :: rank_value
        contains
                procedure :: handRankToString
        end type HandRank

        ! Integer constants for hand rankings
        integer, parameter :: HIGH_CARD = 0, PAIR = 1, TWO_PAIR = 2, THREE_OF_A_KIND = 3, STRAIGHT = 4, FLUSH = 5, FULL_HOUSE = 6, FOUR_OF_A_KIND = 7, STRAIGHT_FLUSH = 8, ROYAL_FLUSH = 9

        ! String descriptions for hand rankings
        character(len=19), parameter :: RANK_NAMES(10) = (/ &
                "High Card           ", &  ! length 19 (padded with spaces)
                "Pair                ", &
                "Two Pair            ", &
                "Three of a Kind     ", &
                "Straight            ", &
                "Flush               ", &
                "Full House          ", &
                "Four of a Kind      ", &
                "Straight Flush      ", &
                "Royal Straight Flush" /)
contains 

        function handRankToString(this) result(rank_str)
                class(HandRank), intent(in) :: this
                character(len=20) :: rank_str

                select case (this%rank_value)
                        case (HIGH_CARD)
                                rank_str = "High Card            "
                        case (PAIR)
                                rank_str = "Pair                 "
                        case (TWO_PAIR)
                                rank_str = "Two Pair             "
                        case (THREE_OF_A_KIND)
                                rank_str = "Three of a Kind      "
                        case (STRAIGHT)
                                rank_str = "Straight             "
                        case (FOUR_OF_A_KIND)
                                rank_str = "Four of a Kind       "
                        case (FLUSH)
                                rank_str = "Flush                "
                        case (STRAIGHT_FLUSH)
                                rank_str = "Straight Flush       "
                        case (ROYAL_FLUSH)
                                rank_str = "Royal Straight Flush "
                        case (FULL_HOUSE)
                                rank_str = "Full House           "
                        case default
                                rank_str = "Unknown Rank         "
                end select
        end function handRankToString

        function countOccurrences(hand, rank) result(count)
                type(Card), intent(in) :: hand(:)
                integer, intent(in) :: rank
                integer :: count, i

                count = 0 
                do i = 1, size(hand)
                        if (hand(i)%rank == rank) then
                                count = count + 1
                        endif
                enddo
        end function countOccurrences

        function isAceLowStraight(hand) result(is_ace_low)
                type(Card), intent(in) :: hand(:)
                logical :: is_ace_low
                integer :: i

                is_ace_low = .false.
                do i = 1, size(hand)
                        if (hand(i)%rank == 14) then
                                is_ace_low = .true.
                                return
                        endif
                enddo        
        end function isAceLowStraight

        function getHighestCard(hand, isAceStraight) result(highest_card)
                type(Card), intent(in) :: hand(:)
                logical, intent(in) :: isAceStraight
                type(Card) :: highest_card
                type(Card), allocatable :: tempHand(:)
                integer :: i

                allocate(tempHand(size(hand)))
                tempHand = hand

                if (isAceStraight) then
                        do i = 1, size(tempHand)
                                if (tempHand(i)%rank == 14) then
                                        tempHand(i)%rank = 1
                                endif
                        enddo
                endif

                highest_card = tempHand(1)
                do i = 2, size(tempHand)
                        if (tempHand(i)%rank > highest_card%rank) then
                                highest_card = tempHand(i)
                        endif
                enddo
        end function getHighestCard

        function getHighestPairRank(hand) result(highestPairRank)
                type(Card), intent(in) :: hand(:)
                integer :: highestPairRank
                integer :: i

                highestPairRank = -1
                do i = 1, size(hand)
                        if (countOccurrences(hand, hand(i)%rank) == 2) then
                                if (hand(i)%rank > highestPairRank) then
                                        highestPairRank = hand(i)%rank
                                endif
                        endif
                enddo
        end function getHighestPairRank

        function getLowestPairRank(hand) result(lowestPairRank)
                type(Card), intent(in) :: hand(:)
                integer :: lowestPairRank
                integer :: i

                lowestPairRank = 15
                do i = 1, size(hand)
                        if (countOccurrences(hand, hand(i)%rank) == 2) then
                                if (hand(i)%rank < lowestPairRank) then
                                        lowestPairRank = hand(i)%rank
                                endif
                        endif
                enddo
        end function getLowestPairRank

        function getKicker(hand) result(kicker)
                type(Card), intent(in) :: hand(:)
                integer :: kicker
                integer :: maxVal, i

                maxVal = 0
                do i = 1, size(hand)
                        if (countOccurrences(hand, hand(i)%rank) == 1 .and. hand(i)%rank > maxVal) then
                                maxVal = hand(i)%rank
                        endif
                enddo
                kicker = maxVal
        end function getKicker

        function getPairRank(hand) result(pairRank)
                type(Card), intent(in) :: hand(:)
                integer :: pairRank
                integer :: i

                pairRank = -1
                do i = 1, size(hand)
                        if (countOccurrences(hand, hand(i)%rank) == 2) then
                                pairRank = hand(i)%rank
                                exit
                        endif
                enddo
        end function getPairRank
        
        function getHighestNonPairCard(hand) result(highestCard)
                type(Card), intent(in) :: hand(:)
                type(Card) :: highestCard
                type(Card), allocatable :: tempHand(:)
                integer :: i, nonPairCount

                nonPairCount = 0 
                do i = 1, size(hand)
                        if (countOccurrences(hand, hand(i)%rank) /= 2) then
                                nonPairCount = nonPairCount + 1 
                        endif
                enddo
                
                allocate(tempHand(nonPairCount))

                nonPairCount = 0
                do i = 1, size(hand)
                        if (countOccurrences(hand, hand(i)%rank) /= 2) then
                                nonPairCount = nonPairCount + 1
                                tempHand(nonPairCount) = hand(i)
                        endif
                enddo

                highestCard = tempHand(1)
                do i = 2, nonPairCount
                        if (tempHand(i)%rank > highestCard%rank) then
                                highestCard = tempHand(i)
                        endif
                enddo
                deallocate(tempHand)
        end function getHighestNonPairCard

        function getTripletRank(hand) result(tripletRank)
                type(Card), intent(in) :: hand(:)
                integer :: tripletRank
                integer :: i

                tripletRank = -1
                do i = 1, size(hand)
                        if (countOccurrences(hand, hand(i)%rank) == 3) then
                                tripletRank = hand(i)%rank
                                exit
                        endif
                enddo
        end function getTripletRank

        function getQuadRank(hand) result(quadRank)
                type(Card), intent(in) :: hand(:)
                integer :: quadRank
                integer :: i

                quadRank = -1
                do i = 1, size(hand)
                        if (countOccurrences(hand, hand(i)%rank) == 4) then
                                quadRank = hand(i)%rank
                                exit
                        endif
                enddo
        end function getQuadRank

end module HandRankings

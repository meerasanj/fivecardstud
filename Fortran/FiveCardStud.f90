program FiveCardStud
        use DeckModule
        use CardModule
        use HandRankings
        implicit none

        type(Deck) :: my_deck
        type(Card), allocatable :: hands(:,:)
        type(HandRank), dimension(6) :: handRanks
        integer :: sortedIndices(6)
        integer :: i, j
        integer :: argc
        character(len=100) :: filename
        logical :: success

        argc = command_argument_count() ! get # of command line args
 
        print *, "*** P O K E R    H A N D    A N A L Y Z E R ***"
        print *
        print *

        if (argc > 0) then ! part 2 w/ command line args 
                print *, "*** USING TEST DECK ***"
                print *
                call get_command_argument(1, filename)
                print *, "*** File: ", trim(filename)
                call readDeckFromFile(trim(filename), hands)
        else ! part 1 w/o command line args 
                print *, "*** USING RANDOMIZED DECK OF CARDS ***"
                print *       
                print *, "*** Shuffled 52 card deck:"

                call my_deck%initialize()
                call my_deck%shuffle_deck()
                call my_deck%print_deck(.false.)
                call deal_hands(my_deck, hands)
                call printSixHands(hands)
                print *, "*** Here is what remains in the deck..."
                call my_deck%print_deck(.true.)
                print *
        endif

        call sortHands(hands, handRanks, sortedIndices)
        call printWinningHand(hands, handRanks, sortedIndices)

        deallocate(hands)

contains
        ! to print 6 hands of 5 cards 
        subroutine printSixHands(hands)
                implicit none
                type(Card), intent(in) :: hands(:, :)
                integer :: i, j
                character(len=100) :: line

                print *, "*** Here are the six hands..."  
                do j = 1, 6 
                        do i = 1, 5  
                                if (i < 5) then
                                        write(*, '(A)', advance='no') trim(card_to_string(hands(i, j))) // ' '
                                else
                                        write(*, '(A)', advance='no') trim(card_to_string(hands(i, j)))
                                end if
                        end do
                        print *  
                end do
                print *              

        end subroutine printSixHands 

        ! to print the winning hand order 
        subroutine printWinningHand(hands, handRanks, sortedIndices)
                type(Card), intent(in) :: hands(:, :)
                type(HandRank), intent(in) :: handRanks(:)
                integer, intent(in) :: sortedIndices(:)
                integer :: i, j, idx

                print *, "--- WINNING HAND ORDER ---"
                do i = 1, 6
                        idx = sortedIndices(i)
                        do j = 1, 5
                                !write(*, '(A)', advance="no") trim(card_to_string(hands(sortedIndices(i), j)))
                                write(*, '(A)', advance="no") trim(card_to_string(hands(j, idx)))
                                write(*, '(A)', advance="no") " " 
                        enddo
                        print *, " - ", trim(handRankToString(handRanks(idx)))
                enddo
                print *
        end subroutine printWinningHand

        ! handle command line args to read deck from file 
        subroutine readDeckFromFile(filename, hands)
                implicit none
                character(len=*), intent(in) :: filename
                type(Card), allocatable :: hands(:,:)
                character(len=100) :: line
                character(len=20) :: cardStr
                character(len=100) :: lines(6)
                integer :: i, j, rank, suitIndex
                integer :: ioStatus
                character(len=1) :: suit
                logical :: cardSeen(13, 4)  ! Ranks 2-14 mapped to indices 1-13
                character(len=1), parameter :: suits(4) = ['D', 'C', 'H', 'S']
                integer :: unit

                allocate(hands(5, 6))
                cardSeen = .false.

                unit = 10
                open(unit=unit, file=filename, status='old', action='read')
                do i = 1, 6
                        read(unit, '(A)', iostat=ioStatus) lines(i) ! read each line from file 
                        if (ioStatus /= 0) then
                                print *, 'Error reading file: ', filename ! error check, should not occur 
                                stop
                        endif
                        print *, trim(lines(i))  ! display file content to user
                end do
                print *
                close(unit)

                do i = 1, 6  
                        line = trim(lines(i))
                        do j = 1, 5 
                                if (j < 5) then
                                        call extractCard(line, cardStr, ',')
                                else
                                        call extractCard(line, cardStr)
                                end if
                                cardStr = adjustl(trim(cardStr))  ! Remove leading/trailing spaces
                                call parseCard(cardStr, rank, suit)
                                suitIndex = suitToIndex(suit)

                                ! duplicate card check 
                                if (cardSeen(rank - 1, suitIndex)) then
                                        print *, '*** ERROR - DUPLICATED CARD FOUND IN DECK ***'
                                        print *
                                        print *
                                        print *, '*** DUPLICATE: ', trim(cardStr), ' ***'
                                        stop
                                end if
                                cardSeen(rank - 1, suitIndex) = .true.
                                hands(j, i)%rank = rank
                                hands(j, i)%suit = suit
                        end do
                end do
                
                call printSixHands(hands)
        
        end subroutine readDeckFromFile

        ! sort the hands based on ranks using compareHands
        subroutine sortHands(hands, handRanks, sortedIndices)
                implicit none
                type(Card),intent(inout) :: hands(:,:)
                type(HandRank), intent(out) :: handRanks(:)
                integer, intent(out) :: sortedIndices(:)
                integer :: i, j, n
                type(HandRank) :: tempRank
                integer :: tempIndex

                n = size(hands, 2)  ! get the number of hands
                do i = 1, n
                        sortedIndices(i) = i
                enddo

                do i = 1, n
                        handRanks(i) = classifyHand(hands(:, i))
                enddo

                do i = 1, n - 1
                        do j = i + 1, n
                                if (.not. compareHands(hands(:, sortedIndices(i)), hands(:, sortedIndices(j)))) then
                                        tempIndex = sortedIndices(i)
                                        sortedIndices(i) = sortedIndices(j)
                                        sortedIndices(j) = tempIndex
                                endif
                        enddo
                enddo

        end subroutine sortHands

        ! function to classify the rank of a hand
        function classifyHand(hand) result(rank)
                implicit none
                type(Card), intent(in) :: hand(:)
                type(HandRank) :: rank
                integer :: occurrences(15) = 0
                integer :: suitCount(4) = 0
                character(len=1), parameter :: suits(4) = ['D', 'C', 'H', 'S']
                integer :: i, j
                logical :: localFlush, localStraight
                integer :: threeCount, pairCount
                type(Card), allocatable :: sortedHand(:)
                character(len=100) :: classifiedHandStr 
                occurrences = 0
                suitCount = 0
                allocate(sortedHand(size(hand)))
                sortedHand = hand

                call sortDescending(sortedHand)
                do i = 1, size(sortedHand)
                        occurrences(sortedHand(i)%rank) = occurrences(sortedHand(i)%rank) + 1 ! count occurences of card value 
                        do j = 1, 4
                                if (sortedHand(i)%suit == suits(j)) then
                                        suitCount(j) = suitCount(j) + 1 ! count occurences of suit 
                                        exit
                                endif
                        enddo
                enddo

                localFlush = any(suitCount == 5)
                localStraight = isStraight(sortedHand)

                if (localFlush .and. localStraight) then
                        if (occurrences(10) > 0 .and. occurrences(11) > 0 .and. occurrences(12) > 0 .and. occurrences(13) > 0 .and. occurrences(14) > 0) then
                                rank%rank_value = ROYAL_FLUSH
                                return
                        else
                                rank%rank_value = STRAIGHT_FLUSH
                                return
                        endif
                endif
                
                threeCount = 0
                pairCount = 0
                do i = 2, 14
                        if (occurrences(i) == 4) then
                                rank%rank_value = FOUR_OF_A_KIND
                                return
                        endif
                        if (occurrences(i) == 3) threeCount = threeCount + 1
                        if (occurrences(i) == 2) pairCount = pairCount + 1
                enddo

                if (threeCount == 1 .and. pairCount == 1) then
                        rank%rank_value = FULL_HOUSE 
                        return
                endif

                if (localFlush) then
                        rank%rank_value = FLUSH
                        return
                endif

                if (localStraight) then
                        rank%rank_value = STRAIGHT
                        return
                endif

                if (threeCount == 1) then
                        rank%rank_value = THREE_OF_A_KIND 
                        return
                endif

                if (pairCount == 2) then
                        rank%rank_value = TWO_PAIR
                        return
                endif
        
                if (pairCount == 1) then
                        rank%rank_value = PAIR
                        return
                endif
        
                rank%rank_value = HIGH_CARD
                
        end function classifyHand

        ! to compare hands by ranks, tie breaking rules 
        function compareHands(hand1, hand2) result(isHand1Better)
                type(Card), intent(in) :: hand1(:)
                type(Card), intent(in) :: hand2(:)
                logical :: isHand1Better
                type(HandRank) :: rank1, rank2
                integer :: highPair1, highPair2
                integer :: lowPair1, lowPair2
                integer :: kicker1, kicker2
                type(Card) :: highestCard1, highestCard2
                logical :: checkAce1, checkAce2
                integer :: pairRank1, pairRank2
                integer :: quadRank1, quadRank2
                integer :: tripletRank1, tripletRank2

                rank1 = classifyHand(hand1)
                rank2 = classifyHand(hand2)

                if (rank1%rank_value /= rank2%rank_value) then
                        isHand1Better = rank1%rank_value > rank2%rank_value
                        return
                endif

                ! tie breaking rules:

                ! Case 1: Flush categories (Straight Flush, Flush, Royal Flush)
                if (rank1%rank_value == FLUSH .or. rank1%rank_value == STRAIGHT_FLUSH .or. rank1%rank_value == ROYAL_FLUSH) then
                        highestCard1 = getHighestCard(hand1, .false.)
                        highestCard2 = getHighestCard(hand2, .false.)
                        if (highestCard1%rank /= highestCard2%rank) then
                                isHand1Better = highestCard1%rank > highestCard2%rank
                                return
                        endif
                        isHand1Better = highestCard1%suit > highestCard2%suit
                        return
                endif

                ! Case 2: Straights but not flushes
                if (rank1%rank_value == STRAIGHT) then
                        checkAce1 = isAceLowStraight(hand1)
                        checkAce2 = isAceLowStraight(hand2)
                        highestCard1 = getHighestCard(hand1, checkAce1)
                        highestCard2 = getHighestCard(hand2, checkAce2)

                        if (highestCard1%rank /= highestCard2%rank) then
                                isHand1Better = highestCard1%rank > highestCard2%rank
                                return
                        endif
                        isHand1Better = highestCard1%suit > highestCard2%suit
                        return
                endif

                ! Case 3: Two pair
                if (rank1%rank_value == TWO_PAIR) then
                        highPair1 = getHighestPairRank(hand1)
                        highPair2 = getHighestPairRank(hand2)
                        if (highPair1 /= highPair2) then
                                isHand1Better = highPair1 > highPair2
                                return
                        endif

                        lowPair1 = getLowestPairRank(hand1)
                        lowPair2 = getLowestPairRank(hand2)
                        if (lowPair1 /= lowPair2) then
                                isHand1Better = lowPair1 > lowPair2
                                return
                        endif

                        kicker1 = getKicker(hand1)
                        kicker2 = getKicker(hand2)
                        isHand1Better = kicker1 > kicker2
                        return
                endif

                ! Case 4: Pairs
                if (rank1%rank_value == PAIR) then
                        pairRank1 = getPairRank(hand1)
                        pairRank2 = getPairRank(hand2)
                        if (pairRank1 /= pairRank2) then
                                isHand1Better = pairRank1 > pairRank2
                                return
                        endif

                        highestCard1 = getHighestNonPairCard(hand1)
                        highestCard2 = getHighestNonPairCard(hand2)
                        if (highestCard1%rank /= highestCard2%rank) then
                                isHand1Better = highestCard1%rank > highestCard2%rank
                                return
                        endif
                        isHand1Better = highestCard1%suit > highestCard2%suit
                        return
                endif

                ! Case 5: High card
                if (rank1%rank_value == HIGH_CARD) then
                        highestCard1 = getHighestCard(hand1, .false.)
                        highestCard2 = getHighestCard(hand2, .false.)
                        if (highestCard1%rank /= highestCard2%rank) then
                                isHand1Better = highestCard1%rank > highestCard2%rank
                                return
                        endif
                        isHand1Better = highestCard1%suit > highestCard2%suit
                        return
                endif

                ! Direct comparisons for Four of a Kind and Three of a Kind
                if (rank1%rank_value == FOUR_OF_A_KIND) then
                        quadRank1 = getQuadRank(hand1)
                        quadRank2 = getQuadRank(hand2)
                        isHand1Better = quadRank1 > quadRank2
                        return
                endif

                if (rank1%rank_value == THREE_OF_A_KIND) then
                        tripletRank1 = getTripletRank(hand1)
                        tripletRank2 = getTripletRank(hand2)
                        isHand1Better = tripletRank1 > tripletRank2
                        return
                endif

                ! Full House comparison
                if (rank1%rank_value == FULL_HOUSE) then
                        tripletRank1 = getTripletRank(hand1)
                        tripletRank2 = getTripletRank(hand2)
                        if (tripletRank1 /= tripletRank2) then
                                isHand1Better = tripletRank1 > tripletRank2
                                return
                        endif

                        pairRank1 = getPairRank(hand1)
                        pairRank2 = getPairRank(hand2)
                        isHand1Better = pairRank1 > pairRank2
                        return
                endif
                
                isHand1Better = .false.

        end function compareHands

        ! sort the hand in descending order 
        subroutine sortDescending(sortedHand)
                type(Card), allocatable :: sortedHand(:)
                integer :: i, j
                type(Card) :: temp

                do i = 1, size(sortedHand)-1
                        do j = i+1, size(sortedHand)
                                if (sortedHand(i)%rank < sortedHand(j)%rank) then
                                        temp = sortedHand(i)
                                        sortedHand(i) = sortedHand(j)
                                        sortedHand(j) = temp
                                endif
                        enddo
                enddo
        end subroutine sortDescending

        ! sort the hand in ascending order 
        subroutine sortAscending(array) ! bubble sort
                integer, intent(inout) :: array(:)
                integer :: i, j, temp

                do i = 1, size(array) - 1
                        do j = 1, size(array) - i
                                if (array(j) > array(j + 1)) then
                                        temp = array(j)
                                        array(j) = array(j + 1)
                                        array(j + 1) = temp
                                endif
                        enddo
                enddo
        end subroutine sortAscending

        ! check if the hand is a straight 
        function isStraight(hand) result(is_straight)
                type(Card), intent(in) :: hand(:)
                logical :: is_straight
                integer :: ranks(size(hand))
                integer :: i

                do i = 1, size(hand)
                        ranks(i) = hand(i)%rank
                enddo

                call sortAscending(ranks)

                ! considers Ace Low Straight case 
                if (all(ranks == [2, 3, 4, 5, 14])) then
                        is_straight = .true.
                return
                endif

                is_straight = .true.
                do i = 1, size(ranks) - 1
                        if (ranks(i + 1) /= ranks(i) + 1) then
                                is_straight = .false.
                                return
                        endif
                enddo
        end function isStraight 

        
end program FiveCardStud

#!/usr2/local/sbcl/bin/sbcl --script

(load "Card.lisp")
(load "Deck.lisp")

;; Suit Constants
(defconstant +diamonds+ "D")
(defconstant +clubs+ "C")
(defconstant +hearts+ "H")
(defconstant +spades+ "S")

;; Suit Ranking
(defparameter *suit-ranking*
        '(("D" . 1)
        ("C" . 2)
        ("H" . 3)
        ("S" . 4)))

;; Get suit rank as integer 
(defun suit-rank (suit)
        (cdr (assoc suit *suit-ranking* :test #'string=)))

;; HandRank constants
(defconstant +high-card+ 1)
(defconstant +pair+ 2)
(defconstant +two-pair+ 3)
(defconstant +three-of-a-kind+ 4)
(defconstant +straight+ 5)
(defconstant +flush+ 6)
(defconstant +full-house+ 7)
(defconstant +four-of-a-kind+ 8)
(defconstant +straight-flush+ 9)
(defconstant +royal-flush+ 10)

;; Convert HandRank to string
(defun hand-rank-to-string (rank)
	(cond
    		((= rank +high-card+) "High Card")
    		((= rank +pair+) "Pair")
    		((= rank +two-pair+) "Two Pair")
    		((= rank +three-of-a-kind+) "Three Of A Kind")
    		((= rank +straight+) "Straight")
    		((= rank +flush+) "Flush")
    		((= rank +full-house+) "Full House")
    		((= rank +four-of-a-kind+) "Four Of A Kind")
    		((= rank +straight-flush+) "Straight Flush")
    		((= rank +royal-flush+) "Royal Straight Flush")
    		(t "Unknown")))

;; method to print six hands 
(defun print-six-hands (hands)
        (format t "*** Here are the six hands...~%")
        (loop for i from 0 below 6 do
                (let ((hand (reverse (aref hands i))))
                        (dolist (card hand)
                                (format t "~a " (card-to-string card)))
                        (format t "~%"))))

;; Method to print winning hand order 
(defun print-winning-hand (sorted-hands hand-ranks)
	(format t "~%--- WINNING HAND ORDER ---~%")
  	(loop for hand in sorted-hands
        for rank in hand-ranks do
        	(let ((hand (reverse hand)))  ; Reverse the hand before printing
        	(dolist (card hand)
            		(format t "~A " (card-to-string card))))
        		(format t "- ~A~%" (hand-rank-to-string rank))))

;; Checks if the given hand is a straight
(defun is-straight (hand)
	(let ((unique-ranks (remove-duplicates (mapcar #'card-rank hand))))
    		(when (= (length unique-ranks) 5)
      			(let ((sorted-ranks (sort unique-ranks #'<)))
        			;; Special case for Ace-low straight (A, 2, 3, 4, 5)
        			(if (equal sorted-ranks '(2 3 4 5 14))
            				t
          			(loop for i from 0 below (1- (length sorted-ranks))
                			always (= (nth (+ i 1) sorted-ranks) (1+ (nth i sorted-ranks)))))))))

;; Classifies the rank of a hand 
(defun classify-hand (hand)
        (block classify-hand
	(let* ((hand-copy (sort (copy-seq hand) #'> :key #'card-rank))
        (occurrences (make-array 15 :initial-element 0))
        (suits (make-hash-table :test 'equal)))

        (dolist (card hand-copy)
                (incf (aref occurrences (card-rank card)))
                (incf (gethash (card-suit card) suits 0)))

        (let ((flush (some (lambda (count) (= count 5))
                (loop for value being the hash-value of suits collect value)))
                (straight (is-straight hand-copy)))

        (if (and flush straight)
                (let ((unique-ranks (remove-duplicates (mapcar #'card-rank hand-copy))))
                (if (equal (sort unique-ranks #'<) '(10 11 12 13 14))
			(return-from classify-hand +royal-flush+)
			(return-from classify-hand +straight-flush+)))
                (let ((three-count 0)
                (pair-count 0))
                        (loop for count in (subseq (coerce occurrences 'list) 2)
                                do (cond ((= count 4) (return-from classify-hand +four-of-a-kind+))
                                        ((= count 3) (incf three-count))
                                        ((= count 2) (incf pair-count))))

	(cond
		((and (= three-count 1) (= pair-count 1)) (return-from classify-hand +full-house+))
                (flush (return-from classify-hand +flush+))
              	(straight (return-from classify-hand +straight+))
              	((= three-count 1) (return-from classify-hand +three-of-a-kind+))
              	((= pair-count 2) (return-from classify-hand +two-pair+))
              	((= pair-count 1) (return-from classify-hand +pair+))
              	(t (return-from classify-hand +high-card+)))))))))

;; Checks if the hand is an Ace-low straight (A, 2, 3, 4, 5)
(defun is-ace-low-straight (hand)
        (let ((ranks (remove-duplicates (mapcar #'card-rank hand))))
                (equal (sort ranks #'<) '(2 3 4 5 14))))

;; Returns the highest card in the hand, considering Ace-low straight case
(defun get-highest-card (hand is-ace-straight)
        (let ((temp-hand (mapcar #'copy-card hand)))  ;; Make a copy of the hand
         ;; Treat Ace as low if it's an Ace-low straight
                (when is-ace-straight
                        (dolist (card temp-hand)
                                (when (= (card-rank card) 14)
                                        (setf (card-rank card) 1))))
                (reduce (lambda (highest card)
                        (if (> (card-rank card) (card-rank highest))
                                card
                                highest))
                        temp-hand)))

;; Counts the number of times a specific rank appears in the hand
(defun count-occurrences (hand rank)
        (count rank (mapcar #'card-rank hand)))

;; Returns the highest non-pair card (the kicker) in the hand
(defun get-highest-non-pair-card (hand)
        (let ((temp-hand (remove-if (lambda (card) (= (count-occurrences hand (card-rank card)) 2))
        hand)))
        (if (null temp-hand)
                nil
        (reduce (lambda (highest card)
                (if (> (card-rank card) (card-rank highest))
                    card
                    highest))
              temp-hand))))

;; Returns the kicker (highest non-pair card) in the hand
(defun get-kicker (hand)
	(let ((kickers (remove-if (lambda (card)
        	(> (count-occurrences hand (card-rank card)) 1))
                hand)))
    	(if kickers
        	(reduce (lambda (card1 card2)
               	(if (> (card-rank card1) (card-rank card2)) card1 card2))
                kickers)
      		nil)))

;; Gets the rank (value) of the pair in the hand
(defun get-pair-rank (hand)
        (loop for card in hand
                thereis (when (= (count-occurrences hand (card-rank card)) 2)
                        (card-rank card))))

;; Returns the highest rank of pairs in the hand
(defun get-highest-pair-rank (hand)
        (let ((highest-pair -1))
                (dolist (card hand highest-pair)
                        (when (and (= (count-occurrences hand (card-rank card)) 2)
                                (> (card-rank card) highest-pair))
                        (setf highest-pair (card-rank card))))))

;; Returns the lowest rank of pairs in the hand
(defun get-lowest-pair-rank (hand)
        (let ((lowest-pair 15))
        (dolist (card hand)
                (when (and (= (count-occurrences hand (card-rank card)) 2)
                        (< (card-rank card) lowest-pair))
                (setf lowest-pair (card-rank card))))
        (if (= lowest-pair 15)
                -1
        lowest-pair)))

;; Returns the rank of the three-of-a-kind in the hand
(defun get-triplet-rank (hand)
  	(or (loop for card in hand
        when (= (count-occurrences hand (card-rank card)) 3)
        	return (card-rank card))
      		-1))

;; Returns the rank of the four-of-a-kind in the hand
(defun get-quad-rank (hand)
  	(or (loop for card in hand
        when (= (count-occurrences hand (card-rank card)) 4)
            	return (card-rank card))
      		-1))

;; Compares two hands and determines the winner 
(defun compare-hands (hand1 hand2)
  	(let ((rank1 (classify-hand hand1))
        (rank2 (classify-hand hand2)))
    	(if (/= rank1 rank2)
        	(if (> rank1 rank2) 1 -1)
      	
	;; Tie-breaking logic 
      	(or
       	
	;; Case 1: Flush
       	(when (member rank1 (list +flush+ +straight-flush+ +royal-flush+))
        (let ((highest-card1 (get-highest-card hand1 nil))
        (highest-card2 (get-highest-card hand2 nil)))
        (cond
        	((> (card-rank highest-card1) (card-rank highest-card2)) 1)
        	((< (card-rank highest-card1) (card-rank highest-card2)) -1)
             	((> (suit-rank (card-suit highest-card1)) (suit-rank (card-suit highest-card2))) 1)
             	((< (suit-rank (card-suit highest-card1)) (suit-rank (card-suit highest-card2))) -1))))
       	
	;; Case 2: Straight
       	(when (= rank1 +straight+)
        (let* ((check-ace1 (is-ace-low-straight hand1))
        (check-ace2 (is-ace-low-straight hand2))
        (highest-card1 (get-highest-card hand1 check-ace1))
        (highest-card2 (get-highest-card hand2 check-ace2)))
        (cond
             	((> (card-rank highest-card1) (card-rank highest-card2)) 1)
             	((< (card-rank highest-card1) (card-rank highest-card2)) -1)
             	((> (suit-rank (card-suit highest-card1)) (suit-rank (card-suit highest-card2))) 1)
             	((< (suit-rank (card-suit highest-card1)) (suit-rank (card-suit highest-card2))) -1))))
       
	;; Case 3: Two Pair
       	(when (= rank1 +two-pair+)
       	(let ((high-pair1 (get-highest-pair-rank hand1))
       	(high-pair2 (get-highest-pair-rank hand2)))
       	(cond
             	((> high-pair1 high-pair2) 1)
             	((< high-pair1 high-pair2) -1)
             	(t
              	(let ((low-pair1 (get-lowest-pair-rank hand1))
                (low-pair2 (get-lowest-pair-rank hand2)))
                (cond
                  	((> low-pair1 low-pair2) 1)
                  	((< low-pair1 low-pair2) -1)
                  	(t
                   	(let ((kicker1 (get-kicker hand1))
                        (kicker2 (get-kicker hand2)))
                     	(cond
                       		((and kicker1 kicker2
                             	(> (card-rank kicker1) (card-rank kicker2))) 1)
                       		((and kicker1 kicker2
                             	(< (card-rank kicker1) (card-rank kicker2))) -1)
                       		((and kicker1 kicker2
                             	(> (suit-rank (card-suit kicker1)) (suit-rank (card-suit kicker2)))) 1)
                       		((and kicker1 kicker2
                             	(< (suit-rank (card-suit kicker1)) (suit-rank (card-suit kicker2)))) -1))))))))))
       
	;; Case 4: Three of a Kind
       	(when (= rank1 +three-of-a-kind+)
        (let ((triplet-rank1 (get-triplet-rank hand1))
        (triplet-rank2 (get-triplet-rank hand2)))
        (cond
        	((> triplet-rank1 triplet-rank2) 1)
             	((< triplet-rank1 triplet-rank2) -1))))
       
	;; Case 5: Pair
       	(when (= rank1 +pair+)
        (let ((pair-rank1 (get-pair-rank hand1))
        (pair-rank2 (get-pair-rank hand2)))
        (cond
        	((> pair-rank1 pair-rank2) 1)
             	((< pair-rank1 pair-rank2) -1)
             	(t
              	(let ((high-val1 (get-highest-non-pair-card hand1))
                (high-val2 (get-highest-non-pair-card hand2)))
                (cond
                  	((and high-val1 high-val2
                        (> (card-rank high-val1) (card-rank high-val2))) 1)
                  	((and high-val1 high-val2
                        (< (card-rank high-val1) (card-rank high-val2))) -1)
                  	((and high-val1 high-val2
                        (> (suit-rank (card-suit high-val1)) (suit-rank (card-suit high-val2)))) 1)
                  	((and high-val1 high-val2
                        (< (suit-rank (card-suit high-val1)) (suit-rank (card-suit high-val2)))) -1)))))))
       
	;; Case 6: High Card
       (when (= rank1 +high-card+)
       (let ((highest-card1 (get-highest-card hand1 nil))
       (highest-card2 (get-highest-card hand2 nil)))
       (cond
             	((> (card-rank highest-card1) (card-rank highest-card2)) 1)
             	((< (card-rank highest-card1) (card-rank highest-card2)) -1)
             	((> (suit-rank (card-suit highest-card1)) (suit-rank (card-suit highest-card2))) 1)
             	((< (suit-rank (card-suit highest-card1)) (suit-rank (card-suit highest-card2))) -1))))
       
	;; Case 7: Four of a Kind
       	(when (= rank1 +four-of-a-kind+)
        (let ((quad-rank1 (get-quad-rank hand1))
        (quad-rank2 (get-quad-rank hand2)))
        (cond
             	((> quad-rank1 quad-rank2) 1)
                ((< quad-rank1 quad-rank2) -1))))
       
	;; Case 8: Full House
       	(when (= rank1 +full-house+)
        (let ((triplet-rank1 (get-triplet-rank hand1))
        (triplet-rank2 (get-triplet-rank hand2)))
        (cond
             	((> triplet-rank1 triplet-rank2) 1)
             	((< triplet-rank1 triplet-rank2) -1)
             	(t
              	(let ((pair-rank1 (get-pair-rank hand1))
                (pair-rank2 (get-pair-rank hand2)))
                (cond
                  	((> pair-rank1 pair-rank2) 1)
                  	((< pair-rank1 pair-rank2) -1)))))))
       0))))

;; predicate function for sorting hands in descending order
(defun compare-hands-p (hand1 hand2)
	(> (compare-hands hand1 hand2) 0))

;; Sorts hands based on their rank and tie-breakers
(defun sort-hands (hands)
  	(let ((indices (loop for i from 0 below (length hands) collect i)))
    	(sort indices
        (lambda (i j)
        (let* ((hand1 (nth i hands))
        	(hand2 (nth j hands))
                (rank1 (classify-hand hand1))
                (rank2 (classify-hand hand2)))
              	(if (/= rank1 rank2)
                	(> rank1 rank2)  
                  	(> (compare-hands hand1 hand2) 0)))))))  

;; splits string based on delimeter (;) and returns list of substrings
(defun split-string (string &optional (delimiter #\,))
  	(let ((start 0)
        (result '()))
    	(loop for end = (position delimiter string :start start)
        while end
        do (push (string-trim '(#\Space) (subseq string start end)) result)
        	(setf start (1+ end)))
    		(push (string-trim '(#\Space) (subseq string start)) result)
    		(nreverse result)))

;; Reads a deck of cards from a file, populating hands and checking for duplicates
(defun read-deck-from-file (filename hands)
	(let ((seen-cards (make-hash-table :test 'equal)))  ; To track duplicate cards
    	(handler-case
        (with-open-file (file filename :direction :input)
          	;; Print entire file content
          	(loop for line = (read-line file nil nil)
                while line do
                  	(format t "~A~%" line))

          	;; Reset file pointer and start actual processing
          	(file-position file 0)
          	(loop for i from 0 below 6 do
                (let ((line (read-line file nil)))
                (when line
                	(let ((card-strings (split-string line #\,)))
                      	(loop for card-str in card-strings do
                            	(setf card-str (string-trim '(#\Space) card-str))
                            	;; Duplicate card check
                            	(if (gethash card-str seen-cards)
                                	(progn
                                  	(format t "~%*** ERROR - DUPLICATED CARD FOUND IN DECK ***~%")
                                  	(format t "*** DUPLICATE: ~A ***~%" card-str)
                                  	(return-from read-deck-from-file nil))
                                	(setf (gethash card-str seen-cards) t))

                            	;; Extract suit and rank
                            	(let* ((suit (subseq card-str (1- (length card-str))))
                                   	(rank-str (subseq card-str 0 (1- (length card-str))))
                                   	(rank (rank-to-int rank-str)))
                              		(push (make-card :rank rank :suit suit) (aref hands i)))))))))
      	(file-error (e)
        	(format t "Error: The file ~A was not found.~%" filename)
                nil)
      	(error (e)
             	(format t "An error occurred: ~A~%" e)
             	nil)))
  	
	(format t "~%")
  	(print-six-hands hands)
  	hands)

;; main method to handle overall program flow 
(defun main (&optional args)
  	(setf *random-state* (make-random-state t))

  	(format t "*** P O K E R    H A N D    A N A L Y Z E R ***~%~%~%")

  	(let ((deck (create-deck))
        (hands (make-array 6 :initial-element '())))

    	;; Part 2: With command line arguments
    	(if (and args (plusp (length args)))
        (progn
          	(format t "*** USING TEST DECK ***~%~%")
		(format t "*** File: ~A~%" (first args))
          	(if (null (read-deck-from-file (first args) hands))
              		(return-from main)))
      	;; Part 1: Without command line arguments
      	(progn
        	(format t "*** USING RANDOMIZED DECK OF CARDS ***~%")
        	(format t "~%*** Shuffled 52 card deck:~%")
        	(shuffle-deck deck)
        	(print-deck deck)
        	(deal-hands deck hands)
        	(print-six-hands hands)
        	(format t "~%*** Here is what remains in the deck...~%")
        	(print-deck deck t)))

    		;; convert hands to list for processing
    	(let ((original-hands (coerce hands 'list)))
      		;; get sorted indices based on hand ranks and tie-breakers
      	(let ((sorted-indices (sort-hands original-hands)))
        (let ((sorted-hands (mapcar (lambda (i) (nth i original-hands)) sorted-indices)))
        (let ((hand-ranks (mapcar #'classify-hand sorted-hands)))
            	(print-winning-hand sorted-hands hand-ranks)))))))

(main (rest sb-ext:*posix-argv*))

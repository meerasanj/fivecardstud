(defclass deck ()
	((cards :initform nil :accessor deck-cards)))

;; Method to create standard deck of 52 cards 
(defun create-deck ()
  	(let ((suits '("H" "D" "C" "S"))
        	(ranks '("2" "3" "4" "5" "6" "7" "8" "9" "10" "J" "Q" "K" "A"))
        	(deck (make-instance 'deck)))
    	(setf (deck-cards deck)
          	(loop for suit in suits
                	append (loop for rank in ranks
                             	collect (make-card :rank (rank-to-int rank)
                                        :suit suit))))
    	deck))

;; Function to shuffle the deck
(defun shuffle-deck (deck)
  	(setf (deck-cards deck) (shuffle (deck-cards deck))))

;; Simple shuffle function using Fisher-Yates algorithm
(defun shuffle (list)
	(let ((vec (coerce list 'vector)))
    		(loop for i from (length vec) downto 2 do
         		(rotatef (aref vec (random i))
                  	(aref vec (1- i))))
    		(coerce vec 'list)))

;; Deal 6 hands of 5 cards 
(defun deal-hands (deck hands)
	(loop repeat 5
		do (loop for i from 0 below (length hands)
			do (setf (aref hands i) (cons (pop (deck-cards deck)) (aref hands i))))))

;; Print the cards in the deck, optionally in a single line
(defun print-deck (deck &optional (single-line nil))
  	(loop for card in (deck-cards deck)
        	for count from 1
        		do (progn
             			(format t "~a " (card-to-string card))
             			(when (and (not single-line) (zerop (mod count 13)))
               			(format t "~%"))))
  				(format t "~%"))

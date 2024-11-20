;; Card Struct
(defstruct card
	rank
  	suit)

;; Function to convert rank string to integer representation
(defun rank-to-int (rank-str)
	(cond
    	((not (stringp rank-str))
     		(error "Expected a string for rank, got ~a" (type-of rank-str)))
    	((equal rank-str "10") 10)
    	((equal rank-str "J") 11)
    	((equal rank-str "Q") 12)
    	((equal rank-str "K") 13)
    	((equal rank-str "A") 14)
    	((member rank-str '("2" "3" "4" "5" "6" "7" "8" "9") :test #'equal)
     	(parse-integer rank-str))
    		(t (error "Invalid rank: ~a" rank-str))))

;; Function to convert integer rank back to string representation
(defun rank-to-string (rank)
	(cond
    		((= rank 14) "A")
    		((= rank 13) "K")
    		((= rank 12) "Q")
    		((= rank 11) "J")
    		(t (write-to-string rank))))

;; Function to create a string representation of a card
(defun card-to-string (card)
	(let ((rank-str (rank-to-string (card-rank card)))
        (suit (card-suit card)))
    	(concatenate 'string rank-str suit)))

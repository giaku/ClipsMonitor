

(defmodule REQUEST_HANDLER (import AGENT ?ALL) (export ?ALL))
;se il vecchio chiede il pasto bisogna discriminare tre casi:
; - pills before  -> wait (non considero altri casi)
; - pills no      -> yes
; - pills after   -> yes

;se chiede il dessert bisogna discriminare due casi:
; - concesso (altri tre casi):
;     - pills before e nopills  -> answer yes
;     - pills after già prese   -> answer yes
;     - pills after da prendere -> answer wait
; - non concesso -> answer no

;le pills after vanno comunque prima del dessert

(defrule respond-meal-nopills
  (msg-to-agent
    (request-time ?time)
		(step ?step)
		(sender ?id)
		(request meal)
		(t_pos-r ?row)
		(t_pos-c ?column)
	)
  (prescription
    (patient ?id)
    (meal ?kind)
    (pills no)
    (dessert ?)
  )
  =>
  (assert (task-serve
            (what meal)
            (variants ?kind)
            (id ?id)
            (t_pos-r ?row)
            (t_pos-c ?column)
          )
  )
  ;(assert (exec
  ;          (action Inform)
  ;          (param1 ?id)
  ;          (param2 ?request)
  ;          (param3 yes)
  ;          (param4 be-right-there!)
  ;        )
  ;)
  (assert (to-achieve
            (task respond)
            (param1 ?id)
            (param2 meal)
            (param3 yes)
            (param4 be-right-there!)
          )
  )
  (pop-focus) (pop-focus)
)

(defrule respond-meal-pillsbefore
  (msg-to-agent
    (request-time ?time)
		(step ?step)
		(sender ?id)
		(request meal)
		(t_pos-r ?row)
		(t_pos-c ?column)
	)
  (prescription
    (patient ?id)
    (meal ?kind)
    (pills before)
    (dessert ?)
  )
  =>
  (assert (task-serve
            (what pills)
            (variants before-meal)
            (id ?id)
            (t_pos-r ?row)
            (t_pos-c ?column)
          )
  )
  (assert (to-achieve
            (task respond)
            (param1 ?id)
            (param2 meal)
            (param3 wait)
            (param4 you-are-getting-pills-before)
          )
  )
  (pop-focus) (pop-focus)
)

(defrule respond-meal-pillsafter
  (msg-to-agent
    (request-time ?time)
		(step ?step)
		(sender ?id)
		(request meal)
		(t_pos-r ?row)
		(t_pos-c ?column)
	)
  (prescription
    (patient ?id)
    (meal ?kind)
    (pills after)
    (dessert ?)
  )
  =>
  (assert (task-serve
            (what meal)
            (variants ?kind pills-after)
            (id ?id)
            (t_pos-r ?row)
            (t_pos-c ?column)
          )
  )
  (assert (to-achieve
            (task respond)
            (param1 ?id)
            (param2 meal)
            (param3 yes)
            (param4 be-right-there!)
          )
  )
  (pop-focus) (pop-focus)
)

(defrule respond-dessert-allowed-nopills
  (msg-to-agent
    (request-time ?time)
		(step ?step)
		(sender ?id)
		(request dessert)
		(t_pos-r ?row)
		(t_pos-c ?column)
	)
  (prescription
    (patient ?id)
    (meal ?)
    (pills ?p&:(or (eq ?p no) (eq ?p before)))
    (dessert yes)
  )
  =>
  (assert (task-serve
            (what dessert)
            (variants none)
            (id ?id)
            (t_pos-r ?row)
            (t_pos-c ?column)
          )
  )
  (assert (to-achieve
            (task respond)
            (param1 ?id)
            (param2 dessert)
            (param3 yes)
            (param4 be-right-there!)
          )
  )
  (pop-focus) (pop-focus)
)

(defrule respond-dessert-allowed-pills-taken
  (msg-to-agent
    (request-time ?time)
		(step ?step)
		(sender ?id)
		(request dessert)
		(t_pos-r ?row)
		(t_pos-c ?column)
	)
  (prescription
    (patient ?id)
    (meal ?)
    (pills after)
    (dessert yes)
  )
  (delivered
    (what pills)
  	(id ?id)
  	(t_pos-r ?row)
  	(t_pos-c ?column)
  )
  =>
  (assert (task-serve
            (what dessert)
            (variants none)
            (id ?id)
            (t_pos-r ?row)
            (t_pos-c ?column)
          )
  )
  (assert (to-achieve
            (task respond)
            (param1 ?id)
            (param2 dessert)
            (param3 yes)
            (param4 be-right-there!)
          )
  )
  (pop-focus) (pop-focus)
)

(defrule respond-dessert-allowed-pills-untaken
  (msg-to-agent
    (request-time ?time)
		(step ?step)
		(sender ?id)
		(request dessert)
		(t_pos-r ?row)
		(t_pos-c ?column)
	)
  (prescription
    (patient ?id)
    (meal ?)
    (pills after)
    (dessert yes)
  )
  (not (delivered
    (what pills)
  	(id ?id)
  	(t_pos-r ?row)
  	(t_pos-c ?column)
  ))
  =>
  (assert (task-serve
            (what dessert)
            (variants none)
            (id ?id)
            (t_pos-r ?row)
            (t_pos-c ?column)
          )
  )
  (assert (to-achieve
            (task respond)
            (param1 ?id)
            (param2 dessert)
            (param3 wait)
            (param4 you-are-getting-pills-before)
          )
  )
  (pop-focus) (pop-focus)
)

(defrule respond-dessert-denied
  (msg-to-agent
    (request-time ?time)
		(step ?step)
		(sender ?id)
		(request dessert)
		(t_pos-r ?row)
		(t_pos-c ?column)
	)
  (prescription
    (patient ?id)
    (meal ?)
    (pills ?)
    (dessert no)
  )
  =>
  (assert (to-achieve
            (task respond)
            (param1 ?id)
            (param2 dessert)
            (param3 no)
            (param4 times-for-desserts-are-over!)
          )
  )
  (pop-focus) (pop-focus)
)

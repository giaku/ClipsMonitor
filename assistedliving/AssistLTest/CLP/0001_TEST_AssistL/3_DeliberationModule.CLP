

(defmodule DELIBERATION_MODULE (import AGENT ?ALL) (export ?ALL))
;deliberate module e planning

;Prima cosa: se ci sono messaggi a cui rispondere si risponde
(defrule message-pending
	(declare (salience 10))
  (status (step ?i))
	(msg-to-agent
    (request-time ?)
		(step ?i)
		(sender ?)
		(request ?)
		(t_pos-r ?)
		(t_pos-c ?)
	)
	=>
	(focus REQUEST_HANDLER)
)

(defrule plan-running
  (declare (salience 9))
  (plan-running)
  =>
  (pop-focus)
)

(defrule nothing-to-do
  (status (step ?))
  =>
  (assert (to-achieve (task Wait)))
  (pop-focus)
)

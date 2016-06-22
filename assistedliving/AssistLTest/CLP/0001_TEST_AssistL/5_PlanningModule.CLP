(defmodule PLANNING_MODULE (import AGENT ?ALL) (export ?ALL))
;controllo se l'azione to-exec eccede la maxduration diventa una Done!
;regola che se ho un replanning mi manda in un modulo che li gestisce e rigenera un to-achieve
;se non ci sono task prima volta no-op magari e seconda volta wait (vedere penalties per decidere)
;se non ci sono task e tutti hanno avuto tutto done! (magari servono template to-deliver per verificare questa condizione)
(defrule respond
  (declare (salience 10))
  (status (step ?s))
  ?f<-(to-achieve
    (task respond)
    (param1 ?id)
    (param2 ?request)
    (param3 ?answer)
    (param4 ?justification)
  )
  =>
  (assert (to-exec
            (step ?s)
            (action Inform)
            (param1 ?id)
            (param2 ?request)
            (param3 ?answer)
            (param4 ?justification)
          )
  )
  (retract ?f)
  (pop-focus)
)

(defrule need-replanning
  (declare (salience 9))
  (status (step ?s))
  ?f<-(replanning)
  =>
  (focus REPLANNING)
  (retract ?f)
)

(defrule plan-running
  (declare (salience 8))
  (plan-running)
  =>
  ;incrementa indice del piano TODO
)

(defrule plann-wait
  (status (step ?s))
  ?f<-(to-achieve (task Wait))
  =>
  (assert (to-exec
            (step ?s)
            (action Wait)
          )
  )
  (pop-focus)
)

(defmodule REPLANNING (import PLANNING_MODULE ?ALL) (export ?ALL))
;TODO in caso di replanning

;// AGENT
(defmodule AGENT (import MAIN ?ALL) (export ?ALL))

;modella i task di tipo serve
(deftemplate task-serve
	(slot what (allowed-values meal dessert pills))
	(multislot variants)
	(slot id)
	(slot t_pos-r)
	(slot t_pos-c)
)

;modella i task di risposta ai messaggi
(deftemplate task-respond
	(slot param1)
	(slot param2)
	(slot param3)
	(slot param4)
)

;cosa ha portato e a chi (anche dove)
(deftemplate delivered
	(slot what (allowed-values meal dessert pills))
	(slot id)
	(slot t_pos-r)
	(slot t_pos-c)
)

;modella il task da pianificare
(deftemplate to-achieve
	(slot task)
	(slot param1)
	(slot param2)
	(slot param3)
	(slot param4)
)

;modella l'azione pianificata da eseguire
(deftemplate to-exec
	(slot step)
	(slot action  (allowed-values Forward Turnright Turnleft Wait
                                      LoadMeal LoadPill LoadDessert
                                      DeliveryMeal DeliveryPill DeliveryDessert
                                      CleanTable EmptyRobot ReleaseTrash CheckId
                                      Inform Done))
  (slot param1)
  (slot param2)
  (slot param3)
  (slot param4)
)

;modella lo stato della cella secondo l'agente
(deftemplate K-cell  (slot pos-r) (slot pos-c) (slot contains))

;modella lo stato dell'agente secondo l'agente
(deftemplate K-agent
	(slot step)
  (slot time)
	(slot pos-r)
	(slot pos-c)
	(slot direction)
	;quattro simboli:
	; -dietetic-meals -> dietetic
	; -normal-meals   -> normal
	; -desserts       -> dessert
	; -pills          -> ?person
	(multislot content)
  (slot free)
  (slot waste)
)

;indispensabili per clips monitor
(deftemplate last-status (slot step))
(deftemplate init-agent (slot done))
(deffacts init-monitor (last-status (step 0)))

(defrule  beginagent1
	(declare (salience 11))
  (status (step 0))
  (not (exec (step 0)))
  (prior-cell (pos-r ?r) (pos-c ?c) (contains ?x))
	(not (K-cell (pos-r ?r) (pos-c ?c) (contains ?x)))
	=>
  (assert (K-cell (pos-r ?r) (pos-c ?c) (contains ?x)))
)

(defrule  beginagent2
  (declare (salience 10))
	(status (step 0))
	(not (exec (step 0)))
	(K-cell (pos-r ?r) (pos-c ?c) (contains Parking))
	=>
	(assert (K-agent (time 0) (step 0) (pos-r ?r) (pos-c ?c) (direction north)
	                    (free 2) (waste no)))
	(assert (deliberate 0))
	(assert (init-agent (done yes)))
)

(defrule start-deliberation
	?f<-(deliberate ?s)
	=>
	(retract ?f)
	(assert (print-action ?s))
	(assert (plann ?s))
	(focus DELIBERATION_MODULE)
)

(defrule start-planning
	?f<-(plann ?s)
	=>
	(retract ?f)
	(assert (print-action ?s))
	(assert (execute ?s))
	(focus PLANNING_MODULE)
)

(defrule start-execution
	?f<-(execute ?s)
	=>
	(retract ?f)
	(assert (print-action ?s))
	(focus EXECUTION_MODULE)
)

;TODO
;(defrule start-replanning
;
;)

(defrule ask_act
	(declare (salience 2))
	?f <- (status (step ?i))
	(exec (action ?a) (step ?i))
	?f2<-(print-action ?i)
	(test (neq ?a Wait))
	=>
	(printout t crlf crlf)
	(printout t "action to be executed at step:" ?i " -> " ?a)
	(printout t crlf crlf)
	(retract ?f2)
	(modify ?f (work on))
)

(defrule exec_act
	(status (step ?i))
	(exec (step ?i))
	=>
	(assert (deliberate (+ ?i 1)))
	(pop-focus)
 )

package org.clipsmonitor.monitor2016;

import java.util.ArrayList;
import java.util.Observer;
import net.sf.clipsrules.jni.CLIPSError;
import org.clipsmonitor.core.MonitorMap;

public class AssistLAgentMap extends MonitorMap implements Observer {    
    private final String UNKNOWN_COLOR = "#000000";
    private final String DISCOVERED_COLOR = "rgba(0,255,0,0.3)";
    private final String CHECKED_COLOR = "rgba(255,255,0,0.3)";
    private final String CLEAR_COLOR = "rgba(182,20,91,0.3)";
    
    public AssistLAgentMap(){
        super();
    }
    
    @Override
    protected void onDispose() {
        console.debug("Dispose effettuato");
        String result = model.getResult();
        double score = model.getScore();
        @SuppressWarnings("UnusedAssignment")
        String advise = "";
        if (result.equals("disaster")) {
            advise = "Distaster \n";
        } else if (model.getTime() > model.getMaxDuration()) {
            advise = "Maxduration has been reached \n";
        } else {
            advise = "The agent says DONE.\n";
        }
        advise = advise + "Penalties: " + score;
        model.setAdvise(advise);
        this.setChanged();
        this.notifyObservers("advise");
    }
    
    @Override
    protected void initializeMap() throws CLIPSError {
        console.debug("Inizializzazione del modello (EnvMap).");
        String[][] mp = core.findAllFacts("ENV", AssistLFacts.PriorCell.factName(), "TRUE", AssistLFacts.PriorCell.slotsArray());
        int maxr = 0;
        int maxc = 0;
        for (int i = 0; i < mp.length; i++) {
            int r = new Integer(mp[i][AssistLFacts.PriorCell.POSR.index()]);
            int c = new Integer(mp[i][AssistLFacts.PriorCell.POSC.index()]);
            if (r > maxr) {maxr = r;}
            if (c > maxc) {maxc = c;}
        }
        map = new String[maxr][maxc];//Matrice di max_n_righe x max_n_colonne
        for (int i = 0; i < map.length; i++) {
            for (int j = 0; j < map[i].length; j++) {
                map[i][j] = UNKNOWN_COLOR;
            }
        }
    }
    
    /**
     * Aggiorna la mappa visualizzata nell'interfaccia per farla allineare alla
     * versione nel modello.
     *
     */
    @Override
    protected void refreshMap() throws CLIPSError {
        updateCells();
        updatePersonStatus();
        updateStaffStatus();
        updateAgentStatus();
        /*
        if(model.getShowGoalEnabled()){
            updateGoal();
            updateGoalsToDo();
        }*/
        // debugMap("cell");
    }

    private void updateCells() throws CLIPSError {
        console.debug("Aggiornamento mappa reale in corso...");

        String[][] cellFacts = core.findAllFacts("ENV", AssistLFacts.Cell.factName(), "TRUE", AssistLFacts.Cell.slotsArray());

        for (String[] fact : cellFacts) {
            // Nei fatti si conta partendo da 1, nella matrice no, quindi sottraiamo 1.
            int c = new Integer(fact[AssistLFacts.Cell.POSC.index()]) - 1;
            int r = new Integer(fact[AssistLFacts.Cell.POSR.index()]) - 1;
            String contains = fact[AssistLFacts.Cell.CONTAINS.index()];
            String previous = fact[AssistLFacts.Cell.PREVIOUS.index()];
            
            //caso di default preleviamo il valore dello slot contains e lo applichiamo alla mappa
            map[r][c] = contains;  
            
            if(contains.equals("Robot")){
                map[r][c] = previous;
            }
        }
    }

    public void updateAgentStatus() throws CLIPSError{
        console.debug("Acquisizione posizione dell'agente...");
        int r = model.getRow() - 1;
        int c = model.getColumn() - 1;
        map[r][c] = map[r][c] + "+agent_" + model.getDirection();
        ArrayList<String> tmp = model.getContent();
        if(!tmp.isEmpty()) {
            if(tmp.contains("dietetic") || tmp.contains("dessert")){
                map[r][c]+= "+dish"; 
            }
            if(tmp.contains("pills")) {
                 map[r][c]+= "+pill";
            }   
        }
        if(model.getWaste()) {
            map[r][c] += "+bin";
        }
        if(model.getBumped()){
          int [] offset = model.getOffset().get(model.getDirection());
          map[r + offset[0]][c + offset[1]] += "+bump";
        }
    }

    public void updatePersonStatus() throws CLIPSError{
        console.debug("Acquisizione posizione degli altri agenti...");
        ArrayList<int[]> personPositions = model.getPersonPositions();
        for (int[] person : personPositions) {
            int r = person[0] - 1;
            int c = person[1] - 1;
            map[r][c] += "+person";
        }
    }
    
    public void updateStaffStatus() throws CLIPSError{
        console.debug("Acquisizione posizione degli altri agenti...");
        ArrayList<int[]> personPositions = model.getStaffPositions();
        for (int[] person : personPositions) {
            int r = person[0] - 1;
            int c = person[1] - 1;
            map[r][c] += "+staff";
        }
    }
    
    public void updateTableStatus() throws CLIPSError{
        String[][] tableFacts = core.findAllFacts("ENV", AssistLFacts.TableStatus.factName(), "TRUE", AssistLFacts.TableStatus.slotsArray());
        for (String[] fact : tableFacts) {
            // Nei fatti si conta partendo da 1, nella matrice no, quindi sottraiamo 1.
            int c = new Integer(fact[AssistLFacts.TableStatus.POSC.index()]) - 1;
            int r = new Integer(fact[AssistLFacts.TableStatus.POSR.index()]) - 1;
            boolean clean = fact[AssistLFacts.TableStatus.CLEAN.index()].compareTo("no") == 0;
            if(clean){
                map[r][c] += "+dirty_dish";
            }
        }
    }
    
    public void updateGoal()throws CLIPSError{}
    
    public void updateGoalsToDo() throws CLIPSError{}
}
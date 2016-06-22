/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.clipsmonitor.gui;

import java.util.Observable;
import java.util.Observer;
import org.clipsmonitor.clips.ClipsConsole;
import org.clipsmonitor.core.MonitorModel;
import org.clipsmonitor.monitor2016.*;
import org.netbeans.api.settings.ConvertAsProperties;
import org.openide.awt.ActionID;
import org.openide.awt.ActionReference;
import org.openide.windows.TopComponent;
import org.openide.util.NbBundle.Messages;

/**
 * Top component which displays something.
 */
@ConvertAsProperties(
        dtd = "-//org.clipsmonitor.gui//Focus//EN",
        autostore = false
)
@TopComponent.Description(
        preferredID = "FocusTopComponent",
        //iconBase="SET/PATH/TO/ICON/HERE", 
        persistenceType = TopComponent.PERSISTENCE_ALWAYS
)
@TopComponent.Registration(mode = "focus", openAtStartup = true)
@ActionID(category = "Window", id = "org.clipsmonitor.gui.FocusTopComponent")
@ActionReference(path = "Menu/Window" /*, position = 333 */)
@TopComponent.OpenActionRegistration(
        displayName = "#CTL_FocusAction",
        preferredID = "FocusTopComponent"
)
@Messages({
    "CTL_FocusAction=Focus",
    "CTL_FocusTopComponent=Focus Window",
    "HINT_FocusTopComponent=This is a Focus window"
})
public final class FocusTopComponent extends TopComponent implements Observer {
    private MonitorModel model;
    private ClipsConsole console;
    
    public FocusTopComponent() {
        initComponents();
        setName(Bundle.CTL_FocusTopComponent());
        //setToolTipText(Bundle.HINT_FocusTopComponent());
        init();
    }
    
    private void init(){
        model = AssistLModel.getInstance();
        console = ClipsConsole.getInstance();
        model.addObserver(this);
    }
    
    private void clear(){
        model = null;
        console = null;
        this.jTextPane1.setText("");
    }

    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        jScrollPane1 = new javax.swing.JScrollPane();
        jTextPane1 = new javax.swing.JTextPane();

        jTextPane1.setEditable(false);
        jScrollPane1.setViewportView(jTextPane1);

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(this);
        this.setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 400, Short.MAX_VALUE)
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 300, Short.MAX_VALUE)
        );
    }// </editor-fold>//GEN-END:initComponents

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JTextPane jTextPane1;
    // End of variables declaration//GEN-END:variables
    @Override
    public void componentOpened() {
        // TODO add custom code on component opening
    }

    @Override
    public void componentClosed() {
        // TODO add custom code on component closing
    }

    void writeProperties(java.util.Properties p) {
        // better to version settings since initial version as advocated at
        // http://wiki.apidesign.org/wiki/PropertyFiles
        p.setProperty("version", "1.0");
        // TODO store your settings
    }

    void readProperties(java.util.Properties p) {
        String version = p.getProperty("version");
        // TODO read your settings according to their version
    }

    @Override
    public void update(Observable o, Object arg) {
        if(arg == "actionDone" || arg == "cmd" || arg == "disposeDone" || arg == "setupDone"){
            this.updateFocusStack();
        }
        else if(arg == "clearApp"){
            this.clear();
        }
        else if(arg == "startApp"){
            this.init();
        }
    }
    
    
    
    private void updateFocusStack(){
        String[] focusStack = model.getFocusStack();
        String focusString = "";
        for (int i=focusStack.length-1; i>=0; i--) {
            focusString += focusStack[i] + "\n";
        }
        this.jTextPane1.setText(focusString);
        this.jTextPane1.setCaretPosition(0);
    }
}

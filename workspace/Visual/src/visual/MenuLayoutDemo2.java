package visual;



import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;
import java.awt.event.KeyEvent;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Vector;

import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JFrame;
import javax.swing.JList;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JPopupMenu;
import javax.swing.JSpinner;
import javax.swing.JTextField;
import javax.swing.SpinnerNumberModel;

import visual.GraphPanel.Edge;
import visual.GraphPanel.Node;

import javax.swing.*;
import javax.swing.border.EtchedBorder;
import javax.swing.event.ListDataEvent;
import javax.swing.event.ListDataListener;

import java.util.Stack;


/**
 * Class for data synthesis: on the basis of the transitions graph created in @see GraphPanel , it is possible to compose the sequence of templates
 * @author Claudio Savaglio
 * @author Junchao Lu 
 *
 */

//string s;
public class MenuLayoutDemo2 implements ActionListener, ItemListener {
	
	
	
	boolean StartMessageGenerate = true;  // when clicking "start button", starting message once and only once
	int loopcounter = 0;					// global open loop counter
	
	// Buttons for primary control funcitons in the Tool
	final JButton forStarting=new JButton("Loop");    // "loop" menu
	final JButton forEnding=new JButton("End Loop");   // "end loop" menu
	final JButton save_synth=new JButton("Save & Synthesize"); // Saves Diary & Launches Matlab
	final JButton SaveDiary=new JButton("Save"); // Saves the Diary File to Utility Folder
	final JButton newDiary =new JButton("New Diary"); // Creates a new diary after "Finalize"
	final JButton reset =new JButton("Reset");		 // Reset the current diary (erases all current movement & protagonist data
	
	// Vectors used for holding Groups of Buttons and checkboxes in Menu  TRB Update, Some will be removed for Groups of Radio Buttons/Check Boxes
	final Vector<JButton> l1=new Vector<JButton>();	// for holding buttons for the subjects in "start" menu
	final Vector<JButton> l4=new Vector<JButton>(); // for holding buttons "Repeat 5 times" "Repeat 10 times" "Repeat 25 times" "Repeat random times"
	final Vector<JButton> l5=new Vector<JButton>();// for holding buttons "Best" "Random execution" "Random epsilon"
	final Vector<JButton> l6=new Vector<JButton>(); // for holding buttons "1 miles/hours, " "2 miles/hours, "
	final Vector<JButton> l7=new Vector<JButton>(); // for holding buttons "Perform for 5 seconds, " "Perform for 10 seconds, " "Perform for 15 seconds, "
	final Vector<JButton> l8=new Vector<JButton>(); // holding buttons for movements
	final Vector<JMenu> motion_opt=new Vector<JMenu>();	// for holding options "duration" "trials" "mode" "speed"
	
	static Vector<JCheckBox> l2=new Vector<JCheckBox>();
	static Vector<JCheckBox> l3=new Vector<JCheckBox>();
	
	
	JTextField fileName = new JTextField();  // File Name for Saving Diary
	
	Stack<String> lifo = new Stack<String>();
	Stack<String> ilegalMov = new Stack<String>();
	List<String> loopSinMov= new ArrayList<String>();
	
	static String diary_out;
	String disp_out;
	String logic_cur; // keep track of current
	String dur_sel;  // This string holds the current Duration Selection
	String mode_sel; // This string holds the current Mode Selection
	String speed_sel; // This string holds the current Speed Selection
	
	boolean flagAdd=false;
	// Hashtable validMov = new Hashtable();
	 Hashtable<String, ArrayList<String>> data = new Hashtable<String, ArrayList<String>>();
	 
	static List<Node>n;
	public static List<Edge>ed;
	static Vector<JButton>b;
	JMenuBar menuBar;
	//PrintStream ps;
	HashMap<String,Integer> hm;
	final JSpinner spinner1=ShowTimeJSpinner("h"); // A single line input field that lets the user select a number or an object value from an ordered sequence. 
	final JSpinner spinner2=ShowTimeJSpinner("m");
	SpinnerModel sm = new SpinnerNumberModel(2, 2, 30, 1);
	final JSpinner spinner3=new JSpinner(sm);
	//final JSpinner spinner3=ShowTimeJSpinner("for"); // used for number of loops
	Vector<JMenu> options=new Vector<JMenu>();
	int hmindex=0;
	

	String [] lst;
	Vector<String> labels;
	static DefaultListModel<String>  listModel;// = new DefaultListModel();
	JList<String>		listbox;
	
	  JLabel statusbar;
    /* statusbar = new JLabel();
     statusbar.setText(cur);
     statusbar.setBorder(BorderFactory.createEtchedBorder(EtchedBorder.RAISED));
	*/
	
	  public MenuLayoutDemo2(List<Node> nodes, List<Edge> edges) throws FileNotFoundException{
			//JOptionPane.showMessageDialog(null,fileName,"Please, lEnter your diary file name ",JOptionPane.PLAIN_MESSAGE);
			n=nodes;ed=edges; hm=new HashMap<String,Integer>();
			loopSinMov.add("Sit_to_lie");
			loopSinMov.add("Sit_to_stand");
			loopSinMov.add("Stand_to_sit");
			loopSinMov.add("Lie_to_sit");
			
			//validMov.put("Sit_to_lie",new ArrayList<String>("Sit_to_stand","Stand_to_sit","Sit_to_lie"))
			ArrayList<String> a1= new ArrayList<String>();
			a1.add("Sit_to_lie");
			a1.add("Sit_to_stand");
			a1.add("Stand_to_sit");
			//a1.add("Sit_to_lie");
			data.put("Sit_to_lie", a1);
			ArrayList<String> a2= new ArrayList<String>();
			a2.add("Sit_to_lie");
			a2.add("Sit_to_stand");
			a2.add("Lie_to_sit");
			data.put("Sit_to_stand", a2);
			ArrayList<String> a3= new ArrayList<String>();
			a3.add("Stand_to_sit");
			a3.add("Lie_to_sit");
			//a2.add("Lie_to_sit");
			data.put("Stand_to_sit", a3);
			ArrayList<String> a4= new ArrayList<String>();
			a4.add("Lie_to_sit");
			a4.add("Stand_to_sit");
			//a2.add("Lie_to_sit");
			data.put("Lie_to_sit", a4);
			
			// System.out.println(fileName.getText());
			
			//ps = new PrintStream(new FileOutputStream("../../Utility/synthesis.txt"));		
		}
	
	
	public JList<String> createJList()
	{
		listModel= new DefaultListModel<String>();
		
		//listModel.addElement("Jane Doe");
		//listModel.addElement("John Smith");
		//((Vector<JButton>) listModel).addElement("tri");
	    
		 listbox=new JList<String>();
		 
		 
		listbox.setModel(listModel);
		
		//listbox.setSelectedIndex(0);
	   // listbox.addListSelectionListener(this);
	    //listbox.setVisibleRowCount(5);
	//	listbox.addListSelectionListener((ListSelectionListener) this);
		//listbox.add()
		return listbox;
	
	}
	
	/**
	 * Create the vertical menu with all the templates allowable, and start and stop button
	 * 
	 */
    
	public JMenuBar createMenuBar() {

        menuBar = new JMenuBar();
        menuBar.setLayout(new BoxLayout(menuBar, BoxLayout.PAGE_AXIS));
        b=new Vector<JButton>();
        System.out.println("ok");
       // listbox = new JList( "here" );
        
        /*
        JLabel statusbar;
        statusbar = new JLabel(" Statusbar");
        statusbar.setBorder(BorderFactory.createEtchedBorder(EtchedBorder.RAISED));
        menuBar.add(statusbar, BorderLayout.SOUTH);
        */
        for(int i=0;i<n.size();i++)
        {
        	if(i==0)
        	{	
        		JMenu NewDiary = createMenu("New Diary");
            	menuBar.add(NewDiary);
            	newDiary.setEnabled(true);   // first disable "New Diary" button
        		  	
            	
        		JMenu StartDiary = createMenu("Start Diary");
        		menuBar.add(StartDiary);
        		
        		JMenu FinalizeDiary = createMenu("Save Diary");
            	menuBar.add(FinalizeDiary);
            	save_synth.setEnabled(false);   // first disable "finalize" button
            	SaveDiary.setEnabled(false);
            	
            	JMenu ResetDiary = createMenu("Reset Diary");
            	menuBar.add(ResetDiary);
            	reset.setEnabled(false);   // disable reset button
            	
            	
        		JMenu CloseTool = createMenu("Close Tool");
        		menuBar.add(CloseTool);
        		
        		JMenu CloseTool1 = createMenu1();
        		//CloseTool1.setLayout(new BoxLayout(CloseTool1, BoxLayout.LINE_AXIS));
        		//CloseTool1.addSeparator();
        		menuBar.add(CloseTool1);
        		CloseTool1.setEnabled(false);
            	
        	}
        	else{
        		/*if(i==n.size()-1)
        		{
        			//menuBar.add(Box.createHorizontalGlue());
        			JMenu x=createMenu(""+n.get(i).getName());
	            	x.setName(""+n.get(i).getName());
	            	menuBar.add(x); 
	            	x.setEnabled(false); // initially disable all menus except "start" and "quit"
	            		            	
            	}
        		else
        		{*/
		        	JMenu x=createMenu(""+n.get(i).getName());
		        	x.setName(""+n.get(i).getName());
		        	menuBar.add(x);
		        
		        	x.setEnabled(false);
        		//}
        
        	
        		}
        }
        menuBar.setBorder(BorderFactory.createMatteBorder(0,0,0,1,Color.darkGray));
        
        
        for(final JButton bb:b) bb.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {
                       	// Clear two values.
            	//ps.println(bb.getName());
            	diary_out = diary_out + bb.getName();
            	
            	lifo.add(bb.getName());
            	
            	listModel.addElement(bb.getName());
            	
            }
        });
        return menuBar;
    }
    
   
 public JMenu createMenu1() {
    	
        final JMenu m = new HorizontalMenu1();
        return m;
 }

   /**
    * Create the horizontal menu for the relative menu of @see createMenuBar items
    * @param title
    * @return
 * @throws FileNotFoundException 
    */
    public JMenu createMenu( final String title) {
    	
        final JMenu m = new HorizontalMenu(title);
        
      // statusbar.setText(title);
  
     if(title.compareTo("Start Diary")==0) {   // when you click "start"
    	 
    	 
    	 JOptionPane.showMessageDialog(null,fileName,"Enter your diary file name :",JOptionPane.PLAIN_MESSAGE);
 		//n=nodes;ed=edges; hm=new HashMap<String,Integer>();
 		
 		//System.out.println(fileName.getText());
    	 //System.out.println(lifo.peek());
    	 diary_out ="";
    /*	 
 		try {
			//ps = new PrintStream(new FileOutputStream("../../Utility/"+"trash"+".txt"));
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}	
    */	 
    	 System.out.println("is start");
    	// statusbar.setText("start clicked");
    	 JButton subject1=new JButton("M1");subject1.setName("M1");
    	 JButton subject2=new JButton("M2");subject2.setName("M2");
    	 JButton subject3=new JButton("F1");subject3.setName("F1");
    	 JButton subject4=new JButton("F2");subject4.setName("F2");
    	 JButton category1=new JButton("Male");category1.setName("Male");
    	 JButton category2=new JButton("Female");category2.setName("Female");
    	 JMenu submenu6=new HorizontalMenu("Protagonist");
    	 JMenu submenu7=new HorizontalMenu("Sensors Modalities");
    	 JMenu submenu8=new HorizontalMenu("Body-part monitored");
    	 
    	 JMenu submenu4 = new HorizontalMenu("Subject");
    	 submenu4.add(subject1);
    	 submenu4.add(subject2);
    	 submenu4.add(subject3);
    	 submenu4.add(subject4);
    	 JMenu submenu5 = new HorizontalMenu("Categories");
    	 submenu5.add(category1);
    	 submenu5.add(category2);
    	 submenu6.add(submenu4);
    	 submenu6.add(submenu5);
    	
    	 m.add(submenu7);
    	 m.add(submenu8);
    	 
    	 
    	 	
    	 l1.add(subject1);
    	 l1.add(subject2);
    	 l1.add(subject3);
    	 l1.add(subject4);
    	 l1.add(category1);
    	 l1.add(category2);
    	 
    	 for(int i=1;i<7;i++){
    		 JCheckBox jcb = null;
    		 switch (i)
    		 {
	    		 case 1:
	    			 jcb= new JCheckBox("Right Ankle"); jcb.setName("Right Ankle"); break;
	    		 case 2: 
	    			 jcb= new JCheckBox("Waist");jcb.setName("Waist");break;
	    		 case 3:
	    			 jcb= new JCheckBox("Right Arm"); jcb.setName("Right Arm");break;	 
	    		 case 4:
	    			 jcb= new JCheckBox("Right Wrist"); jcb.setName("Right Wrist");break;
	    		 case 5 :
	    			 jcb= new JCheckBox("Left Thigh"); jcb.setName("Left Thigh");break;
	    		 case 6 :
	    			 jcb= new JCheckBox("Right Thigh"); jcb.setName("Right Thigh");break;
	    		 default: 
	    			 break;
    		 }
    	      jcb.setMnemonic(KeyEvent.VK_G); 
    	      jcb.setSelected(true);
    	      
    	     submenu8.add(jcb);
    	     jcb.addItemListener(this);
    	     l2.add(jcb);
    	    
    	   }
    	 
    	 for(int ir=1;ir<7;ir++){
    		 JCheckBox jcb2 = null;
    		 switch (ir)
    		 {
				 case 1:
					 jcb2= new JCheckBox("Acc X"); jcb2.setName("Acc X"); break;
				 case 2: 
					 jcb2= new JCheckBox("Acc Y");jcb2.setName("Acc Y");break;
				 case 3:
					 jcb2= new JCheckBox("Acc Z"); jcb2.setName("Acc Z");break;	 
				 case 4:
					 jcb2= new JCheckBox("Gyr X"); jcb2.setName("Gyr X");break;
				 case 5 :
					 jcb2= new JCheckBox("Gyr Y"); jcb2.setName("Gyr Y");break;
				 case 6 :
					 jcb2= new JCheckBox("Gyr Z"); jcb2.setName("Gyr Z");break;
				 default: 
					 break;
    		 }
  	      
  	       jcb2.setMnemonic(KeyEvent.VK_G); 
  	       jcb2.setSelected(true);
  	     
  	     submenu7.add(jcb2);
  	     jcb2.addItemListener(this);
  	     l3.add(jcb2);
  	    
  	   }
    	 
    	 JLabel hour = new JLabel("Hour");
    	 JLabel minute = new JLabel("minute");
    	
    	 // add components to start menu
    	 m.add(hour);
    	 m.add( spinner1);
    	 m.add(minute);
    	 m.add( spinner2);
    	 m.add(submenu6);

    	 for(final  JButton y:l1)
    	 {
			y.addActionListener(new ActionListener() 
			{
		    @Override
		    public void actionPerformed(ActionEvent actionEvent) {
		    	
		    	for(final  JButton y:l1)
		    	{
		    	  y.setEnabled(false);   // once clicked, disable all the options
		    	}
		    	save_synth.setEnabled(true);  // enable "save & synthesize" button
		    	SaveDiary.setEnabled(true);
		    	reset.setEnabled(true);  // enable reset button
		    	
		    	if (StartMessageGenerate)
		    	{
			   //   ps.print("START , "+y.getName()+" , "+data(System.currentTimeMillis()));
			      lifo.add("START , "+y.getName()+" , "+data(System.currentTimeMillis()));
			     // ps.println();
			      
			      diary_out = diary_out + "START , "+y.getName()+" , "+data(System.currentTimeMillis()) +System.getProperty("line.separator");
			      mode_sel = "  /B,";
			      dur_sel = "";
			      listModel.insertElementAt(diary_out, listModel.getSize());
			      //listModel.addElement(s);
			     // listModel.addElement("trung");
			      
				  int MenuNum = menuBar.getMenuCount(); // get the total number of menus in  menuBar
			      
			      for (int i =6; i<MenuNum; i++ ) // all menus after Finalize
			      {
			    	  
			    	  menuBar.getMenu(i).setEnabled(true); // enable them back once user clicks
			      }
			      
			      menuBar.getMenu(1).setEnabled(false); // disable start button
			      
			      
			      
			      for (int i = 0; i<2; i++ )
			      {
			    	  m.getItem(i).setEnabled(false);   // disable other options once subject is chosen
	  
			      }
			      spinner1.setEnabled(false);
		    	  spinner2.setEnabled(false);
		    	  
			      forEnding.setEnabled(false); // end loop button is initially disabled until start loop in clicked
			      
			      
		    	} 
		    	else 
		    	{	
		    	}
		    	
		    	StartMessageGenerate = false; 
		    	   
		    }
		});
		
    	 }
    	 
     } 
     
     else{   	 
		 
		 if(title.compareTo("Save Diary")==0){
			 
			// statusbar.setText();
			 m.add(SaveDiary); // add "save diary" button
    		// m.add(save_synth); // add "Finalize button"
    		 
    		 SaveDiary.addActionListener(new ActionListener() {
    			 
    			 public void actionPerformed(ActionEvent actionEvent) {
    				 if(loopcounter !=0)
    					 JOptionPane.showMessageDialog(null,"You must close "+ Integer.toString(loopcounter) +" loop(s).");
    				 else
    				 {
    				 SaveDiary.setEnabled(false);
    				 save_synth.setEnabled(false);	  // button can be clicked only once

    				 diary_out = diary_out + System.getProperty("line.separator");

    		    	 lifo.push("STOP!");
    		    	 diary_out = diary_out + "STOP! "+ " * "+spinner1.getValue()+":"+spinner2.getValue()+ "{";
    		    	 
    		    	 String temp = "STOP! "+ " * "+spinner1.getValue()+":"+spinner2.getValue()+ "{";
    		    	 for(JCheckBox k:l2) {if(k.isSelected()) {diary_out = diary_out + k.getName()+", ";temp = temp+k.getName()+",";};//ps.print(k.getName()+", ");
    		    	 		}
    		    	 temp +="}  <";

    		    	 diary_out = diary_out+"}  <";
    		    	 for(JCheckBox k:l3) {if(k.isSelected()) {diary_out = diary_out + k.getName()+", ";temp = temp+k.getName()+",";}}

    		    	 diary_out = diary_out+">";
    		    	 temp =temp +">";
    		    	 
    		    	 listModel.insertElementAt(temp, listModel.getSize());

    		    	 if(fileName.getText().equals(""))
    		    		 fileName.setText("Untiled.txt");
    		    	 
                     Writer output=null;
                     File file = new File("../../UserSpace/"+fileName.getText()+".txt");  // changed path
                     
                     //File file = new File("write.txt");
                     
                     try {
						output = new BufferedWriter(new FileWriter(file));
						diary_out = diary_out+ System.getProperty("line.separator") + "Note:  Use the DataSynthesis tool in the Tools/Matlab Folder.";
						output.write(diary_out);
						
						//diary_out ="good";
						//output.write(diary_out);
					
						output.close();
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
                   //  } 
                     diary_out = "";
                     
                     StartMessageGenerate = false;
                     
                     JOptionPane.showMessageDialog(null,fileName.getText()+ " was created successfully !  You can find saved diary file in UserSpace folder.");
                     


 			         reset.setEnabled(true);
    		    	 
    		    	 JMenu fileMenu = menuBar.getMenu( 0); 
        			 fileMenu.setEnabled(true);  // enable start menu
        			 for(final  JButton y:l1)
     		    	{
     		    	  y.setEnabled(false);   // enable options in start menu
     		    	}
        			 
 					for(final  JButton y:l4)
 			    	{
 			    	  y.setEnabled(false);   
 			    	}
 					for(final  JButton y:l5)
 			    	{
 			    	  y.setEnabled(false);   
 			    	}
 					for(final  JButton y:l6)
 			    	{
 			    	  y.setEnabled(false);   
 			    	} 
        			 
 					for(final  JButton y:l7)
 						    	{
 				  	 y.setEnabled(false);   
 			    	} 

 					forStarting.setEnabled(false);// disable loop menu
 					forEnding.setEnabled(false); // disable end loop menu
    				newDiary.setEnabled(true);
    				 
    				 
    				 loopcounter = 0;		 // set loop counter back to 0
    				 for(final  JButton y:l8)
 			    	{
 			    	  y.setEnabled(true);   // once clicked, enable all movement buttons //TRB Test
 			    	}
    				
    				 
    				 for(final  JMenu y:motion_opt)
 			    	{
 			    	  y.setEnabled(true);   // once clicked, disable all the buttons so that no more clicks can be made
 			    	}
    		    	 
    		    	 
    				 }
    			 }
    		 });
    		 
    		 
    		 
    		 save_synth.addActionListener(new ActionListener() {
    	 		    
    			 @Override
    	      public void actionPerformed(ActionEvent actionEvent) {
    				 
    				 if(loopcounter !=0)
    					 JOptionPane.showMessageDialog(null,"You must close "+ Integer.toString(loopcounter) +" loop");
    				 else
    				 {
    				// System.out.println(lifo.peek());
    				 SaveDiary.setEnabled(false);
    				 save_synth.setEnabled(false);	  // button can be clicked only once
    		    	 
    				// ps.println();
    				 diary_out = diary_out + System.getProperty("line.separator");
    		    	// ps.print("STOP! "+ " * "+spinner1.getValue()+":"+spinner2.getValue()+ "{");
    		    	 lifo.push("STOP!");
    		    	 diary_out = diary_out + "STOP! "+ " * "+spinner1.getValue()+":"+spinner2.getValue()+ "{";
    		    	 
    		    	 String temp = "STOP! "+ " * "+spinner1.getValue()+":"+spinner2.getValue()+ "{";
    		    	 for(JCheckBox k:l2) {if(k.isSelected()) {diary_out = diary_out + k.getName()+", ";temp = temp+k.getName()+",";};//ps.print(k.getName()+", ");
    		    	 		}
    		    	 temp +="}  <";
    		    	// ps.print("} , < ");
    		    	 diary_out = diary_out+"}  <";
    		    	 for(JCheckBox k:l3) {if(k.isSelected()) {diary_out = diary_out + k.getName()+", ";temp = temp+k.getName()+",";}}
    		    	 //ps.print(k.getName()+", ");}
    		    	// ps.println(">");
    		    	 diary_out = diary_out+">";
    		    	 temp =temp +">";
    		    	 
    		    	 listModel.insertElementAt(temp, listModel.getSize());
    		    	 
    		    	// while (!ilegalMov.isEmpty())
    		    	// {
    		    	//	 s=s+System.getProperty("line.separator")+ilegalMov.pop();
    		    	// }
    		    	 
    		    	// s=s+System.getProperty("line.separator")+cur;
    		    	// s=s+System.getProperty("line.separator")+loopSinMov.contains(cur);
    		    	// System.out.println(data.get(cur).toString());
    		    	// System.out.println(ilegalMov.peek());
    		    	// System.out.println(data.get(cur).contains(ilegalMov.peek()));
    		    	 
                   //  ps.print(s);
                    // if(lifo.pop().equals("STOP!"))
                    // {
    		    	 if(fileName.getText().equals(""))
    		    		 fileName.setText("Untiled.txt");
    		    	 
                     Writer output=null;
                     File file = new File("../../Utility/"+fileName.getText()+".txt");
                     
                     //File file = new File("write.txt");
                     
                     try {
						output = new BufferedWriter(new FileWriter(file));
					
						output.write(diary_out);
					
						output.close();
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
                   //  } 
                     diary_out = "";
                     
                     StartMessageGenerate = false;
                     
                     JOptionPane.showMessageDialog(null,fileName.getText()+ " was created successfully ! Starting generate data files in Matlab");
                     try {
						Process p = Runtime.getRuntime().exec("../../Tools/MATLAB Folder/test3.bat");  // changed path
					
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
                     //MatlabControl mc = new MatlabControl();
                     //MatlabProxyFactory factory = new MatlabProxyFactory();
                     //MatlabProxy proxy = factory.getProxy();

					
                     //Display 'hello world' just like when using the demo
                     //proxy.eval("disp('hello world')");

                     //Disconnect the proxy from MATLAB
                     //proxy.disconnect();
    		    	 //ps.close();
 			         reset.setEnabled(true);
    		    	// newDiary.setEnabled(true);   // enable "New Diary" button
    		    	 
    		    	 JMenu fileMenu = menuBar.getMenu( 0); 
        			 fileMenu.setEnabled(true);  // enable start menu
        			 for(final  JButton y:l1)
     		    	{
     		    	  y.setEnabled(false);   // enable options in start menu
     		    	}
        			 //bb3.setEnabled(true); // set "finalize" button enabled
        			 
 					for(final  JButton y:l4)
 			    	{
 			    	  y.setEnabled(false);   
 			    	}
 					for(final  JButton y:l5)
 			    	{
 			    	  y.setEnabled(false);   
 			    	}
 					for(final  JButton y:l6)
 			    	{
 			    	  y.setEnabled(false);   
 			    	} 
        			 
 					for(final  JButton y:l7)
 						    	{
 				  	 y.setEnabled(false);   
 			    	} 
 					
 					 
 					
 					
    				/* 
 					for(int i=2;i<menuBar.getComponentCount();i++){  // always make start, start loop, end loop, quit, finalize, new diary visible
						//first and last indices in MenuBar.getComponent are resserved for start and quit buttons,which need to be visualized anytime
						
 						menuBar.getMenu(i-2).setEnabled(false);
						
							menuBar.getComponent(i).setVisible(false);
							newDiary.setEnabled(true);
							menuBar.repaint();
 					}
        			 */
    				/* 
    				 *try{
    					 String temp = data(System.currentTimeMillis()) ;
    					 String[] temp2 = temp.split(":");
    					 
    					 String temp3;
    					 String temp4 = "";
    					 for (int i = 0; i < temp2.length; i++){
    						 temp3 = temp2[i];
    						 temp4 = temp4 + temp3;
    					 }
    				 ps = new PrintStream(new FileOutputStream("../../Utility/synthesis" +temp4 + ".txt"));	
    				 
    				 }
    				 catch (FileNotFoundException e){
    					 e.printStackTrace();
    				 }
    				 */
 					
 					//JOptionPane.showMessageDialog(null,fileName,"Enter your diary file name :",JOptionPane.PLAIN_MESSAGE);
			 		//n=nodes;ed=edges; hm=new HashMap<String,Integer>();
			 		
			 		//System.out.println(fileName.getText());
			 	/*	
			 		try {
						ps = new PrintStream(new FileOutputStream("../../Utility/"+fileName.getText()+".txt"));
					} catch (FileNotFoundException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}	
			 		*/
 					forStarting.setEnabled(false);// disable loop menu
 					forEnding.setEnabled(false); // disable end loop menu
    				newDiary.setEnabled(true);
    				 
    				 
    				 loopcounter = 0;		 // set loop counter back to 0
    				 for(final  JButton y:l8)
 			    	{
 			    	  y.setEnabled(true);   // once clicked, enable all movement buttons //TRB Test
 			    	}
    				 //StartMessageGenerate= true;
    				 
    				 for(final  JMenu y:motion_opt)
 			    	{
 			    	  y.setEnabled(true);   // once clicked, disable all the buttons so that no more clicks can be made
 			    	}
    		    	 
    		    	 
    				 }
    			 }
    		 });
    		 
		 }
		 
		 else if(title.compareTo("New Diary")==0){ 
			 
    		 m.add(newDiary);
    		 newDiary.addActionListener(new ActionListener() {
    			 @Override
    	 		    public void actionPerformed(ActionEvent actionEvent) {
    				 
    				 
    				 menuBar.getMenu(1).setEnabled(true);  // enable start menu
    				 menuBar.getMenu(3).setEnabled(true);  // disable new diary button
    				 listModel.removeAllElements();
        			 
        			 
        			 for (int i = 0; i<2; i++ )
        			  {
        				 menuBar.getMenu(1).getItem(i).setEnabled(true);   // re-enable other options in start menu since it was disabled after "start"
        	
        			 }
        			 spinner1.setEnabled(true);
        		  	  spinner2.setEnabled(true);
        			 for(final  JButton y:l1)
     		    	{
     		    	  y.setEnabled(true);   // enable options in start menu
     		    	}
        			 
        			 
 					for(final  JButton y:l4)
 			    	{
 			    	  y.setEnabled(true);   
 			    	}
 					for(final  JButton y:l5)
 			    	{
 			    	  y.setEnabled(true);   
 			    	}
 					for(final  JButton y:l6)
 			    	{
 			    	  y.setEnabled(true);   
 			    	} 
        			 
 					for(final  JButton y:l7)
 					{
 				  	 y.setEnabled(true);   
 			    	} 
    				 
 					forStarting.setEnabled(true);// enable loop menu
 					forEnding.setEnabled(false); // enable end loop menu
 					
 					for(int i=0;i<5;i++){  

						
 							menuBar.getMenu(i).setEnabled(true);

 					}
 					
 					for(int i=5;i<menuBar.getComponentCount();i++){  // always make start, start loop, end loop, quit, finalize, new diary visible
						//first and last indices in MenuBar.getComponent are resserved for start and quit buttons,which need to be visualized anytime
						
 							menuBar.getMenu(i).setEnabled(false);
						
							menuBar.getComponent(i).setVisible(true);
							menuBar.repaint();
 					}
        			 
    				
 					
 					JOptionPane.showMessageDialog(null,fileName,"Enter your diary file name :",JOptionPane.PLAIN_MESSAGE);
			 	
    				 newDiary.setEnabled(false);
    				 forEnding.setEnabled(true);
    				 loopcounter = 0;		 // set loop counter back to 0
    				 for(final  JButton y:l8)
 			    	{
 			    	  y.setEnabled(true);   // once clicked, enable all movement buttons
 			    	}
    				 StartMessageGenerate= true;
    				 
    				 for(final  JMenu y:motion_opt)
 			    	{
 			    	  y.setEnabled(true);   // once clicked, disable all the buttons so that no more clicks can be made
 			    	}
    			 }
    		 });
    		 
		 }
		 
 else if(title.compareTo("Reset Diary")==0){ 
			 
    		 m.add(reset);
    		 reset.addActionListener(new ActionListener() {
    			 @Override
    	 		    public void actionPerformed(ActionEvent actionEvent) {
    				  save_synth.setEnabled(false);  // disable "save & synthesize" button
    			    reset.setEnabled(false); // disable "reset" button
    			    newDiary.setEnabled(true); // disable "new diary" button
    			    SaveDiary.setEnabled(false);
    			    
    				 menuBar.getMenu(0).setEnabled(true);  // enable start menu
    				 
    				 listModel.removeAllElements();
        			 
        			 for (int i = 0; i<2; i++ )
        			      {
        				 menuBar.getMenu(1).getItem(i).setEnabled(true);   // re-enable other options in start menu since it was disabled after "start"
        	      	  
        				 }
        				 spinner1.setEnabled(true);
        				 spinner2.setEnabled(true);
        			 
        			 for(final  JButton y:l1)
     		    	{
     		    	  y.setEnabled(true);   // enable options in start menu
     		    	}
        			
        			 
 					for(final  JButton y:l4)
 			    	{
 			    	  y.setEnabled(true);   
 			    	}
 					for(final  JButton y:l5)
 			    	{
 			    	  y.setEnabled(true);   
 			    	}
 					for(final  JButton y:l6)
 			    	{
 			    	  y.setEnabled(true);   
 			    	} 
        			 
 					for(final  JButton y:l7)
 					{
 					  y.setEnabled(true);   
 			    	}
    				 
 					for(int i=0;i<5;i++){  // always make start, start loop, end loop, quit, finalize, new diary visible
						
						
 						menuBar.getMenu(i).setEnabled(true);
						
							
 					}
 					
 					for(int i=5;i<menuBar.getComponentCount();i++){  // always make start, start loop, end loop, quit, finalize, new diary visible
						//first and last indices in MenuBar.getComponent are resserved for start and quit buttons,which need to be visualized anytime
						
 						menuBar.getMenu(i).setEnabled(false);
						
					    menuBar.getComponent(i).setVisible(true);
						menuBar.repaint();
 					}
        			 
    			
 					diary_out = "";
    				
    				 forStarting.setEnabled(true);
    				 forEnding.setEnabled(false);
    				 loopcounter = 0;
    				
    				 for(final  JButton y:l8)
 			    	{
 			    	  y.setEnabled(true);   // once clicked, enable all movement buttons
 			    	}
    				 StartMessageGenerate= true;
    				 
    				 for(final  JMenu y:motion_opt)
 			    	{
 			    	  y.setEnabled(true);   // once clicked, disable all the buttons so that no more clicks can be made
 			    	}
    			 }
    		 });
    		 
		 }
		 
		 
		 
		 else if(title.compareTo("Close Tool")==0){  // when user clicks "quit"
    		 final JButton close=new JButton("Close"); 
    		 
    		 m.add(close);
    		 
    		 
    		 close.addActionListener(new ActionListener() {
    	 		    
    			 @Override
 		    public void actionPerformed(ActionEvent actionEvent) {
    
 			 System.exit(0);
 		    }
 		});
    	
    	 }
    	 
    	 else if (title.compareTo("Start Loop")==0){    // read the button with "start loop"
    		 spinner3.setValue(2);
    	
        	 m.add(forStarting);m.add(spinner3);
        	 
        	 forStarting.addActionListener(new ActionListener(){
        		 public void actionPerformed(ActionEvent actionEvent) { // action listener for the "loop" button
        			
        			 
        		  menuBar.repaint();
        		  
        		  
        		  if(loopcounter > 4)
         			 JOptionPane.showMessageDialog(null,"You cannot create more than 5 nested loops");
         		 
        		  else
        		  {
        			  diary_out = diary_out + System.getProperty("line.separator")+"["+spinner3.getValue();
        			  lifo.add("["+spinner3.getValue());
    		      
        			  loopcounter++;
        			  flagAdd=true;
    		      
        			  forEnding.setEnabled(true);
        			  listModel.insertElementAt("\n["+spinner3.getValue(), listModel.getSize());
        			  // JOptionPane.showMessageDialog(null,"Your Current Diary \n "+ s);
        			  //int MenuNum = menuBar.getMenuCount();
        			  //JMenu fileMenu = menuBar.getMenu( MenuNum-1 ); 
        			  //fileMenu.setEnabled(false); // disable "quit" whenever a loop starts
        		  }
    		    }});
    		 
        	
    	 }
    	 
    	 else if (title.compareTo("End Loop")==0){     // read the button with "end loop"
    		 m.add(forEnding);
    		 
    		 forEnding.addActionListener(new ActionListener(){
        		
				public void actionPerformed(ActionEvent actionEvent) {
        	     //forEnding.setEnabled(false);// button can be clicked only once
        	     //
				String s1=lifo.get(lifo.size()-1);
				//lifo.pop();
				String s2=lifo.get(lifo.size()-2);
				System.out.println(s2);
				
				//lifo.pop();
        	   if( loopSinMov.contains(s1)&& s2.startsWith("[") )
        	     JOptionPane.showMessageDialog(null,"Subject posture at the start and end of loop must match.  Please select another movement.");
        	   else if( loopSinMov.contains(logic_cur)&& !ilegalMov.isEmpty()&& data.get(logic_cur).contains(ilegalMov.peek()))
        	     {
        	    	 //JOptionPane.showMessageDialog(null,"Impossible movement");
        	    	 
        	    		
        	    	JOptionPane.showMessageDialog(null,"Could not move from \""+ logic_cur+ "\" to \""+ilegalMov.peek()+"\"  in a loop. Please, choose other movement to continue");
        	    	 	 
        	     }
        	     
        	     else
        	     {
			    //ps.print(lifo.);
			    if(!ilegalMov.isEmpty())
			    	ilegalMov.pop();
					//String content = ps.toString();
				//System.out.println(content);
        		 //ps.println("");
        		 //ps.println("]");
        		 
        	    diary_out=diary_out+System.getProperty("line.separator")+"]";
        		// lifo.add("]");
        		 //JOptionPane.showMessageDialog(null,"Your Current Diary \n "+ s);
        		 listModel.insertElementAt("\n]", listModel.getSize());
        		 
        		 loopcounter --; 
        		 if (loopcounter >0){}// if still greater than 0, means still have open loops needed to close
        		 else
        		 {
        			 forEnding.setEnabled(false); 
        			 int MenuNum = menuBar.getMenuCount();
        			 JMenu fileMenu = menuBar.getMenu( MenuNum-1 ); 
        			 fileMenu.setEnabled(true); // disable "quit" whenever a loop starts
        		 }
        		 	menuBar.repaint();
        		 }
				}
        	 });
    	 }
    	 
    	 
    	 else { // This else is reached when a movement is selected (e.g. sit_to_stand, etc.)		  		
   
    		/* **************************************************************************
    		 *  Set up Menus for all Movement Specific Control Options 
    		 ************************************************************************** */
    		 
    		/* Setting Up the Group of Radio Buttons for Speed Selection*/
            final JMenu submenu_speed = new JMenu("Walking Speed");
	        submenu_speed.setEnabled(true);
	        
	        final JRadioButton defspeed=new JRadioButton("Default", true);
	        submenu_speed.add(defspeed);
	        defspeed.addActionListener(new ActionListener() {
			    @Override
			    public void actionPerformed(ActionEvent actionEvent) {
			    	speed_sel = "";
			    }
			});
	        final JRadioButton speed1=new JRadioButton("1 Mile/Hour");
	        submenu_speed.add(speed1);
	        speed1.addActionListener(new ActionListener() {
			    @Override
			    public void actionPerformed(ActionEvent actionEvent) {
			    	speed_sel = "S-1,";
			    }
			});
	        final JButton speed2=new JButton("2 Miles/Hour");
	        submenu_speed.add(speed2);
	        speed2.addActionListener(new ActionListener() {
			    @Override
			    public void actionPerformed(ActionEvent actionEvent) {
			    	speed_sel= "S-2,";
			    }
			});
	        
	        ButtonGroup speedgroup = new ButtonGroup();
	        speedgroup.add(defspeed);
	        speedgroup.add(speed1);
	        speedgroup.add(speed2);
	        	        
	        
	        /* Setting Up the Group of Radio Buttons for Duration Selection*/
	        final JMenu submenu_dur = new HorizontalMenu("Duration");
	        submenu_dur.setEnabled(true);
	        //JMenuItem menuItem = new JMenuItem("Select Duration");
	        //submenu_dur.add(menuItem);
	        final JRadioButton defdur=new JRadioButton("Default", true);
	        submenu_dur.add(defdur);
	        defdur.addActionListener(new ActionListener() {
			    @Override
			    public void actionPerformed(ActionEvent actionEvent) {
			    	dur_sel = "";
			    }
			});
	        final JRadioButton dur5=new JRadioButton("5 seconds");
	        submenu_dur.add(dur5);
	        dur5.addActionListener(new ActionListener() {
			    @Override
			    public void actionPerformed(ActionEvent actionEvent) {
			    	dur_sel = " D-5";
			    }
			});
	        
	        final JRadioButton dur10=new JRadioButton("10 seconds");
	        submenu_dur.add(dur10);
	        dur10.addActionListener(new ActionListener() {
			    @Override
			    public void actionPerformed(ActionEvent actionEvent) {
			    	dur_sel = " D-10";
			    }
			});
	        
	        final JRadioButton dur15=new JRadioButton("15 seconds");
	        submenu_dur.add(dur15);
	        dur15.addActionListener(new ActionListener() {
			    @Override
			    public void actionPerformed(ActionEvent actionEvent) {
			    	dur_sel = " D-15";
			    }
			});
	        
	        ButtonGroup durgroup = new ButtonGroup();
	        durgroup.add(defdur);
	        durgroup.add(dur5);
	        durgroup.add(dur10);
	        durgroup.add(dur15);
	       
	        
	        /* *********************************************************************************************
	         * TRB Update - Removed Trials menu (i.e. submenu1).  Many methods available to repeat a movement.
	         * If it's determined to be useful, Maybe add a spinner to select the number of trials. 
	         *************************************************************************************************/
	        
	        
	    	final JMenu submenu_mode = new HorizontalMenu("Mode");
	        submenu_mode.setEnabled(true);
	        final JRadioButton best=new JRadioButton("Best",true);
	        submenu_mode.add(best);
	        best.addActionListener(new ActionListener() {
			    @Override
			    public void actionPerformed(ActionEvent actionEvent) {
			    	mode_sel="  /B,";
			    }
			}); 
	        final JRadioButton random=new JRadioButton("Random");
	        submenu_mode.add(random);
	        random.addActionListener(new ActionListener() {
			    @Override
			    public void actionPerformed(ActionEvent actionEvent) {
			    	mode_sel="  /REx,";
			    }
			});
	        final JRadioButton randomeps=new JRadioButton("Random Epsilon");
	        //submenu_mode.add(randomeps);
	        random.addActionListener(new ActionListener() {
			    @Override
			    public void actionPerformed(ActionEvent actionEvent) {
			    	mode_sel="  /REps,";
			    }
			});	        

	        ButtonGroup modegroup = new ButtonGroup();
	        modegroup.add(best);
	        modegroup.add(random);
	        //durgroup.add(randeps); // Random Epsilon currently not implemented, but may be in the future
	        
	        /*  This code no longer needed with Radio buttons
	        l4.add(t5);
	        l4.add(t10);
	        l4.add(t25);
	        l4.add(tRand);
	        
	        //l5.add(best);
	       // l5.add(random);
	       // l5.add(randomE);
	        
	       // l6.add(s1);
	        //l6.add(s2);
	        
	        //l7.add(d5);
	        //l7.add(d10);
	        //l7.add(d15);
	        */
	        motion_opt.add(submenu_dur);
	        //motion_opt.add(submenu_trial); // Trials currently not implemented
	        motion_opt.add(submenu_mode);
	        motion_opt.add(submenu_speed);
	        

	        m.add(submenu_speed);
	        m.add(submenu_mode);
	        m.add(submenu_dur);
	        
	        final JButton motion_select = new JButton(title);
	         //motion_select.setName("Add to Diary");
			 m.add(motion_select);
			 hm.put(title,hmindex+1);
			 hmindex++;
			 l8.add(motion_select);
	        
	      // final JList listbox= new JList();
	      // listbox.add(title);
	     //   m.add(listbox);
	        //m.add(submenu1);
	        //m.add(submenu10);
        
	        // button click event
	      /*  final JButton x=new JButton(title);
	        x.setName(title);
			 m.add(x);
			 hm.put(title,hmindex+1);
			 hmindex++;
			 l8.add(x);
			*/ 
			motion_select.addActionListener(new ActionListener(){ // every time click a motion button, menus will be activated, and it can only be clicked once.  			 
	
				@SuppressWarnings("unused")
				@Override
				public void actionPerformed(ActionEvent e) {
					
					
					
					 for(final  JButton y:l8)
	 			    	{
	 			    	  y.setEnabled(true);   // once clicked, enable all movement buttons
	 			    	}
				System.out.println(title);
				System.out.println(loopSinMov);
				if(loopSinMov.contains(title))
				{
					motion_select.setEnabled(false);
					System.out.println("here");
				}
				else
					motion_select.setEnabled(true);
					
					submenu_dur.setEnabled(true);
					//submenu1.setEnabled(true); // Trial currently not implemented
					submenu_mode.setEnabled(true);
					submenu_speed.setEnabled(true);
					for(final  JButton y:l4)
			    	{
			    	  y.setEnabled(true);   
			    	}
					for(final  JButton y:l5)
			    	{
			    	  y.setEnabled(true);   
			    	}
					for(final  JButton y:l6)
			    	{
			    	  y.setEnabled(true);   
			    	}
					for(final  JButton y:l7)
			    	{
			    	  y.setEnabled(true);   // once clicked, disable all the buttons so that no more clicks can be made
			    	}
					
					// TODO Auto-generated method stub
				//	ps.println();
					//ps.print(title+ " ");
					if(flagAdd==true)
					{
						ilegalMov.push(title);
						flagAdd=false;
					}
					
					disp_out=title+mode_sel+" "+dur_sel;
					logic_cur=title;
					diary_out+=System.getProperty("line.separator")+title+" "+mode_sel+" "+dur_sel;
					defdur.setSelected(true);
					best.setSelected(true);
					mode_sel = "  /B,";
					dur_sel = "";
					System.out.println(diary_out);
					/*Writer output = null;
					File file = new File("../../Utility/"+fileName.getText()+".txt");
					try {
						output = new BufferedWriter(new FileWriter(file));
					
						output.write(diary_out);
					
						output.close();
						
					} catch (IOException ex) {
						// TODO Auto-generated catch block
						ex.printStackTrace();
					}
					*/
					//JOptionPane.showMessageDialog(null,"Your Current Diary \n "+ s);
					
				//	labels.add("terry");
					//listbox = new JList( (labels) );
					
					 //listModel.addElement(s);
					 //listModel.addElement("trung");
					// listModel.insertElementAt("trung", 3);
				//	 System.out.println(listModel.size());
					 //listModel.fire
					// listbox.setVisible(true);
					// listbox.repaint();
					// listbox.revalidate();
					
					
					 listModel.insertElementAt(disp_out, listModel.getSize());
				      
				      // Select the new item and make it visible.
				     // listbox.setSelectedIndex(index);
				      //listbox.ensureIndexIsVisible(index);
				      
					 
					lifo.add(title);
					
					//for(int i=0;i<menuBar.getComponentCount();i++){ 
					
					for(int i=8;i<menuBar.getComponentCount();i++){  // always make start, start loop, end loop, quit, finalize, new diary visible
						//first and last indices in MenuBar.getComponent are resserved for start and quit buttons,which need to be visualized anytime
						
						 String name=menuBar.getComponent(i).getName();
						
							menuBar.getComponent(i).setVisible(false);
						 boolean allowed=false;
				for(Edge e1:ed){
						
						if(e1.getV1().equals(title)&&(e1.getV2().equals(name))) {
							allowed=true; 
							menuBar.getComponent(i).setVisible(true);
							
							
							
							menuBar.repaint();
						}
						
						
					}
					
					  
					}
					if (loopcounter == 0){}
					else{
					JMenu fileMenu = menuBar.getMenu(2); 
		   		    fileMenu.setEnabled(true); // only when one action is selected, enable " end loop" button
					}
				}
				 
			 });
        
        
        //rules the allowed length of movements
        /* ****************************************************************************************************
         * Submenus (for duration, speed, and trials) are activated based on the location in the HashMap.
         * This is currently hard coded, but the position information should be made dynamic based on the 
         * generated graph file.  TRB Update.  Build Individual Menus based on this concept   
        *******************************************************************************************************/
       if(hm.get(title)<16) {submenu_speed.setVisible(false);submenu_dur.setVisible(false);}
       // else if(hm.get(title)<15) submenu_speed.setVisible(false);
       // else if(hm.get(title)==6) submenu10.setVisible(false);
        //else {if(hm.get(title)<22) {submenu10.setVisible(false);submenu1.setVisible(false);}
        else {if(hm.get(title)<25) {submenu_speed.setVisible(false);} // Removed submenu1 reference
         
        } }//end else
     }
          
        return m;
    }

    
    
    
    @SuppressWarnings("unused")
	protected String data(long currentTimeMillis) {
    	long yourmilliseconds = currentTimeMillis;
        SimpleDateFormat sdf = new SimpleDateFormat("MMM dd,yyyy HH:mm");

        Date resultdate = new Date(yourmilliseconds);
        
		return resultdate.toString();
	}

	public void actionPerformed(ActionEvent e) {
       System.out.println(e.getSource());
    } 
    
    
    
    /**
     * Create the GUI and show it.  For thread safety,
     * this method should be invoked from the
     * event-dispatching thread.
     * @throws FileNotFoundException 
     */
    private void createAndShowGUI() throws FileNotFoundException {
        //Create and set up the window.
        final JFrame frame = new JFrame("Diary Generator");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        
        //Create and set up the content pane.
        MenuLayoutDemo2 demo = new MenuLayoutDemo2(n,ed);
        MenuLayoutDemo2 demo1 = new MenuLayoutDemo2(n,ed);
        Container contentPane = frame.getContentPane();
        //contentPane.setBackground(Color.white); //contrasting bg
        contentPane.add(demo.createMenuBar(),
                        BorderLayout.LINE_START);
        //contentPane.add(new JList())
        JScrollPane scrollPane = new JScrollPane();
      //  JList list = new JList();
        scrollPane.setViewportView(demo1.createJList());
        contentPane.add(scrollPane,
              BorderLayout.CENTER);
        //TextArea t = new TextArea();
        
      //  t.setText(s);
      //  t.repaint();
       // t.revalidate();
        //contentPane.add(new JListDemo(labels),BorderLayout.CENTER);
       // listbox = new JList( (labels) );
        
       // contentPane.add(listbox,
          //      BorderLayout.CENTER);
        
        // String labels[] = { "A", "B", "C", "D", "E", "F", "G" };
         final DefaultListModel model = new DefaultListModel();
         for (int i = 0, n = lifo.size(); i < n; i++) {
           model.addElement(lifo.get(i));
         }
         JList jlist = new JList(model);
         JScrollPane scrollPane1 = new JScrollPane(jlist);
         ListDataListener listDataListener = new ListDataListener() {
             
			@Override
			public void contentsChanged(ListDataEvent arg0) {
				
				// TODO Auto-generated method stub
				//frame.repaint();
				
			}

			@Override
			public void intervalAdded(ListDataEvent arg0) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void intervalRemoved(ListDataEvent arg0) {
				// TODO Auto-generated method stub
				
			}
           };
         model.addListDataListener(listDataListener);
         
      //   contentPane.add(listbox, BorderLayout.CENTER);
        
       //	JList		listbox;
       	String	listData[] =
    		{
    			disp_out
    		};
       	//lifo.push("here");
      
       // contentPane.add(listbox);
        //JLabel statusbar;
        statusbar = new JLabel();
        statusbar.setText(disp_out);
        statusbar.setBorder(BorderFactory.createEtchedBorder(EtchedBorder.RAISED));
        statusbar.setVisible(true);
        
      // contentPane.add(statusbar, BorderLayout.SOUTH);
       
        
        //contentPane.add(k);
        
                //Display the window.
        //frame.setSize(500, 700);  
        //frame.setVisible(true);
        frame.pack();
       frame.setExtendedState(JFrame.MAXIMIZED_BOTH);
       frame.setVisible(true);
    }

    
    
    public void start() {
        //Schedule a job for the event-dispatching thread:
        //creating and showing this application's GUI.
        javax.swing.SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                try {
					createAndShowGUI();
				} catch (FileNotFoundException ex) {
					// TODO Auto-generated catch block
					ex.printStackTrace();
				}
            }
        });
    }

    @SuppressWarnings("serial")
	class HorizontalMenu extends JMenu {
        HorizontalMenu(String label) {
            super(label);
            JPopupMenu pm = getPopupMenu();
           // listbox= new JList(labels);
            pm.setLayout(new BoxLayout(pm, BoxLayout.LINE_AXIS));
        }

        public Dimension getMinimumSize() {
            return getPreferredSize();
        }

        public Dimension getMaximumSize() {
            return getPreferredSize();
        }

        public void setPopupMenuVisible(boolean b) {
            boolean isVisible = isPopupMenuVisible();
            if (b != isVisible) {
                if ((b==true) && isShowing()) {
                    //Set location of popupMenu (pulldown or pullright).
                    //Perhaps this should be dictated by L&F.
                    int x = 0;
                    int y = 0;
                    Container parent = getParent();
                    if (parent instanceof JPopupMenu) {
                        x = 0;
                        y = getHeight();
                    } else {
                        x = getWidth();
                        y = 0;
                    }
                    getPopupMenu().show(this, x, y);
                } else {
                    getPopupMenu().setVisible(false);
                }
            }
        }
    }

	@Override
	public void itemStateChanged(ItemEvent arg0) {		
	}
	
	@SuppressWarnings("unused")
	public JSpinner ShowTimeJSpinner(String h){
		 
JSpinner spinner=null;
		 if(h.equals("h")){
		 spinner = new JSpinner((new SpinnerNumberModel(0, 0, 23, 1)));
		 
		 
		 }
		 
		 else 
			 spinner = new JSpinner((new SpinnerNumberModel(0, 0, 59, 1)));
			 Integer currentValue = (Integer)spinner.getValue();
		return spinner;
		 }
	
}


class HorizontalMenu1 extends JMenu {
    HorizontalMenu1() {
     //super();
        super("________________________");
        JMenu pm = new JMenu();
       // pm.addSeparator();
       // pm.setVisible(true);
       // listbox= new JList(labels);
        pm.setLayout(new BoxLayout(pm, BoxLayout.LINE_AXIS));
        //JMenuItem j= new JMenuItem();
        //j.add(new JSeparator());
        //pm.add(j);
       
    }

    public Dimension getMinimumSize() {
        return getPreferredSize();
    }

    public Dimension getMaximumSize() {
        return getPreferredSize();
    }




}


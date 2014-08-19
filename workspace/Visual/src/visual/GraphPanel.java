package visual;

import java.awt.*;
import java.awt.event.*;
import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.List;
import java.util.ListIterator;
import java.util.StringTokenizer;
import java.util.Vector;

import javax.swing.*;
import javax.swing.event.*;

/*************************************************************************************
 * Description: CONTAINS MAIN()
 * This class creates a frame that contains an initially empty graph.
 * #The user has the following options in this frame:
 * -Load from file: loads movement data from a file named 'generated_graph.txt'
 * -Compose Sequence: starts the diary generation part of code. See DiaryGenerationMenu.java
 * #Right click opens up a pop-up menu with the following options
 * -New: Creates a new node in the graph. Prompts user for details on node creation.
 * -Show/Hide Postures: Shows start and end postures of each movement node below the nodes
 * -Delete: Deletes the selected node and its related edges
 * -Textualize Rules: Creates a new generated_graph marked with a timestamp using the current nodes and information
 * -Clear: Clears all nodes from the graph
 * 
 * @author John B. Matthews; distribution per GPL.
 * @author Claudio Savaglio; customization of the code and inserting new
 *         functionalities
 * @author Hunter Massey; bug fixes and feature addition - latest to touch code
 **************************************************************************************
 *
 * Class GraphPanel
 * Description:
 * ***********************************************
 */
@SuppressWarnings("serial")
public class GraphPanel extends JComponent
{
	/**
	 * Variables that control size of frame and radius of the nodes in the graph
	 */
	private static final int WIDE = 840;
	private static final int HIGH = 580;
	private static final int RADIUS = 15;
	private ControlPanel control = new ControlPanel();

	/**
	 * postures: Vector of postures possible for start and end positions of movement. This is built either directly by the user or
	 * when the program loads from file using the LoadAction.
	 * nodes, edges: Lists containing all nodes and edges, respectively
	 */
	Vector<String> postures = new Vector<String>();
	private List<Node> nodes = new ArrayList<Node>();
	private List<Edge> edges = new ArrayList<Edge>();

	/**
	 * mousePt: current location of mouse
	 * mouseRect: rectangle drawn when user is drag-clicking to select nodes
	 * selecting: user is currently selecting nodes
	 * posturesVisible: true if user has selected ShowPosturesAction
	 */
	private Point mousePt = new Point(WIDE / 2, HIGH / 2);
	private Rectangle mouseRect = new Rectangle();
	private boolean selecting = false;
	private static boolean posturesVisible = false;

	
	/**
	 * Constructor
	 */
	public GraphPanel()
	{
		this.setOpaque(true);
		this.addMouseListener(new MouseHandler());
		this.addMouseMotionListener(new MouseMotionHandler());
	}	
	
	/**
	 * Main method. Sets up graphical environment
	 */
	public static void main(String[] args) throws Exception {
		
		EventQueue.invokeLater(new Runnable()
		{
			public void run() {
				JFrame f = new JFrame("GraphPanel");
				f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
				GraphPanel gp = new GraphPanel();
				f.add(gp.control, BorderLayout.NORTH);
				f.add(new JScrollPane(gp), BorderLayout.CENTER);
				f.pack();
				f.setLocationByPlatform(true);
				f.setVisible(true);
			}
		});
	}

	
	/***************************************************************
	 * Methods
	 **************************************************************/

	/**
	 * Return the dimensions set by WIDE and HIGH
	 */
	@Override
	public Dimension getPreferredSize() {
		return new Dimension(WIDE, HIGH);
	}
	
	/**
	 * Draw individual nodes and edges through method calls
	 */
	@Override
	public void paintComponent(Graphics g) {
		g.setColor(new Color(0x00f0f0f0));
		g.fillRect(0, 0, getWidth(), getHeight());
		for (Edge e : edges)
		{
			e.draw(g);
		}
		for (Node n : nodes)
		{
			n.draw(g,posturesVisible);
		}
		
		if (selecting)
		{
			g.setColor(Color.darkGray);
			g.drawRect(mouseRect.x, mouseRect.y, mouseRect.width, mouseRect.height);
		}
		revalidate();
		repaint();
	}

	/******************************************************
	 * Subclasses that handle Mouse events
	 *****************************************************/
	private class MouseHandler extends MouseAdapter
	{
		@Override
		public void mouseReleased(MouseEvent e) {
			selecting = false;
			mouseRect.setBounds(0, 0, 0, 0);
			if (e.isPopupTrigger())
			{
				showPopup(e);
			}
			e.getComponent().repaint();
		}

		@Override
		public void mousePressed(MouseEvent e) {
			mousePt = e.getPoint();
			if (e.isShiftDown())
			{
				Node.selectToggle(nodes, mousePt);
			}
			else if (e.isPopupTrigger())
			{
				Node.selectOne(nodes, mousePt);
				showPopup(e);
			}
			else if (Node.selectOne(nodes, mousePt))
			{
				selecting = false;
			}
			else
			{
				Node.selectNone(nodes);
				selecting = true;
			}
			e.getComponent().repaint();
		}

		private void showPopup(MouseEvent e) {
			if(posturesVisible)
			{
				control.popup.getComponent(2).setVisible(false);
				control.popup.getComponent(3).setVisible(true);
			}
			else
			{
				control.popup.getComponent(2).setVisible(true);
				control.popup.getComponent(3).setVisible(false);
			}
			control.popup.show(e.getComponent(), e.getX(), e.getY());
		}
	}

	//Handles mouse motions, say if user is currently holding down left click -Hunter
	private class MouseMotionHandler extends MouseMotionAdapter
	{
		Point delta = new Point();

		@Override
		public void mouseDragged(MouseEvent e) {
			if (selecting)
			{
				mouseRect.setBounds(Math.min(mousePt.x, e.getX()), Math.min(mousePt.y, e.getY()), Math.abs(mousePt.x - e.getX()), Math.abs(mousePt.y - e.getY()));
				Node.selectRect(nodes, mouseRect);
			}
			else
			{
				delta.setLocation(e.getX() - mousePt.x, e.getY() - mousePt.y);
				Node.updatePosition(nodes, delta);
				mousePt = e.getPoint();
			}
			e.getComponent().repaint();
		}
	}
	
	/**
	 * ***********************************************
	 * Subclass Class ControlPanel
	 * ***********************************************
	 * Description: Handles addition of all actions and buttons for user to interact with.
	 * These include things such as the right-click popup menu and loading from file
	 * Toolbar for transitions graph's creation
	 * @author Claudio Savaglio
	 */
	public class ControlPanel extends JToolBar
	{
		/**
		 * Actions available to user
		 */
		private Action newNode = new NewNodeAction("New");
		private Action clearAll = new ClearAction("Clear");
		private Action color = new ColorAction("Color");
		private Action show = new ShowPosturesAction("Show Postures");
		private Action hide = new HidePosturesAction("Hide Postures");
		private Action delete = new DeleteAction("Delete");
		private Action compose = new ComposeAction("Compose Sequence");
		private Action load = new LoadAction("Load from File");
		private ColorIcon hueIcon = new ColorIcon(Color.blue);
		private JPopupMenu popup = new JPopupMenu();
		private Action rename = new TextualizeAction("Textualize Rules");

		
		private int radius = RADIUS;


		ControlPanel()
		{
			this.setLayout(new FlowLayout(FlowLayout.LEFT));
			this.setBackground(Color.lightGray);
			JSpinner js = new JSpinner();
			js.setModel(new SpinnerNumberModel(RADIUS, 5, 100, 5));
			js.addChangeListener(new ChangeListener()
			{
				@Override
				public void stateChanged(ChangeEvent e) {
					JSpinner s = (JSpinner) e.getSource();
					radius = (Integer) s.getValue();
					Node.updateRadius(nodes, radius);
					GraphPanel.this.repaint();
				}
			});
			//Adds the load from file action
			this.add(load);
			//Adds button for composing the sequence
			this.add(new JButton(compose));
			//Items in the popup menu when a user right-clicks
			popup.add(new JMenuItem(newNode));
			popup.add(new JMenuItem(color));
			popup.add(new JMenuItem(show));
			popup.add(new JMenuItem(hide));
			popup.add(new JMenuItem(delete));
			popup.add(new JMenuItem(rename));
			popup.add(new JMenuItem(clearAll));
		}
		
		/**
		 * Redraw all edges in the graph, used whenever a node is added or removed. May be a more efficient way to do this.
		 */
		private void redrawEdges() {
			edges.clear();
			for (int u = 0; u < nodes.size(); u++)
			{
				for (int uu = 0; uu < nodes.size(); uu++)
				{
					//System.out.println(nodes.get(u).getEndPosture() + " , " + nodes.get(uu).getStartPosture());
					if (nodes.get(u).getEndPosture().trim().equals(nodes.get(uu).getStartPosture().trim()))
					{
						edges.add(new Edge(nodes.get(u), nodes.get(uu)));
					}
				}
			}
		}

		/**
		 * Class for loading a pre-existent transitions graph from a txt file;
		 * syntax is one string for each line to indicate the node (or template)
		 * and one <x,y> for each line to indicate an edge (from template x,
		 * template y is reachable)
		 * 
		 * @throws FileNotFoundException
		 * @author Claudio Savaglio
		 * 
		 */
		private class LoadAction extends AbstractAction
		{
			public LoadAction(String s)
			{
				super(s);
			}

			public void actionPerformed(ActionEvent e) {
				//System.out.println("method called");
				int xLoc = 60;
				int yLoc = 60;
				BufferedReader br = null;
				String name;
				String startPosture;
				String endPosture;
				String duration;
				String transition;
				boolean durational = false;
				boolean transitional = false;
				
				//Read from ../../Tools/generated_graph.txt and handle file not found
				try
				{
					br = new BufferedReader(new InputStreamReader(new FileInputStream("../../Tools/generated_graph.txt"))); // path name changed
				}
				catch (FileNotFoundException e1)
				{
					// TODO Auto-generated catch block
					JOptionPane.showMessageDialog(null, "Did not find file ../../Tools/generated_graph.txt, please verify that the file exists", "Error", JOptionPane.ERROR_MESSAGE);
					e1.printStackTrace();
				}
				String line = null;
				StringTokenizer st = null;
				try
				{
					while ((line = br.readLine()) != null)
					{
						line = line.trim();
						if (line.length() == 0)
						{
							continue;
						}
						else if (!line.startsWith("%"))
						{
							System.out.println(line);
							Point p = mousePt.getLocation();
							p.setLocation(xLoc, yLoc);
							yLoc += 80;
							if (yLoc >= 440)
							{
								yLoc = 60;
								xLoc += 140;
							}
							Color color = control.hueIcon.getColor();
							st = new StringTokenizer(line, ",<>");
							startPosture = st.nextToken().trim();
							name = st.nextToken().trim();
							endPosture = st.nextToken().trim();
							if (!postures.contains(startPosture))
							{
								postures.add(startPosture);
							}
							if (!postures.contains(endPosture))
							{
								postures.add(endPosture);
							}
							duration = st.nextToken().trim();
							if (duration.equals("Y"))
							{
								durational = true;
							}
							transition = st.nextToken().trim();
							if (transition.equals("Y"))
							{
								transitional = true;
							}
							Node n = new Node(p, radius, color, name, startPosture, endPosture,durational,transitional);
							n.setSelected(true);
							nodes.add(n);
							durational = false;
							transitional = false;
							line = "";
						}
						else
						{
							load.setEnabled(false);
						}
					} // end of while loop
					br.close();
					redrawEdges();
				}
				catch (IOException e1)
				{
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
				//No nodes selected on startup. Repaint graph with showGraph
				Node.selectNone(nodes);
			}
		}

		/**
		 * From the transitions graph shown in the frame, create the relative
		 * text file with the known syntax @see LoadAction
		 * 
		 * Syntax:
		 * <"StartPosture" , "Movement" , "EndPosture">
		 * replace "*" with the actual name (no quotation marks)
		 * 
		 * @throws FileNotFoundException
		 * @author Claudio Savaglio
		 */
		class TextualizeAction extends AbstractAction
		{
			String dur = "N";
			String trans = "N";
			
			public TextualizeAction(String s)
			{
				super(s);
			}

			public void actionPerformed(ActionEvent e) {
				PrintStream ps = null;
				
				try
				{
					ps = new PrintStream(new FileOutputStream("../../Tools/generated_graph" + System.currentTimeMillis() + ".txt")); // changed path
				}
				catch (FileNotFoundException e1)
				{
					JOptionPane.showMessageDialog(null, "Did not find path ../../Tools/, please verify that the folder exists", "Error", JOptionPane.ERROR_MESSAGE);
					e1.printStackTrace();
				}
				
				ps.println("%Please refrain from altering this file. Instead, use the graph portion of the DiaryGenerator tool");
				ps.println("%Fields are as follows: start posture, movement name, end posture, can it be durational (Y/N), can it be transitional (Y/N)");
				
				for (int i = 0; i < nodes.size(); i++)
				{
					if(nodes.get(i).hasDurationalProperty())
					{
						dur = "Y";
						if(nodes.get(i).isTransitional())
						{
							trans = "Y";
						}
					}
					
					ps.println("<" + nodes.get(i).getStartPosture() + " , " + nodes.get(i).getName() + " , " + nodes.get(i).getEndPosture() +  " , " + dur + " , " + trans + ">");
					dur = "N";
					trans = "N";
				}
				ps.close();
			}
		}
		
		/**
		 * Clear all the existing nodes and edges
		 * 
		 * @author Claudio Savaglio
		 * 
		 */
		private class ClearAction extends AbstractAction
		{
			public ClearAction(String name)
			{
				super(name);
			}

			public void actionPerformed(ActionEvent e) {
				nodes.clear();
				edges.clear();
				repaint();
			}
		}
		
		/**
		 * Select the colors of the nodes
		 * 
		 * @author Claudio Savaglio
		 * 
		 */
		private class ColorAction extends AbstractAction
		{
			public ColorAction(String name)
			{
				super(name);
			}

			public void actionPerformed(ActionEvent e) {
				Color color = control.hueIcon.getColor();
				color = JColorChooser.showDialog(GraphPanel.this, "Choose a color", color);
				if (color != null)
				{
					Node.updateColor(nodes, color);
					control.hueIcon.setColor(color);
					control.repaint();
					repaint();
				}
			}
		}
		

		/**
		 * Shows the start and end postures below each movement node
		 */
		private class ShowPosturesAction extends AbstractAction
		{
			public ShowPosturesAction(String name)
			{
				super(name);
			}
			public void actionPerformed(ActionEvent e) {
				posturesVisible = true;
				repaint();
			}
		}
		
		/**
		 * Hides the start and end postures below each movement node
		 */
		private class HidePosturesAction extends AbstractAction
		{
			public HidePosturesAction(String name)
			{
				super(name);
			}
			public void actionPerformed(ActionEvent e) {
				posturesVisible = false;
				repaint();
			}
		}
		
		/**
		 * Remove the selected node
		 * 
		 * @author Claudio Savaglio
		 * 
		 */
		private class DeleteAction extends AbstractAction
		{
			public DeleteAction(String name)
			{
				super(name);
			}

			public void actionPerformed(ActionEvent e) {
				ListIterator<Node> iter = nodes.listIterator();
				while (iter.hasNext())
				{
					Node n = iter.next();
					if (n.isSelected())
					{
						deleteEdges(n);
						iter.remove();
					}
				}
				repaint();
			}

			private void deleteEdges(Node n) {
				ListIterator<Edge> iter = edges.listIterator();
				while (iter.hasNext())
				{
					Edge e = iter.next();
					if (e.getN1() == n || e.getN2() == n)
					{
						iter.remove();
					}
				}
			}
		}

		/**
		 * Create a new node
		 * 
		 * @author Claudio Savaglio
		 * 
		 */
		private class NewNodeAction extends AbstractAction
		{
			public NewNodeAction(String name)
			{
				super(name);
			}

			public void actionPerformed(ActionEvent e) {
				Node.selectNone(nodes);
				Point p = mousePt.getLocation();
				Color color = control.hueIcon.getColor();
				this.createNewVertice(p, color);
				redrawEdges();
				repaint();
			}

			//Prompts the user to create a new movement, and allows them to create a new posture category along the way -Hunter
			private void createNewVertice(Point pnt, Color c) {
				boolean dur,trans;
				dur = trans = false;
				String name = JOptionPane.showInputDialog(null, "Input a name for the movement", "Name the movement", JOptionPane.INFORMATION_MESSAGE);
				if(name.equals(""))
				{
					name = "Untitled";
				}
				postures.add("New");
				Object[] possibilities = postures.toArray();//{"Standing", "Sitting", "Lying", "New"};
				String start = (String) JOptionPane.showInputDialog(null, "Select the starting posture of the movement or add a new one", "Start posture", JOptionPane.PLAIN_MESSAGE, null, possibilities, postures.get(0));
				if (start == "New")
				{
					start = this.createNewPosture(JOptionPane.showInputDialog(null, "Input a name for the posture", "Name the posture", JOptionPane.QUESTION_MESSAGE));
					possibilities = postures.toArray();
				}
				String end = (String) JOptionPane.showInputDialog(null, "Select the ending posture of the movement or add a new one", "End posture", JOptionPane.PLAIN_MESSAGE, null, possibilities, postures.get(0));
				if (end == "New")
				{
					end = this.createNewPosture(JOptionPane.showInputDialog(null, "Input a name for the posture", "Name the posture", JOptionPane.QUESTION_MESSAGE));
					possibilities = postures.toArray();
				}
				
				
				int reply = JOptionPane.showConfirmDialog(null, "Is the movement durational? (Can it be done for an extended period of time continuously?)", "Durational?", JOptionPane.YES_NO_OPTION);
		        if (reply == JOptionPane.YES_OPTION) {
		        	dur = true;
		        	reply = JOptionPane.showConfirmDialog(null, "Is the movement transitional? (Do you need to do some transitional movement to get from basic postures to the movement?)", "Transitional?", JOptionPane.YES_NO_OPTION);
			        if (reply == JOptionPane.YES_OPTION) {
			          trans = true;
			        }
		        }
		        
				postures.remove(postures.size() - 1);
				Node n = new Node(pnt, radius, c, name, start, end, dur, trans);
				n.setSelected(true);
				nodes.add(n);
			}

			private String createNewPosture(String postureName) {
				//System.out.println("Creating the posture");
				postures.remove(postures.size() - 1);
				postures.add(postureName);
				postures.add("New");
				return postureName;
			}
		}

		/**
		 * From the given transitions graph, allowing data synthesis
		 * 
		 * @author Claudio Savaglio
		 * 
		 */
		private class ComposeAction extends AbstractAction
		{
			public ComposeAction(String name)
			{
				super(name);
			}

			public void actionPerformed(ActionEvent e) {
				DiaryGenerationMenu mld;
				try
				{
					PrintStream mvmntlist = new PrintStream(new FileOutputStream("../../Tools/movement_list.txt"));
					
					for(int i = 0; i<nodes.size(); i++)
					{
						if(nodes.get(i).isTransitional())
						{
							mvmntlist.println(nodes.get(i).getName() + "_transitionIn");
							mvmntlist.println(nodes.get(i).getName());
							mvmntlist.println(nodes.get(i).getName() + "_transitionOut");
						}
						else
						{
							mvmntlist.println(nodes.get(i).getName());
						}
					}
					mvmntlist.close();
					
					mld = new DiaryGenerationMenu(nodes, edges);
					mld.start();
				}
				catch (FileNotFoundException e1)
				{
					JOptionPane.showMessageDialog(null, "Did not find path ../../Tools/, please verify that the folder exists", "Error", JOptionPane.ERROR_MESSAGE);
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
				repaint();
			}
		}

		private class ColorIcon implements Icon
		{
			private static final int WIDE = 20;
			private static final int HIGH = 20;
			private Color color;

			public ColorIcon(Color color)
			{
				this.color = color;
			}

			public Color getColor() {
				return color;
			}

			public void setColor(Color color) {
				this.color = color;
			}

			public void paintIcon(Component c, Graphics g, int x, int y) {
				g.setColor(color);
				g.fillRect(x, y, WIDE, HIGH);
			}

			public int getIconWidth() {
				return WIDE;
			}

			public int getIconHeight() {
				return HIGH;
			}
		}
	}
	
}
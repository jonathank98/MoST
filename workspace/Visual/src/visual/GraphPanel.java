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
import java.util.HashMap;
import java.util.List;
import java.util.ListIterator;
import java.util.Scanner;
import java.util.StringTokenizer;

import javax.swing.*;
import javax.swing.event.*;



/**
 * Class that allows:
 * (1) to create a "transitions graph" (e.g. the rules for switching from one template to another one) graphically or loading from a file.
 * <p>
 * (2) to properly synthesize data  
 * 
 * @author John B. Matthews; distribution per GPL.
 * @author Claudio Savaglio; customization of the code and inserting new functionalities
 *  
 */
@SuppressWarnings("serial")
public class GraphPanel extends JComponent {

    private static final int WIDE = 640;
    private static final int HIGH = 480;
    private static final int RADIUS = 35;
  
    private ControlPanel control = new ControlPanel();
    private int radius = RADIUS;
    private Kind kind = Kind.Circular;
    /**
     * it contains the list of the current nodes  
     */
    private List<Node> nodes = new ArrayList<Node>();
    /**
     * it contains the list of the current selected nodes  
     */
    private List<Node> selected = new ArrayList<Node>();
    /**
     * it contains the list of the current edges  
     */
    private List<Edge> edges = new ArrayList<Edge>();
    private Point mousePt = new Point(WIDE / 2, HIGH / 2);
    private Rectangle mouseRect = new Rectangle();
    private boolean selecting = false;
    /**
     * use for creating directional edges (first selected node is the source of the edge,second selected node is the end of the edge)
     */
public static HashMap<String,Integer> hm =new HashMap<String,Integer>();
public static  int cont=1;



    public static void main(String[] args) throws Exception {
        EventQueue.invokeLater(new Runnable() {
/**
 * Set the graphical enviroment
 */
            public void run() {
                JFrame f = new JFrame("GraphPanel");
                f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
                GraphPanel gp = new GraphPanel();
                //f.add(gp.control, BorderLayout.CENTER);
               f.add(gp.control, BorderLayout.NORTH);
                f.add(new JScrollPane(gp), BorderLayout.CENTER);
             //  f.add(new JScrollPane(gp), BorderLayout.SOUTH);
              // f.getRootPane().setDefaultButton(gp.control.defaultButton);
                f.pack();
               f.setLocationByPlatform(true);
               
              //  f.setExtendedState(JFrame.MAXIMIZED_BOTH);
                f.setVisible(true);
            }
        });
    }
    /**
     * Get the angle from two points
     * @param from first point
     * @param to	second point
     * @return angle from two points
     */
    private static double getAngle(Point from,Point to)
    {
    	double  m = (to.getY() - from.getY()) / (to.getX() - from.getX());    
    	double ang = 0d;
            double w = (to.x - from.x);
            double h = (to.y - from.y);

            if ((w < 0) && (h < 0))
            {
                    ang = Math.atan(m) + Math.PI;
            }
            else if (w < 0 && h >= 0)
            {
                    ang = Math.atan(m) + Math.PI;
            }
            else if (w >= 0 && h < 0)
            {
                    ang = 2 * Math.PI + Math.atan(m);
            }
            else if (w >= 0 && h >= 0)
            {
                    ang = Math.atan(m);
            }

            return ang;
    }
    public GraphPanel() {
        this.setOpaque(true);
        this.addMouseListener(new MouseHandler());
        this.addMouseMotionListener(new MouseMotionHandler());
    }

    @Override
    public Dimension getPreferredSize() {
        return new Dimension(WIDE, HIGH);
    }

    @Override
    public void paintComponent(Graphics g) {
        g.setColor(new Color(0x00f0f0f0));
        g.fillRect(0, 0, getWidth(), getHeight());
        for (Edge e : edges) {
            e.draw(g);
        }
        for (Node n : nodes) {
            n.draw(g);
        }
        if (selecting) {
            g.setColor(Color.darkGray);
            g.drawRect(mouseRect.x, mouseRect.y,
                mouseRect.width, mouseRect.height);
        }
    }

    private class MouseHandler extends MouseAdapter {

        @Override
        public void mouseReleased(MouseEvent e) {
            selecting = false;
            mouseRect.setBounds(0, 0, 0, 0);
            if (e.isPopupTrigger()) {
                showPopup(e);
            }
            e.getComponent().repaint();
        }

       @Override
        public void mousePressed(MouseEvent e) {
            mousePt = e.getPoint();
            if (e.isShiftDown()) {
                Node.selectToggle(nodes, mousePt);
            } else if (e.isPopupTrigger()) {
                Node.selectOne(nodes, mousePt);
                showPopup(e);
            } else if (Node.selectOne(nodes, mousePt)) {
                selecting = false;
            } else {
                Node.selectNone(nodes);
                selecting = true;
            }
            e.getComponent().repaint();
        }

        private void showPopup(MouseEvent e) {
            control.popup.show(e.getComponent(), e.getX(), e.getY());
        }
    }

    private class MouseMotionHandler extends MouseMotionAdapter {

        Point delta = new Point();

        @Override
        public void mouseDragged(MouseEvent e) {
            if (selecting) {
                mouseRect.setBounds(
                    Math.min(mousePt.x, e.getX()),
                    Math.min(mousePt.y, e.getY()),
                    Math.abs(mousePt.x - e.getX()),
                    Math.abs(mousePt.y - e.getY()));
                Node.selectRect(nodes, mouseRect);
            } else {
                delta.setLocation(
                    e.getX() - mousePt.x,
                    e.getY() - mousePt.y);
                Node.updatePosition(nodes, delta);
                mousePt = e.getPoint();
            }
            e.getComponent().repaint();
        }
    }

    public JToolBar getControlPanel() {
        return control;
    }
/**
 * Toolbar for transitions graph's creation
 * @author Claudio Savaglio
 *
 */
    
    private class ControlPanel extends JToolBar {
/**
 * create a new node
 */
    	
        private Action newNode = new NewNodeAction("New");
      
        private Action clearAll = new ClearAction("Clear");
    
        private Action kind = new KindComboAction("Kind");
   
        private Action color = new ColorAction("Color");
        private Action connect = new ConnectAction("Connect");
        private Action delete = new DeleteAction("Delete");
        private Action compose = new ComposeAction("Compose Sequence");
        private Action load= new LoadAction("Load from File");
        private JButton defaultButton = new JButton(newNode);
        private Action showGraph = new ComposeAction1("Show Graph");
        //private JButton load1 = new JButton("load1");
        private JComboBox<Kind> kindCombo = new JComboBox<Kind>();
        private ColorIcon hueIcon = new ColorIcon(Color.blue);
        private JPopupMenu popup = new JPopupMenu();
        private Action rename= new TextualizeAction("Textualize Rules");
        private Action bidir=new BiConnectAction("Bidiretional Edge");

        ControlPanel() {
            this.setLayout(new FlowLayout(FlowLayout.LEFT));
            this.setBackground(Color.lightGray);

            
            //this.add(defaultButton);
           // this.add(new JButton(clearAll));
            //this.add(kindCombo);
            
           // this.add(new JButton(color));
           // this.add(new JLabel(hueIcon));
           
            JSpinner js = new JSpinner();
            js.setModel(new SpinnerNumberModel(RADIUS, 5, 100, 5));
            js.addChangeListener(new ChangeListener() {

                @Override
                public void stateChanged(ChangeEvent e) {
                    JSpinner s = (JSpinner) e.getSource();
                    radius = (Integer) s.getValue();
                    Node.updateRadius(nodes, radius);
                    GraphPanel.this.repaint();
                }
            });
           // this.add(new JLabel("Size:"));
            //this.add(js);
            this.add(load);
           // this.add(showGraph);
            
          //  this.add(load1);
            this.add(new JButton(compose));
           
            popup.add(new JMenuItem(newNode));
            popup.add(new JMenuItem(color));
            popup.add(new JMenuItem(connect));
            popup.add(new JMenuItem(delete));
            popup.add(new JMenuItem(rename));
            popup.add(new JMenuItem(bidir));
            JMenu subMenu = new JMenu("Kind");
            for (Kind k : Kind.values()) {
                kindCombo.addItem(k);
                subMenu.add(new JMenuItem(new KindItemAction(k)));
            }
            popup.add(subMenu);
            kindCombo.addActionListener(kind);
        }
/**
 * Class for loading a pre-existent transitions graph from a txt file; 
 * syntax is one string for each line to indicate the node (or template) and one <x,y> for each line to indicate an edge (from template x, template y is reachable)
 *  
 *   @throws FileNotFoundException  
 *   change the default name of the input text file!
 * @author Claudio Savaglio
 *
 */
        

			
			
        
	private class LoadAction extends AbstractAction{
        	public LoadAction(String s){
        		super(s);
        	}
        	public void actionPerformed(ActionEvent e) {
        		System.out.println("metodi chiamato");
        		BufferedReader br = null;String name1,name2;
        		//repaint();
        		//revalidate();
				try {
					br = new BufferedReader(new InputStreamReader(new FileInputStream("../../Tools/generated_graph.txt"))); // path name changed
				} catch (FileNotFoundException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
				String line=null;StringTokenizer st=null;
				try {
					while ((line = br.readLine()) != null) {
						if(!line.startsWith("<")&&!line.startsWith("%")) {
							System.out.println(line);
					    Point p = mousePt.getLocation();
					    p.setLocation(320*Math.random(), 240*Math.random());
					    System.out.println("point "+p.getX()+p.getY());
					    Color color = control.hueIcon.getColor();
					    System.out.println("colore ok");
					    Node n = new Node(p, radius, color, Kind.Square,line);
					    System.out.println("nodo creato "+n.getName());
					    n.setSelected(true);
					    nodes.add(n);
					    line="";System.out.println("nodo aggiutnop");
					    //repaint();
					    
					    System.out.println("repasint");}
						else{
							if(!line.startsWith("%")){
							Node.getSelected(nodes, selected);
							st=new StringTokenizer(line,",<>");
							name1=st.nextToken().trim();name2=st.nextToken().trim();
							System.out.println("arco"+ name1+"@"+name2);
							System.out.println("sel size "+selected.size());
							for(int u=0;u<selected.size();u++){
								if(selected.get(u).getName().trim().equals(name1)){
									System.out.println("trovato1 "+selected.get(u).getName());
									for(int uu=0;uu<selected.size();uu++){
										if(selected.get(uu).getName().equals(name2)){
											System.out.println("trovato2 "+selected.get(uu).getName());
									edges.add(new Edge(selected.get(u),selected.get(uu))); 
									//repaint();
									System.out.println("aggiunto"+ selected.get(u).getName()+"-"+selected.get(uu).getName());
									break;}}
								}
														
							}
						
					   // repaint(); 
					    load.setEnabled(false);
					System.out.println("esco");}}//else
						
						//control.repaint();
						//repaint();
						//revalidate();
						
						}
					//JOptionPane.showMessageDialog(null,"ok");
				br.close();
				 //Action showGraph = new ComposeAction1("Show Graph");
				 } catch (IOException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
				showGraph.actionPerformed(e);
				
					//repaint();
				
				//repaint();
				System.out.println("here-tery");
				
			
        	}
    		    		       		
        		
        }
        /**
         * From the transitions graph showed in the frame, create the relative text file with the known syntax @see LoadAction
         *   @throws FileNotFoundException  change the default name of the output text file!
         * 
         * @author Claudio Savaglio
         *
         */
           
         class TextualizeAction extends AbstractAction{
        	public TextualizeAction(String s){
        		super(s);
        	}
        	public void actionPerformed(ActionEvent e) {
        		PrintStream ps = null;
				try {
					ps = new PrintStream(new FileOutputStream("../../Tools/generated_graph"+System.currentTimeMillis()+".txt"));  // changed path
				} catch (FileNotFoundException e1) {
					
					e1.printStackTrace();
				}
				
    		    		       		
        		for(int i=0;i<nodes.size();i++) ps.println(nodes.get(i).getName());
        		for(int j=0;j<edges.size();j++) ps.println(edges.get(j).getVertex());
        		ps.close();
        	}
        }
        /**
         * Select the shape of the nodes
         * @author Claudio Savaglio
         *
         */
        class KindItemAction extends AbstractAction {

            private Kind k;

            public KindItemAction(Kind k) {
                super(k.toString());
                this.k = k;
            }

            @Override
            public void actionPerformed(ActionEvent e) {
                kindCombo.setSelectedItem(k);
            }
        }
    }
/**
 * Clear all the existing nodes and edges
 * @author Claudio Savaglio
 *
 */
    private class ClearAction extends AbstractAction {

        public ClearAction(String name) {
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
     * @author Claudio Savaglio
     *
     */
    private class ColorAction extends AbstractAction {

        public ColorAction(String name) {
            super(name);
        }

        public void actionPerformed(ActionEvent e) {
            Color color = control.hueIcon.getColor();
            color = JColorChooser.showDialog(
                GraphPanel.this, "Choose a color", color);
            if (color != null) {
                Node.updateColor(nodes, color);
                control.hueIcon.setColor(color);
                control.repaint();
                repaint();
            }
        }
    }
    /**
     * Create a directional edge between two selected nodes (click for selecting the source node, click+shift for selecting the ending node)
     * @author Claudio Savaglio
     *
     */
    private class ConnectAction extends AbstractAction {

        public ConnectAction(String name) {
            super(name);
        }

        public void actionPerformed(ActionEvent e) {
            Node.getSelected(nodes, selected);
            if (selected.size() > 1) {
                for (int i = 0; i < selected.size() - 1; ++i) {
                    Node n1 = selected.get(i);
                    Node n2 = selected.get(i + 1);
                  //  System.out.println("1+"+n1.getName()+","+hm.get(n1.getName()+" - 2"+n2.getName()+" ,"+hm.get(n2.getName())));
                    if(hm.get(n1.getName())<hm.get(n2.getName()))
                    edges.add(new Edge(n1, n2));
                    else edges.add(new Edge(n2, n1));
                    hm.clear(); Node.selectNone(selected);
                }
            }
            repaint(); 
        }
    }
    
    /**
     * Create a bidirectional edge between two selected nodes (click for selecting a node, click+shift for selecting other node)
     * @author Claudio Savaglio
     *
     */
    private class BiConnectAction extends AbstractAction {

        public BiConnectAction(String name) {
            super(name);
        }

        public void actionPerformed(ActionEvent e) {
            Node.getSelected(nodes, selected);
            if (selected.size() > 1) {
                for (int i = 0; i < selected.size() - 1; ++i) {
                    Node n1 = selected.get(i);
                    Node n2 = selected.get(i + 1);
                    edges.add(new Edge(n1, n2));
                    edges.add(new Edge(n2,n1));
                    Node.selectNone(selected);
                }
            }
            repaint();
        }
    }
    /**
     * Remove the selected node
     * @author Claudio Savaglio
     *
     */
    private class DeleteAction extends AbstractAction {

        public DeleteAction(String name) {
            super(name);
        }

        public void actionPerformed(ActionEvent e) {
            ListIterator<Node> iter = nodes.listIterator();
            while (iter.hasNext()) {
                Node n = iter.next();
                if (n.isSelected()) {
                    deleteEdges(n);
                    iter.remove();
                }
            }
            repaint();
        }

        private void deleteEdges(Node n) {
            ListIterator<Edge> iter = edges.listIterator();
            while (iter.hasNext()) {
                Edge e = iter.next();
                if (e.n1 == n || e.n2 == n) {
                    iter.remove();
                }
            }
        }
    }
    /**
     * Change teh shape of an existing selected node
     * @author Claudio Savaglio
     *
     */
    private class KindComboAction extends AbstractAction {

        public KindComboAction(String name) {
            super(name);
        }

        public void actionPerformed(ActionEvent e) {
            JComboBox<?> combo = (JComboBox<?>) e.getSource();
            kind = (Kind) combo.getSelectedItem();
            Node.updateKind(nodes, kind);
            repaint();
        }
    }
/**
 * Create a new node
 * @author Claudio Savaglio
 *
 */
    
    private class NewNodeAction extends AbstractAction {

        public NewNodeAction(String name) {
            super(name);
        }

        public void actionPerformed(ActionEvent e) {
            Node.selectNone(nodes);
            Point p = mousePt.getLocation();
            Color color = control.hueIcon.getColor();
            Node n = new Node(p, radius, color, kind);
            n.setSelected(true);
            nodes.add(n);
            repaint();
        }
    }
/**
 * From the given transitions graph, allowing data synthesis
 * @author Claudio Savaglio
 *
 */
    private class ComposeAction extends AbstractAction {

        public ComposeAction(String name) {
            super(name);
        }

        public void actionPerformed(ActionEvent e) {
          MenuLayoutDemo2 mld;
		try {
			mld = new MenuLayoutDemo2(nodes,edges); 
			mld.start();
		} catch (FileNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
         
          
            repaint();
        }
    }

    
    private class ComposeAction1 extends AbstractAction {

        public ComposeAction1(String name) {
            super(name);
        }

 
          
            //repaint();
    	@Override
		public void actionPerformed(ActionEvent arg0) {
			 repaint();
			// TODO Auto-generated method stub
			
		}


		
     
    }

    /**
     * The kinds of node in a graph.
     */
    public enum Kind {

        Circular, Rounded, Square;
    }

    /**
     * An Edge is a pair of Nodes.
     */
    public static class Edge {

        private Node n1;
        private Node n2;

        public Edge(Node n1, Node n2) {
            this.n1 = n1;
            this.n2 = n2;
        }
         public String getVertex(){return ("<"+n1.getName()+" , "+n2.getName()+">");  
         }
        
        public void draw(Graphics g) {
            Point p1 = n1.getLocation();
            Point p2 = n2.getLocation();
           
            
            @SuppressWarnings("unused")
			double ang = getAngle(p1,p2);
            g.setColor(Color.RED);
           // g.drawLine(p1.x, p1.y, p2.x, p2.y);
           /*
            double sxx=p2.x-Node.r-10+ LEN * Math.cos(ang+ANGLE_SX);
            double sxy=p2.y-Node.r-10+ LEN * Math.cos(ang+ANGLE_SX);
            double dxx=p2.x-Node.r-10+ LEN * Math.cos(ang+ANGLE_DX);
            double dxy=p2.y-Node.r-10+ LEN * Math.cos(ang+ANGLE_DX);
            g.setColor(Color.RED);
            g.drawLine((int) p2.x-Node.r-10, (int) p2.y-Node.r-10, (int) Math.round(sxx), (int)Math.round(sxy));
            g.drawLine((int) p2.x-Node.r-10, (int) p2.y-Node.r-10, (int) Math.round(dxx), (int) Math.round(dxy));
          */
            drawArrow(g,p1.x,p1.y,p2.x-Node.getR(),p2.y-Node.getR(),15,15);
        }
        
        public String getV1(){return n1.getName();}
        public String getV2(){return n2.getName();}

    }

    /**
     * A Node represents a node in a graph.
     */
    public static class Node {

        private Point p;
        private static int r;
        private Color color;
        private Kind kind;
        private boolean selected = false;
        private Rectangle b = new Rectangle();
        private String name;
        Scanner sc = new Scanner(System.in);
        /**
         * Construct a new node.
         */
        public Node(Point p, int r, Color color, Kind kind) {
            this.p = p;
            this.setR(r);
            this.color = color;
            this.kind = kind;
            name=sc.nextLine();
            setBoundary(b);
        }
        public Node(Point p, int r, Color color, Kind kind,String nome) {
            this.p = p;
            this.setR(r);
            this.color = color;
            this.kind = kind;
            name=nome;
            setBoundary(b);
        }
        
public String getName(){return name;}
public Node getFromName(String name){if(this.name.equals(name))return this; else return null;}
        /**
         * Calculate this node's rectangular boundary.
         */
        private void setBoundary(Rectangle b) {
            b.setBounds(p.x - getR(), p.y - getR(), 2 * getR(), 2 * getR());
        }

        /**
         * Draw this node.
         */
        public void draw(Graphics g) {
            g.setColor(this.color);
            g.drawString(name, b.x, b.y);
            if (this.kind == Kind.Circular) {
                g.fillOval(b.x, b.y, b.width, b.height);
            } else if (this.kind == Kind.Rounded) {
                g.fillRoundRect(b.x, b.y, b.width, b.height, getR(), getR());
            } else if (this.kind == Kind.Square) {
                g.fillRect(b.x, b.y, b.width, b.height);
            }
            if (selected) {
                g.setColor(Color.darkGray);
                g.drawRect(b.x, b.y, b.width, b.height);
            }
        }

        /**
         * Return this node's location.
         */
        public Point getLocation() {
            return p;
        }

        /**
         * Return true if this node contains p.
         */
        public boolean contains(Point p) {
            return b.contains(p);
        }

        /**
         * Return true if this node is selected.
         */
        public boolean isSelected() {
            return selected;
        }

        /**
         * Mark this node as selected.
         */
        public void setSelected(boolean selected) {
            this.selected = selected;
        }

        /**
         * Collected all the selected nodes in list.
         */
        public static void getSelected(List<Node> list, List<Node> selected) {
            selected.clear();
            for (Node n : list) {
                if (n.isSelected()) {
                    selected.add(n);
                }
            }
        }

        /**
         * Select no nodes.
         */
        public static void selectNone(List<Node> list) {
            for (Node n : list) {
                n.setSelected(false);
            }
        }

        /**
         * Select a single node; return true if not already selected.
         */
        public static boolean selectOne(List<Node> list, Point p) {
            for (Node n : list) {
                if (n.contains(p)) {
                    if (!n.isSelected()) {
                        Node.selectNone(list);
                        n.setSelected(true);
                       hm.put(n.getName(),cont);
                       //System.out.println(n.getName()+"="+cont);
                       
                    }
                    return true;
                }
            }
            return false;
        }

        /**
         * Select each node in r.
         */
        public static void selectRect(List<Node> list, Rectangle r) {
            for (Node n : list) {
                n.setSelected(r.contains(n.p));
            }
        }

        /**
         * Toggle selected state of each node containing p.
         */
        public static void selectToggle(List<Node> list, Point p) {
        	int cont2=2;
            for (Node n : list) {
                if (n.contains(p)) {
                    n.setSelected(!n.isSelected());
                   hm.put(n.getName(),cont2);
                   // System.out.println("toogle "+n.getName()+"="+cont2);
                }
            }
        }

        /**
         * Update each node's position by d (delta).
         */
        public static void updatePosition(List<Node> list, Point d) {
            for (Node n : list) {
                if (n.isSelected()) {
                    n.p.x += d.x;
                    n.p.y += d.y;
                    n.setBoundary(n.b);
                }
            }
        }

        /**
         * Update each node's radius r.
         */
        public static void updateRadius(List<Node> list, int r) {
            for (Node n : list) {
                if (n.isSelected()) {
                    n.setR(r);
                    n.setBoundary(n.b);
                }
            }
        }

        /**
         * Update each node's color.
         */
        public static void updateColor(List<Node> list, Color color) {
            for (Node n : list) {
                if (n.isSelected()) {
                    n.color = color;
                }
            }
        }

        /**
         * Update each node's kind.
         */
        public static void updateKind(List<Node> list, Kind kind) {
            for (Node n : list) {
                if (n.isSelected()) {
                    n.kind = kind;
                }
            }
        }
		public static int getR() {
			return r;
		}
		public void setR(int r) {
			Node.r = r;
		}
    }

    private static class ColorIcon implements Icon {

        private static final int WIDE = 20;
        private static final int HIGH = 20;
        private Color color;

        public ColorIcon(Color color) {
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
     /**
      * Obtain an arrow connecting 2 points
      * @param g Graphics element
      * @param x0 start point x
      * @param y0 start point y
      * @param x1 end point x
      * @param y1 end point y
      */
     static public void drawArrow(Graphics g, int x0, int y0, int x1, int y1,
             int headLength, int headAngle) {
         double offs = headAngle * Math.PI / 180.0;
         double angle = Math.atan2(y0 - y1, x0 - x1);
         int[] xs = { x1 + (int) (headLength * Math.cos(angle + offs)), x1,
             x1 + (int) (headLength * Math.cos(angle - offs)) };
         int[] ys = { y1 + (int) (headLength * Math.sin(angle + offs)), y1,
             y1 + (int) (headLength * Math.sin(angle - offs)) };
         g.drawLine(x0, y0, x1, y1);
         g.drawPolyline(xs, ys, 3);
         
     }
     
}
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintStream;
import java.util.Vector;

/**
 * Generate the indices of the frame that will be used by Untitled2.m script for generating video, change the path of the file in which those indices are saved!
 * @throws FileNotFoundException change the path of the file
 * @author Claudio Savaglio
 *
 */
public class MI {
static Vector<Integer> frame;
	public MI(int a,int b){
		System.out.println("creo");
frame=new Vector<Integer>();		
frame.add(a);
frame.add(b);}
	public static void addFrame(int c,int d){
frame.add(c);
	frame.add(d);
	//System.out.println("add "+c+","+d);
}
	
	public static void getFinal(int totalAnnotations) throws FileNotFoundException{
		System.out.println("chiamato finale");
		
		PrintStream ps = new PrintStream(new FileOutputStream("../../Utility/indices.txt"));
		
		for(int y=0;y<totalAnnotations;y++) {
			ps.println(frame.elementAt(y));
		}
	ps.close();
	}
}
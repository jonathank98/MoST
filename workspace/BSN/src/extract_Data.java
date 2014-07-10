import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.util.StringTokenizer;
import java.util.Vector;
/**
 * Class that select a subset of lines and frames from the relative stream data/video files, realizing the annotation phase
 * At the end, it runs test2.bat that will launch the matlab script for creating video from frames
 * @author Claudio Savaglio
 *
 */
public class extract_Data {

	@SuppressWarnings("unused")
	public extract_Data(int pos1, int pos2, File[] f, boolean flag,int numAnnotation,int totalAnnotations)
			throws IOException {

		// data extracted is supposed to belong to well-format file (without
		// first line textual description and complete last line)

		BufferedReader br = null;
		int cont = 1;
		int cont2 = 0;
		Vector<String> v = new Vector<String>();

		StringTokenizer st;
		String linea = "";

		String analizzato = "";
		PrintStream ps;
		for (int index = 0; index < f.length; index++) {
			// ricopio il contenuto se serve
			/*if (!flag) {
System.out.println("secondo ");
				BufferedReader br2 = new BufferedReader(new InputStreamReader(
						new FileInputStream(f[index].getParent()
								+ "\\annotated_" +(index)+"@" + f[index].getName())));
				while ((linea = br2.readLine()) != null) {
					v.add(linea);
					linea = "";
				}
				br2.close();
				System.out.println("ricopio, v ha elementi " + v.size());
			}*/
			br = new BufferedReader(new InputStreamReader(new FileInputStream(
					"" + f[index].getAbsolutePath())));
			System.out.println("Extracting Datad from  files "
					+ f[index].getAbsolutePath());

			// Read file and save in a Vector
			while ((linea = br.readLine()) != null) {

				if (cont2 >= pos1 & cont2 <= pos2) {
					v.add(linea);
					cont2++;

				} else
					cont2++;
				
			}
			br.close();
			linea = "";

			// Write everything

			ps = new PrintStream(new FileOutputStream(f[index].getParent()
					+ "\\annotated_"+((numAnnotation/2)+1)+"@" + f[index].getName()));
			for (int x = 0; x < v.size(); x++) {
				ps.println((String) v.elementAt(x));
			}
			ps.close();
			v.clear();
			linea = "";
			cont2 = 0;
				
		
		}
		//extract relative video 
		double d1=pos1;
		d1=d1/200;
		double d2=pos2;
		d2=d2/200;
		System.out.println(d1+"'"+d2);
		int frame_starting=(int) Math.floor((d1*15));
		if(frame_starting<1) frame_starting=1;
		int frame_ending=(int) Math.ceil((d2*15));
		//first invocation (NumAnnotation==0) create MI and save the first 2 indices, other invocations save other frames, last invocation launch the matlab script 
		//ita translating :il primo apre una finestra,gli altri indici vengono accumulati e viene lanciato un nuovo script matlab con tutti gli indici
		
		if(numAnnotation==0){ MI mi=new MI(frame_starting,frame_ending);
		
		if(totalAnnotations==2) { //handle case of just one annotation 
			MI.getFinal(totalAnnotations);
		//launch the matlab script
			//System.out.println(new File(".").getCanonicalPath());
	String [] cmds =  { "../../Utility/test2.bat" , "\\c" ,String.valueOf(totalAnnotations) };
	Process p = Runtime.getRuntime().exec(cmds);}
		
		
		
		//String [] cmds =  { "C:/Documents and Settings/cxs135030/Desktop/test.bat" , "\\c" , String.valueOf(frame_starting), String.valueOf(frame_ending),String.valueOf(numAnnotation) };
		//cmds[0] = "C:/Documents and Settings/cxs135030/Desktop/test.bat";
		//Process p = Runtime.getRuntime().exec(cmds);
		
			//p.waitFor();
			//Erasing c1=new Erasing("C:/Documents and Settings/cxs135030/Desktop/frames/");
		}
		else {
			MI.addFrame(frame_starting,frame_ending);
		if(numAnnotation==(totalAnnotations-2)){ 
			System.out.println("total Annotations ="+totalAnnotations);
			MI.getFinal(totalAnnotations);//devo lanciare un nuovo process con un nuovo cmds
			//launch the matlab script
		String [] cmds =  { "../../Utility/test2.bat" , "\\c" ,String.valueOf(totalAnnotations) };
		Process p = Runtime.getRuntime().exec(cmds);
		}
		}
	}}



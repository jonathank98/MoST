
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.StringTokenizer;
import java.util.Vector;
 /**
  * Class for reading the annotations created by VibMotions2 and saved in the default txt file
  * @see getIndices returns the indices, output of annotation pahse in VibMotions2
  * @author Claudio Savaglio
  *
  */
public class extract_Index {

	Vector<Integer> indices = new Vector<Integer>();

	public extract_Index(File f) throws IOException {

		// data extracted is supposed to belong to well-format file (without
		// first line textual description and complete last line)

		BufferedReader br = null;
		int cont = 0;
		
		
		System.out.println("Extract Indices from files " + f.getAbsolutePath());
		StringTokenizer st;
		String linea = "";
		String analizzato = "";
	
		Integer temp;

		br = new BufferedReader(new InputStreamReader(new FileInputStream(""
				+ f.getAbsolutePath())));

		// Read all the file and save it in a Vector
		while ((linea = br.readLine()) != null) {

			st = new StringTokenizer(linea, ",");

			while (st.hasMoreTokens()) {
				analizzato = st.nextToken();

				if (cont % 2 == 0) {

					temp = new Integer(analizzato);
					// System.out.println(analizzato+" * "+cont+" * "+temp);
					indices.addElement(temp);
				}
				cont++;
			}
		}

		br.close();

		
	}
/**
 * 
 * @return returns the indices Vector, output of annotation pahse in VibMotions2
 */
	public Vector<Integer> getIndices() {

		// for(int x=0; x<indices.size(); x++)
		// System.out.println(indices.elementAt(x));
		return indices;

	}

}

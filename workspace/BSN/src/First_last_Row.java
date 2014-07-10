import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.util.Vector;
/**
 * Class for remove first line (header , string made by "AccX AccY...") and the last line (if incomplete) from the text files selected 
 * @author Claudio Savaglio
 *
 */
public class First_last_Row {

	public First_last_Row(File[] f) throws IOException {

		BufferedReader br = null;
		File[] files = null;
		files = f;
		Vector<String> v = new Vector<String>();
		System.out.println("Analyzing files " + files.length);
		for (int i = 0; i < files.length; i++) {

			br = new BufferedReader(new InputStreamReader(new FileInputStream(
					"" + files[i].getAbsolutePath())));
			System.out.println("analyzing file " + files[i].getAbsolutePath());
			// Conterrà tutte le righe del file
			String linea = "";

			// Leggo tutto il file e lo memorizzo nel Vector
			while ((linea = br.readLine()) != null) {
				v.add(linea);
			}
			br.close();

			// Ora riscrivo tutto, tranne l'ultima riga
			PrintStream ps = new PrintStream(new FileOutputStream(""
					+ files[i].getAbsolutePath()));
			int index1 = 0;
			int index2 = v.size();
			System.out.println(index1 + "-" + index2);
			if (v.elementAt(0).contains("Acc"))
				index1 = 1;
			if (isIncomplete(v.elementAt(v.size() - 1)))
				index2 = (v.size() - 1);
			for (int x = index1; x < index2; x++) {
				ps.println((String) v.elementAt(x));
			}
			ps.close();
			v.clear();
			linea = "";
		}
System.out.println("COMPLETE");
	}

	public boolean isIncomplete(String finale) {

		if (finale.length() < 45)
			return true;
		else
			return false;
	}

}

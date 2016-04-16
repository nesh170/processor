import java.io.*;
public class color_gen {
	public static void main(String[] args) throws IOException {
		BufferedReader buffer = new BufferedReader(new FileReader("color.txt"));
		BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(new File("color_palette.mif"))));
		try {
			
			writer.write("WIDTH = 24;");
			writer.newLine();
			writer.write("DEPTH = 256;");
			writer.newLine();
			writer.newLine();
			writer.write("ADDRESS_RADIX = UNS;");
			writer.newLine();
			writer.write("DATA_RADIX = HEX;");
			writer.newLine();
			writer.newLine();
			writer.write("CONTENT BEGIN");
			writer.newLine();
			String line;
			int i = 0;
			while ((line = buffer.readLine()) != null) {
				writer.write(i + " : ");
				writer.write(line);
				writer.write(";");
				writer.newLine();
				i = i + 1;
			}
			writer.write("END;");

		}
		catch (IOException exception) {
			exception.printStackTrace();
		}
		finally {
			try{
			buffer.close();
			writer.close();
		}
		catch (IOException except) {
			except.printStackTrace();
		}
		}
	}



}
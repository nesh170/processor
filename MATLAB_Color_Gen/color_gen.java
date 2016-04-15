import java.io.*;
public class color_gen {
	public static void main(String[] args) throws IOException {
		BufferedReader buffer = new BufferedReader(new FileReader("color.txt"));
		try {
			String line;
			while ((line = buffer.readLine()) != null) {
				System.out.println(line);
			}


		}
		catch (IOException exception) {
			exception.printStackTrace();
		}
		finally {
			try{
			buffer.close();
		}
		catch (IOException except) {
			except.printStackTrace();
		}
		}
	}



}
import java.io.*;
import java.util.*;
import java.lang.*;
import javax.xml.transform.*;
import javax.xml.transform.stream.*;

class ArgoUMLTest {

  public static void main(String[] args) {

    try {
        
      Source xmlInput = new StreamSource(new File("proj8.xmi"));
      Source xsl = new StreamSource(new File("OWLfromUML.xsl"));
      Result xmlOutput = new StreamResult(new File("C:\\output\\outputfile.xml"));
  

      Transformer transformer = TransformerFactory.newInstance().newTransformer(xsl);
      long start = System.currentTimeMillis();
      transformer.transform(xmlInput, xmlOutput);
      long elapsed = System.currentTimeMillis() - start;

      System.out.println(elapsed);

    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}
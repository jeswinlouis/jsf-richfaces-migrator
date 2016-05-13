package pl.edu.pw.ii.migration;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.Parameter;
import org.richfaces.resource.Xcss2EcssConverter;
import org.xml.sax.SAXException;

import javax.xml.parsers.ParserConfigurationException;
import java.io.IOException;

public class Xcss2Ecss {

    @Parameter(names =  { "--file", "-f" }, description = "File to process")
    private String file;

    @Parameter(names = { "--help", "-h" }, help = true)
    private boolean help;

    public static void main(String[] args) throws IOException, SAXException, ParserConfigurationException {
        Xcss2Ecss xcss2Ecss = new Xcss2Ecss();
        JCommander jCommander = new JCommander(xcss2Ecss, args);
        if(xcss2Ecss.help){
            jCommander.usage();
            return;
        }
        Xcss2EcssConverter.main(new String[] {xcss2Ecss.file});
    }
}

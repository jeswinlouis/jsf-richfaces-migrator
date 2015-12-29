package pl.edu.pw.ii.migration;

import org.richfaces.resource.Xcss2EcssConverter;
import org.xml.sax.SAXException;

import javax.xml.parsers.ParserConfigurationException;
import java.io.IOException;

/**
 * Created by mwasi_000 on 28.12.2015.
 */
public class Xcss2Ecss {

    public static void main(String[] args) throws IOException, SAXException, ParserConfigurationException {
        Xcss2EcssConverter.main(new String[] {"D:\\DEV\\omegapsir\\experimental\\repo-jsf-migrator\\theme.xcss"});
    }
}

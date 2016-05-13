package pl.edu.pw.ii.migration;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.Parameter;
import com.typesafe.config.Config;
import com.typesafe.config.ConfigFactory;
import org.apache.commons.lang3.StringUtils;
import org.xml.sax.SAXException;

import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.nio.file.Files;
import java.util.*;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.*;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import static pl.edu.pw.ii.migration.AppConfig.*;

public class Main {

    @Parameter(names =  { "--configFile", "-c" }, description = "Custom config file location")
    private String configFileParam;

    @Parameter(names =  { "--webContentPath", "-wcp" }, description = "Web content path with files to process. Takes precedence over value from config file")
    private String webContentPathParam;

    @Parameter(names = { "--help", "-h" }, help = true)
    private boolean help;

    public static void main(String[] args) throws TransformerException, IOException, ParserConfigurationException, SAXException {
        Main main = new Main();
        JCommander jCommander = new JCommander(main, args);
        if(main.help){
            jCommander.usage();
            return;
        }
        main.run();
    }

    private void run() throws ParserConfigurationException, TransformerException, SAXException, IOException {
        initConfiguration();

        File[] files = getFilesToProcess();

        processFiles(files);
    }

    private void processFiles(File[] files) throws IOException, TransformerException, ParserConfigurationException, SAXException {
        TransformerFactory factory = TransformerFactory.newInstance();
        Source xslt = new StreamSource(ClassLoader.getSystemResourceAsStream("migration.xslt"));
        Templates templates = factory.newTemplates(xslt);
        xsltTransform(files, templates, recursive);
    }

    private File[] getFilesToProcess() {
        File webContentPathFile = new File(webContentPath);
        File[] files = null;
        if(webContentPathFile.isDirectory()){
            files = webContentPathFile.listFiles();
        }else{
            files = new File[]{webContentPathFile};
        }
        return files;
    }

    private void initConfiguration() {

        Config config = ConfigFactory.load();
        File customConfigFile = new File(configFileParam);
        if(customConfigFile.isFile()){
            Config customConfig = ConfigFactory.parseFile(customConfigFile);
            config = customConfig.withFallback(config);
        }

        AppConfig.read(config);

        if(StringUtils.isNotBlank(webContentPathParam)){
            webContentPath = webContentPathParam;
        }
        System.setProperty("javax.xml.transform.TransformerFactory", "net.sf.saxon.TransformerFactoryImpl");
    }

     private void xsltTransform(File[] files, final Templates templates, boolean recursive) throws IOException, TransformerException, ParserConfigurationException, SAXException {
        Arrays.stream(files).parallel().forEach(file -> {
            try {
                String name = file.getName();
                if (file.isDirectory() && !ignoredDirNames.contains(name)) {
                    if (recursive) {
                        xsltTransform(file.listFiles(), templates, recursive);
                    }
                    return;
                }
                trnasformFile(templates, file);
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
    }

    private void trnasformFile(Templates templates, File file) throws ParserConfigurationException, IOException, TransformerException {
        Transformer transformer = templates.newTransformer();

        String filename = file.getName();
        String ext_file = filename.substring(filename.lastIndexOf(".") + 1, filename.length());
        String ext = "xhtml";
        String oldFileName = file.getParent() +"/"+ oldFileBackupPrefix + filename;
        File oldName = new File(oldFileName);
        if (ext.equals(ext_file) && !filename.startsWith(oldFileBackupPrefix)) {
            if (!oldName.exists() && createOldFileBackup) {
                FileUtil.copyFile(file, oldName);
            }else if(notMigratedOnly){
                return;
            }

            String text = new String(Files.readAllBytes(oldName.toPath()));
            text = replaceStrings(text);

            Source source = new StreamSource(new StringReader(text));
            System.out.println("XSLT transformation started: "+file.getAbsolutePath());
            StreamResult result = new StreamResult(file);
//                    Document doc = db.parse(new FileInputStream(oldName));
            transformer.transform(source, result);
            System.out.println("XSLT transformed file: "+file.getAbsolutePath());
        }
    }

    private String replaceStrings(String text) {
        String result = text;
        for (Map.Entry<String, String> e : stringsToReplace.entrySet()) {
            result = result.replaceAll(e.getKey(), e.getValue());
        }
        return result;
    }
}
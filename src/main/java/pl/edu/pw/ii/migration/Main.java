package pl.edu.pw.ii.migration;

import org.xml.sax.EntityResolver;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.nio.file.Files;
import java.util.*;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.*;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

public class Main {

    public static final boolean ONLY_NOT_MIGRATED = false;
    public static final boolean RECURSIVE = true;
    //    private static String WEB_CONTENT_PATH = "D:\\DEV\\omegapsir\\experimental\\migration test\\webapp";
//    private static String WEB_CONTENT_PATH = "D:\\DEV\\omegapsir\\experimental\\framework-parent\\framework-resources\\src\\main\\resources\\webapp\\layout";
    private static String WEB_CONTENT_PATH = "D:\\DEV\\omegapsir\\experimental\\itm-parent\\itm-war\\src\\main\\webapp\\customized";
//    private static String WEB_CONTENT_PATH = "D:\\DEV\\omegapsir\\experimental\\migration test\\test";

    public static Map<String, String> stringsToReplace = new HashMap<>();
    public static Set<String> ignoredDirNames = new HashSet<>(Arrays.asList("sorttemplates"));

    static {
        stringsToReplace.put("http://jboss.com/products/seam/taglib", "http://jboss.org/schema/seam/taglib");
        stringsToReplace.put("http://java.sun.com/jstl/core", "http://java.sun.com/jsp/jstl/core");
    }

    public static void main(String[] args) throws TransformerException, IOException, ParserConfigurationException, SAXException {
        System.setProperty("javax.xml.transform.TransformerFactory", "net.sf.saxon.TransformerFactoryImpl");
        System.out.println("Start");
        System.out.println(WEB_CONTENT_PATH);

		/* 3. Tranformation xhtml */
        System.out.println("     BEGIN XHTML ");
        File[] files = new File(WEB_CONTENT_PATH).listFiles();
        TransformerFactory factory = TransformerFactory.newInstance();
        Source xslt = new StreamSource(new File("D:\\DEV\\omegapsir\\experimental\\repo-jsf-migrator\\src\\main\\resources\\migration.xslt"));
        Templates templates = factory.newTemplates(xslt);

        xsltTransform(files, templates, RECURSIVE);
        System.out.println("     END XHTML Files");
        System.out.println("END TRANSFORMATIONS");
    }

    public static void xsltTransform(File[] files, final Templates templates, boolean recursive) throws IOException, TransformerException, ParserConfigurationException, SAXException {
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

  /*      for (File file : files) {
            if (file.isDirectory()) {
//                xsltTransform(file.listFiles(), transformer); // Recursive.
            }
            else {

                trnasformFile(transformer, file);
            }
        }*/
    }

    private static void trnasformFile(Templates templates, File file) throws ParserConfigurationException, IOException, TransformerException {
//        DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
//        DocumentBuilder db = dbFactory.newDocumentBuilder();
//        db.setEntityResolver(new EntityResolver() {
//
//            public InputSource resolveEntity(String publicId, String systemId) throws SAXException, IOException {
//                return null; // Never resolve any IDs
//            }
//        });
        Transformer transformer = templates.newTransformer();

        String filename = file.getName();
        String ext_file = filename.substring(filename.lastIndexOf(".") + 1, filename.length());
        String ext = "xhtml";
        String oldFileName = file.getParent() + "\\old_" + filename;
        File oldName = new File(oldFileName);
        if (ext.equals(ext_file) && !filename.startsWith("old")) {
            System.out.println("File: " + file.getAbsolutePath());
            if (!oldName.exists()) {

                FileUtil.copyFile(file, oldName);
                System.out.println("Copy old file");
//						FileUtil.deleteLines(oldFileName, 1, 1);
            }else if(ONLY_NOT_MIGRATED){
                return;
            }

            String text = new String(Files.readAllBytes(oldName.toPath()));
            text = replaceStrings(text);


            Source source = new StreamSource(new StringReader(text));
            System.out.println("Debut transformation XSLT");
            StreamResult result = new StreamResult(file);
//                    Document doc = db.parse(new FileInputStream(oldName));
            transformer.transform(source, result);
            System.out.println("Fin transformation");
        }
    }

    private static String replaceStrings(String text) {
        String result = text;
        for (Map.Entry<String, String> e : stringsToReplace.entrySet()) {
            result = result.replaceAll(e.getKey(), e.getValue());
        }
        return result;
    }
}
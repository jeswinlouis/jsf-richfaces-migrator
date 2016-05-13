package pl.edu.pw.ii.migration;

import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.IOException;

public class FileUtil {


    public static void copyFile(File sourceFile, File destFile) throws IOException {
        FileUtils.copyFile(sourceFile,destFile);
    }
}

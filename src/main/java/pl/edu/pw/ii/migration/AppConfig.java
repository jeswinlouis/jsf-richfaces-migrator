package pl.edu.pw.ii.migration;


import com.typesafe.config.Config;

import java.util.*;

public class AppConfig {
    static boolean notMigratedOnly;
    static boolean createOldFileBackup;
    static boolean recursive;
    static Set<String> ignoredDirNames = new HashSet<>();
    static String webContentPath;
    static String oldFileBackupPrefix;
    static Map<String, String> stringsToReplace = new HashMap<>();

    static {
        stringsToReplace.put("http://jboss.com/products/seam/taglib", "http://jboss.org/schema/seam/taglib");
        stringsToReplace.put("http://java.sun.com/jstl/core", "http://java.sun.com/jsp/jstl/core");
    }

    public static void read(Config conf) {
        webContentPath = conf.getString("migrator.webContentPath");
        ignoredDirNames.addAll(conf.getStringList("migrator.ignoredDirNames"));

        recursive = conf.getBoolean("migrator.recursive");
        notMigratedOnly = conf.getBoolean("migrator.notMigratedOnly");
        createOldFileBackup=conf.getBoolean("migrator.createOldFileBackup");
        oldFileBackupPrefix=conf.getString("migrator.oldFileBackupPrefix");

        System.out.println("Web content path: " + conf.getString("migrator.webContentPath"));
    }
}

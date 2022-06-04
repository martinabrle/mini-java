package com.maabrle.web.model;

import java.io.InputStream;
import java.util.Properties;

public class TodoApiConfiguration {

    private static TodoApiConfiguration INSTANCE;

    private Properties properties;
    private String API_URI;

    
    protected TodoApiConfiguration() {
        try {
            Properties props = new Properties();

            try (InputStream is = getClass().getResourceAsStream("/application.properties")) {
                props.load(is);
            }
            properties = props;
        } catch (Exception exception) {
            properties = new Properties();
        }
        
        try {
            API_URI = removeQuotes((String) properties.get("todo.api.url"));
            if (API_URI == null || API_URI.isEmpty()) {
                API_URI = System.getenv("API_URI");
            }
            if (API_URI.startsWith("${") && API_URI.endsWith("}")) {
                API_URI = API_URI.substring(2, API_URI.length() - 1);
                API_URI = System.getenv(API_URI);
            }
            API_URI = removeQuotes(API_URI);
        } catch (Exception exception) {
            try {
                API_URI = System.getenv("API_URI");
            } catch (Exception exception2) {
                API_URI = "";
            }
        }
    }

    protected static String removeQuotes(String s) {
        if (s != null && s.length() >= 2 && s.startsWith("\"") && s.endsWith("\""))
            return s.substring(1, s.length() - 1);
        return s;

    }

    protected static TodoApiConfiguration getConfig() {
        if (INSTANCE == null) {
            INSTANCE = new TodoApiConfiguration();
        }
        return INSTANCE;
    }
    
    public static String getTodoApiURI() {
        return getConfig().API_URI;
    }
}

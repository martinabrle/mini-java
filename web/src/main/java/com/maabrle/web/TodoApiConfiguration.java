package com.maabrle.web;

import java.io.InputStream;
import java.util.Properties;

public class TodoApiConfiguration {

    private static TodoApiConfiguration INSTANCE;

    private Properties properties;

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
        String apiURI = "";
        try {
            System.out.println(getConfig().properties.get("todo.api.url").getClass().getName());

            apiURI = removeQuotes((String) getConfig().properties.get("todo.api.url"));
        } catch (Exception exception) {
            apiURI = "";
        }
        return apiURI;
    }
}

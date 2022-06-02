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

        System.out.println(getConfig().properties.get("todo.api.url").getClass().getName());

        try {
            apiURI = removeQuotes((String) getConfig().properties.get("todo.api.url"));
            if (apiURI == null || apiURI.isEmpty()) {
                apiURI = System.getenv("API_URI");
            }
            if (apiURI.startsWith("${") && apiURI.endsWith("}")) {
                apiURI = apiURI.substring(2, apiURI.length() - 1);
                apiURI = System.getenv(apiURI);
            }
            apiURI = removeQuotes(apiURI);
        } catch (Exception exception) {
            try {
                apiURI = System.getenv("API_URI");
            } catch (Exception exception2) {
                apiURI = "";
            }
        }

        return apiURI;
    }
}

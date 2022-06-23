package com.maabrle.web.model;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.InputStream;
import java.util.Properties;

public class TodoApiConfiguration {

    public static final Logger LOGGER = LoggerFactory.getLogger(Todo.class);

    private static TodoApiConfiguration INSTANCE;

    private Properties properties;
    private String API_URI;
    private String EVENT_HUB_NAME;
    private String EVENT_HUB_NAMESPACE_CONNECTION_STRING;

    protected TodoApiConfiguration() {
        try {
            Properties props = new Properties();

            try (InputStream is = getClass().getResourceAsStream("/application.properties")) {
                props.load(is);
            }
            properties = props;
        } catch (Exception ex) {
            LOGGER.error("Failed to retrieve application.properties: {}\n{}", ex.getMessage(), ex);
            properties = new Properties();
        }

        API_URI = getProperty(properties, "todo.api.url", "API_URI");
        EVENT_HUB_NAMESPACE_CONNECTION_STRING = getProperty(properties, "todo.eventhub.namespace.connection_string",
                "EVENT_HUB_NAMESPACE_CONNECTION_STRING");
        EVENT_HUB_NAME = getProperty(properties, "todo.eventhub.name", "EVENT_HUB_NAME");
    }

    protected static String getProperty(Properties properties, String key, String fallbackEnvVariable) {
        String paramValue;

        try {
            paramValue = removeQuotes((String) properties.get(key));
            if (paramValue == null || paramValue.isEmpty()) {
                LOGGER.debug("Attempting to retrieve application's property {} as an environment variable", key);
                paramValue = System.getenv(fallbackEnvVariable);
            }
            if (paramValue.startsWith("${") && paramValue.endsWith("}")) {
                paramValue = paramValue.substring(2, paramValue.length() - 1);
                paramValue = System.getenv(paramValue);
            }
            paramValue = removeQuotes(paramValue);
        } catch (Exception ex) {
            LOGGER.error("Failed to retrieve application's property: {}\n{}", key, ex.getMessage(), ex);
            try {
                LOGGER.debug("Attempting to retrieve application's property {} as an environment variable", key);
                paramValue = System.getenv(fallbackEnvVariable);
            } catch (Exception ex2) {
                LOGGER.error("Failed to retrieve application's property {} as an environment variable: {}\n{}", key,
                        ex2.getMessage(), ex2);
                paramValue = "";
            }
        }
        return paramValue;
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

    public static String getEventHubName() {
        return getConfig().EVENT_HUB_NAME;
    }

    public static String getEventHubNameSpaceConnectionString() {
        return getConfig().EVENT_HUB_NAMESPACE_CONNECTION_STRING;
    }
}

package com.maabrle.api;

import com.azure.core.credential.SimpleTokenCache;
import com.azure.core.credential.TokenCredential;
import com.azure.core.credential.TokenRequestContext;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
//@ConfigurationProperties(prefix = "spring.datasource.hikari")
public class AzureAdDataSource extends HikariDataSource {

    private final SimpleTokenCache cache;

    public AzureAdDataSource(TokenCredential credential) {
        this.cache = new SimpleTokenCache(() -> credential.getToken(createRequestContext()));
    }

    @Override
    public String getPassword() {
        var accessToken = cache
                .getToken()
                .retry(3L)
                .blockOptional()
                .orElseThrow(() -> new RuntimeException("Attempt to retrieve AAD token failed"));

        return accessToken.getToken();
    }

    private static TokenRequestContext createRequestContext() {
        return new TokenRequestContext().addScopes("https://ossrdbms-aad.database.windows.net/.default");
    }
}

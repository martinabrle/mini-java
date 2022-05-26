package com.maabrle.api;

//as seen on
//   https://www.azureblue.io/how-to-authenicated-aad-identity-against-postgres-using-spring-boot/

import com.azure.identity.*;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AppConfig {
    @Bean
    public ChainedTokenCredential chainedTokenCredential() {
        var azureCliCredential = new AzureCliCredentialBuilder()
                .build();

        var managedIdentityCredential = new ManagedIdentityCredentialBuilder()
                .clientId("75c4085d-573d-402c-8cef-83b9647f5855")
                .build();

        var credentialChain = new ChainedTokenCredentialBuilder()
                .addLast(azureCliCredential)
                .addLast(managedIdentityCredential)
                .build();

        return credentialChain;
    }
}
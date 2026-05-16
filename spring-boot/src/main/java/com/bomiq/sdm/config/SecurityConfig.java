package com.bomiq.sdm.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.logout.LogoutHandler;
import org.springframework.security.web.authentication.ui.DefaultLoginPageGeneratingFilter;
import org.springframework.web.util.UriComponentsBuilder;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

    private static final String KEYCLOAK_JWK_SET_URI =
            "http://localhost:8080/realms/bomiq/protocol/openid-connect/certs";
    private static final String KEYCLOAK_END_SESSION =
            "http://localhost:8080/realms/bomiq/protocol/openid-connect/logout";

    @Bean
    @Order(1)
    public SecurityFilterChain apiSecurityFilterChain(HttpSecurity http) throws Exception {
        http
                .securityMatcher("/api/**")
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/api/v1/public/**").permitAll()
                        .anyRequest().authenticated()
                )
                .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .oauth2ResourceServer(oauth2 -> oauth2
                        .jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthenticationConverter()))
                )
                .csrf(csrf -> csrf.disable());
        return http.build();
    }

    @Bean
    @Order(2)
    public SecurityFilterChain uiSecurityFilterChain(HttpSecurity http) throws Exception {
        http
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(
                                "/",
                                "/login/oauth2/code/**",
                                "/oauth2/**",
                                "/error",
                                "/static/**",
                                "/css/**",
                                "/js/**",
                                "/actuator/health"
                        ).permitAll()
                        .anyRequest().authenticated()
                )
                .oauth2Login(oauth2 -> oauth2
                        .loginPage("/")
                        .defaultSuccessUrl("/bom", true)
                        .failureUrl("/")
                )
                .logout(logout -> logout
                        .logoutUrl("/logout")
                        .addLogoutHandler(keycloakLogoutHandler())
                        .logoutSuccessUrl("/")
                        .invalidateHttpSession(true)
                        .clearAuthentication(true)
                        .deleteCookies("JSESSIONID")
                )
                .csrf(csrf -> csrf.ignoringRequestMatchers("/api/**"));

        http.addFilterAt(new NoOpFilter(), DefaultLoginPageGeneratingFilter.class);

        return http.build();
    }

    static class NoOpFilter implements Filter {
        @Override
        public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
                throws IOException, ServletException {
            chain.doFilter(req, res);
        }
    }

    @Bean
    public JwtDecoder jwtDecoder() {
        return NimbusJwtDecoder.withJwkSetUri(KEYCLOAK_JWK_SET_URI).build();
    }

    @Bean
    public JwtAuthenticationConverter jwtAuthenticationConverter() {
        JwtGrantedAuthoritiesConverter rolesConverter = new JwtGrantedAuthoritiesConverter();
        rolesConverter.setAuthorityPrefix("ROLE_");
        rolesConverter.setAuthoritiesClaimName("realm_access.roles");
        JwtAuthenticationConverter converter = new JwtAuthenticationConverter();
        converter.setJwtGrantedAuthoritiesConverter(rolesConverter);
        return converter;
    }

    @Bean
    public LogoutHandler keycloakLogoutHandler() {
        return (request, response, authentication) -> {
            if (authentication == null) return;
            String idToken = "";
            if (authentication instanceof org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken oauthToken) {
                Object principal = oauthToken.getPrincipal();
                if (principal instanceof org.springframework.security.oauth2.core.oidc.user.OidcUser oidcUser) {
                    idToken = oidcUser.getIdToken().getTokenValue();
                }
            }
            String logoutUrl = UriComponentsBuilder
                    .fromUriString(KEYCLOAK_END_SESSION)
                    .queryParam("id_token_hint", idToken)
                    .queryParam("post_logout_redirect_uri", getBaseUrl(request))
                    .toUriString();
            try {
                response.sendRedirect(logoutUrl);
            } catch (Exception e) {
                throw new RuntimeException("Logout redirect failed", e);
            }
        };
    }

    private String getBaseUrl(HttpServletRequest request) {
        return request.getScheme() + "://" + request.getServerName()
                + ":" + request.getServerPort() + request.getContextPath();
    }
}
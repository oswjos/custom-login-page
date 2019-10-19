<%--

ADOBE CONFIDENTIAL
__________________

Copyright 2015 Adobe
All Rights Reserved.

NOTICE:  All information contained herein is, and remains
the property of Adobe and its suppliers,
if any.  The intellectual and technical concepts contained
herein are proprietary to Adobe and its
suppliers and are protected by trade secret or copyright law.
Dissemination of this information or reproduction of this material
is strictly forbidden unless prior written permission is obtained
from Adobe.
--%><%@page session="false"
        contentType="text/html"
        pageEncoding="utf-8"
        import="java.util.HashMap,
                  java.util.Map,
                  java.util.List,
                  java.util.Iterator,
                  java.util.Arrays,
                  java.util.Locale,
                  java.util.ResourceBundle,
                  org.apache.commons.io.IOUtils,
                  org.apache.commons.lang3.StringUtils,
                  org.apache.sling.api.resource.Resource,
                  org.apache.sling.api.resource.ResourceUtil,
                  org.apache.sling.api.SlingHttpServletRequest,
                  org.apache.sling.api.resource.ValueMap,
                  com.adobe.granite.xss.XSSAPI,
                  com.day.cq.i18n.I18n,
                  com.adobe.granite.ui.clientlibs.HtmlLibrary,
                  com.adobe.granite.ui.clientlibs.HtmlLibraryManager,
                  com.adobe.granite.ui.clientlibs.LibraryType,
                  com.adobe.granite.license.ProductInfoProvider,
                  com.adobe.granite.auth.ims.ImsConfigProvider,
                  com.adobe.granite.security.user.UserManagementService,
                  org.apache.sling.auth.core.AuthUtil,
                  org.apache.sling.auth.core.AuthConstants,
					org.apache.sling.settings.SlingSettingsService,
					java.util.Set,
                  java.util.Calendar"%><%
%><%@taglib prefix="sling" uri="http://sling.apache.org/taglibs/sling/1.0"%><%
%><%@ taglib prefix="ui" uri="http://www.adobe.com/taglibs/granite/ui/1.0" %><%--
login
=====

    The component to render the login screen.

    It has the following content structure:

   /**
    * The HTML title.
    * Defaults to "Adobe Experience Cloud".
    */
    - title (String)


   /**
    * The favicon.
    * Defaults to "login/adobe-logo.png".
    */
    - favicon (String)


   /**
    * The title in the box.
    * Defaults to "Welcome to Adobe Experience Cloud".
    */
    - box/title (String)


   /**
    * The text in the box.
    * Defaults to "All the tools you need to solve these complex digital business challenges.".
    */
    - box/text (String)


   /**
    * The text of the learn more link. The link is following the text.
    * Defaults to "Learn More".
    */
    - /box/learnMore/text (String)


   /**
    * The href of the learn more link.
    * Defaults to "#".
    */
    - /box/learnMore/link (String)


   /**
    * Enables autocomplete for fields username and password.
    * Defaults to "false".
    */
    - box/autocomplete (Boolean)


   /**
    * The title of the login form. Note that this title is not shown in browsers that display field labels instead of
    * placeholders (IE8 and older).
    * Defaults to "Sign In".
    */
    - box/formTitle (String)


   /**
    * The title of the change password form. Note that this title is not shown in browsers that display field labels instead of
    * placeholders (IE8 and older).
    * Defaults to "Change Password".
    */
    - box/changePasswordTitle (String)


   /**
    * The placeholder of the user field.
    * Defaults to "User name".
    */
    - box/userPlaceholder (String)


   /**
    * The placeholder of the password field in the login form.
    * Defaults to "Password".
    */
    - box/passwordPlaceholder (String)


   /**
    * The placeholder of the password field in the change password form.
    * Defaults to "Old password".
    */
    - box/oldPasswordPlaceholder (String)


   /**
    * The placeholder of the new password field.
    * Defaults to "New password".
    */
    - box/newPasswordPlaceholder (String)


   /**
    * The placeholder of the confirm password field.
    * Defaults to "Confirm new password".
    */
    - box/confirmPasswordPlaceholder (String)


   /**
    * The text of the submit button in the login form.
    * Defaults to "Sign In".
    */
    - box/submitText (String)


   /**
    * The text of the submit button in the change password form.
    * Defaults to "Submit".
    */
    - box/changePasswordSubmitText (String)


   /**
    * The text of the back button.
    * Defaults to "Back".
    */
    - box/backText (String)


   /**
    * The error message displayed when login fails.
    * Defaults to "User name and password do not match".
    */
    - box/invalidLoginText (String)


   /**
    * The error message displayed when the session timed out.
    * Defaults to "Session timed out, please login again".
    */
    - box/sessionTimedOutText (String)


   /**
    * The error message displayed when the password is expired.
    * Defaults to "Your password has expired".
    */
    - box/loginExpiredText (String)

   /**
    * The error message displayed when the password is expired and the newly chosen password is in the password history.
    * Defaults to "New password is in password history".
    */
    - box/loginInHistoryText (String)

   /**
    * The error message displayed when the new and confirm passwords do not match.
    * Defaults to "New passwords do not match".
    */
    - box/passwordsDoNotMatchText (String)


   /**
    * The error message displayed when the new password is blank.
    * Defaults to "New password must not be blank".
    */
    - box/passwordEmptyText (String)


    /**
     * The title of the success modal.
     * Defaults to "Password Changed"
     */
     - changePasswordSuccessTitle


    /**
     * The text of the success modal.
     * Defaults to "Your password has been changed successfully."
     */
     - changePasswordSuccessText


   /**
    * The items on the left side of the footer.
    * Default items are "Help", "Term of Use" and "Privacy Policy and Cookies".
    */
    - footer/items (String)


   /**
    * The copyright on the right side of the footer.
    * Defaults to "© 2014 Adobe. All Rights Reserved.".
    */
    - footer/copy/text (String)


--%><%!

    static final String PARAM_NAME_REASON = "j_reason";

    static final String REASON_KEY_INVALID_LOGIN = "invalid_login";
    static final String REASON_KEY_SESSION_TIMED_OUT = "session_timed_out";

    static final String DEFAULT_AUTH_URL_SUFFIX  = "/j_security_check";

    static final String ERROR_SELECTOR = "error";
    static final String CHANGE_PWD_SELECTOR = "changepassword";

    String imsLoginUrl = null;

    private String printProperty(ValueMap cfg, I18n i18n, XSSAPI xssAPI, String name, String defaultText) {
        String text = getText(cfg, i18n, name, defaultText);
        return xssAPI.encodeForHTML(text);
    }

    private String printAttribute(ValueMap cfg, I18n i18n, XSSAPI xssAPI, String name, String defaultText) {
        String text = getText(cfg, i18n, name, defaultText);
        return xssAPI.encodeForHTMLAttr(text);
    }

    private String getText(ValueMap cfg, I18n i18n, String name, String defaultText) {
        String text = cfg.get(name, String.class);
        return text != null ? i18n.getVar(text) : defaultText;
    }

    /**
     * Select the configuration root resource among those stored under <code>configs</code> node.
     * The configuration with the highest order property is selected.
     * @param current the
     * @return the selected configuration root resource or <code>null</code> if no configuration root could be found.
     */
    private Resource getConfigRoot(Resource current) {
        Resource configs = current.getChild("configs");
        Resource configRoot = null;
        if (configs != null) {
            long maxOrder = Long.MIN_VALUE;
            for (Iterator<Resource> cfgs = configs.listChildren() ; cfgs.hasNext() ; ) {
                Resource cfg = cfgs.next();
                ValueMap props = ResourceUtil.getValueMap(cfg);
                Long order = props.get("order", Long.class);
                if (order != null) {
                    if (order > maxOrder) {
                        configRoot = cfg;
                        maxOrder = order;
                    }
                }
            }
        }
        return configRoot;
    }

    /**
     * Returns a URL suffix which ensures that the request is handled by {@link org.apache.sling.auth.core.impl.SlingAuthenticator}
     * If no custom suffices are found, this method returns <code>DEFAULT_AUTH_URL_SUFFIX</code>
     *
     * @return a URL suffix which will ensure that the URL is handled by the authenticator.
     */
    private String getAuthURLSuffix(SlingHttpServletRequest req) {
        final Object authUriSufficesObj = req.getAttribute(AuthConstants.ATTR_REQUEST_AUTH_URI_SUFFIX);
        if (authUriSufficesObj instanceof String[]) {
            final String[] authUriSuffices = (String[]) authUriSufficesObj;
            if (authUriSuffices.length > 0) {
                // Any suffix from this array would be valid. Return the first.
                return authUriSuffices[0];
            }
        }
        return DEFAULT_AUTH_URL_SUFFIX;
    }

%><sling:defineObjects /><%
    final String DEFAULT_LANG = "en";

    final Resource configs = getConfigRoot(resource);

    final String browserAcceptLang = request.getHeader("Accept-Language");

    String browserRegion;
    String browserLang = null;
    Locale browserLocale = null;

    if (browserAcceptLang != null) {
        if (browserAcceptLang.matches("^[a-zA-Z][a-zA-Z](-|_)[a-zA-Z][a-zA-Z].*")) {
            browserLang = browserAcceptLang.substring(0,2);
            browserRegion = browserAcceptLang.substring(3,5);
            browserLocale = new Locale(browserLang, browserRegion);
        } else if (browserAcceptLang.matches("^[a-zA-Z][a-zA-Z].*")) {
            browserLang = browserAcceptLang.substring(0,2);
            browserLocale = new Locale(browserLang);
        }
    } else {
        // default lang in case the request does not have any language
        browserLang = DEFAULT_LANG;
    }

    final I18n i18n;
    if (browserLocale != null) {
        ResourceBundle browserLocaleBundle = slingRequest.getResourceBundle(browserLocale);
        i18n = new I18n(browserLocaleBundle);
    } else {
        i18n = new I18n(slingRequest);
    }

    final XSSAPI xssAPI = sling.getService(XSSAPI.class).getRequestSpecificAPI(slingRequest);
    final UserManagementService userManagementService = sling.getService(UserManagementService.class);
    final ValueMap cfg = ResourceUtil.getValueMap(configs);

    final String authType = request.getAuthType();
    final String user = request.getRemoteUser();
    final String contextPath = slingRequest.getContextPath();

    // used to map readable reason codes to valid reason messages to avoid phishing attacks through j_reason param
    Map<String,String> validReasons = new HashMap<String, String>();
    validReasons.put(REASON_KEY_INVALID_LOGIN, printProperty(cfg, i18n, xssAPI, "box/invalidLoginText", i18n.get("User name and password do not match")));
    validReasons.put(REASON_KEY_SESSION_TIMED_OUT, printProperty(cfg, i18n, xssAPI, "box/sessionTimedOutText", i18n.get("Session timed out, please login again")));
    // load custom error types
    Resource errors = resource.getChild("errors");
    if (errors != null) {
        for (Iterator<Resource> customErrors = errors.listChildren() ; customErrors.hasNext() ; ) {
            Resource customError = customErrors.next();
            validReasons.put(customError.getName(), printProperty(customError.adaptTo(ValueMap.class), i18n, xssAPI, "/text", i18n.get("Error")));
        }
    }

    String reason = request.getParameter(PARAM_NAME_REASON) != null
            ? request.getParameter(PARAM_NAME_REASON)
            : "";

    if (!StringUtils.isEmpty(reason)) {
        if (validReasons.containsKey(reason)) {
            reason = validReasons.get(reason);
        } else {
            // a reason param value not matching a key in the validReasons map is considered bogus
            log.warn("{} param value '{}' cannot be mapped to a valid reason message: ignoring", PARAM_NAME_REASON, reason);
            reason = "";
        }
    }

    List<String> selectors = Arrays.asList(slingRequest.getRequestPathInfo().getSelectors());

    boolean isLogin = ! selectors.contains(CHANGE_PWD_SELECTOR);
    boolean isError = selectors.contains(ERROR_SELECTOR);

%><!DOCTYPE html>
<html lang="<%= xssAPI.encodeForHTMLAttr(browserLang) %>">
<head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <%-- optimized for mobile, zoom/scaling disabled --%>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta http-equiv="X-UA-Compatible" content="chrome=1" /><%
        ImsConfigProvider imsConfigProvider = sling.getService(ImsConfigProvider.class);
        if (imsConfigProvider != null) {
            imsLoginUrl = imsConfigProvider.getImsLoginUrl(slingRequest);
            %><meta name="granite.login.imsLoginUrl" content="<%= xssAPI.getValidHref(imsLoginUrl) %>"><%
        }
    %><title><%= printProperty(cfg, i18n, xssAPI, "title", i18n.get("Adobe Experience Cloud")) %></title>
    <style type="text/css"><%
        HtmlLibraryManager htmlMgr = sling.getService(HtmlLibraryManager.class);
        HtmlLibrary lib = htmlMgr.getLibrary(LibraryType.CSS, "/apps/granite/core/content/login/clientlib");
        IOUtils.copy(lib.getInputStream(true), out, "utf-8");
    %></style>
    <ui:includeClientLib categories="coralui3" /><%
        String favicon = xssAPI.getValidHref(cfg.get("favicon", "login/adobe-logo.png"));
        favicon = xssAPI.getValidHref(favicon);
    %><link rel="shortcut icon" href="<%= favicon %>" type="image/png">
    <link rel="icon" href="<%= favicon %>" type="image/png">
    <%-- Load the clientlib(s). Extension libraries should use the  'granite.core.login.extension' category. --%>
    <ui:includeClientLib js="jquery,typekit,apps.granite.core.login,granite.core.login.extension"/>
    <ui:includeClientLib css="granite.core.login.extension"/>
</head>
<body class="coral--light">
<div id="wrap" role="main">
    <div id="backgrounds">
        <%-- this holds all the background divs that are dynamically loaded --%>

		<%

		String css_id = "bg_default";

        SlingSettingsService slingSettingsService = sling.getService(SlingSettingsService.class);

        Set<String> runmodes = slingSettingsService.getRunModes();

		if (runmodes.contains("ginza")) {
            css_id = "bg_author_ginza";
        } else if (runmodes.contains("hongkong")) {
			css_id = "bg_author_hongkong";
        }

        %>

        <div id="<%= css_id %>" class="background"></div>
    </div>
    <div id="tag"></div><%
        // make sure the redirect path is valid and prefixed with the context path
        String redirect = request.getParameter("resource");
        if (redirect == null || !AuthUtil.isRedirectValid(request, redirect)) {
            redirect = "/";
        }
        if (!redirect.startsWith(contextPath)) {
            redirect = contextPath + redirect;
        }
        String urlLogin = request.getContextPath() + resource.getPath() + ".html" + getAuthURLSuffix(slingRequest);

        if (authType == null || user == null || userManagementService.getAnonymousId().equals(user)) {
    %><div id="login-box" class="coral--dark">
        <div id="leftbox" class="box">
            <div class="header">
                <h1 class="coral-Heading coral-Heading--1"><%= printProperty(cfg, i18n, xssAPI, "box/title", i18n.get("Welcome to Adobe Experience Cloud")) %></h1>
            </div>
            <p>
                <%= printProperty(cfg, i18n, xssAPI, "box/text", i18n.get("All the tools you need to solve these complex digital business challenges.")) %>
                <a class="coral-Link" id="learnmore" href="<%= xssAPI.getValidHref(i18n.getVar(cfg.get("box/learnMore/href", "#"))) %>" x-cq-linkchecker="skip"><%= printProperty(cfg, i18n, xssAPI, "box/learnMore/text", i18n.get("Learn More")) %></a>
            </p>
        </div>

        <%-- If IMS is provided we render the choice --%>
        <% if (imsLoginUrl != null) { %>
            <div id="rightbox" class="box">
                <button is="coral-button" id="submit-button-ims" variant="primary" type="submit" block><%= xssAPI.encodeForHTML(i18n.get("Sign in with Adobe")) %></button>
                <coral-accordion variant="quiet">
                    <coral-accordion-item>
                        <coral-accordion-item-label><%= xssAPI.encodeForHTML(i18n.get("Sign in locally (admin tasks only)")) %></coral-accordion-item-label>
                        <coral-accordion-item-content>
                            <% if (isError && reason.length() > 0) { %>
                            <p><%= xssAPI.encodeForHTML(i18n.get("Please contact your administrator or try again later.")) %></p>
                            <coral-alert variant="error">
                                <coral-alert-content><%= xssAPI.encodeForHTML(reason) %></coral-alert-content>
                            </coral-alert>
                            <% } else { %>
                            <% String autocomplete = cfg.get("box/autocomplete", false) ? "on" : "off" ; %>
                            <form class="coral-Form coral-Form--vertical" name="login" method="POST" id="login" action="<%= xssAPI.getValidHref(urlLogin) %>" novalidate="novalidate">
                                <input type="hidden" name="_charset_" value="UTF-8">
                                <input type="hidden" name="errorMessage" value="<%= validReasons.get(REASON_KEY_INVALID_LOGIN) %>">
                                <input type="hidden" name="resource" id="resource" value="<%= xssAPI.encodeForHTMLAttr(redirect) %>">
                                <%
                                    String loginTitle = printProperty(cfg, i18n, xssAPI, "box/formTitle", i18n.get("Sign In"));
                                    String changeTitle = printProperty(cfg, i18n, xssAPI, "box/changePasswordTitle", i18n.get("Change Password"));
                                    String loginSubmitText = printProperty(cfg, i18n, xssAPI, "box/submitText", i18n.get("Sign In"));
                                    String changeSubmitText = printProperty(cfg, i18n, xssAPI, "box/changePasswordSubmitText", i18n.get("Submit"));
                                    String userPlaceholder = printAttribute(cfg, i18n, xssAPI, "box/userPlaceholder", i18n.get("User name"));
                                    String loginPasswordPlaceholder = printAttribute(cfg, i18n, xssAPI, "box/passwordPlaceholder", i18n.get("Password"));
                                    String changePasswordPlaceholder = printAttribute(cfg, i18n, xssAPI, "box/oldPasswordPlaceholder", i18n.get("Old password"));
                                    String newPasswordPlaceholder = printAttribute(cfg, i18n, xssAPI, "box/newPasswordPlaceholder", i18n.get("New password"));
                                    String confirmPasswordPlaceholder = printAttribute(cfg, i18n, xssAPI, "box/confirmPasswordPlaceholder", i18n.get("Confirm new password"));
                                %>
                                <div class="coral-Form-fieldwrapper">
                                    <input is="coral-textfield" aria-label="<%= userPlaceholder %>" class="coral-Form-field" id="username" name="j_username" type="text" autofocus="autofocus" pattern=".*" placeholder="<%= userPlaceholder %>" spellcheck="false" autocomplete="<%= autocomplete %>">
                                </div>
                                <div class="coral-Form-fieldwrapper">
                                    <input is="coral-textfield" aria-label="<%= isLogin ? loginPasswordPlaceholder : changePasswordPlaceholder %>" class="coral-Form-field" id="password" name="j_password" type="password"  placeholder="<%= isLogin ? loginPasswordPlaceholder : changePasswordPlaceholder %>" spellcheck="false" autocomplete="<%= autocomplete %>">
                                </div>
                                <div class="coral-Form-fieldwrapper">
                                    <input is="coral-textfield" aria-label="<%= newPasswordPlaceholder %>" class="coral-Form-field" id="new_password" name="<%= isLogin ? "" : "j_newpassword" %>" type="password"  placeholder="<%= newPasswordPlaceholder %>" spellcheck="false" autocomplete="false" <%= isLogin ? "hidden" : "" %>>
                                </div>
                                <div class="coral-Form-fieldwrapper">
                                    <input is="coral-textfield" aria-label="<%= confirmPasswordPlaceholder %>" class="coral-Form-field" id="confirm_password" name="" type="password"  placeholder="<%= confirmPasswordPlaceholder %>" spellcheck="false" autocomplete="false" <%= isLogin ? "hidden" : "" %>>
                                </div>
                                <coral-alert id="error" variant="error" <%= reason.length() > 0 ? "" : "hidden" %>>
                                    <coral-alert-content><%= xssAPI.encodeForHTML(reason) %></coral-alert-content>
                                </coral-alert>
                                <button is="coral-button" id="submit-button" variant="primary" type="submit"><%= isLogin ? loginSubmitText : changeSubmitText %></button>
                                <button is="coral-button" id="back-button" hidden><%= printProperty(cfg, i18n, xssAPI, "box/backText", i18n.get("Back")) %></button>
                            </form>
                            <input id="login_title" type="hidden" value="<%= loginTitle %>">
                            <input id="change_title" type="hidden" value="<%= changeTitle %>">
                            <input id="login_password_placeholder" type="hidden" value="<%= loginPasswordPlaceholder %>">
                            <input id="change_password_placeholder" type="hidden" value="<%= changePasswordPlaceholder %>">
                            <input id="login_submit_text" type="hidden" value="<%= loginSubmitText %>">
                            <input id="change_submit_text" type="hidden" value="<%= changeSubmitText %>">
                            <input id="invalid_message" type="hidden" value="<%= validReasons.get(REASON_KEY_INVALID_LOGIN) %>"/>
                            <input id="expired_message" type="hidden" value="<%= printProperty(cfg, i18n, xssAPI, "box/loginExpiredText", i18n.get("Your password has expired")) %>"/>
                            <input id="in_history_message" type="hidden" value="<%= printProperty(cfg, i18n, xssAPI, "box/loginInHistoryText", i18n.get("New password was found in password history")) %>"/>
                            <input id="not_match_message" type="hidden" value="<%= printProperty(cfg, i18n, xssAPI, "box/passwordsDoNotMatchText", i18n.get("New passwords do not match")) %>"/>
                            <input id="empty_message" type="hidden" value="<%= printProperty(cfg, i18n, xssAPI, "box/passwordEmptyText", i18n.get("New password must not be blank")) %>"/>
                            <% } %>
                        </coral-accordion-item-content>
                    </coral-accordion-item>
                </coral-accordion>
            </div>
        <%-- else render standard local login --%>
        <% } else { %>
            <div id="rightbox" class="box">
                <% if (isError && reason.length() > 0) { %>
                <p><%= xssAPI.encodeForHTML(i18n.get("Please contact your administrator or try again later.")) %></p>
                <coral-alert variant="error">
                    <coral-alert-content><%= xssAPI.encodeForHTML(reason) %></coral-alert-content>
                </coral-alert>
                <% } else { %>
                <% String autocomplete = cfg.get("box/autocomplete", false) ? "on" : "off" ; %>
                <form class="coral-Form coral-Form--vertical" name="login" method="POST" id="login" action="<%= xssAPI.getValidHref(urlLogin) %>" novalidate="novalidate">
                    <input type="hidden" name="_charset_" value="UTF-8">
                    <input type="hidden" name="errorMessage" value="<%= validReasons.get(REASON_KEY_INVALID_LOGIN) %>">
                    <input type="hidden" name="resource" id="resource" value="<%= xssAPI.encodeForHTMLAttr(redirect) %>">
                    <%
                        String loginTitle = printProperty(cfg, i18n, xssAPI, "box/formTitle", i18n.get("Sign In"));
                        String changeTitle = printProperty(cfg, i18n, xssAPI, "box/changePasswordTitle", i18n.get("Change Password"));
                        String loginSubmitText = printProperty(cfg, i18n, xssAPI, "box/submitText", i18n.get("Sign In"));
                        String changeSubmitText = printProperty(cfg, i18n, xssAPI, "box/changePasswordSubmitText", i18n.get("Submit"));
                        String userPlaceholder = printAttribute(cfg, i18n, xssAPI, "box/userPlaceholder", i18n.get("User name"));
                        String loginPasswordPlaceholder = printAttribute(cfg, i18n, xssAPI, "box/passwordPlaceholder", i18n.get("Password"));
                        String changePasswordPlaceholder = printAttribute(cfg, i18n, xssAPI, "box/oldPasswordPlaceholder", i18n.get("Old password"));
                        String newPasswordPlaceholder = printAttribute(cfg, i18n, xssAPI, "box/newPasswordPlaceholder", i18n.get("New password"));
                        String confirmPasswordPlaceholder = printAttribute(cfg, i18n, xssAPI, "box/confirmPasswordPlaceholder", i18n.get("Confirm new password"));
                    %>
                    <p id="sign-in-title"><%= isLogin ? loginTitle : changeTitle %></p>
                    <div class="coral-Form-fieldwrapper">
                        <input is="coral-textfield" aria-label="<%= userPlaceholder %>" class="coral-Form-field" id="username" name="j_username" type="text" autofocus="autofocus" pattern=".*" placeholder="<%= userPlaceholder %>" spellcheck="false" autocomplete="<%= autocomplete %>">
                    </div>
                    <div class="coral-Form-fieldwrapper">
                        <input is="coral-textfield" aria-label="<%= isLogin ? loginPasswordPlaceholder : changePasswordPlaceholder %>" class="coral-Form-field" id="password" name="j_password" type="password"  placeholder="<%= isLogin ? loginPasswordPlaceholder : changePasswordPlaceholder %>" spellcheck="false" autocomplete="<%= autocomplete %>">
                    </div>
                    <div class="coral-Form-fieldwrapper">
                        <input is="coral-textfield" aria-label="<%= newPasswordPlaceholder %>" class="coral-Form-field" id="new_password" name="<%= isLogin ? "" : "j_newpassword" %>" type="password"  placeholder="<%= newPasswordPlaceholder %>" spellcheck="false" autocomplete="false" <%= isLogin ? "hidden" : "" %>>
                    </div>
                    <div class="coral-Form-fieldwrapper">
                        <input is="coral-textfield" aria-label="<%= confirmPasswordPlaceholder %>" class="coral-Form-field" id="confirm_password" name="" type="password"  placeholder="<%= confirmPasswordPlaceholder %>" spellcheck="false" autocomplete="false" <%= isLogin ? "hidden" : "" %>>
                    </div>
                    <coral-alert id="error" variant="error" <%= reason.length() > 0 ? "" : "hidden" %>>
                        <coral-alert-content><%= xssAPI.encodeForHTML(reason) %></coral-alert-content>
                    </coral-alert>
                    <button is="coral-button" id="submit-button" variant="primary" type="submit"><%= isLogin ? loginSubmitText : changeSubmitText %></button>
                    <button is="coral-button" id="back-button" hidden><%= printProperty(cfg, i18n, xssAPI, "box/backText", i18n.get("Back")) %></button>
                </form>
                <input id="login_title" type="hidden" value="<%= loginTitle %>">
                <input id="change_title" type="hidden" value="<%= changeTitle %>">
                <input id="login_password_placeholder" type="hidden" value="<%= loginPasswordPlaceholder %>">
                <input id="change_password_placeholder" type="hidden" value="<%= changePasswordPlaceholder %>">
                <input id="login_submit_text" type="hidden" value="<%= loginSubmitText %>">
                <input id="change_submit_text" type="hidden" value="<%= changeSubmitText %>">
                <input id="invalid_message" type="hidden" value="<%= validReasons.get(REASON_KEY_INVALID_LOGIN) %>"/>
                <input id="expired_message" type="hidden" value="<%= printProperty(cfg, i18n, xssAPI, "box/loginExpiredText", i18n.get("Your password has expired")) %>"/>
                <input id="in_history_message" type="hidden" value="<%= printProperty(cfg, i18n, xssAPI, "box/loginInHistoryText", i18n.get("New password was found in password history")) %>"/>
                <input id="not_match_message" type="hidden" value="<%= printProperty(cfg, i18n, xssAPI, "box/passwordsDoNotMatchText", i18n.get("New passwords do not match")) %>"/>
                <input id="empty_message" type="hidden" value="<%= printProperty(cfg, i18n, xssAPI, "box/passwordEmptyText", i18n.get("New password must not be blank")) %>"/>
                <% } %>
            </div>
        <% } %>
    </div>
    <div id="push"></div>
</div>
<div id="footer" role="contentinfo">
    <div class="legal-footer"><%
        // Footer: default copyright (removable)
        if (cfg.containsKey("footer/copy/text")) {
            ProductInfoProvider productInfoProvider = sling.getService(ProductInfoProvider.class);
            String year = productInfoProvider == null ? null : productInfoProvider.getProductInfo().getYear();
            if (year == null) {
                year = String.valueOf(Calendar.getInstance().get(Calendar.YEAR));
            }
            String text = cfg.get("footer/copy/text","");
            %><span><%= xssAPI.encodeForHTML(i18n.getVar(text, "{0} is the product year", year)) %></span><%
        }
        %><ul id="usage-box"><%

            // Footer: dynamic items (config/footer/items)
            if (configs.getChild("footer/items") != null) {
                Iterator<Resource> footerItems = configs.getChild("footer/items").listChildren();
                while (footerItems.hasNext()) {
                    %>
                    <li><%
                    String itemName = footerItems.next().getName();
                    String href = i18n.getVar(cfg.get("footer/items/" + itemName + "/href", String.class));
                    if (href != null) {
                        %><a href="<%= xssAPI.getValidHref(href) %>"><%
                    }
                    %><%= printProperty(cfg, i18n, xssAPI, "footer/items/" + itemName + "/text", "") %><%
                    if (href != null) {
                        %></a><%
                    }
                    %></li><%
                }
            }
        %>
        </ul>
    </div>
</div><%
    String modalTitle = printProperty(cfg, i18n, xssAPI, "changePasswordSuccessTitle", i18n.get("Password Changed"));
%><coral-dialog id="success-dialog" variant="success" closable="true">
    <coral-dialog-header><%= modalTitle %></coral-dialog-header>
    <coral-dialog-content>
        <%= printProperty(cfg, i18n, xssAPI, "changePasswordSuccessText", i18n.get("Your password has been changed successfully.")) %>
    </coral-dialog-content>
    <coral-dialog-footer>
        <button is="coral-button" variant="primary" coral-close><%= i18n.get("Ok") %></button>
    </coral-dialog-footer>
</coral-dialog>
<script type="text/javascript">
    // try to append the current hash/fragment to the redirect resource
    if (window.location.hash) {
        var resource = document.getElementById("resource");
        if (resource) {
            resource.value += window.location.hash;
        }
    }
</script>
<% } else { %>
<script type="text/javascript">
    var redirect = '<%= xssAPI.encodeForJSString(xssAPI.getValidHref(redirect)) %>';
    if (window.location.hash) {
        redirect += window.location.hash;
    }
    document.location = redirect;
</script>
<% } %>
<!-- QUICKSTART_HOMEPAGE - (string used for readyness detection, do not remove) -->
</body>
</html>
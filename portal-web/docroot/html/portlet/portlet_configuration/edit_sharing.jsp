<%
/**
 * Copyright (c) 2000-2009 Liferay, Inc. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
%>

<%@ include file="/html/portlet/portlet_configuration/init.jsp" %>

<%
String tabs2 = ParamUtil.getString(request, "tabs2", "any-website");

String redirect = ParamUtil.getString(request, "redirect");
String returnToFullPageURL = ParamUtil.getString(request, "returnToFullPageURL");

String portletResource = ParamUtil.getString(request, "portletResource");

Portlet portlet = PortletLocalServiceUtil.getPortletById(company.getCompanyId(), portletResource);

PortletPreferences preferences = PortletPreferencesFactoryUtil.getLayoutPortletSetup(layout, portletResource);

PortletURL portletURL = renderResponse.createRenderURL();

portletURL.setWindowState(WindowState.MAXIMIZED);

portletURL.setParameter("struts_action", "/portlet_configuration/edit_sharing");
portletURL.setParameter("redirect", redirect);
portletURL.setParameter("returnToFullPageURL", returnToFullPageURL);
portletURL.setParameter("portletResource", portletResource);

String widgetURL = PortalUtil.getWidgetURL(portlet, themeDisplay);
%>

<liferay-util:include page="/html/portlet/portlet_configuration/tabs1.jsp">
	<liferay-util:param name="tabs1" value="sharing" />
</liferay-util:include>

<liferay-ui:tabs
	names="any-website,facebook,google-gadget,netvibes,friends"
	param="tabs2"
	url="<%= portletURL.toString() %>"
/>

<portlet:actionURL windowState="<%= WindowState.MAXIMIZED.toString() %>" var="editSharingURL">
	<portlet:param name="struts_action" value="/portlet_configuration/edit_sharing" />
	<portlet:param name="<%= Constants.CMD %>" value="<%= Constants.SAVE %>" />
</portlet:actionURL>

<aui:form action="<%= editSharingURL %>" method="post" name="fm">
	<aui:input name="tabs2" type="hidden" value="<%= tabs2 %>" />
	<aui:input name="redirect" type="hidden" value="<%= currentURL %>" />
	<aui:input name="returnToFullPageURL" type="hidden" value="<%= returnToFullPageURL %>" />
	<aui:input name="portletResource" type="hidden" value="<%= portletResource %>" />

	<aui:fieldset>
		<c:choose>
			<c:when test='<%= tabs2.equals("any-website") %>'>

				<%
				boolean widgetShowAddAppLink = GetterUtil.getBoolean(preferences.getValue("lfr-widget-show-add-app-link", null), PropsValues.THEME_PORTLET_SHARING_DEFAULT);
				%>

				<div class="portlet-msg-info">
					<liferay-ui:message key="share-this-application-on-any-website" />
				</div>

				<liferay-util:buffer var="textAreaContent">
<script src="<%= themeDisplay.getPortalURL() %><%= themeDisplay.getPathContext() %>/html/js/liferay/widget.js" type="text/javascript"></script>
<script type="text/javascript">
	Liferay.Widget({ url: '<%= widgetURL %>'});
</script>
				</liferay-util:buffer>

				<aui:input type="textarea" cssClass="lfr-textarea-container" label="" name="example" onClick="Liferay.Util.selectAndCopy(this);" value="<%= textAreaContent %>" />

				<aui:input inlineLabel="left" label='<%= LanguageUtil.format(pageContext, "allow-users-to-add-x-to-any-website", portletDisplay.getTitle()) %>' name="widgetShowAddAppLink" type="checkbox" value="<%= widgetShowAddAppLink %>" />
			</c:when>
			<c:when test='<%= tabs2.equals("facebook") %>'>

				<%
				String facebookAPIKey = GetterUtil.getString(preferences.getValue("lfr-facebook-api-key", null));
				String facebookCanvasPageURL = GetterUtil.getString(preferences.getValue("lfr-facebook-canvas-page-url", null));
				boolean facebookShowAddAppLink = GetterUtil.getBoolean(preferences.getValue("lfr-facebook-show-add-app-link", null), true);

				String callbackURL = widgetURL;

				if (portlet.getFacebookIntegration().equals(PortletConstants.FACEBOOK_INTEGRATION_FBML)) {
					PortletURL fbmlPortletURL = new PortletURLImpl(request, portletResource, plid, PortletRequest.RENDER_PHASE);

					fbmlPortletURL.setWindowState(WindowState.MAXIMIZED);

					fbmlPortletURL.setParameter("struts_action", "/message_boards/view");

					callbackURL = FacebookUtil.getCallbackURL(fbmlPortletURL.toString(), facebookCanvasPageURL);
				}
				%>

				<div class="portlet-msg-info">
					<a href="http://www.facebook.com/developers/editapp.php?new" target="_blank"><liferay-ui:message key="get-the-api-key-and-canvas-page-url-from-facebook" /></a>
				</div>

				<aui:input cssClass="lfr-input-text-container" label="api-key" name="facebookAPIKey" value="<%= HtmlUtil.toInputSafe(facebookAPIKey) %>" />

				<aui:input cssClass="lfr-input-text-container flexible" label="canvas-page-url" name="facebookCanvasPageURL" prefix="http://apps.facebook.com/" suffix="/" value="<%= HtmlUtil.toInputSafe(facebookCanvasPageURL) %>" />

				<c:if test="<%= Validator.isNotNull(facebookCanvasPageURL) %>">
					<br />

					<div class="portlet-msg-info">
						<liferay-ui:message key="copy-the-callback-url-and-specify-it-in-facebook" />

						<c:choose>
							<c:when test="<%= portlet.getFacebookIntegration().equals(PortletConstants.FACEBOOK_INTEGRATION_FBML) %>">
								<liferay-ui:message key="this-application-is-exposed-to-facebook-via-fbml" />
							</c:when>
							<c:otherwise>
								<liferay-ui:message key="this-application-is-exposed-to-facebook-via-an-iframe" />
							</c:otherwise>
						</c:choose>
					</div>

					<label><liferay-ui:message key="callback-url" /></label>
					<liferay-ui:input-resource url="<%= callbackURL %>" />

					<aui:input inlineLabel="left" label='<%= LanguageUtil.format(pageContext, "allow-users-to-add-x-to-facebook", portletDisplay.getTitle()) %>' name="facebookShowAddAppLink" type="checkbox" value="<%= facebookShowAddAppLink %>" />
				</c:if>
			</c:when>
			<c:when test='<%= tabs2.equals("google-gadget") %>'>

				<%
				boolean iGoogleShowAddAppLink = PrefsParamUtil.getBoolean(preferences, request, "lfr-igoogle-show-add-app-link");
				%>

				<div class="portlet-msg-info">
					<liferay-ui:message key="use-the-google-gadget-url-to-create-a-google-gadget" />
				</div>

				<label><liferay-ui:message key="google-gadget-url" /></label>
				<liferay-ui:input-resource url="<%= PortalUtil.getGoogleGadgetURL(portlet, themeDisplay) %>" />

				<aui:input inlineLabel="left" label='<%= LanguageUtil.format(pageContext, "allow-users-to-add-x-to-igoogle", portletDisplay.getTitle()) %>' name="iGoogleShowAddAppLink" type="checkbox" value="<%= iGoogleShowAddAppLink %>" />
			</c:when>
			<c:when test='<%= tabs2.equals("netvibes") %>'>

				<%
				boolean netvibesShowAddAppLink = PrefsParamUtil.getBoolean(preferences, request, "lfr-netvibes-show-add-app-link");
				%>

				<div class="portlet-msg-info">
					<liferay-ui:message key="use-the-netvibes-widget-url-to-create-a-netvibes-widget" />
				</div>

				<label><liferay-ui:message key="netvibes-widget-url" /></label>
				<liferay-ui:input-resource url="<%= PortalUtil.getNetvibesURL(portlet, themeDisplay) %>" />

				<aui:input inlineLabel="left" label='<%= LanguageUtil.format(pageContext, "allow-users-to-add-x-to-netvibes-pages", portletDisplay.getTitle()) %>' name="netvibesShowAddAppLink" type="checkbox" value="<%= netvibesShowAddAppLink %>" />
			</c:when>
			<c:when test='<%= tabs2.equals("friends") %>'>

				<%
				boolean appShowShareWithFriendsLink = GetterUtil.getBoolean(preferences.getValue("lfr-app-show-share-with-friends-link", null));
				%>

				<aui:input inlineLabel="left" label='<%= LanguageUtil.format(pageContext, "allow-users-to-share-x-with-friends", portletDisplay.getTitle()) %>' name="appShowShareWithFriendsLink" type="checkbox" value="<%= appShowShareWithFriendsLink %>" />
			</c:when>
		</c:choose>
	</aui:fieldset>

	<aui:button-row>
		<aui:button type="submit" value="save" />

		<aui:button onClick="<%= redirect %>" value="cancel" />
	</aui:button-row>
</aui:form>

<%
PortalUtil.addPortletBreadcrumbEntry(request, LanguageUtil.get(pageContext, tabs2), currentURL);
%>
<%--
/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/init.jsp" %>

<%
JournalFolder folder = journalDisplayContext.getFolder();

String eventName = ParamUtil.getString(request, "eventName", liferayPortletResponse.getNamespace() + "selectFolder");

String folderName = LanguageUtil.get(request, "home");

if (folder != null) {
	folderName = folder.getName();

	JournalPortletUtil.addPortletBreadcrumbEntries(folder, request, journalDisplayContext.getPortletURL());
}
%>

<aui:form method="post" name="selectFolderFm">
	<liferay-ui:header
		title="home"
	/>

	<liferay-ui:breadcrumb showCurrentGroup="<%= false %>" showGuestGroup="<%= false %>" showLayout="<%= false %>" showParentGroups="<%= false %>" />

	<%
	PortletURL portletURL = renderResponse.createRenderURL();

	portletURL.setParameter("mvcPath", "/select_folder.jsp");
	portletURL.setParameter("folderId", String.valueOf(journalDisplayContext.getFolderId()));
	%>

	<%
	boolean hasAddFolderPermission = JournalFolderPermission.contains(permissionChecker, scopeGroupId, journalDisplayContext.getFolderId(), ActionKeys.ADD_FOLDER);
	%>

	<aui:button-row>
		<c:if test="<%= hasAddFolderPermission %>">
			<portlet:renderURL var="editFolderURL">
				<portlet:param name="mvcPath" value="/edit_folder.jsp" />
				<portlet:param name="redirect" value="<%= currentURL %>" />
				<portlet:param name="parentFolderId" value="<%= String.valueOf(journalDisplayContext.getFolderId()) %>" />
			</portlet:renderURL>

			<aui:button href="<%= editFolderURL %>" value='<%= (folder == null) ? "add-folder" : "add-subfolder" %>' />
		</c:if>

		<%
		Map<String, Object> data = new HashMap<String, Object>();

		data.put("folderid", String.valueOf(journalDisplayContext.getFolderId()));
		data.put("foldername", HtmlUtil.escape(folderName));
		%>

		<aui:button cssClass="selector-button" data="<%= data %>" value="choose-this-folder" />
	</aui:button-row>

	<br />

	<liferay-ui:search-container
		iteratorURL="<%= portletURL %>"
		total="<%= JournalFolderServiceUtil.getFoldersCount(scopeGroupId, journalDisplayContext.getFolderId()) %>"
	>
		<liferay-ui:search-container-results
			results="<%= JournalFolderServiceUtil.getFolders(scopeGroupId, journalDisplayContext.getFolderId(), searchContainer.getStart(), searchContainer.getEnd()) %>"
		/>

		<liferay-ui:search-container-row
			className="com.liferay.journal.model.JournalFolderModel"
			keyProperty="folderId"
			modelVar="curFolder"
			rowVar="row"
		>
			<liferay-portlet:renderURL varImpl="rowURL">
				<portlet:param name="mvcPath" value="/select_folder.jsp" />
				<portlet:param name="folderId" value="<%= String.valueOf(curFolder.getFolderId()) %>" />
			</liferay-portlet:renderURL>

			<%
			AssetRendererFactory<JournalFolder> assetRendererFactory = AssetRendererFactoryRegistryUtil.getAssetRendererFactoryByClass(JournalFolder.class);

			AssetRenderer<JournalFolder> assetRenderer = assetRendererFactory.getAssetRenderer(curFolder.getFolderId());

			int foldersCount = 0;
			int articlesCount = 0;

			List<Long> subfolderIds = JournalFolderServiceUtil.getSubfolderIds(scopeGroupId, curFolder.getFolderId(), false);

			foldersCount = subfolderIds.size();

			subfolderIds.clear();
			subfolderIds.add(curFolder.getFolderId());

			articlesCount = JournalArticleServiceUtil.getFoldersAndArticlesCount(scopeGroupId, subfolderIds);
			%>

			<liferay-ui:search-container-column-text
				name="folder"
			>
				<liferay-ui:icon
					iconCssClass="<%= assetRenderer.getIconCssClass() %>"
					label="<%= true %>"
					message="<%= HtmlUtil.escape(curFolder.getName()) %>"
					url="<%= (rowURL != null) ? rowURL.toString() : StringPool.BLANK %>"
				/>
			</liferay-ui:search-container-column-text>

			<liferay-ui:search-container-column-text
				name="num-of-folders"
				value="<%= String.valueOf(foldersCount) %>"
			/>

			<liferay-ui:search-container-column-text
				name="num-of-web-content-instances"
				value="<%= String.valueOf(articlesCount) %>"
			/>

			<c:if test="<%= rowURL != null %>">
				<liferay-ui:search-container-column-text>

					<%
					Map<String, Object> data = new HashMap<String, Object>();

					data.put("folderid", curFolder.getFolderId());
					data.put("foldername", HtmlUtil.escape(curFolder.getName()));
					%>

					<aui:button cssClass="selector-button" data="<%= data %>" value="choose" />
				</liferay-ui:search-container-column-text>
			</c:if>

		</liferay-ui:search-container-row>

		<liferay-ui:search-iterator />
	</liferay-ui:search-container>
</aui:form>

<aui:script>
	Liferay.Util.selectEntityHandler('#<portlet:namespace />selectFolderFm', '<%= HtmlUtil.escapeJS(eventName) %>');
</aui:script>
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

<%@ include file="/html/taglib/init.jsp" %>

<%
SearchContainer searchContainer = (SearchContainer)request.getAttribute("liferay-ui:search:searchContainer");

String markupView = (String)request.getAttribute("liferay-ui:search-iterator:markupView");
boolean paginate = GetterUtil.getBoolean((String)request.getAttribute("liferay-ui:search-iterator:paginate"));
ResultRowSplitter resultRowSplitter = (ResultRowSplitter)request.getAttribute("liferay-ui:search-iterator:resultRowSplitter");
String type = (String)request.getAttribute("liferay-ui:search:type");

String id = searchContainer.getId(request, namespace);

List resultRows = searchContainer.getResultRows();
List<String> headerNames = searchContainer.getHeaderNames();
List<String> normalizedHeaderNames = searchContainer.getNormalizedHeaderNames();
String emptyResultsMessage = searchContainer.getEmptyResultsMessage();
RowChecker rowChecker = searchContainer.getRowChecker();

if (rowChecker != null) {
	if (headerNames != null) {
		headerNames.add(0, StringPool.BLANK);

		normalizedHeaderNames.add(0, "rowChecker");
	}
}

JSONArray primaryKeysJSONArray = JSONFactoryUtil.createJSONArray();
%>

<c:if test="<%= resultRows.isEmpty() && (emptyResultsMessage != null) %>">
	<liferay-ui:empty-result-message message="<%= emptyResultsMessage %>" />
</c:if>

<div id="<%= namespace + id %>SearchContainer">

	<%
	request.setAttribute(WebKeys.SEARCH_CONTAINER_RESULT_ROW_CHECKER, rowChecker);

	boolean allRowsIsChecked = true;

	List<List<com.liferay.portal.kernel.dao.search.ResultRow>> resultRowsList = new ArrayList<List<com.liferay.portal.kernel.dao.search.ResultRow>>();

	if (resultRowSplitter != null) {
		resultRowsList = resultRowSplitter.split(searchContainer.getResultRows());
	}
	else {
		resultRowsList.add(resultRows);
	}

	for (int i = 0; i < resultRowsList.size(); i++) {
		List<com.liferay.portal.kernel.dao.search.ResultRow> curResultRows = resultRowsList.get(i);
	%>

		<ul class="<%= searchContainer.getCssClass() %> <%= resultRows.isEmpty() ? "hide" : StringPool.BLANK %> list-unstyled row">

			<%
			for (int j = 0; j < curResultRows.size(); j++) {
				com.liferay.portal.kernel.dao.search.ResultRow row = curResultRows.get(j);

				primaryKeysJSONArray.put(row.getPrimaryKey());

				request.setAttribute(WebKeys.SEARCH_CONTAINER_RESULT_ROW, row);

				List entries = row.getEntries();

				boolean rowIsChecked = false;

				if (rowChecker != null) {
					rowIsChecked = rowChecker.isChecked(row.getObject());

					if (!rowIsChecked) {
						allRowsIsChecked = false;
					}
				}

				request.setAttribute("liferay-ui:search-container-row:rowId", id.concat(StringPool.UNDERLINE.concat(row.getRowId())));

				Map<String, Object> data = row.getData();
			%>

				<li class="<%= GetterUtil.getString(row.getClassName()) %> <%= row.getCssClass() %> <%= rowIsChecked ? "active" : StringPool.BLANK %>"  <%= AUIUtil.buildData(data) %>>

					<%
					for (int k = 0; k < entries.size(); k++) {
						com.liferay.portal.kernel.dao.search.SearchEntry entry = (com.liferay.portal.kernel.dao.search.SearchEntry)entries.get(k);

						entry.setIndex(k);

						request.setAttribute(WebKeys.SEARCH_CONTAINER_RESULT_ROW_ENTRY, entry);
					%>

							<%
							entry.print(pageContext.getOut(), request, response);
							%>

					<%
					}
					%>

				</li>

				<%
					request.removeAttribute(WebKeys.SEARCH_CONTAINER_RESULT_ROW);
					request.removeAttribute(WebKeys.SEARCH_CONTAINER_RESULT_ROW_ENTRY);

					request.removeAttribute("liferay-ui:search-container-row:rowId");
				}
				%>

				<c:if test="<%= i == (resultRowsList.size() - 1) %>">
					<li></li>
				</c:if>
			</ul>

		<%
		}
		%>

</div>

<c:if test="<%= PropsValues.SEARCH_CONTAINER_SHOW_PAGINATION_BOTTOM && paginate %>">
	<div class="<%= resultRows.isEmpty() ? "hide" : StringPool.BLANK %> taglib-search-iterator-page-iterator-bottom">
		<liferay-ui:search-paginator id='<%= id + "PageIteratorBottom" %>' markupView="<%= markupView %>" searchContainer="<%= searchContainer %>" type="<%= type %>" />
	</div>
</c:if>

<c:if test="<%= Validator.isNotNull(id) %>">
	<input id="<%= namespace + id %>PrimaryKeys" name="<%= namespace + id %>PrimaryKeys" type="hidden" value="" />

	<aui:script use="liferay-search-container">
		var searchContainer = new Liferay.SearchContainer(
			{
				classNameHover: '<%= _CLASS_NAME_HOVER %>',
				hover: <%= searchContainer.isHover() %>,
				id: '<%= namespace + id %>',
				rowClassNameAlternate: '<%= _ROW_CLASS_NAME_ALTERNATE %>',
				rowClassNameAlternateHover: '<%= _ROW_CLASS_NAME_ALTERNATE_HOVER %>',
				rowClassNameBody: '<%= _ROW_CLASS_NAME_BODY %>',
				rowClassNameBodyHover: '<%= _ROW_CLASS_NAME_BODY %>'
			}
		).render();

		searchContainer.updateDataStore(<%= primaryKeysJSONArray.toString() %>);

		var destroySearchContainer = function(event) {
			if (event.portletId === '<%= portletDisplay.getRootPortletId() %>') {
				searchContainer.destroy();

				Liferay.detach('destroyPortlet', destroySearchContainer);
			}
		};

		Liferay.on('destroyPortlet', destroySearchContainer);
	</aui:script>
</c:if>

<%!
private static final String _CLASS_NAME_HOVER = "hover";

private static final String _ROW_CLASS_NAME_ALTERNATE = "";

private static final String _ROW_CLASS_NAME_ALTERNATE_HOVER = "-hover";

private static final String _ROW_CLASS_NAME_BODY = "";
%>
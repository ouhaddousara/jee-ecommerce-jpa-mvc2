<%@ tag language="java" pageEncoding="UTF-8" body-content="empty" description="Hidden CSRF field: every POST form must include it" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<input type="hidden" name="_csrf" value="<c:out value='${sessionScope.csrf}'/>">

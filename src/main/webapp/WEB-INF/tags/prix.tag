<%@ tag language="java" pageEncoding="UTF-8" body-content="empty" description="Formats an amount: 1 007,00 MAD" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ attribute name="valeur" required="true" type="java.math.BigDecimal" %>
<fmt:formatNumber value="${valeur}" minFractionDigits="2" maxFractionDigits="2"/>&#160;MAD

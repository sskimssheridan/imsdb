<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Error</title>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
</head>

<body>
<table id="mainView">
<colgroup>
    <col width="25%">
    <col width="25%">
    <col width="25%">
    <col width="25%">
</colgroup>
	<tr>
		<td id = "logoBar" colspan="3">
			<img src="${pageContext.request.contextPath}/images/Sheridan_College_Logo.jpg" height="75">
		</td>
		<td id = "welcomeMsg" colspan="1">
		</td>
	</tr>
	<tr>
		<td id = "workingBar" colspan="4">
			<table>
				<tr>
					<td>
						<h3>Error ${sessionScope.error}</h3>
					</td>
				</tr>
				<tr>
					<td>
						<input type="submit" value="Back to Login" onclick="window.location='${pageContext.request.contextPath}/index.jsp';" />
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
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
			<colgroup>
			    <col width="25%">
			    <col width="25%">
			    <col width="25%">
			    <col width="25%">
			</colgroup>
				<tr>
					<td colspan="4">
						<h3>Error Occurred While Connecting to Database </h3>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/DatabseConnectionError_Servlet" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Back To Main">
						</form>
					</td>
					<td colspan="3">
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Login</title>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
</head>

<body>
<table id="mainView">
	<tr>
		<td id = "logoBar" colspan="2">
			<img src="${pageContext.request.contextPath}/images/Sheridan_College_Logo.jpg" height="75">
		</td>
	</tr>
	<tr>
		<td id = "workingBar" colspan="2">
			<h3>Sign In</h3>
			<h4>Fields marked with an <span class="required">*</span> are required.</h4>
			<form action="${pageContext.request.contextPath}/LoginServlet" method="post">
			<table>
				<tr>
					<td class="field">USER ID: <span class="required">*</span></td>
					<td>
						<input type="text" id="username" name="username" size="20" value="${param.username}"/>
					</td>
					<td>
						<span class="error">${messages.username}</span><br>
					</td>
				</tr>
				<tr>
					<td class="field">PASSWORD: <span class="required">*</span></td>
					<td>
						<input type="password" id="password" name="password" size="20"/>
					</td>
					<td>
						<span class="error">${messages.password}</span><br>
					</td>
				</tr>
				<tr>
					<td class="field">LOGIN AS:</td>
					<td>
						<select name="loginAs" id="loginAs">
						  <option value="student">STUDENT</option>
						  <option value="employee">EMPLOYEE</option>
						</select>
					</td>
					<td></td>
				</tr>
				<tr>
					<td></td>
					<td>
						<input id="submit" type="submit" class="btnSubmit" value="Submit">
					</td>
				</tr>	
			</table>
			</form>
		</td>
	</tr>
</table>
</body>
</html>
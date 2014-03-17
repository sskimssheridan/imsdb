<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*,java.util.*,java.text.*,java.util.Date" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Pending Order IMSDB</title>
	<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mainIMSDB.css"/>
	<script src="http://code.jquery.com/jquery-1.9.1.js"></script>
  	<script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
  	<script src="${pageContext.request.contextPath}/jQuery/jquery.elevatezoom.js"></script>
	<script src="${pageContext.request.contextPath}/jQuery/paging.js"></script>
	<%
	if(session.getAttribute("name")== null || session.getAttribute("name").equals("") || !(session.getAttribute("role").equals("ADMINISTRATOR") || session.getAttribute("role").equals("TECHNICIAN")))
	{
		request.getRequestDispatcher("/index.jsp").forward(request, response);
	}
	%>
	<style type="text/css">    
         .pg-normal {
             color: black;
             font-weight: normal;
             text-decoration: none;    
             cursor: pointer;    
         }
         .pg-selected {
             color: black;
             font-weight: bold;        
             text-decoration: underline;
             cursor: pointer;
         }
    </style>
    
    <style type="text/css" media='print' >
	@page
    {
        size: auto;   /* auto is the initial value */
        margin: 0mm;  /* this affects the margin in the printer settings */
    }
	body {visibility: hidden;}
	#orderSerachTable 
	{
		visibility: visible;
        position: absolute;
        top: 0;
	}
	.orderSearchRows 
	{
		display:block!important;	
		page-break-inside:avoid;
		page-break-after:auto;
		
	}
	</style>
	<script>
	$(document).ready(function(){
		//for image zooming
		$(".itemImage").elevateZoom();

	})
	
	//validating number field
	function validate(evt)
	{
		var theEvent = evt || window.event;
		var key = theEvent.keyCode || theEvent.which;
		key = String.fromCharCode( key );
		var regex = /[0-9]/;
		if( !regex.test(key) )
		{
			theEvent.returnValue = false;
			if(theEvent.preventDefault) theEvent.preventDefault();
		}
	}
	</script>
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
			Welcome ${sessionScope.name}
			<br/>
			<% // setting date format and Displaying it
				java.text.DateFormat df = new java.text.SimpleDateFormat("EEE, MMM d, YYYY h:mm a");
			%> 
			<%= df.format(new java.util.Date()) %>
			<form action="${pageContext.request.contextPath}/LogoutServlet" method="post">
				<input id="submit" type="submit" class="btnLogout" value="Logout">
			</form>
		</td>
	</tr>
	<tr>
		<td id="role" colspan="4">
			<h4>You are in Pending Order </h4>
		</td>
	</tr>
	<tr>
		<td id = "menuBar" colspan="1">
			<table>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Admin_BackToMain" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Back To Main">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Admin_OrderPlace" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Place Order">
						</form>
					</td>
				</tr>
				<tr>
					<td>
						<form action="${pageContext.request.contextPath}/Admin_OrderSearch" method="post">
							<input id="submit" type="submit" class="btnSubmit" value="Search Order">
						</form>
					</td>
				</tr>
			</table>
		</td>
		<td id = "workingBar" colspan="3">
			<%
				String valid = request.getAttribute("valid") != null ? request.getAttribute("valid").toString() : "";
				if(valid != null && valid.trim().equals("1"))
				{
			%>
			<span class="error">
				${messages.result}
			</span>
			<%
				}
				else if(valid != null && valid.trim().equals("2"))
				{
			%>
			<span class="error">
				${messages.error}
			</span>
			<%
				}
			%>
			<form method="post" action="${pageContext.request.contextPath}/Admin_OrderPending_Servlet">
			<table>
			<colgroup>
			    <col width="25%">
			    <col width="25%">
			    <col width="25%">
			    <col width="25%">
			</colgroup>
				<!-- Connecting to the database -->
				<%
					Context initContext;
					Context envContext;
					DataSource ds = null;
					Connection conn = null;
					Statement st = null;
					Statement st1 = null;
					Statement st2 = null;
					ResultSet rs = null;
					ResultSet rsSub = null;
					ResultSet rsSub2 = null;
					
					try
					{
						initContext = new InitialContext();
						envContext  = (Context)initContext.lookup("java:/comp/env");
						ds = (DataSource)envContext.lookup("jdbc/myoracle");
						conn = ds.getConnection();
						st = conn.createStatement();
						st1 = conn.createStatement();
						st2 = conn.createStatement();
					}
					catch(Exception e)
					{
						request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
					}
				%>
				<tr>
					<td colspan="4">
						<table width="100%" id="orderSerachTable">
									<tr>
										<td>
											<h4>PENDING ORDERS SEARCH RESULT</h4>
										</td>
									</tr>
									<%
									try
									{
										String sql = "SELECT * FROM ITEM_ORDER WHERE ORDER_STATUS = 'PENDING' ORDER BY DATE_OF_ORDER DESC";
										//executing query
										rs = st.executeQuery(sql);
										
										while(rs.next())
										{
											String orderItem = rs.getString("ITEM_ID").trim();
											String barcodeID = null;
											String itemOrderID = rs.getString("ITEM_ORDER_ID").trim();
											
											String orderDate = rs.getString("DATE_OF_ORDER").trim();
											
											//converting date to MM/dd/yyyy format
								    		SimpleDateFormat format10 = new SimpleDateFormat("yyyy-MM-dd");
								    	    SimpleDateFormat format20 = new SimpleDateFormat("dd-MMM-yy");
								    	    
								            Date dateExp1 = format10.parse(orderDate);
								            
								            orderDate = format20.format(dateExp1);
											
											rsSub = st1.executeQuery("SELECT * FROM ITEM WHERE ITEM_ID ='"+orderItem+"'");
											
											if(rsSub.next())
											{
												barcodeID = rsSub.getString("CAMPUS_ID").trim();
												barcodeID += rsSub.getString("LAB_ID").trim();
												barcodeID += rsSub.getString("CONTAINER_CODE").trim();
												barcodeID += rsSub.getString("CATEGORY_ID").trim();
												barcodeID += orderItem;
											}
										%>
									<tr class="orderSearchRows">
										<td>
											<div class="orderSerachDiv">
												<table width="100%" border="1">
												<colgroup>
												    <col width="35%">
												    <col width="25%">
												    <col width="40%">
												</colgroup>
													<tr>
														<td>
															<div id="imageItem">
																<img class="itemImage" 
																src="${pageContext.request.contextPath}/ItemDisplay_ItemCreated?itemID=<%= orderItem %>" 
																width="90" height="90" alt="no image" onerror="this.src='${pageContext.request.contextPath}/images/no-photo.jpg';"/>
															</div>
														</td>
														<td colspan="2"  class="field">
															<%= barcodeID%>
														</td>
													</tr>
													<tr>
														<td class="field">
															ORDER ID:
														</td>
														<td colspan="2">
															<%= itemOrderID %>
														</td>
													</tr>
													<tr>
														<td class="field">
															SUPPLIER:
														</td>
														<td colspan="2">
															<%
																String supplier = "";
																rsSub = st1.executeQuery("SELECT SNAME FROM SUPPLIER WHERE SUPPLIER_ID ='"+rs.getString("SUPPLIER_ID")+"'");
																if (rsSub.next())
																{
																	supplier = rsSub.getString("SNAME").trim(); 
																}
															%>
														<select name="supplierID" id="supplierID">
															<%
																rsSub = st1.executeQuery("SELECT DISTINCT SUPPLIER_ID FROM SUPPLIER_ITEM WHERE ITEM_ID = '"+orderItem+"'");
																while(rsSub.next())
																{
																	String supID = rsSub.getString("SUPPLIER_ID");
																	rsSub2 = st2.executeQuery("SELECT SNAME FROM SUPPLIER WHERE SUPPLIER_ID = '"+supID.trim()+"'");
																	while(rsSub2.next())
														    		{
																		String supName = rsSub2.getString("SNAME");
														    			%>
														    			<option value="<%= supID.trim()%>"  <% if(supName.trim().toUpperCase().equals(supplier.toUpperCase())){%>selected="selected"<%} %>
														    			><%= supName%></option>
														    			<% 
														    		}
																}
															%>
														</select>
														</td>
													</tr>
													<tr>
														<td class="field">
															ORDER DATE:
														</td>
														<td colspan="2">
															<%= orderDate %>
														</td>
													</tr>
													<tr>
														<td class="field">
															EMPLOYEE ID:
														</td>
														<td colspan="2">
															<%= rs.getString("EMPLOYEE_ID").trim() %>
														</td>
													</tr>
													<tr>
														<td class="field">
															QUANTITY:
														</td>
														<td colspan="2">
															<input type='text' name="quantity" id="quantity" onkeypress='validate(event)' maxlength="5" size="10" value="<%= rs.getString("ORDER_ITEM_QUANTITY").trim() %>"/>
														</td>
													</tr>
													<tr>
														<td class="field">
															PURPOSE OF ORDER:
														</td>
														<td colspan="2">
															<%= rs.getString("PURPOSE_OF_ORDER").trim() %>
														</td>
													</tr>
													<tr>
														<td class="field">
															DESCRIPTION:
														</td>
														<td colspan="2">
															<%= rs.getString("DESCRIPTION").trim() %>
														</td>
													</tr>
													<tr>
														<td class="field">
															ORDER STATUS:
														</td>
														<td colspan="2">
															<%= rs.getString("ORDER_STATUS").trim() %>
														</td>
													</tr>
													<tr>
														<td colspan="3">
															<button id="cancelOrder" name="act" type="submit" class="btnSubmit" value="CAN<%= itemOrderID %>">CANCEL ORDER</button>
														</td>
													</tr>
													<tr>
														<td colspan="3">
															<button id="approveOrder" name="act" type="submit" class="btnSubmit" value="APP<%= itemOrderID %>">APPROVE ORDER</button>
														</td>
													</tr>
												</table>
											</div>
										</td>
									</tr>
										<%
										}
									}
									catch(Exception e)
									{
										request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
									}
									%>
								</table>
								<div id="pageNavPosition"></div>
								 <script type="text/javascript">
							        var pager = new Pager('orderSerachTable', 5); 
							        pager.init(); 
							        pager.showPageNav('pager', 'pageNavPosition'); 
							        pager.showPage(1);
		    					</script>
		    					<br/>
		    					<input type='button' class="btnSubmit" value='Print' onclick='window.print()'/>
							</td>
						</tr>
					</table>
				<!-- Closing database connection-->	
				<% 
					try
					{
						conn.close();
					}
					catch(Exception e)
					{
						request.getRequestDispatcher("jsp/task/item/Error/ErrorConnection.jsp").forward(request, response);
					}		
				%>
			</form>
		</td> 
	</tr>
</table>
</body>
</html>
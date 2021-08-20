<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
    <% 
	request.setCharacterEncoding("EUC-KR");	
	%>
<jsp:useBean id="itemBean" class="com.mission.javabeans.ItemBean" />
<jsp:setProperty property="*" name="itemBean"/>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Insert title here</title>
</head>
<style>
body {
	margin-top: 200px;
	text-align: center;
	margin: 0 auto;
	background-color: #515F6D;
}

h2 {
	font-size: 40px;
	color: white;
	margin-bottom: 50px;
	margin-top: 100px;
}

table {
	width: 60%;
	backgroud-color: white;
	margin: 0 auto;
}

td {
	color: black;
	backgroud-color: white;
}

.record {
	background-color: white;
	text-align: center;
}

th {
	color: black;
	background-color: #EAEAEA;
	margin-top: 50px;
}

.inbutton {
	margin-top: 50px;
	background-color: #3498DB;
	font-size: medium;
	color: white;
	font-weight: bold;
}

#checkboxtbl {
	width: 50px;
}

#desc {
	padding-bottom: 25px;
	font-size: 12px;
	font-weight: bold;
}
</style>
<body>
<%
try{
	
	String url="jdbc:oracle:thin:@192.168.116.15:1521:XE";
	String uid="testuser";
	String pass="testuser";
	
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs = null;
	Class.forName("oracle.jdbc.driver.OracleDriver");
	System.out.println("드라이버 로딩 성공");
	conn = DriverManager.getConnection(url, uid, pass);
	System.out.println("연결 성공");

	String user_pw = request.getParameter("pwd");

	
	stmt = conn.createStatement();
	String sql = "SELECT * FROM EMP WHERE PWD='" + user_pw + "'" ;
	stmt.executeUpdate(sql);
	rs = stmt.executeQuery(sql);
	
	Boolean correct = false;
	while(rs.next()){
		correct = true;
	}
	
	if (correct){
		session.setAttribute("pwd", user_pw);
		String pwdflag = "yes";
		%>
		<script>
		alert("확인되었습니다.");
		</script>
		<%
		 response.sendRedirect("defectiveList.jsp");
	}else{
		%> <script type="text/javascript">
			alert("비밀번호가 틀렸습니다.");
		   	history.go(-1);
		    </script>
		<% 
	}
}catch(Exception e){
	e.printStackTrace();
}

%>
</body>
</html>
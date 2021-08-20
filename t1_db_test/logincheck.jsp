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

	
	String user_id = request.getParameter("id");
	String user_pw = request.getParameter("pwd");

	
	stmt = conn.createStatement();
	String sql = "SELECT * FROM EMP WHERE ID='" + user_id + "' AND PWD='" + user_pw+ "'";
	stmt.executeUpdate(sql);
	rs = stmt.executeQuery(sql);
	
	Boolean correct = false;
	while(rs.next()){
		correct = true;
	}
	
	if (correct){
		session.setAttribute("id", user_id);
		session.setAttribute("pwd", user_pw);
		response.sendRedirect("dashboard.jsp");
	}else{
		%> <script type="text/javascript">alert("아이디 또는 비밀번호가 틀렸습니다.");
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
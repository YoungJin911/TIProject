<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
    
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>

<%@page import="java.util.Date" %>
<%@page import="java.text.SimpleDateFormat" %>   
<%@page import="java.util.Calendar" %>      
<%
request.setCharacterEncoding("EUC-KR");
%>
<jsp:useBean id="itemBean" class="com.mission.javabeans.ItemBean" />
<jsp:setProperty property="*" name="itemBean" />



   <%
   int zero = 0;
   int one = 0;
   int all = 0;
   int err = 0;

   Date todayTime = new Date();
   SimpleDateFormat sf = new SimpleDateFormat("yyyy:MM:dd");
   Calendar cal = Calendar.getInstance();
   int todaydate = cal.get(Calendar.DATE);
   String today = sf.format(todayTime);
   int yesterday = 0;
   
   SimpleDateFormat sf2 = new SimpleDateFormat("yyyy:MM:dd:HH:mm:ss");
   String todayall = sf2.format(todayTime);
   
   try {
      String url = "jdbc:oracle:thin:@192.168.116.15:1521:XE";
      String uid = "testuser";
      String pass = "testuser";
      Class.forName("oracle.jdbc.driver.OracleDriver");
      System.out.println("드라이버 로딩 성공");
      Connection conn = null;
      Statement stmt = null;
      conn = DriverManager.getConnection(url, uid, pass);
      System.out.println("연결 성공");
      stmt = conn.createStatement();
      
      // prod 테이블
      String sql = "select * from (select * from dashboard order by PROCESS_NO desc) where rownum=1";
      ResultSet rs = null;
      rs = stmt.executeQuery(sql);
      String num = null;
      
      System.out.println(rs);
      
      
      if(rs.next()){
         
         String processno = rs.getString("PROCESS_NO");
         String startTime = rs.getString("END_TIME");
         String sqlcount = rs.getString("PROCESS_COUNT");
         String sqlstartDate = startTime.substring(0,10);
         
         
         PreparedStatement pstmt = null;
         PreparedStatement pstmt2 = null;
      
         
         System.out.println("sqlstartdate:"+sqlstartDate);
         System.out.println("today:"+today);
         
         
         if(sqlstartDate.equals(today)){
            System.out.println("ta");
            int updatecount = Integer.parseInt(sqlcount);
            System.out.println(updatecount);
            updatecount++;
            String countString = Integer.toString(updatecount);
            pstmt = conn.prepareStatement("insert into DASHBOARD (PROCESS_NO, PROCESS_COUNT) values(SEQ_DASH_PROCESSNO.nextval,?)");
            pstmt.setString(1, countString);
            int result = pstmt.executeUpdate();
         }
         else{
            String insertsql = "insert into DASHBOARD (PROCESS_NO, PROCESS_COUNT) values(SEQ_DASH_PROCESSNO.nextval,?)";
            pstmt2 = conn.prepareStatement(insertsql);
            pstmt2.setString(1, "1");
            int result2 = pstmt2.executeUpdate();
         }
      } else{
         PreparedStatement pstmt3 = null;
         String insertsql = "insert into DASHBOARD (PROCESS_NO, PROCESS_COUNT) values(SEQ_DASH_PROCESSNO.nextval,?)";
         pstmt3 = conn.prepareStatement(insertsql);
         pstmt3.setString(1, "1");
         int result3 = pstmt3.executeUpdate();
      }
      
      
      request.setCharacterEncoding("UTF-8");
      response.sendRedirect("http://192.168.116.15:5000/"); // 나중에 바꿔주기
   %>

   <%
   } catch (Exception e) {
   e.printStackTrace();
   }
   
   
   %>

<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR"
   pageEncoding="EUC-KR"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Calendar"%>

<%
request.setCharacterEncoding("EUC-KR");
%>
<jsp:useBean id="itemBean" class="com.mission.javabeans.ItemBean" />
<jsp:setProperty property="*" name="itemBean" />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta charset="UTF-8">
<title>실시간 공정 정보</title>
</head>
<script type="text/javascript">
   window.history.forward();
   function noBack() {
      window.history.forward();
   }

   function logout() {
      alert("로그아웃 합니다.");
   }
</script>
<style>
body {
   margin-top: 200px;
   text-align: center;
   margin: 0 auto;
   background-color: #515F6D;
}

h2 {
   color: white;
   margin-left: 25%;
   text-align: left;
   font-size: 50px;

}

#logoutfor1m {
   font-size: 40px;
   color: white;
   margin-bottom: 50px;
   margin-top: 50px;
   margin-left: 7%;
   text-align: right;
   margin-top: 10%;
   float: right;
}


table {
   width: "80%";
   height: "300";
   text-align: "center";
   margin: 0 auto;
   margin-top: 50px;
   font-size: 25px;
   font-weight: bold;
}


#prostartbtn {
   background-color: #FA3D3D;
   border-color: #FA3D3D;
   color: white;
   padding: 5px 10px 5px 10px;
   display: block;
   font-size: 25px;
   font-weight: bold;
   float:right;
}

#logoutbtn {
   background-color: #3498db;
   border-color: #3498db;
   color: white;
   padding: 5px 10px 5px 10px;
   float:left;
   display: block;
   font-size: 25px;
   font-weight: bold;
}

#h2div {
   width: 50%;
   float: left;
   height: 150px;
   display: inline-block;
   float: left;
}

#btndiv {
   width: 50%;
   float: right;
   height: 150px;
}

#prodiv {
   width: 50%;
   height: 150px;
   float: left;
}

#logoutdiv {
   width: 50%;
   height: 150px;
   float: left;
}



form {
   margin: 0 auto;
   width: 50%;
   text-align: center;
}

.thcls {
   background-color: #01DFA5;
   margin: 25px;
   padding: 8px;
   border-radius: 40px;
}

.tdcls {
   margin-top: 10px;
   padding-top: 20px;
   width: 500px;
}

#charttable {
   padding-top: 30px;
   border: none;
}
#head{
   display: block;
   margin-bottom: 20px;
}
#div1{
   float: right;
   margin-right: 15px;
}
#div2{
   float: left;
}
</style>
<body bgcolor="#515f6d" onload="noBack();"
   onpageshow="if(event.persisted)noBack();" onunload="">

   <div id="head">
      <div id="h2div">
         <h2>실시간 공정 정보</h2>
      </div>
      <div id="btndiv">
         <div id="prodiv" align="right">
            <form method="post" action="processStart.jsp"  id ="div1">
               <input type="submit" value="공정시작" id="prostartbtn" />
            </form>
         </div>
         <div id="logoutdiv" align="right">
            <form action="logout.jsp" id = "div2">
               <button onclick="logout()" id="logoutbtn">로그아웃</button>
            </form>
         </div>

      </div>
   </div>
   <%
   int zero = 0;
   int one = 0;
   int all = 0;
   int err = 0;

   Date todayTime = new Date();
   SimpleDateFormat sf = new SimpleDateFormat("yyyy:MM:dd:HH:mm:ss");
   Calendar cal = Calendar.getInstance();
   int todaydate = cal.get(Calendar.DATE);
   String today = sf.format(todayTime);
   int yesterday = 0;

   int count = 0;

   int todayTotalError = 0;
   double countTotalYield = 0.0;
   int countTodayError = 0;
   int countTodaycount = 0;
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
      String sql = "SELECT * FROM PROD";
      ResultSet rs = null;
      rs = stmt.executeQuery(sql);
      String num = null;

      while (rs.next()) {
         String qual = rs.getString("quality");
         int temp1 = Integer.parseInt(qual);
         if (temp1 == 1) {
      one++;
         } else {
      zero++;
         }
         all++;
      }

      // dashboard table
      PreparedStatement pstmt = null;
      pstmt = conn.prepareStatement(
      "select sum(error_rate) from dashboard where SUBSTR(end_time,0,10) in (select to_char(sysdate,'yyyy:mm:dd') from dual)");
      ResultSet rsrs = pstmt.executeQuery();
      rsrs.next();
      countTodayError = rsrs.getInt(1);
      System.out.println("countTodayError: " + countTodayError);

      PreparedStatement pstmt2 = null;
      pstmt = conn.prepareStatement(
      "select max(process_count) from dashboard where SUBSTR(end_time,0,10) in (select to_char(sysdate,'yyyy:mm:dd') from dual)");
      ResultSet rsrs2 = pstmt.executeQuery();
      rsrs2.next();
      countTodaycount = rsrs2.getInt(1);
      System.out.println("countTodaycount: " + countTodaycount);
      if(countTodaycount != 0){
          todayTotalError = countTodayError / countTodaycount;    	  
      }


      System.out.println("todayTotalError: " + todayTotalError);

      // 수율
      PreparedStatement pstmt3 = null;
      pstmt3 = conn.prepareStatement(
      "select avg(yield) from dashboard where SUBSTR(end_time,0,10) in (select to_char(sysdate,'yyyy:mm:dd') from dual)");
      ResultSet yieldrs = pstmt3.executeQuery();
      yieldrs.next();
      countTotalYield = yieldrs.getDouble(1);
      System.out.println("countTotalYield: " + countTotalYield);

      PreparedStatement pstmt4 = null;
      pstmt4 = conn.prepareStatement(
      "select avg(yield) from dashboard where SUBSTR(end_time,0,10) in (select to_char(sysdate-3,'yyyy:mm:dd') from dual)");
      ResultSet sys3 = pstmt4.executeQuery();
      sys3.next();
      double sysminius3 = sys3.getDouble(1);
      // int countTodaYield = Integer.parseInt(temp3);
      System.out.println("sysminius3: " + sysminius3);

      PreparedStatement pstmt5 = null;
      pstmt5 = conn.prepareStatement(
      "select avg(yield) from dashboard where SUBSTR(end_time,0,10) in (select to_char(sysdate-2,'yyyy:mm:dd') from dual)");
      ResultSet sys2 = pstmt5.executeQuery();
      sys2.next();
      double sysminius2 = sys2.getDouble(1);
      // int countTodaYield = Integer.parseInt(temp3);
      System.out.println("sysminius2: " + sysminius2);

      PreparedStatement pstmt6 = null;
      pstmt5 = conn.prepareStatement(
      "select avg(yield) from dashboard where SUBSTR(end_time,0,10) in (select to_char(sysdate-1,'yyyy:mm:dd') from dual)");
      ResultSet sys1 = pstmt5.executeQuery();
      sys1.next();
      double sysminius1 = sys1.getDouble(1);
      System.out.println("sysminius1: " + sysminius1);

      PreparedStatement pstmt7 = null;
      pstmt7 = conn.prepareStatement(
      "select avg(yield) from dashboard where SUBSTR(end_time,0,10) in (select to_char(sysdate,'yyyy:mm:dd') from dual)");
      ResultSet sys = pstmt7.executeQuery();
      sys.next();
      double sysdate = sys.getDouble(1);
      System.out.println("sysdate: " + sysdate);
   %>

   <%
   } catch (Exception e) {
   e.printStackTrace();
   }
   %>


   <table>
      <tr>
         <th><span style="font-size: 1em; color: white;" class="thcls">
               ALL Good </span></th>
         <th><span style="font-size: 1em; color: white;" class="thcls">
               ALL Defect </span></th>
         <th><span style="font-size: 1em; color: white;" class="thcls">
               데이터 총 수율 </span></th>
      </tr>
      <tr align="center">
         <td class="tdcls"><span style="font-size: 1em; color: white;">
               <%
               out.println(one);
               %>
         </span></td>
         <td class="tdcls"><span style="font-size: 1em; color: white;">
               <%
               out.println(zero);
               %>
         </span></td>
         <td class="tdcls"><span style="font-size: 1em; color: white;">
               <%
               if(all != 0){
            	   out.println((double) one / (double) all * 100);    	  
               }
               
               %>
         </span></td>
      </tr>
   </table>
   <table>
      <tr>
         <th><span style="font-size: 1em; color: white;" class="thcls">
               오늘 공정 평균 오류율 </span></th>
         <th><span style="font-size: 1em; color: white;" class="thcls">
               오늘 공정 평균 수율 </span></th>
      </tr>
      <tr align="center">
         <td class="tdcls"><span style="font-size: 1em; color: white;">
               <%
               out.println(todayTotalError);
               %>
         </span></td>
         <td class="tdcls"><span style="font-size: 1em; color: white;">
               <%
               out.println(countTotalYield);
               %>
         </span></td>
      </tr>

   </table>
   <table id="charttable">
      <tr>
         <th><span style="font-size: 1em; color: white;"> </span></th>
         <th><span style="font-size: 1em; color: white;"> </span></th>
         <th><span style="font-size: 1em; color: white;"> </span></th>
      </tr>
      <tr align="center">
         <td class="tdcls"><span style="font-size: 1em; color: white;">
               <img src="linechart.jsp" />
         </span></td>
         <td class="tdcls"><span style="font-size: 1em; color: white;">
               <img src="barchart.jsp" />
         </span></td>
         <td class="tdcls"><span style="font-size: 1em; color: white;">
               <img src="piechart.jsp" />
         </span></td>
      </tr>

   </table>
</body>
</html>
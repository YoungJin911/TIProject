<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<style>
    body{
        margin-top: 200px;
        text-align: center;
        margin: 0 auto;
        background-color: #515F6D;
    }
    div{
        text-align: center;
        margin: 25px;
    }
    
    h2{
       font-size: 45px;
        color: white;
        margin-bottom : 100px;
        margin-top: 100px;
    }
    
    h3{
       color: white;
        margin-bottom : 20px;
      
    }
    
    #adminid{
        font-size: 25px;
        color: white;
        font-weight: bold;
    }
    
    #adminpwd{
        font-size: 25px;
        color: white;
        font-weight: bold;
    }
    
    #submitbutton{
        margin-top: 50px;
        background-color: #3498db;
      color: white;
      padding: 5px 10px 5px 10px;
      font-size: 25px;
      font-weight: bold;
    }
     
table{
    text-align: center;
   width: 60%;
   margin: auto;
}

#userid{
   font-size:25px;

}
#userpwd{
   font-size:25px;
}
</style>
<body>
<h2>열화상 양/불량 판정 프로그램</h2>
<br/>
<br/>
<table>
   <h3>※ 관리자 로그인이 필요합니다.</h3>
    <form action = "logincheck.jsp">
        <label for="userid" id = "adminid"> 아이디 : </label>
        <input type="text" name="id" id="userid"><br>
          <br/>
        <label for="userpwd" id = "adminpwd"> 암 &nbsp; 호 : </label>
        <input type ="password" name="pwd" id="userpwd"><br>
        <input type="submit" value="관리자 로그인" id ="submitbutton" >    
    </form>
</table>
</body>
</html>
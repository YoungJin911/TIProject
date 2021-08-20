from flask import Blueprint, Flask, request, render_template, flash, redirect, url_for
import numpy as np
import matplotlib.pyplot as plt 
from skimage.morphology import skeletonize
import cv2
import json
from sklearn.svm import SVC
from skimage.morphology import skeletonize
import cv2
from sklearn.svm import SVC
import joblib
import warnings
import cx_Oracle
from datetime import datetime

## 이메일 전송 관련 라이브러리
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders

## 새로운 데이터 파일 만들기
# text = request.form['run']
# exec(open("makedatafile.py", encoding='utf-8-sig').read())

# matchingmodel = Blueprint('matchingmodel', __name__)
# @matchingmodel.route("/Direct_input", methods=['POST', 'GET'])
# def Direct_input():
#     if request.method == 'POST' :

def run():
    dash_starttime = datetime.today().strftime("%Y:%m:%d:%H:%M:%S")
    result = {
        'wrongGuessRate': 0,
        'logList': []
    }
    ## 오류문 무시
    warnings.filterwarnings(action='ignore')

    ## 예측 모델 Open
    test_model = joblib.load('./test_total_model.pkl')

    ## input 데이터 파일 open, 변수 저장
    file_name = 'test_total_input.csv' # csv 파일명
    vectors = np.zeros((100,82)) # 전체데이터를 저장할 변수 선언
    r = open(file_name,mode= 'r') # 데이터 파일 open 
    lines = r.readlines() # 파일에서 변수로 값 불러오기
    lines[0]


    for data in range(0,100):

        numbers = lines[data].split(',') #각 행에서 comma 로 데이터를 구분하여 변수에 저장 
        flir_vector = [] # 행 데이터를 저장할 변수 선언 
        for i in range(0,82):
            flir_vector.append(float(numbers[i])) # 데이터를 순서대로 붙여 행에 저장

        vectors[data,:] = np.transpose(flir_vector) # 전체 데이터 변수에 저장


    ##############################################
    ### 예측 모델에 Input Data 넣기
    ##############################################

    ## DB에 연결

    connection = cx_Oracle.connect("testuser", "testuser", "192.168.116.15:1521/XE")
    cur = connection.cursor()

    ## 오류 회수 초기화

    wrong_guess_stack= 0
    wrong_guess = 0

    ## 양불 판단 컬럼 생성

    predict_result = np.zeros((100,1))

    i = 0
    goodcount = 0
    defectcount = 0
    countyield = 0
    for i in range(0,100):

        sXt = vectors[0:100,0:80] # 테스트용 데이터
        sYt = vectors[0:100,80:81] # 테스트용 라벨
        sZt = vectors[0:100,81:82] # 테스트용 좌우 표시

        prod_inptime = datetime.today().strftime("%Y:%m:%d:%H:%M:%S")  # YYYY:mm:dd:HH:MM:SS 형태의 시간 저장
        s_result = test_model.predict(sXt)
        prod_outtime = datetime.today().strftime("%Y:%m:%d:%H:%M:%S")  # YYYY:mm:dd:HH:MM:SS 형태의 시간 저장

        ## 틀리면 0 컬럼에 저장
        if s_result[i] == 1:
            goodcount += 1
            predict_result[i] = 1
            prod_quality = '1'    
        elif s_result[i] == 0:
            defectcount += 1
            predict_result[i] = 0
            prod_quality = '0'

        if sZt[i] == 0:
            prod_leftright = 'L'
        elif sZt[i] == 1:
            prod_leftright = 'R'

        
        ## DB에 넣기
        query_prod = "insert into PROD VALUES(SEQ_PROD_PRODID.NEXTVAL,:col2,:col3,:col4,:col5)"
        cur.execute(query_prod, [prod_quality, prod_inptime, prod_outtime, prod_leftright])
        connection.commit()

        ## 불량품 prod_no 찾아서 defective 테이블에 넣기
        if predict_result[i] == 0 :
            query_fk_select = "select max(PROD_NO) from PROD"   #해당 루프에서 불량품 걸리면 sequence에 의해 가장 높은 prod_no를 가져오면 됨.
            rs = cur.execute(query_fk_select)
            for record in rs:
                def_prodno = record[0]

            result['logList'].append({
                'def_prodno': def_prodno,
                'prod_inptime': prod_inptime,
                'prod_outtime': prod_outtime,
                'prod_leftright': prod_leftright
            })
            query_def="insert into DEFECTIVE VALUES(:col1,:col2,:col3,:col4)"
            cur.execute(query_def, [def_prodno, prod_inptime, prod_outtime, prod_leftright])
            connection.commit()

        wrong_guess = (np.sum(np.abs(s_result-np.transpose(sYt)))) # 틀린 예측 개수
        wrong_guess_stack = wrong_guess_stack + wrong_guess
    print(goodcount)
    print(defectcount)
    
    countyield = goodcount/(defectcount+goodcount) * 100
    yieldquery = "update DASHBOARD set YIELD=:col1 where PROCESS_NO = :col2"
    ##############################################
    ## 공정 관련, Dashboard에 데이터 update
    ##############################################
    dash_endtime = datetime.today().strftime("%Y:%m:%d:%H:%M:%S")  # YYYY:mm:dd:HH:MM:SS 형태의 시간 저장
    
    query_processno_select = "select max(PROCESS_NO) from DASHBOARD"   #해당 루프에서 불량품 걸리면 sequence에 의해 가장 높은 prod_no를 가져오면 됨.
    rs = cur.execute(query_processno_select)
    for record in rs:
        dash_processno = record[0]
    wrongguessrate = (wrong_guess_stack/100/100)*100

    query_update_process_data = "update DASHBOARD set START_TIME=:col0, END_TIME=:col1 ,ERROR_RATE=:col2 where PROCESS_NO = :col3"
  
    cur.execute(query_update_process_data, [dash_starttime, dash_endtime, wrongguessrate, dash_processno])
    cur.execute(yieldquery, [countyield,dash_processno])

    #DASHBOARD 테이블 YIELD(수율) insert
    connection.commit()

    print(wrong_guess)
    print(wrong_guess_stack)
    print('오류율 : ', (wrong_guess_stack/100/100)*100) # 100
    result['wrongGuessRate'] = (wrong_guess_stack/100/100)*100
    ## DB 연결 종료
    connection.close()

    ##############################################
    ### 불량품 log file 생성(.txt 확장자로)
    ##############################################

    f = open('def_log.txt', 'w')
    query = "SELECT * FROM defective"

    connection = cx_Oracle.connect("testuser", "testuser", "192.168.116.15:1521/XE")
    cur = connection.cursor()
    cur.execute(query)

    row = cur.fetchone()
    while row is not None:
        f.write(str(row))
        f.write("\n")
        row = cur.fetchone()
    print("'def_log.txt' is writed successfully.")

    f.close()
    cur.close()
    connection.close()

    ##############################################
    ### (.txt )이메일 전송
    ##############################################

    # 세션생성, 로그인
    s = smtplib.SMTP('smtp.gmail.com', 587)
    s.starttls()
    s.login('tmaxti1234@gmail.com', 'xizcossqyovslmup')

    # 제목, 본문
    msg = MIMEMultipart()
    msg['Subject'] = 'Defectives Log File'
    msg.attach(MIMEText('This is a "def_log.txt" file containing defective product information.', 'plain'))

    # 파일첨부
    attachment = open('def_log.txt', 'rb')
    part = MIMEBase('application', 'octet-stream')
    part.set_payload((attachment).read())
    encoders.encode_base64(part)

    return result

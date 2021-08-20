from flask import Flask, Blueprint, request, render_template, flash, redirect, url_for
import urllib3
import json
import modelpredict
import makedatafile
#Flask 객체를 app에 할당
app = Flask(__name__)

# app 객체를 이용해 라우팅 경로를 설정("/")
# 해당 라우팅 경로로 요청이 올 때 실행할 함수를 바로 아래에 작성한다.
@app.route("/")
def main_get():
    return render_template('/ML_Predict_Front.html')

@app.route("/modelpredict", methods=['POST', 'GET'])
def modelpredictRoute():
    makedatafile.run() 
    return modelpredict.run()
    
if __name__ == "__main__":
    app.run(host="192.168.116.15", port="5000", debug = True)


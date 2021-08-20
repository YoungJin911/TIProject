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

####################################################################
####left data
####################################################################

# 데이터 파일
def run():
    file_name = './2nd_process_left_data.csv' # 좌측 전처리 완료 데이터 선택

    left_vectors = np.zeros((414,80)) # 전체데이터를 저장할 변수 선언

    r = open(file_name, mode= 'r') # 데이터 파일 open 
    l_lines = r.readlines() # 파일에서 변수로 값 불러오기
    l_lines[0]

    for data in range(0,414):

            numbers = l_lines[data].split(',') #각 행에서 comma 로 데이터를 구분하여 변수에 저장 

            flir_vector = [] # 행 데이터를 저장할 변수 선언 
            for i in range(0,80):
                flir_vector.append(float(numbers[i])) # 데이터를 순서대로 붙여 행에 저장
            
            left_vectors[data,:] = np.transpose(flir_vector) # 전체 데이터 변수에 저장


    # 전처리 완료 라벨 가져오기

    import json

    with open('2nd_process_left_label.json', 'r') as infile:
            newlist_left = json.load(infile)
            
    print(newlist_left)

    # 전처리 완료 라벨 append 전 dimension 맞추기
    left_label = np.zeros((len(newlist_left),1))

    num = 0

    for val in newlist_left:
        left_label[num] = newlist_left[num]
        num = num + 1

    # 좌측 식별 칼럼

    left_sign = np.zeros((len(newlist_left),1))

    num = 0

    for val in newlist_left:
        left_sign[num] = 0
        num = num + 1

    ####################################################################
    ####right data
    ####################################################################
    file_name = './2nd_process_right_data.csv' # 좌측 전처리 완료 데이터 선택

    right_vectors = np.zeros((423,80)) # 전체데이터를 저장할 변수 선언

    r = open(file_name, mode= 'r') # 데이터 파일 open 
    r_lines = r.readlines() # 파일에서 변수로 값 불러오기
    r_lines[0]

    for data in range(0,423):

            numbers = r_lines[data].split(',') #각 행에서 comma 로 데이터를 구분하여 변수에 저장 

            flir_vector = [] # 행 데이터를 저장할 변수 선언 
            for i in range(0,80):
                flir_vector.append(float(numbers[i])) # 데이터를 순서대로 붙여 행에 저장
            
            right_vectors[data,:] = np.transpose(flir_vector) # 전체 데이터 변수에 저장



    # 전처리 완료 라벨 가져오기
    import json

    with open('2nd_process_right_label.json', 'r') as infile:
            newlist_right = json.load(infile)
            
    print(newlist_right)

    # 전처리 완료 라벨 append 전 dimension 맞추기
    right_label = np.zeros((len(newlist_right),1))

    num = 0

    for val in newlist_right:
        right_label[num] = newlist_right[num]
        num = num + 1

    # 우측 식별 칼럼

    right_sign = np.zeros((len(newlist_right),1))

    num = 0

    for val in newlist_right:
        right_sign[num] = 1
        num = num + 1

    #################################################################
    #### 데이터 합치기
    #################################################################

    import warnings # 경고문을 꺼주는 코드입니다

    warnings.filterwarnings(action='ignore') 

    # 데이터 + 라벨링 + 좌우식별 append => (414x82)
    input_left_datas1 = np.hstack((left_vectors, left_label))
    input_left_datas2 = np.hstack((input_left_datas1, left_sign))

    input_right_datas1 = np.hstack((right_vectors, right_label))
    input_right_datas2 = np.hstack((input_right_datas1, right_sign))

    ##우측, 좌측 세로로 붙임
    input_total_datas = np.vstack((input_right_datas2, input_left_datas2))

    np.random.shuffle(input_total_datas)

    import pandas as pd

    df = pd.DataFrame(input_total_datas[0:100,])
    df.to_csv("test_total_input.csv", mode ='w', header=None, index =None)


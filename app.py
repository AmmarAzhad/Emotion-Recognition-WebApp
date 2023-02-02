from flask import Flask, render_template, Response, request
import cv2
from deepface import DeepFace as df
import datetime, time
import os, sys
import numpy as np
from threading import Thread

app = Flask(__name__, template_folder='./templates')

camera = cv2.VideoCapture(0)

global cameraOn

cameraOn = 1

@app.route("/")
def index():
    return render_template('index.html')

@app.route('/requests', methods=['POST','GET'])
def cam():
    if request.method == 'POST':
        if request.form.get('start') == 'Start':
            if(cameraOn == 1):
                cameraOn = 0
                camera.release()
                cv2.destroyAllWindows()
            else:
                camera = cv2.VideoCapture(0)
                cameraOn = 1

@app.route('/video_feed')
def video_feed():
    return Response(gen_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

def gen_frames():
    
    while True:
        ret, frame = camera.read()

        try:
            detectEmotion(frame)
            ret, buffer = cv2.imencode('.jpg', cv2.flip(frame,1))
            frame = buffer.tobytes()
            yield (b'--frame\r\n'
                    b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
        except Exception as e:
            pass


def detectEmotion(frame):

    faceCascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')

    result = df.analyze(frame, actions = ['emotion'], enforce_detection=False)

    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    faces = faceCascade.detectMultiScale(gray,1.1,4)

    for (x, y, w, h) in faces:
        cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)

    font = cv2.FONT_HERSHEY_SIMPLEX

    cv2.putText(frame,
                result['dominant_emotion'],
                (50,50),
                font, 3,
                (255, 255, 255),
                2,
                cv2.LINE_4)

    return frame
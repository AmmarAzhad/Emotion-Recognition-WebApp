from flask import Flask, request, jsonify
from PIL import Image
import base64
import cv2
from deepface import DeepFace as df
import datetime, time
import os, sys
import numpy as np
from threading import Thread

app = Flask(__name__)

@app.route('/api', methods = ['GET'])
def detect_emotion():
    image = request.files['images']
    detectedImage = {}
    img = Image.open(image.stream)
    detected = detectEmotion(img)
    encodedImage = base64.b64encode(detected.read())
    detectedImage['output'] = encodedImage
    return jsonify({detectedImage})

if __name__ =='__main__':
    app.run()

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
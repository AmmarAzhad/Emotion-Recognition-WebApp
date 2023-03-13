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

@app.route('/api', methods = ['POST'])
def detect_emotion():
    if request.method == 'POST':
        file = request.files['image']
        data = file.stream.read()
        data = base64.b64encode(data).decode()
        image = cv2.imread(file.filename)
        #detectedImage = {}
        detected = detectEmotion(image)
        encodedImage = base64.b64encode(detected)
        encoded_str = encodedImage.decode("ascii")
        #detectedImage['output'] = encodedImage
        #encodedImage = base64.b64encode(image.read())
        return jsonify({'output': encoded_str})

if __name__ =='__main__':
    app.run()

def detectEmotion(image):

    faceCascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')

    result = df.analyze(img_path = 'C:\\Users\\User\\Downloads\\WhatsApp Image 2023-03-09 at 23.28.53.jpeg', actions = ['emotion'], enforce_detection=False)

    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    faces = faceCascade.detectMultiScale(gray,1.1,4)

    for (x, y, w, h) in faces:
        cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 0), 2)

    font = cv2.FONT_HERSHEY_SIMPLEX

    cv2.putText(image,
                result['dominant_emotion'],
                (50,50),
                font, 3,
                (255, 255, 255),
                2,
                cv2.LINE_4)

    return image
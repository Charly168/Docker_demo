# Test Round

## 1. Test COPY VIDEO inside Docker image

### Dockerfile
```dockerfile
# Use a base image with Python and OpenCV
FROM python:3.9
ARG DEBIAN_FRONTEND=noninteractive
# Install dependencies, including graphics libraries
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx  \
    libxcb-xinerama0
RUN pip install opencv-python
# Copy the Python script into the container
COPY cam_script.py /app/cam_script.py
COPY ./K146.mp4 /app/K146.mp4
ENV VIDEO_PATH default_video_path
# Set the working directory
WORKDIR /app
# Run the Python script
CMD ["python", "cam_script.py"]
```

### Python file
```python
import cv2
import os

cap = cv2.VideoCapture("./K146.mp4")

while True:
    status, photo = cap.read()
    print(photo.shape)

    # Press Enter to exit
    if cv2.waitKey(10) == 13:
        break

cv2.destroyAllWindows()

```

### Build and Run
```bash
sudo docker build -t test:v4 -f Dockerfile .
sudo docker run --rm test:v4

```


## 2. Test COPY VIDEO inside Docker image, use ENV to address the video_path

### Dockerfile
```dockerfile
# Use a base image with Python and OpenCV
FROM python:3.9
ARG DEBIAN_FRONTEND=noninteractive
# Install dependencies, including graphics libraries
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx  \
    libxcb-xinerama0
RUN pip install opencv-python
# Copy the Python script into the container
COPY cam_script.py /app/cam_script.py
COPY ./K146.mp4 /app/K146.mp4
ENV VIDEO_PATH default_video_path
# Set the working directory
WORKDIR /app
# Run the Python script
CMD ["python", "cam_script.py"]

```

### Python file
```python
import cv2
import os

video_path = os.getenv('VIDEO_PATH')
print(f"Video path is: {video_path}")
cap = cv2.VideoCapture(video_path)

while True:
    status, photo = cap.read()
    print(photo.shape)

    # Press Enter to exit
    if cv2.waitKey(10) == 13:
        break

cv2.destroyAllWindows()


```

### Build and Run
```bash
sudo docker build -t test:v5 -f Dockerfile .
sudo docker run --rm -e VIDEO_PATH="./K146.mp4" test:v5

```


## 3.Mount local MP4 to Docker container

### Dockerfile
```dockerfile
# Use a base image with Python and OpenCV
FROM python:3.9
ARG DEBIAN_FRONTEND=noninteractive
# Install dependencies, including graphics libraries
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx  \
    libxcb-xinerama0
RUN pip install opencv-python
# Copy the Python script into the container
COPY cam_script.py /app/cam_script.py
ENV VIDEO_PATH default_video_path
# Set the working directory
WORKDIR /app
# Run the Python script
CMD ["python", "cam_script.py"]


```

### Python file
```python
import cv2
import os

video_path = os.getenv('VIDEO_PATH')
print(f"Video path is: {video_path}")
cap = cv2.VideoCapture(video_path)

while True:
    status, photo = cap.read()
    print(photo.shape)

    # Press Enter to exit
    if cv2.waitKey(10) == 13:
        break

cv2.destroyAllWindows()

```

### Build and Run
```bash
sudo docker build -t test:v5 -f Dockerfile .
sudo docker run -it --rm -v ./K146.mp4:/app/K146.mp4 -e VIDEO_PATH="./K146.mp4" test:v5

```



## 4.Mount stream MP4 to Docker container

### Dockerfile
```dockerfile
# Use a base image with Python and OpenCV
FROM python:3.9
ARG DEBIAN_FRONTEND=noninteractive
# Install dependencies, including graphics libraries
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx  \
    libxcb-xinerama0
RUN pip install opencv-python
# Copy the Python script into the container
COPY cam_script.py /app/cam_script.py
# COPY ./K146.mp4 /app/K146.mp4
ENV VIDEO_PATH default_video_path
# Set the working directory
WORKDIR /app
# Run the Python script
CMD ["python", "cam_script.py"]

```

### Python file
```python
import cv2
import os

video_path = os.getenv('VIDEO_PATH')
print(f"Video path is: {video_path}")
cap = cv2.VideoCapture(video_path)

while True:
    status, photo = cap.read()
    print(photo.shape)

    # Press Enter to exit
    if cv2.waitKey(10) == 13:
        break

cv2.destroyAllWindows()


```

### Build and Run
```bash
sudo docker build -t test:v6 -f Dockerfile .
sudo docker run --rm --network="host" -e VIDEO_PATH="rtsp://localhost:8554/mystream" test:v6

```

To ensure real-time output in the terminal while the Docker container is running, you need to disable output buffering. We can achieve this by using the PYTHONUNBUFFERED environment variable or by modifying the Docker run command like ENV PYTHONUNBUFFERED=1.

```bash
sudo docker run --rm --network="host" -e VIDEO_PATH="rtsp://localhost:8554/mystream" -e PYTHONUNBUFFERED=1 test:v6

```

## 5. Image inshow outside the Docker

```bash
xhost +local:docker
./mediamtx
ffmpeg -re -stream_loop -1 -i K146.mp4 -c copy -f rtsp rtsp://localhost:8554/mystream
sudo docker run --rm -it --network="host" -e VIDEO_PATH="rtsp://localhost:8554/mystream" -e DISPLAY=$DISPLAY  -v /tmp/.X11-unix:/tmp/.X11-unix test:v2
xhost -local:docker

```


## 6. Image inshow outside the Docker with GPU

```bash
xhost +local:docker
./mediamtx
ffmpeg -re -stream_loop -1 -i K146.mp4 -c copy -f rtsp rtsp://localhost:8554/mystream
sudo docker run --rm -it --gpus all --network="host" -e VIDEO_PATH="rtsp://localhost:8554/mystream" -e DISPLAY=$DISPLAY  -v /tmp/.X11-unix:/tmp/.X11-unix test:v2
xhost -local:docker

```
    - Installing NVIDIA Container Runtime
    Create a file named nvidia-container-runtime-script.sh and save it
    ```bash
    echo "curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | \
      sudo apt-key add -
    distribution=\$(. /etc/os-release;echo \$ID\$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-container-runtime/\$distribution/nvidia-container-runtime.list | \
      sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
    sudo apt-get update" >> nvidia-container-runtime-script.sh

    ```
    - Execute the script
    ```bash
    sh nvidia-container-runtime-script.sh
    apt-get install nvidia-container-runtime
    which nvidia-container-runtime-hook
    ```

    - Installing Docker 19.03 Beta 3 Test Build
    ```bash
    curl -fsSL https://test.docker.com -o test-docker.sh 
    ```

    - Execute the script
    ```bash
    sh test-docker.sh
    ```

    - Running a Ubuntu container which leverages GPUs
    ```bash
    docker run -it --rm --gpus all ubuntu nvidia-smi
    ```
    
New Docker CLI API Support for NVIDIA GPUs under Docker Engine 
https://collabnix.com/introducing-new-docker-cli-api-support-for-nvidia-gpus-under-docker-engine-19-03-0-beta-release/
```bash
sudo systemctl restart docker
sudo docker run -it --rm --gpus all ubuntu:20.04 nvidia-smi
```

![MARKDOWN](https://github.com/guodongxiaren/README)


FROM python:3.8-slim

RUN apt-get update && apt-get install -y \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libglib2.0-0 \
    ffmpeg

RUN pip install opencv-python-headless flask

WORKDIR /app
COPY . /app

CMD ["python", "app.py"]


from flask import Flask, Response
import cv2

app = Flask(__name__)

def generate_frames():
    cap = cv2.VideoCapture(0)
    while True:
        success, frame = cap.read()
        if not success:
            break
        else:
            ret, buffer = cv2.imencode('.jpg', frame)
            frame = buffer.tobytes()
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

@app.route('/video_feed')
def video_feed():
    return Response(generate_frames(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/')
def index():
    return '''
    <html>
    <head>
        <title>Video Streaming</title>
    </head>
    <body>
        <h1>Video Streaming</h1>
        <img src="/video_feed">
    </body>
    </html>
    '''

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)


docker build -t opencv-flask-app .
docker run -p 5000:5000 opencv-flask-app

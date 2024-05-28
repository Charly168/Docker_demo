FROM python:3.9
ARG DEBIAN_FRONTEND=noninteractive
# Install dependencies, including graphics libraries

RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libxcb-xinerama0

# 安装 Python 包
RUN pip install opencv-python

# Copy the Python script into the container
COPY cam_script.py /app/cam_script.py
# COPY ./K146.mp4 /app/K146.mp4
ENV VIDEO_PATH default_video_path
# Set the working directory
WORKDIR /app

# Run the Python script
CMD ["python", "cam_script.py"]
import cv2
import os

video_path = os.getenv('VIDEO_PATH')
print(f"Video path is: {video_path}")
cap = cv2.VideoCapture(video_path)

while True:
    status, photo = cap.read()
    cv2.imshow("Webcam Video Stream", photo)
    print(photo.shape)

    # Press Enter to exit
    if cv2.waitKey(10) == 13:
        break

cv2.destroyAllWindows()

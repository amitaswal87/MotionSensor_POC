MotionSensor_POC

**Overview**

MotionSensor_POC is an iOS application that leverages Apple's Vision API to capture human body pose points in real-time. The app allows users to upload images from their camera roll or capture live images using the device’s camera. It then detects body poses, draws points at the detected body positions, and sends this information to a local server using the OSC (Open Sound Control) protocol. A PD (Pure Data) patch is configured to receive the pose points and display them on its console.

**Features**

Detect human body poses using Apple's Vision API.
Capture video via the camera or upload images from the gallery.
Draw key points on the detected human body pose.
Send pose points to a local server on port 8000 using the OSC library.
A Pure Data (PD) patch listens to the port and logs the received pose points.
Easy-to-configure IP address to match the local machine where the server is running.
Supports real-time pose detection and feedback.

**Prerequisites**

iOS device running iOS 14.0 or higher (for Vision API compatibility).
Local server using OSC library (configured to port 8000).
Pure Data (PD) installed with a patch listening on port 8000.

**Installation**

Clone the repository:
git clone : https://github.com/amitaswal87/MotionSensor_POC.git

Open the project: Open the MotionSensor_POC.xcworkspace file using Xcode.

Update IP Address: Inside the code, locate the section where the OSC IP is defined. Update the IP address to match your local machine's IP address.

let serverIP = "YOUR_LOCAL_MACHINE_IP"

Build & Run: Build the app in Xcode and run it on a physical iOS device connected to the same network as your Mac machine running the PD patch.

**Usage**

Upload an Image from the Gallery:
Use the provided button to open the gallery, select an image, and the app will detect the human body pose and draw key points on it.

**Capture video via the Camera:**

Open the camera within the app, and if a human body is detected, the app will draw pose points in real-time.

**Sending Pose Data:**

The detected body pose points are sent to a local server over port 8000 using the OSC protocol. Ensure the iOS device and the Mac machine are on the same network.

**PD Patch Configuration:**

A Pure Data (PD) patch is pre-configured to listen for incoming pose data on port 8000. The patch file is available in the repository. Once the patch starts, it will log the received pose points on the console.

**Important Notes**

Ensure that both the iOS device and the Mac machine running the PD patch are on the same local network.
Update the app’s IP address to match the IP of your local Mac machine before running the app.

**Contributing**

Contributions are welcome! Please feel free to submit a pull request or open an issue for any bugs or suggestions.


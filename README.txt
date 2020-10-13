1.Controller.m is the controller code that generates the steering angle.
2.AV_server.m is the main host file that runs the HMI and integreates all the functions. This is also the server which communicates with the client SignRecognition_Client.m
3.SignRecogntion_Client.m is a road sign recognition used for sign recognition. This is the client that receives commands from server and acts acoordingly
4.RCNN.mat is a mat file that has our trained RCNN model
5.Final video is the Final HMI video

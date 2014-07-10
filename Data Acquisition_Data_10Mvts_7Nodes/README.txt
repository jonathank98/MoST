Description of the files and folders:

raw: this folder contains the collected data for each experiment from all nodes. The name of the files in this folder follow the following convention: m0001_s01_m01.txt : m0001 shows the experiment number, s01 represents the subject number, and m01 is the movement number

video: this folder contains the video files for the collected data. Files are named the same as raw folder and the _c01 at the end of file names show the camera no.

split: contains the collected data, but the data of each node is extracted from the raw data and is saved in a separate file. These files are created using read_and_split.m script.
Instead of using the raw data, you can get the data of each node from these files. In these files, column 14 is the sample number and column 15 to 19 are ACCx, ACCy, ACCz, GYROx, GYROy respectively. Column 22 shows the corresponding video frame.

annotations: this folder contains the annotations for each movement. You can find a text file for each movement. In these files you have two columns. The first column shows the sample number and the second one is either 1 or 2. 1 means the start of the movement and 2 shows the end.

annotated: this folder contains the annotated data, splited by movement, subject, node and trial. Files in this folder have 5 columns corresponsing to ACCx, ACCy, ACCz, GYROx, GYROy.

You can use bsn_visual01.m to annotate data or see the annotated movements.
To play the video files you need to install the required codecs. You can use K-Lite Codec Pack (http://klitedownload.com/).

import 'package:flutter/material.dart';
import '../../fans/screens/homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fans_arena/reusablewidgets/videotrimmer.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver2/image_gallery_saver.dart';
import 'package:dio/dio.dart';

class BottomNavItem0 extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Widget child;
  final void Function()? onTap;

  const BottomNavItem0({super.key, 
    required this.child,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height:35 ,
              width:35,
              color: isSelected ? Colors.grey : Colors.transparent,

              child: child,

            ),
          ),

          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blueAccent : Colors.grey,
              fontSize: isSelected?16.0:14.0,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
  static void setCamera(BuildContext context, ){
    _CameraState? state = context.findAncestorStateOfType<_CameraState>();
    state?.setCamera();
  }
}

class _CameraState extends State<Camera> {
  late CameraDescription? firstCamera;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late bool isFlashOn = false;
  late bool isFrontCamera = false;
  int _selectedIndex = 0;
  DateTime _startTime=DateTime.now();
  setCamera(){
    setState(() {
      _selectedIndex = 0;
    });
  }
  @override
  void initState() {
    super.initState();
    initializeCamera();
    getIndex();
  }
  void getIndex()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = prefs.getInt('index')??0;
    });
    _loadVideos(_selectedIndex,true);
  }
  void disposeIndex()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('index');
  }
  void initializeCamera() async {
    final cameras = await availableCameras();
    setState(() {
      if (cameras.isNotEmpty) {
        firstCamera = cameras.first;
      } else {
        firstCamera = null;
      }
    });
    _controller = CameraController(
      firstCamera!,
      ResolutionPreset.max,
    );
    _initializeControllerFuture = _initializeController();
  }

  Future<void> _initializeController() async {
    await _controller.initialize();
  }

  GlobalKey _globalKey = GlobalKey();
  @override
  void dispose() {
    _controller.dispose();
    disposeIndex();
    Engagement().engagement('Camera', _startTime, '');
    super.dispose();
  }
  void _toggleFlashlight() {
    setState(() {
      isFlashOn = !isFlashOn;
    });
    _controller.setFlashMode(isFlashOn ? FlashMode.torch : FlashMode.off);
  }

  void _toggleCamera() async {
    final cameras = await availableCameras();
    final newCamera = isFrontCamera ? cameras[0] : cameras[1];
    setState(() {
      firstCamera = newCamera;
      _controller = CameraController(
        firstCamera!,
        ResolutionPreset.high,
      );
      _initializeControllerFuture = _initializeController();
    });
    setState(() {
      isFrontCamera = !isFrontCamera;
    });
  }
  String? videoPath;
  bool _isRecording = false;
  Future<void> _startRecording() async {
    if (!_controller.value.isInitialized || _controller.value.isRecordingVideo) {
      return;
    }

    try {
      final Directory? extDir = await getExternalStorageDirectory();
      final String dirPath = '${extDir?.path}/Movies';
      await Directory(dirPath).create(recursive: true);
      final String filePath = '$dirPath/${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _controller.startVideoRecording();
      startTimer();
      setState(() {
        _isRecording = true;
        videoPath = filePath;
      });
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }
  Stopwatch stopwatch = Stopwatch();
  Timer timer=Timer(Duration(seconds: 0),(){});
  int seconds = 0;
  void startTimer() {
    stopwatch.start();
    timer = Timer.periodic(const Duration(microseconds: 1), (_) {
      setState(() {
        seconds = stopwatch.elapsed.inSeconds;
      });
    });

  }
  Future<void> _stopRecording() async {
    if (!_controller.value.isRecordingVideo) {
      return;
    }
    try {
      final XFile videoFile = await _controller.stopVideoRecording();
      stopwatch.stop();
      final result = await ImageGallerySaver.saveFile(videoFile.path);
      print(result);
      setState(() {
        videoPath = videoFile.path;
        _isRecording = false;
        items.add(videoFile.path);
      });
    } catch (e) {
      print('Error stopping video recording: $e');
    }
  }
  Future<void> _takePicture() async {
    if (!_controller.value.isInitialized) {
      return;
    }
    final Directory? extDir = await getExternalStorageDirectory();
    final String dirPath = '${extDir?.path}/DCIM/Camera';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${DateTime.now().millisecondsSinceEpoch}.jpg';
    if (_controller.value.isTakingPicture) {
      return;
    }
    try {
      final XFile pictureFile = await _controller.takePicture();
      final File file = File(pictureFile.path);
      await file.copy(filePath);
      await file.length().then((value) async {
        if (value == 0) {
          await Future.delayed(const Duration(milliseconds: 200));
          return _takePicture();
        } else {
          final result = await ImageGallerySaver.saveFile(filePath);
          print(result);
          setState(() {
            items.add(filePath);
            _controller.setFlashMode(FlashMode.off);
            isFlashOn = false;
          });
        }
      });
    } catch (e) {
      print('Error: $e');
    }
  }
  Future<void> _saveLocalImage() async {
    RenderRepaintBoundary boundary =
    _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData =
    await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      final result = await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());
      print(result);
    }
  }
  Future<void> _saveNetworkImage() async {
    try {
      var response = await Dio().get(
          "https://ss0.baidu.com/94o3dSag_xI4khGko9WTAnF6hhy/image/h%3D300/sign=a62e824376d98d1069d40a31113eb807/838ba61ea8d3fd1fc9c7b6853a4e251f94ca5f46.jpg",
          options: Options(responseType: ResponseType.bytes));

      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/temp_image.png';
      final File tempFile = File(tempPath);

      await tempFile.writeAsBytes(response.data);

      final result = await ImageGallerySaver.saveFile(tempPath);
      print(result);
    } catch (e) {
      print('Error saving network image: $e');
    }
  }
  Future<void> _saveNetworkGifFile() async {
    try {
      var appDocDir = await getTemporaryDirectory();
      String savePath = appDocDir.path + "/temp.gif";
      String fileUrl =
          "https://hyjdoc.oss-cn-beijing.aliyuncs.com/hyj-doc-flutter-demo-run.gif";

      await Dio().download(fileUrl, savePath);

      final result = await ImageGallerySaver.saveFile(savePath, isReturnPathOfIOS: true);
    } catch (e) {
      print('Error saving network GIF: $e');
    }
  }
  Future<void> _saveNetworkVideoFile() async {
    try {
      var appDocDir = await getTemporaryDirectory();
      String savePath = appDocDir.path + "/temp.mp4";
      String fileUrl =
          "https://s3.cn-north-1.amazonaws.com.cn/mtab.kezaihui.com/video/ForBiggerBlazes.mp4";

      await Dio().download(fileUrl, savePath, onReceiveProgress: (count, total) {
        print((count / total * 100).toStringAsFixed(0) + "%");
      });
      final result = await ImageGallerySaver.saveFile(savePath);
    } catch (e) {
      print('Error saving network video: $e');
    }
  }

  Future<void> _loadVideos(int index,bool image) async {
    List<XFile> media =[];
    if(index==0) {
      setState(() {
        s=Alignment(-0.7, -1.0);
        p=Alignment(0.0, -0.92);
        f=Alignment(0.7, -1.0);
        post=true;
        fanstv=false;
        items.clear();
        story=false;
        _selectedIndex=0;
      });
      media = await ImagePicker().pickMultiImage(requestFullMetadata: true);
    }else if(index==1) {
      setState(() {
        f=Alignment(-0.7, -1.0);
        s=Alignment(0.0, -0.92);
        p=Alignment(0.7, -1.0);
        story=true;
        fanstv=false;
        post=false;
        _selectedIndex=1;
      });
      if(image) {
        media = await ImagePicker().pickMultiImage(requestFullMetadata: true);
      }else{
       final m = await ImagePicker().pickVideo(source: ImageSource.gallery);
       media.add(m!);
      }
    }else{
      setState(() {
        p=Alignment(-0.7, -1.0);
        f=Alignment(0.0, -0.92);
        s=Alignment(0.7, -1.0);
        fanstv=true;
        post=false;
        story=false;
        _selectedIndex=2;
      });
      XFile? m = await ImagePicker().pickVideo(source: ImageSource.gallery);
      setState(() {
        media=[m!];
      });
    }
    if (media.isNotEmpty) {
      for (final image in media) {
        final File loadedImage = File(image.path);
        setState(() {
          items.add(loadedImage.path);
        });
      }
    }
  }

  List<String> items = [];
  double xc = 0.0;
  double xr = 1.0;
  double xl = -1.0;
  void updateState(double delta) {
    setState(() {
      if (delta > 0) {
        if (xc == -1.0) {
          xc = 0.0;
          xl = -1.0;
          xr = 1.0;
          if(p.x==-0.7) {
            f = Alignment(0.7, -1.0);
            s = Alignment(-0.7, -1.0);
            p = Alignment(0.0, -0.92);
          }else if(p.x==0.7){
            f = Alignment(0.7, -1.0);
            s = Alignment(-0.7, -1.0);
            p = Alignment(0.0, -0.92);
          }
          post=true;
          items.clear();
          fanstv=false;
          story=false;
          _selectedIndex=0;
        } else if (xc == 0.0) {
          p=Alignment(-0.7, -1.0);
          f=Alignment(0.0, -0.92);
          s=Alignment(0.7, -1.0);
          xc = 1.0;
          xl = -1.0;
          xr = 0.0;
          fanstv=true;
          post=false;
          items.clear();
          story=false;
          _selectedIndex=2;
        } else if (xc == 1.0) {
          p=Alignment(-0.7, -1.0);
          f=Alignment(0.0, -0.92);
          s=Alignment(0.7, -1.0);
          xc = 1.0;
          xl = -1.0;
          xr = 0.0;
          fanstv=true;
          post=false;
          story=false;
          _selectedIndex=2;
        }
      } else if (delta < 0) {
        if (xc == 1.0) {
          xc = 0.0;
          xl = -1.0;
          xr = 1.0;
          if(p.x==-0.7) {
            f = Alignment(0.7, -1.0);
            s = Alignment(-0.7, -1.0);
            p = Alignment(0.0, -0.92);
          }else if(p.x==0.7){
            f = Alignment(0.7, -1.0);
            s = Alignment(-0.7, -1.0);
            p = Alignment(0.0, -0.92);
          }
          post=true;
          fanstv=false;
          items.clear();
          story=false;
          _selectedIndex=0;
        } else if (xc == 0.0) {
          f=Alignment(-0.7, -1.0);
          s=Alignment(0.0, -0.92);
          p=Alignment(0.7, -1.0);
          xc = -1.0;
          xl = 0.0;
          xr = 1.0;
          story=true;
          fanstv=false;
          items.clear();
          post=false;
          _selectedIndex=1;
        } else if (xc == -1.0) {
          f=Alignment(-0.7, -1.0);
          s=Alignment(0.0, -0.92);
          p=Alignment(0.7, -1.0);
          xc = -1.0;
          xl = 0.0;
          xr = 1.0;
          story=true;
          fanstv=false;
          post=false;
          _selectedIndex=1;
        }
      }
    });
  }
  bool post=false;
  bool fanstv=false;
  bool story=false;
  double delta =0.0;
  Map<String,dynamic> align={
    "tl":{
      "y":1.0,
      "x":-0.7,
    },
    "tc":{
      "y":0.92,
      "x":0.0,
    },
    "tr":{
      "y":1.0,
      "x":0.7,
    }
  };
  Alignment s=Alignment(-0.7, -1.0);
  Alignment p=Alignment(0.0, -0.92);
  Alignment f=Alignment(0.7, -1.0);
  @override
  Widget build(BuildContext context) {
    int hours = seconds~/3600;
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    String hoursString = hours.toString().padLeft(2,'0');
    String minutesString = minutes.toString().padLeft(2, '0');
    String secondsString = remainingSeconds.toString().padLeft(2, '0');
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller);
                  } else {
                    return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ));
                  }
                },
              ),
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: _toggleFlashlight,
                          icon: Icon(isFlashOn
                              ? Icons.flash_on
                              : Icons.flash_off, color: Colors.white,)),
                      IconButton(
                        icon: Icon(
                          isFrontCamera
                              ? Icons.cameraswitch
                              : Icons.cameraswitch_outlined,
                          color: Colors.white,
                        ),
                        onPressed: _toggleCamera,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedAlign(
                alignment: s,
                duration: Duration(milliseconds: 300),
                child: InkWell(
                    onTap: (){
                      setState(() {
                         f=Alignment(-0.7, -1.0);
                         s=Alignment(0.0, -0.92);
                         p=Alignment(0.7, -1.0);
                         items.clear();
                         story=true;
                         fanstv=false;
                         post=false;
                         _selectedIndex=1;
                      });
                    },
                    child:  Text("Story",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize:story? 22:null),),),
              ),
              AnimatedAlign(
                alignment: p,
                duration: Duration(milliseconds: 300),
                child:  InkWell(
                    onTap: (){
                      setState(() {
                        if(p.x==-0.7) {
                          f = Alignment(0.7, -1.0);
                          s = Alignment(-0.7, -1.0);
                          p = Alignment(0.0, -0.92);
                        }else if(p.x==0.7){
                          f = Alignment(0.7, -1.0);
                          s = Alignment(-0.7, -1.0);
                          p = Alignment(0.0, -0.92);
                        }
                        items.clear();
                        post = true;
                        fanstv = false;
                        items.clear();
                        story = false;
                        _selectedIndex = 0;
                      });
                    },
                    child: Text("Post",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize:post? 22:null),)),
              ),
              AnimatedAlign(
                alignment: f,
                duration: Duration(milliseconds: 300),
                child:  InkWell(
                    onTap: (){
                      setState(() {
                         p=Alignment(-0.7, -1.0);
                         f=Alignment(0.0, -0.92);
                         s=Alignment(0.7, -1.0);
                         items.clear();
                         fanstv=true;
                         post=false;
                         story=false;
                         _selectedIndex=2;
                      });
                    },
                    child: Text("FansTv",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize:fanstv? 22:null),)),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 35),
                  child: SizedBox(
                    height: 85,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 55,
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(width: 0, color: Colors.white70),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Stack(
                              children: [
                                AnimatedAlign(
                                  duration: Duration(milliseconds: 300),
                                  alignment: Alignment(xl, 0.0),
                                  child:fanstv||_isRecording?FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                       Icon( _controller.value.isRecordingPaused||!_controller.value.isRecordingVideo?Icons.play_arrow:Icons.pause,color: Colors.white,),
                                        Text(hours==0?"$minutesString:$secondsString":"$hoursString:$minutesString:$secondsString",style: TextStyle(color:Colors.white),),
                                      ],
                                    ),
                                  ):post?SizedBox.shrink():InkWell(
                                    onTap: (){
                                      _loadVideos(_selectedIndex, false);
                                    },
                                      child: Icon(Icons.video_collection,color: Colors.white,size: 35,))
                                ),
                                AnimatedAlign(
                                  duration: Duration(milliseconds: 300),
                                  alignment: Alignment(xr, 0.0),
                                  child: InkWell(
                                      onTap: (){
                                        _loadVideos(_selectedIndex,fanstv?false:true);
                                      },
                                      child: Icon(fanstv?Icons.video_collection:Icons.collections_outlined,color: Colors.white,size: 35,))
                                ),
                                AnimatedAlign(
                                  duration: Duration(milliseconds: 300),
                                  alignment: Alignment(xc, 0.0),
                                  child: GestureDetector(
                                    onTap:story?null:(){
                                      if(post){
                                        _takePicture();
                                      }else if(fanstv){
                                        if(!_isRecording) {
                                          _startRecording();
                                        }else{
                                          _stopRecording();
                                        }
                                      }
                                    },
                                    onHorizontalDragEnd:(details){
                                      updateState(delta);
                                    },
                                    onHorizontalDragUpdate: (details) {
                                      setState(() {
                                        delta = details.primaryDelta ?? 0.0;
                                      });
                                    },
                                    child:story? FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap:(){
                                              if(!_isRecording) {
                                                _startRecording();
                                              }else{
                                                _stopRecording();
                                              }
                                            },
                                            child: Container(
                                              width: 45,
                                              height: 45,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(50),
                                                  border: Border.all(width: 5, color: Colors.white70)),
                                              child: Icon(Icons.video_camera_back,size: 30,),
                                            ),
                                          ),
                                          SizedBox(width: 10,),
                                          InkWell(
                                            onTap: (){
                                              _takePicture();
                                            },
                                            child: Container(
                                              width: 45,
                                              height: 45,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(50),
                                                  border: Border.all(width: 5, color: Colors.white70)),
                                              child: Icon(Icons.camera,size: 30,),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ):Container(
                                      width: 45,
                                      height: 45,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(50),
                                          border: Border.all(width: 5, color: Colors.white70)),
                                      child: Icon(post?Icons.camera:Icons.video_camera_back,size: 30,),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  width: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          "${items.length}",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TrimmerView(
                                    imagePath: items,
                                    isfanstv: fanstv,
                                    isPosting: post,),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.arrow_forward,
                            color: items.isEmpty
                                ? Colors.white70
                                : Colors.white,size: 30,
                          ))
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}


class ImageProviders extends ChangeNotifier{

  //images
  List<String> images1 = [];
  Set<String> images = {};
  Set<FileSystemEntity> folders = {};
  Set<FileSystemEntity> folders1 = {};

  Future<void> fetchImages({required int set}) async {
    List<File> imageFiles = await _getImagesFromStorage();
    List<String> paths = imageFiles.map((file) => file.path).toList();

    if(paths.length>set) {
      images.addAll(paths.sublist(0, set));
      images1.addAll(paths.sublist(set+1,paths.length));
      loadMore(set: set);
      current=current+1;
      notifyListeners();
    }else{
      images.addAll(paths);
      // Introduce a slight delay before checking the condition
      loadMore(set: set);
      current=current+1;
      notifyListeners();
    }
    notifyListeners();
  }
  int current=0;
  bool hasfetched = false;
  Future<void> loadMore({required int set}) async {
    if (images1.length > set) {
      images.addAll(images1.sublist(0, set));
      images1.removeRange(0, set);
      notifyListeners();
    } else {
      images.addAll(images1);
      notifyListeners();
      images1.clear();
      if (!hasfetched) {
        folders1.clear();
        List<File> moreImages = await _getMoreImages();
        List<String> morePaths = moreImages.map((file) => file.path).toList();
        if (morePaths.length > set) {
          hasfetched = true;
          images.addAll(morePaths.sublist(0, set));
          images1.addAll(morePaths.sublist(set+1, morePaths.length));
          current=current+1;
          notifyListeners();
        } else {
          hasfetched = true;
          images1.clear();
          images.addAll(morePaths);
          if(current<5) {
            loadMore(set: set);
            current = current + 1;
            notifyListeners();
          }
          notifyListeners();
        }
        notifyListeners();
      } else if (hasfetched) {
        folders.clear();
        List<File> moreImages1 = await _getMoreImages1();
        List<String> morePaths1 = moreImages1.map((file) => file.path).toList();
        if (morePaths1.length > set) {
          hasfetched = false;
          images.addAll(morePaths1.sublist(0, set));
          images1.addAll(morePaths1.sublist(set+1, morePaths1.length));
          current=current+1;
          notifyListeners();
        } else {
          hasfetched = false;
          images1.clear();
          images.addAll(morePaths1);
          if(current<5) {
            loadMore(set: set);
            current = current + 1;
            notifyListeners();
          }
          notifyListeners();
        }
        notifyListeners();
      }
    }
  }
  Future<List<File>> _getImagesFromStorage() async {
    List<File> result = [];
    Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir != null) {
      String parent = '/storage/emulated/0';
      String parent1='/storage/0000-0000';
      print(externalDir.path);
      Directory originalDirectory = Directory(parent);
      Directory originalDirectory1 = Directory(parent1);
      if (originalDirectory.existsSync()) {
        List<FileSystemEntity> entities = originalDirectory.listSync();
        for (var entity in entities) {
          if (entity is File && entity.path.endsWith('.jpg')||entity is File && entity.path.endsWith('.png')||entity is File && entity.path.endsWith('.jpeg')) {
            result.add(entity);
          } else if (entity is Directory) {
            if(entity.path!='/storage/emulated/0/Android'){
              folders.add(entity);
              notifyListeners();
            }}
        }

      }else{

      }
      if (originalDirectory1.existsSync()) {
        List<FileSystemEntity> entities = originalDirectory1.listSync();
        for (var entity in entities) {
          if (entity is File && entity.path.endsWith('.jpg')||entity is File && entity.path.endsWith('.png')||entity is File && entity.path.endsWith('.jpeg')) {
            result.add(entity);
          } else if (entity is Directory) {
            if(entity.path!='/storage/0000-0000/Android'){
              folders.add(entity);
              notifyListeners();
            }}
        }

      }else{

      }
    }

    return result;
  }

  Future<List<File>> _getMoreImages() async {

    List<File> result = [];
    for (var folder in folders) {
      if (folder is Directory) {
        List<FileSystemEntity> entities = folder.listSync();
        for (var entity in entities) {
          if (entity is File && entity.path.endsWith('.jpg')||entity is File && entity.path.endsWith('.png')||entity is File && entity.path.endsWith('.jpeg')) {
            result.add(entity);
          }else{
            folders1.add(entity);
            notifyListeners();
          }
        }
      }
    }
    return result;
  }
  Future<List<File>> _getMoreImages1() async {
    List<File> result = [];
    for (var folder in folders1) {
      if (folder is Directory) {
        List<FileSystemEntity> entities = folder.listSync();
        for (var entity in entities) {
          if (entity is File && entity.path.endsWith('.jpg')||entity is File && entity.path.endsWith('.png')||entity is File && entity.path.endsWith('.jpeg')) {
            result.add(entity);
          }else{
            folders.add(entity);
            notifyListeners();
          }
        }
      }
    }
    return result;
  }


  String removeUnwantedPathPart(String path) {
    String unwantedPart = 'Android/data/com.example.imagevideo';

    if (path.contains(unwantedPart)) {
      String newPath = path.replaceAll(unwantedPart, '').replaceAll('//', '/');
      return newPath;
    } else {
      return path;
    }
  }

  //Videos
  List<String> videos1 = [];
  Set<String> videos = {};
  Set<FileSystemEntity> vFolders = {};
  Set<FileSystemEntity> vFolders1 = {};
  int currentV=0;
  Future<void> fetchVideos({required int set}) async {
    List<File> imageFiles = await _getVideosFromStorage();
    List<String> paths = imageFiles.map((file) => file.path).toList();

    if(paths.length>set) {
      videos.addAll(paths.sublist(0, set));
      videos1.addAll(paths.sublist(set+1,paths.length));
      currentV = currentV + 1;
      notifyListeners();
    }else{
      videos.addAll(paths);
      // Introduce a slight delay before checking the condition
      loadMoreV(set: set);
      currentV = currentV + 1;
      notifyListeners();
    }
    notifyListeners();
  }
  bool hasfetchedV = false;

  Future<void> loadMoreV({required int set}) async {
    if (videos1.length > set) {
      videos.addAll(videos1.sublist(0, set));
      videos1.removeRange(0, set);
      notifyListeners();
    } else {
      videos.addAll(videos1);
      notifyListeners();
      videos1.clear();
      if (!hasfetchedV) {
        vFolders1.clear();
        List<File> moreVideos = await _getMoreVideos();
        List<String> morePaths = moreVideos.map((file) => file.path).toList();
        if (morePaths.length > set) {
          hasfetchedV = true;
          videos.addAll(morePaths.sublist(0, set));
          videos1.addAll(morePaths.sublist(set+1, morePaths.length));
          currentV = currentV + 1;
          notifyListeners();
        } else {
          hasfetchedV = true;
          videos1.clear();
          videos.addAll(morePaths);
          if(currentV<5) {
            loadMoreV(set: set);
            currentV = currentV + 1;
            notifyListeners();
          }
          notifyListeners();
        }
      } else if (hasfetchedV) {
        vFolders.clear();
        List<File> moreImages1 = await _getMoreVideos1();
        List<String> morePaths1 = moreImages1.map((file) => file.path).toList();
        if (morePaths1.length > set) {
          hasfetchedV = false;
          videos.addAll(morePaths1.sublist(0, set));
          videos1.addAll(morePaths1.sublist(set+1, morePaths1.length));
          currentV = currentV + 1;
          notifyListeners();
        } else {
          hasfetchedV = false;
          videos1.clear();
          videos.addAll(morePaths1);
          if(currentV<5) {
            loadMoreV(set: set);
            currentV = currentV + 1;
            notifyListeners();
          }
          notifyListeners();
        }
      }

    }
  }


  Future<List<File>> _getVideosFromStorage() async {
    List<File> result = [];
    Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir != null) {
      print(externalDir.path);
      String parent = '/storage/emulated/0';
      String parent1='/storage/0000-0000';
      Directory originalDirectory = Directory(parent);
      Directory? originalDirectory1 = Directory(parent1);

      if (originalDirectory.existsSync()) {
        List<FileSystemEntity> entities = originalDirectory.listSync();
        for (var entity in entities) {
          if (entity is File && entity.path.endsWith('.mp4')) {
            result.add(entity);
          } else if (entity is Directory) {
            if(entity.path!='/storage/emulated/0/Android'){
              vFolders.add(entity);
            }}
        }
      }
      if(originalDirectory1.existsSync()){
        List<FileSystemEntity> entities1 = originalDirectory1.listSync();
        for (var entity in entities1) {
          if (entity is File && entity.path.endsWith('.mp4')) {
            result.add(entity);
          } else if (entity is Directory) {
            if(entity.path!='/storage/0000-0000/Android'){
              vFolders.add(entity);
            }}
        }}
    }

    return result;
  }

  Future<List<File>> _getMoreVideos() async {
    List<File> result = [];
    for (var folder in vFolders) {
      if (folder is Directory) {
        List<FileSystemEntity> entities = folder.listSync();
        for (var entity in entities) {
          if (entity is File && entity.path.endsWith('.mp4')) {
            result.add(entity);
          }else{
            vFolders1.add(entity);
          }
        }
      }
    }
    return result;
  }
  Future<List<File>> _getMoreVideos1() async {
    List<File> result = [];
    for (var folder in vFolders1) {
      if (folder is Directory) {
        List<FileSystemEntity> entities = folder.listSync();
        for (var entity in entities) {
          if (entity is File && entity.path.endsWith('.mp4')) {
            result.add(entity);
          }else{
            vFolders.add(entity);
          }
        }
      }
    }
    return result;
  }

}
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fans_arena/reusablewidgets/v.dart';
import 'package:fans_arena/reusablewidgets/video_trimmer.dart';
import 'package:flutter/scheduler.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'dart:math' as math;
const double _kMinCircularProgressIndicatorSize = 36.0;
const int _kIndeterminateLinearDuration = 1800;
const int _kIndeterminateCircularDuration = 1333 * 2222;
enum ViewerType {
  auto,
  fixed,
  scrollable,
}
class StorageDir {
  const StorageDir._(this.index);

  final int index;

  static const StorageDir temporaryDirectory = StorageDir._(0);
  static const StorageDir applicationDocumentsDirectory = StorageDir._(1);
  static const StorageDir externalStorageDirectory = StorageDir._(2);

  static const List<StorageDir> values = <StorageDir>[
    temporaryDirectory,
    applicationDocumentsDirectory,
    externalStorageDirectory,
  ];

  @override
  String toString() {
    return const <int, String>{
      0: 'temporaryDirectory',
      1: 'applicationDocumentsDirectory',
      2: 'externalStorageDirectory',
    }[index]!;
  }
}

class FileFormat {
  const FileFormat._(this.index);

  final int index;

  static const FileFormat mp4 = FileFormat._(0);
  static const FileFormat mkv = FileFormat._(1);
  static const FileFormat mov = FileFormat._(2);
  static const FileFormat flv = FileFormat._(3);
  static const FileFormat avi = FileFormat._(4);
  static const FileFormat wmv = FileFormat._(5);
  static const FileFormat gif = FileFormat._(6);

  static const List<FileFormat> values = <FileFormat>[
    mp4,
    mkv,
    mov,
    flv,
    avi,
    wmv,
    gif,
  ];

  @override
  String toString() {
    return const <int, String>{
      0: '.mp4',
      1: '.mkv',
      2: '.mov',
      3: '.flv',
      4: '.avi',
      5: '.wmv',
      6: '.gif',
    }[index]!;
  }
}
class EditorPanel extends StatefulWidget {
  String video;
  int index;
  void Function(String video) setvideo;
  EditorPanel({super.key,
    required this.video,
    required this.setvideo,
    required this.index
  });

  @override
  State<EditorPanel> createState() => _EditorPanelState();
}

class _EditorPanelState extends State<EditorPanel> {
  double angle=0.0;
  TextStyle textStyle=TextStyle();
  final FocusNode _focusNode = FocusNode();
  double progressWr = 0.05;
  double progressWl = 0.05;
  double progressLl = 0.05;
  double progressLr = 0.05;
  double saturation=0.0;
  double brightness=0.0;

  @override
  void initState(){
    super.initState();
    addWidgets();
    _pageController = PageController(initialPage: index);
  }
  Map<String,dynamic>data={};
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //addWidgets();
    //_loadVideo();
  }
  Trimmer trimmer = Trimmer();
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool visible = false;
  bool cropping=false;
  Future<void> _loadVideo() async {
    await trimmer.loadVideo(videoFile: File(widget.video));
    setState(() {
      _endValue = trimmer.videoPlayerController!.value.duration.inMilliseconds.toDouble();
    });
  }

double p=0.0;
  Future<void> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });
    double progress= await trimmer.saveEditedVideo(
        data:data,
        context:context,
        onSave: (String? outputPath) {
          setState(() {
            _progressVisibility = false;
            widget.setvideo(outputPath!);
          });
        }, onProgress: (double progress) {  });
    setState((){
      p=progress;
    });
  }

  @override
  void dispose(){
    widgets.clear();
    trimmer.videoPlayerController?.dispose();
    trimmer.videoPlayerController?.setVolume(0);
    _focusNode.dispose();
    super.dispose();
  }
  void _toggleVisibility() {
    setState(() {
      if (write) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(_focusNode);
        });
      } else {
        _focusNode.unfocus();
      }
    });
  }
  bool loaded=false;
  double speed=0.0;
  bool fade=false;
  double opacity=0.0;
  TextEditingController text=TextEditingController();
  Future<void> addWidgets()async{
    if(!loaded) {
      await _loadVideo();
      setState(() {
        loaded=true;
      });
    }
    List<Widget>w=[
      TrimViewer(
        trimmer: trimmer,
        viewerHeight: 50.0,
        viewerWidth: MediaQuery.of(context).size.width,
        maxVideoLength: Duration(seconds: trimmer.isVideoPlayerInitialized?trimmer.videoPlayerController!.value.duration.inSeconds:120),
        onChangeStart: (value){
          setState(() {
            _startValue = value;
            data['trimmer']={
              "startValue":_startValue,
              'endValue': _endValue,
            };
            data1;
          });
        },
        onChangeEnd: (value){
          setState(() {
            _endValue = value;
            data['trimmer']={
              "startValue":_startValue,
              'endValue': _endValue,
            };
            data1;
          });},
        onChangePlaybackState: (value)async{
          if (!trimmer.videoPlayerController!.value.isPlaying) {
            setState(() {
              visible =false;
            });
            await  Future.delayed(const Duration(milliseconds: 400));
            setState(() {
              _isPlaying = value;
            });
          } else {
            setState(() {
              _isPlaying = value;
              visible =true;
            });
          }
        }, trimduration: const Duration(seconds: 120),
        addData: (Map<String, dynamic> d) {
          setState(() {
            data['addAudio']=d;
            data1=d;
          });
        }, data: data,),
      Brightness(trimmer:trimmer, set: (double b) {
        setState(() {
          brightness=b;
          data['brightness']={
            'value':b
          };
        });
      }, data: data,),
      Saturation(trimmer:trimmer, set: (double s) {
        setState(() {
          saturation=s;
          data['saturation']={
            'value':s
          };
        });
      }, data: data,),
      AddText(
        trimmer:trimmer,
        style:textStyle,
        setText: (TextStyle style) {
          setState(() {
            textStyle=style;
          });
        },
      ),
      Crop(trimmer:trimmer,setD: (double wR, double wL, double lL, double lR) {
        setState(() {
          progressWr = wR;
          progressWl = wL;
          progressLl = lL;
          progressLr = lR;
          data['crop']={
            'wr':wR,
            'wl':wL,
            'll':lL,
            'lr':lR,
          };
        });
      }, data: data,),
      Rotation(trimmer:trimmer,set: (double a) {
        setState(() {
          angle=a*1.57;
          data['rotation']={
            'value':a
          };
        });
      }, data: data,),
      Fade(trimmer:trimmer,set: (double fad) {
        setState(() {
          fade=true;
          opacity=fad;
          data['fade']={
            'value':fad
          };
        });
      }, data: data,),
      VideoSpeed(trimmer:trimmer, set: (double spd) {
        setState(() {
          speed=spd;
          data['videospeed']={
            'value':spd
          };
        });
      }, data: data,)
    ];
    setState(() {
      widgets=[...w];
    });
  }
  Map<String,dynamic>data1={};
  List<Widget>widgets=[];
  bool write=false;
  List<Widget> widgets1 = [
    Icon(Icons.cut),
    Icon(Icons.brightness_6),
    Icon(Icons.color_lens),
    Icon(Icons.text_fields),
    Icon(Icons.crop),
    Icon(Icons.rotate_left),
    Icon(Icons.opacity),
    Icon(Icons.slow_motion_video),
  ];

  late PageController _pageController;
  int index=0;
  double y=-0.9;
  double x=-0.9;
  bool _isPlaying = false;
  bool _progressVisibility = false;
  void changePage(int index){
    addWidgets().then((_)=>  _pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.bounceIn));
  }
  String t="";
  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (context) => Center(
            child: widgets.isEmpty?const CircularProgressIndicator():Container(
                padding: const EdgeInsets.only(bottom: 5.0),
                color: Colors.black,
                child:  Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: Stack(
                        children: [
                          Transform(
                            transform: Matrix4.identity()
                              ..rotateZ(angle),
                            alignment: FractionalOffset.center,
                            child: VideoViewer(trimmer: trimmer,
                              onChangePlaybackState: (value)async{
                                if (!trimmer.videoPlayerController!.value.isPlaying) {
                                  setState(() {
                                    visible =false;
                                  });
                                  await  Future.delayed(const Duration(milliseconds: 400));
                                  setState(() {
                                    _isPlaying = value;
                                  });
                                } else {
                                  setState(() {
                                    _isPlaying = value;
                                    visible =true;
                                  });
                                }
                              },),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Visibility(
                                visible: _progressVisibility,
                                child: const LinearProgressIndicator(
                                  backgroundColor: Colors.red,
                                  minHeight: 6.0,
                                ),
                              ),
                            ),
                          ),
                          cropping?Opacity(
                            opacity: 0.9,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border:Border(
                                    top:BorderSide(
                                      width: (progressLr*MediaQuery.of(context).size.height*0.5),
                                      color: Colors.black,),
                                    left: BorderSide(
                                      width: (progressWl*MediaQuery.of(context).size.width),
                                      color: Colors.black,),
                                    right: BorderSide(
                                      width: (progressWr*MediaQuery.of(context).size.width),
                                      color: Colors.black,),
                                    bottom: BorderSide(
                                      width: (progressLl*MediaQuery.of(context).size.height*0.5),
                                      color: Colors.black,),
                                  )
                              ),
                            ),
                          ): Opacity(
                              opacity: opacity,
                              child:Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  decoration: BoxDecoration(
                                    color: fade?Colors.black:Colors.transparent,
                                  )
                              )),
                          Align(
                            alignment: Alignment(x,y),
                            child:Draggable(
                              feedback: const Material(
                                child: SizedBox.shrink(),
                              ),
                              onDragUpdate: (details){
                                setState(() {
                                  y += (0.005*details.delta.dy);
                                  x += (0.05*details.delta.dx);
                                });
                              },
                              child: SizedBox(
                                width: 350,
                                child: write?TextFormField(
                                  controller: text,
                                  style: textStyle,
                                  focusNode: _focusNode,
                                  maxLines: 8,
                                  minLines: 1,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  validator: (value) =>
                                  value != null && value.length>180 ? null : "Max character length exceeded",
                                  onChanged: (value){
                                    setState(() {
                                      t=value;
                                      data['addText']=Text(t,style: textStyle,);
                                    });},
                                ):Text(text.text,style: textStyle,),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: IconButton(
                              icon:AnimatedOpacity(
                                opacity: visible ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 500),
                                child: Icon(_isPlaying?Icons.pause:Icons.play_arrow,
                                  size: 50.0,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () async {
                                bool playbackState = await trimmer.videoPlaybackControl(
                                  startValue: _startValue,
                                  endValue: _endValue,
                                );
                                setState(() {
                                  _isPlaying = playbackState;
                                });
                              },
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: IconButton(
                                onPressed: _progressVisibility
                                    ? null
                                    : (){
                                  _saveVideo().then((_) {
                                    const snackBar = SnackBar(
                                        content: Text('Video Saved successfully'));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      snackBar,
                                    );
                                  });
                                },
                                icon: const Icon(Icons.save,color: Colors.white,),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: IconButton(
                                onPressed: (){
                                  trimmer.removeModifications().then((_) {
                                    const snackBar = SnackBar(
                                        content: Text('Changes Discarded successfully'));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      snackBar,
                                    );
                                  });
                                },
                                icon: const Icon(Icons.delete,color: Colors.white,),
                              ),
                            ),
                          ),
                          //Center(child: Text("$data",style: const TextStyle(color: Colors.white),),),
                        ],
                      ),
                    ),
                    Container(
                      height: 35,
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children:widgets1.map((t)=>InkWell(
                            onTap: (){
                              setState(() {
                                index=widgets1.indexOf(t);
                                if(index==3){
                                  write=true;
                                  _toggleVisibility();
                                }else{
                                  write=false;
                                  _toggleVisibility();
                                }
                                if(index==4){
                                  cropping=true;
                                }else{
                                  cropping=false;
                                }
                                if(index==6){
                                  fade=true;
                                }else {
                                  fade=false;
                                }
                              });
                              changePage(index);
                            },
                            child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                    color: index==widgets1.indexOf(t)?Colors.grey[400]:Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.black54,width: 2
                                    )
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: t,
                                )))).toList(),),
                    ),
                    Container(
                      height: 160,
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width,
                      child: PageView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widgets.length,
                          controller: _pageController,
                          itemBuilder: (context,index){
                            return widgets[index];
                          }),
                    ),
                  ],
                ))));
  }
}
class Brightness extends StatefulWidget {
  Trimmer trimmer;
  Function(double brightness) set;
  Map<String,dynamic> data;
  Brightness({super.key,required this.trimmer,required this.set,required this.data});

  @override
  State<Brightness> createState() => _BrightnessState();
}

class _BrightnessState extends State<Brightness> with SingleTickerProviderStateMixin {
  double progress = 0.5;
  bool dragging = false;
  late AnimationController _controller;

  void _onDragUpdate(DragUpdateDetails details) {
    double delta = details.primaryDelta ?? 0.0;
    setState(() {
      if (delta > 0) {
        progress += (0.003*delta);
      } else if (delta < 0) {
        progress += (0.003*delta);
      }
      progress = progress.clamp(0.0, 1.0);
    });
    widget.set(progress);
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      dragging = false;
    });
    widget.trimmer.adjustBrightness(brightness: progress-0.5, onSave: (value){});
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      dragging = true;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      if(widget.data['brightness']!=null) {
        progress = widget.data['brightness']['value'];
      }
    });
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width*0.9,
      child: GestureDetector(
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width*0.9, 8), // Specify the size
              painter: CustomLinearProgressPainter(
                value: progress,
                circleRadius: dragging ? 10 : 8,
                backgroundColor: Colors.grey.withOpacity(0.3),
                valueColor: Colors.blue,
                animationValue: _controller.value,
                textDirection: TextDirection.ltr,
                indicatorBorderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 10),
            Text("${(progress * 100).toStringAsFixed(1)}%"),
          ],
        ),
      ),
    );
  }
}

class Saturation extends StatefulWidget {
  Trimmer trimmer;
  Function(double saturation) set;
  Map<String,dynamic>data;
  Saturation ({super.key,required this.trimmer,required this.set,required this.data});

  @override
  State<Saturation> createState() => _SaturationState();
}

class _SaturationState extends State<Saturation> with SingleTickerProviderStateMixin {
  double progress = 0.0;
  bool dragging = false;
  late AnimationController _controller;

  void _onDragUpdate(DragUpdateDetails details) {
    double delta = details.primaryDelta ?? 0.0;
    setState(() {
      if (delta > 0) {
        progress += (0.003*delta);
      } else if (delta < 0) {
        progress += (0.003*delta);
      }
      progress = progress.clamp(0.0, 1.0);
    });
    widget.set(progress);
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      dragging = false;
    });
    widget.trimmer.adjustSaturation(saturation: progress-0.5, onSave: (value){});
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      dragging = true;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      if(widget.data['saturation']!=null) {
        progress = widget.data['saturation']['value'];
      }
    });
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width*0.9,
      child: GestureDetector(
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width*0.9, 8), // Specify the size
              painter: CustomLinearProgressPainter(
                value: progress,
                circleRadius: dragging ? 10 : 8,
                backgroundColor: Colors.grey.withOpacity(0.3),
                valueColor: Colors.blue,
                animationValue: _controller.value,
                textDirection: TextDirection.ltr,
                indicatorBorderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 10),
            Text("${(progress * 100).toStringAsFixed(1)}%"),
          ],
        ),
      ),
    );
  }
}

class Fade extends StatefulWidget {
  Function(double fade) set;
  Trimmer trimmer;
  Map<String,dynamic> data;
  Fade({super.key, required this.set,required this.trimmer,required this.data});

  @override
  State<Fade> createState() => _FadeState();
}

class _FadeState extends State<Fade>with SingleTickerProviderStateMixin  {
  double progress = 0.0;
  bool dragging = false;
  late AnimationController _controller;

  void _onDragUpdate(DragUpdateDetails details) {
    double delta = details.primaryDelta ?? 0.0;
    setState(() {
      if (delta > 0) {
        progress += (0.003*delta);
      } else if (delta < 0) {
        progress += (0.003*delta);
      }
      progress = progress.clamp(0.0, 1.0);
    });
    widget.set(progress);
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      dragging = false;
    });
    widget.trimmer.addFadeEffect(onSave: (value){}, fadeInStart: 0, fadeInDuration: 0, fadeOutStart: 0, fadeOutDuration: 0);
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      dragging = true;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      if(widget.data['fade']!=null) {
        progress = widget.data['fade']['value'];
      }
    });
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width*0.9,
      child: GestureDetector(
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width*0.9, 8), // Specify the size
              painter: CustomLinearProgressPainter(
                value: progress,
                circleRadius: dragging ? 10 : 8,
                backgroundColor: Colors.grey.withOpacity(0.3),
                valueColor: Colors.blue,
                animationValue: _controller.value,
                textDirection: TextDirection.ltr,
                indicatorBorderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 10),
            Text("${(progress * 100).toStringAsFixed(1)}%"),
          ],
        ),
      ),
    );
  }
}

class VideoSpeed extends StatefulWidget {
  Trimmer trimmer;
  Function(double speed) set;
  Map<String,dynamic> data;
  VideoSpeed({super.key,
    required this.trimmer,
    required this.set,required this.data});

  @override
  _VideoSpeedState createState() => _VideoSpeedState();
}

class _VideoSpeedState extends State<VideoSpeed> {
  double _selectedSpeed = 1.0;
  final List<double> _speedOptions = [0.5,0.75,1.0,1.25,1.5, 2.0];
  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.data['videospeed']!= null) {
        _selectedSpeed= widget.data['videospeed']['value'];
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _speedOptions.map((speed) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 7,vertical: 5),
                label: Text('${speed}x'),
                selected: _selectedSpeed == speed,
                onSelected: (isSelected) {
                  if (isSelected) {
                    setState(() {
                      _selectedSpeed = speed;
                    });
                    widget.trimmer.changeVideoSpeed(speedMultiplier: _selectedSpeed, onSave: (value){});
                    widget.set(speed);
                  }
                },
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Text(
          'Selected Speed: ${_selectedSpeed}x',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
class AddAudio extends StatefulWidget {
  Trimmer trimmer;
  Map<String,dynamic>data;
  Function(Map<String,dynamic>data)addData;
  AddAudio({super.key,
    required this.trimmer,
    required this.data,required this.addData});

  @override
  State<AddAudio> createState() => _AddAudioState();
}

class _AddAudioState extends State<AddAudio> {

  @override
  void initState() {
    super.initState();
    if(widget.data['addAudio']!=null) {
      setState(() {
        data={
          'file': music.path
        };
        music = File(widget.data['addAudio']['file']);
      });
      addWidgets();
      addMusicTrimmer().then((_)=>_pageController = PageController(initialPage: 1));
    }else {
      addWidgets();
      _pageController = PageController(initialPage: 0);
    }
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //addWidgets();
    //_loadVideo();
  }
  File music=File("");
  Map<String,dynamic> data={};
  @override
  void dispose(){
    widgets.clear();
    super.dispose();
  }
  double startValue=0.0;
  double endValue=0.0;
  Future<void>addMusicTrimmer()async{
    setState(() {
      widgets.add( MusicTrimmer(onChangeEnd: (value){
        setState(() {
          endValue=value;
          data={
            'file': music.path,
            'mTrimmer':{
              'startValue': value,
              'endValue':endValue
            }
          };
        });
        widget.addData(data);
      },onChangeStart: (value){
        setState(() {
          startValue=value;
          data={
            'file': music.path,
            'mTrimmer':{
              'startValue': value,
              'endValue':endValue
            }
          };
        });
        widget.addData(data);
      },
        music: music, trimmer: widget.trimmer,
        delete: () {
          changePage(0).then((_){
            setState(() {
              widgets.removeAt(1);
            });
          });
        }, data: widget.data['addAudio']??{},));
    });
    widget.addData(data);
  }
  Future<void> addWidgets()async{
    List<Widget>w=[
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: OutlinedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.audio,
                  allowCompression: false,
                );
                if (result != null) {
                  File file = File(result.files.single.path!);
                  setState((){
                    music=file;
                    data={
                      'file': file.path
                    };
                    widgets.add( MusicTrimmer(onChangeEnd: (value){
                      setState(() {
                        endValue=value;
                        data={
                          'file': music.path,
                          'mTrimmer':{
                            'startValue': value,
                            'endValue':endValue
                          }
                        };
                      });
                      widget.addData(data);
                    },onChangeStart: (value){
                      setState(() {
                        startValue=value;
                        data={
                          'file': music.path,
                          'mTrimmer':{
                            'startValue': value,
                            'endValue':endValue
                          }
                        };
                      });
                      widget.addData(data);
                    },
                      music: music, trimmer: widget.trimmer,
                      delete: () {
                        changePage(0).then((_){
                          setState(() {
                            widgets.removeAt(1);
                          });
                        });
                      }, data: widget.data['addAudio']??{},));
                  });
                  changePage(1);
                  widget.addData(data);
                }
              }, child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Add Music"),
              SizedBox(width: 5,),
              Icon(Icons.audiotrack),
            ],
          )),
        ),
      ),
    ];
    setState(() {
      widgets=[...w];
    });
  }
  List<Widget>widgets=[];
  late PageController _pageController;
  Future<void> changePage(int index)async{
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut);
  }
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        itemCount:widgets.length,
        itemBuilder: (context,index){
          return widgets[index];
        });
  }
}


class MusicTrimmer extends StatefulWidget {
  Map<String,dynamic>data;
  Trimmer trimmer;
  final File music;
  final double viewerWidth;
  final double viewerHeight;
  Duration maxAudioLength;
  final bool showDuration;
  final TextStyle durationTextStyle;
  final DurationStyle durationStyle;
  final Function(double startValue)? onChangeStart;
  final Function(double endValue)? onChangeEnd;
  VoidCallback delete;
  final TrimEditorProperties editorProperties;
  final FixedTrimAreaProperties areaProperties;
  MusicTrimmer({
    super.key,
    required this.trimmer,
    required this.music,
    this.viewerWidth = 50.0 * 8,
    this.viewerHeight = 28,
    this.maxAudioLength = const Duration(milliseconds: 0),
    this.showDuration = true,
    this.durationTextStyle = const TextStyle(color: Colors.black),
    this.durationStyle = DurationStyle.FORMAT_HH_MM_SS,
    this.onChangeStart,
    this.onChangeEnd,
    required this.delete,
    this.editorProperties = const TrimEditorProperties(),
    this.areaProperties = const FixedTrimAreaProperties(),
    required this.data,
  });

  @override
  State<MusicTrimmer> createState() => _MusicTrimmerState();
}
class _MusicTrimmerState extends State<MusicTrimmer> with TickerProviderStateMixin {
  final _trimmerAreaKey = GlobalKey();
  double _audioStartPos = 0.0;
  double _audioEndPos = 0.0;

  Offset _startPos = const Offset(0, 0);
  Offset _endPos = const Offset(0, 28);

  double _startFraction = 0.0;
  double _endFraction = 1.0;

  int _audioDuration = 0;
  int _currentPosition = 0;

  double _thumbnailViewerW = 0.0;
  double _thumbnailViewerH = 0.0;
  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    _audioPlayer.dispose();
    _animationController?.dispose();
    super.dispose();
  }
  late double _startCircleSize;
  late double _endCircleSize;
  late double _borderRadius;
  double? maxLengthPixels;
  Animation<double>? _scrubberAnimation;
  AnimationController? _animationController;
  Tween<double>? _linearTween; // Change to nullable
  late AudioPlayer _audioPlayer;
  EditorDragType _dragType = EditorDragType.left;
  bool _allowDrag = true;
  double endx = 0.0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.seek(const Duration(milliseconds: 0));
    _initializeAudioController().then((_){
      if (_linearTween != null) {
        _linearTween!.begin = _startPos.dx;
      }
      if (_animationController != null) {
        _animationController!.duration =Duration(milliseconds: (_audioEndPos - _audioStartPos).toInt());
        _animationController!.reset();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startCircleSize = widget.editorProperties.circleSize;
    _endCircleSize = widget.editorProperties.circleSize;
    _borderRadius = widget.editorProperties.borderRadius;
    _thumbnailViewerH = widget.viewerHeight;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      getD();
    });
  }

  Future<void> _initializeAudioController() async {
    await _audioPlayer.play(DeviceFileSource(widget.music.path));
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    getD();
    try {
      //_initStreams();
    }catch(e){
      print("init:$e");
    }
    try {
      _initStreams1();
    }catch(e){
      print("init1:$e");
    }
    try {
      _initStreams2();
    }catch(e){
      print("init2:$e");
    }
    initializeAn();
    if (widget.data['mTrimmer'] != null) {
      setState(() {
        _audioEndPos = widget.data['mTrimmer']['endValue'];
        _audioStartPos = widget.data['mTrimmer']['startValue'];
        final trimmerActualWidth = MediaQuery
            .of(context)
            .size
            .width * 0.95;
        _thumbnailViewerW = (trimmerActualWidth *
            widget.maxAudioLength.inMilliseconds) / 240000;
        if (_thumbnailViewerW < trimmerActualWidth) {
          _thumbnailViewerW = trimmerActualWidth;
        }
        _endFraction = _audioEndPos /  widget.maxAudioLength.inMilliseconds;
        _startFraction = _audioStartPos /  widget.maxAudioLength.inMilliseconds;
        _endFraction = _endFraction.clamp(0, 1.0);
        _startFraction = _startFraction.clamp(0, 1.0);
        _startPos = Offset(_startFraction * trimmerActualWidth, 0);
        _endPos = Offset(
            _endFraction * trimmerActualWidth, _thumbnailViewerH);
        endx = trimmerActualWidth * 0.5;
        _startCircleSize = widget.editorProperties.circleSize;
        _endCircleSize = widget.editorProperties.circleSize;
        _borderRadius = widget.editorProperties.borderRadius;
        _thumbnailViewerH = widget.viewerHeight;
        if (widget.maxAudioLength.inSeconds > 120 &&
            widget.maxAudioLength.inSeconds < 240) {
          double perc = (widget.maxAudioLength.inSeconds * 100) / 240;
          endx = (perc / 100) * _thumbnailViewerW;
        } else if (widget.maxAudioLength.inSeconds < 120 &&
            widget.maxAudioLength.inSeconds > 0) {
          endx = _thumbnailViewerW;
        }
      });
    } else {
      setState(() {
        final trimmerActualWidth = MediaQuery
            .of(context)
            .size
            .width * 0.95;
        _thumbnailViewerW = (trimmerActualWidth *
            widget.maxAudioLength.inMilliseconds) / 240000;
        if (_thumbnailViewerW < trimmerActualWidth) {
          _thumbnailViewerW = trimmerActualWidth;
        }
        endx = trimmerActualWidth * 0.5;
        if (widget.maxAudioLength > const Duration(milliseconds: 0)) {
          _endFraction = (_endPos.dx) / _thumbnailViewerW;
          _endFraction = _endFraction.clamp(0, 1.0);
          _audioEndPos = _audioDuration * _endFraction;
          _audioEndPos =
              _audioEndPos.clamp(0.0, _audioDuration.toDouble());
          widget.onChangeEnd?.call(_audioEndPos);
        } else {
          maxLengthPixels = _thumbnailViewerW;
        }
        _startCircleSize = widget.editorProperties.circleSize;
        _endCircleSize = widget.editorProperties.circleSize;
        _borderRadius = widget.editorProperties.borderRadius;
        _thumbnailViewerH = widget.viewerHeight;
        if (widget.maxAudioLength.inSeconds > 120 &&
            widget.maxAudioLength.inSeconds < 240) {
          double perc = (widget.maxAudioLength.inSeconds * 100) / 240;
          endx = (perc / 100) * _thumbnailViewerW;
        } else if (widget.maxAudioLength.inSeconds < 120 &&
            widget.maxAudioLength.inSeconds > 0) {
          endx = _thumbnailViewerW;
        }
        _endPos = Offset(endx, _thumbnailViewerH);
      });
    }
    setState(() {});
  }

  void _onDragStart(DragStartDetails details) {
    final startDifference = _startPos.dx - details.localPosition.dx;
    final endDifference = _endPos.dx - details.localPosition.dx;
    if (startDifference <= widget.editorProperties.sideTapSize &&
        endDifference >= -widget.editorProperties.sideTapSize) {
      _allowDrag = true;
    } else {
      _allowDrag = false;
      return;
    }
    if (details.localPosition.dx <= _startPos.dx + widget.editorProperties.sideTapSize) {
      _dragType = EditorDragType.left;
    } else if (details.localPosition.dx <=
        _endPos.dx - widget.editorProperties.sideTapSize) {
      _dragType = EditorDragType.center;
    } else {
      _dragType = EditorDragType.right;
    }
    setState(() {
    });
  }

  double scrollextent = 0.0;
  double currentpos = 0.0;
  double x_increament = 0.0;

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_allowDrag) return;
    double width=(MediaQuery.of(context).size.width*0.99);
    if (_dragType == EditorDragType.left) {
      _startCircleSize = widget.editorProperties.circleSizeOnDrag;
      if ((_startPos.dx + details.delta.dx >= 0) && (_startPos.dx + details.delta.dx <= _endPos.dx) && !(_endPos.dx - _startPos.dx - details.delta.dx > endx)) {
        _startPos += details.delta;
        _onStartDragged();
      }else{
        _startPos += details.delta;
        _endPos += details.delta;
        _onStartDragged();
        _onEndDragged();
      }
    } else if (_dragType == EditorDragType.center) {
      _startCircleSize = widget.editorProperties.circleSizeOnDrag;
      _endCircleSize = widget.editorProperties.circleSizeOnDrag;
      if ((_startPos.dx + details.delta.dx >= 0) &&
          (_endPos.dx + details.delta.dx <= width)) {
        _startPos += details.delta;
        _endPos += details.delta;
        _onStartDragged();
        _onEndDragged();
      }
    } else {
      _endCircleSize = widget.editorProperties.circleSizeOnDrag;
      if ((_endPos.dx + details.delta.dx <= width) &&
          (_endPos.dx + details.delta.dx >= _startPos.dx) &&
          !(_endPos.dx - _startPos.dx + details.delta.dx > endx)) {
        _endPos += details.delta;
        _onEndDragged();
      }else{
        _startPos += details.delta;
        _endPos += details.delta;
        _onStartDragged();
        _onEndDragged();
      }
    }
    setState(() {});
  }

  void _onDragEnd(DragEndDetails details)async {
    _startCircleSize = widget.editorProperties.circleSize;
    _endCircleSize = widget.editorProperties.circleSize;
    if (_animationController?.status == AnimationStatus.forward) {
      _animationController?.stop();
    }
    await _audioPlayer.stop();
    await _audioPlayer.seek(Duration(milliseconds: _audioStartPos.toInt()));
    await _audioPlayer.play(DeviceFileSource(widget.music.path));
    _playerState = PlayerState.playing;
    setState(() { });
  }
  Map<String,dynamic>data={};
  void _onStartDragged() {
    double width=(MediaQuery.of(context).size.width*0.99);
    _startFraction = (_startPos.dx) / width;
    _startFraction = _startFraction.clamp(0, 1.0);
    _audioStartPos = _audioDuration * _startFraction;
    _audioStartPos = _audioStartPos.clamp(0.0, _audioDuration.toDouble());
    widget.onChangeStart?.call(_audioStartPos);
    if (_linearTween != null) {
      _linearTween!.begin = _startPos.dx;
    }
    if (_animationController != null) {
      _animationController!.duration =
          Duration(milliseconds: (_audioEndPos - _audioStartPos).toInt());
      _animationController!.reset();
    }
  }

  void _onEndDragged() {
    double width=(MediaQuery.of(context).size.width*0.99);
    _endFraction = (_endPos.dx) / width;
    _endFraction = _endFraction.clamp(0, 1.0);
    _audioEndPos = _audioDuration * _endFraction;
    _audioEndPos = _audioEndPos.clamp(0.0, _audioDuration.toDouble());
    widget.onChangeEnd?.call(_audioEndPos);

    if (_linearTween != null) {
      _linearTween!.end = _endPos.dx;
    }
    if (_animationController != null) {
      _animationController!.duration =
          Duration(milliseconds: (_audioEndPos - _audioStartPos).toInt());
      _animationController!.reset();
    }
  }
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;


  void _onPlayButtonPressed() async {
    if (_isPlaying) {
      setState(() {
        _audioPlayer.pause();
        _playerState = PlayerState.paused;
        _animationController?.stop();
      });
    } else {
      setState(() {
        _audioPlayer.resume();
        _playerState = PlayerState.playing;
        if (!_animationController!.isAnimating) {
          _animationController!.forward();
        }
      });
    }
  }

  void _initStreams1() {
    _positionSubscription = _audioPlayer.onPositionChanged.listen((p) {
      try {
        setState(() {
          _currentPosition = p.inMilliseconds;
          if (_isPlaying) {
            if (p.inMilliseconds >= _audioEndPos.toInt()) {
              _audioPlayer.stop();
              _animationController?.stop();
              _playerState = PlayerState.stopped;
              _position = Duration.zero;
            } else {
              if (!_animationController!.isAnimating) {
                _animationController!.forward();
              }
            }
          } else {
            _animationController?.stop();
          }
        });
      } catch (e) {
        print('Error updating current position: $e');
      }
    });
  }

  void _initStreams2(){
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      try {
        setState(() {
          _playerState = PlayerState.stopped;
          _currentPosition = Duration.zero.inMilliseconds;
          _animationController?.stop();
          _animationController!.reset();
        });
      } catch (e) {
        print('Error on player complete: $e');
      }
    },
    );
  }
  void _initStreams() {
    try {
      _audioPlayer.onPlayerStateChanged.listen((state) {
        try {setState(() {
          animation="onPlayer state changed";});
        } catch (e) {
          print('Error on player state change: $e');
        }
      });

    } catch (e) {
      print('Error initializing streams: $e');
    }
  }

  getD(){
    _playerState = _audioPlayer.state;
    _audioPlayer.getDuration().then(
          (duration) {
        try {
          if (duration != null) {
            setState(() {
              widget.maxAudioLength = duration;
              _audioDuration = duration.inMilliseconds;
            });
          }
        } catch (e) {
          print('Error setting audio duration: $e');
        }
      },
    ).catchError((e) {
      print('Error getting duration: $e');
    });

  }
  String state="";
  String animation="";
  void initializeAn() {
    _linearTween = Tween(begin: _startPos.dx, end: _endPos.dx);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_audioEndPos - _audioStartPos).toInt()),
    );
    _scrubberAnimation = _linearTween?.animate(_animationController!)
      ?..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        setState(() {
          if (status == AnimationStatus.completed) {
            _animationController!.stop();
          }
        });
      });
  }


  void d(){
    showDialog(context: context, builder: (context)=>AlertDialog(content: Column(
      children: [
        Text("Music file: ${widget.music}")
      ],
    ),));
  }
  String getSongName(String filePath) {
    String fileName = filePath.split('/').last;
    String songName = fileName.replaceAll(RegExp(r'\.mp3$'), '');
    songName = songName.replaceAll('_', ' ');
    return songName;
  }


  @override
  Widget build(BuildContext context) {
    String musicname=getSongName(widget.music.path);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: GestureDetector(
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 1.0,left: 4,right: 4),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(
                      Duration(milliseconds: _audioStartPos.toInt()).format(widget.durationStyle),
                      style: widget.durationTextStyle,
                    ),
                    Text(state),
                    Text(
                      Duration(milliseconds: _currentPosition.toInt())
                          .format(widget.durationStyle),
                      style: widget.durationTextStyle,
                    ),
                    Text(animation),
                    Text(
                      Duration(milliseconds:_audioEndPos.toInt())
                          .format(widget.durationStyle),
                      style: widget.durationTextStyle,
                    ),
                  ],
                ),
              ),
            ),
            CustomPaint(
              foregroundPainter: TrimEditorPainter1(
                startPos: _startPos,
                endPos: _endPos,
                scrubberAnimationDx: _scrubberAnimation?.value ?? 0,
                startCircleSize: _startCircleSize,
                endCircleSize: _endCircleSize,
                borderRadius: _borderRadius,
                borderWidth: widget.editorProperties.borderWidth,
              ),
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(widget.areaProperties.borderRadius),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(60, (index) {
                      return const Text("|",style: TextStyle(fontSize: 23),);
                    }),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                InkWell(
                  onTap: ()=>widget.delete(),
                  child: const Icon(Icons.delete),
                ),
                InkWell(
                    onTap: ()=>_onPlayButtonPressed(),
                    child: Icon(_isPlaying ?Icons.pause:Icons.play_arrow,)),
                ScrollingText(musicName: musicname, width: MediaQuery.of(context).size.width * 0.85,)
              ],
            )
          ],
        ),
      ),
    );
  }
}class ScrollingText extends StatefulWidget {
  final String musicName;
  double width;
  ScrollingText({super.key,
    required this.musicName,
    required this.width});

  @override
  _ScrollingTextState createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _animationController.addListener(() {
      _scrollController.jumpTo(
          _animationController.value * _scrollController.position.maxScrollExtent);
    });
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: widget.width,
      child:  SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        child: SizedBox(
          width: (8 * widget.musicName.length).toDouble(),
          child: Text(widget.musicName),
        ),
      ),
    );
  }
}




class Rotation extends StatefulWidget {
  Function(double angle) set;
  Trimmer trimmer;
  Map<String,dynamic>data;
  Rotation({super.key, required this.set,required this.trimmer,required this.data});

  @override
  State<Rotation> createState() => _RotationState();
}

class _RotationState extends State<Rotation> with SingleTickerProviderStateMixin {
  double progress = 0.0;
  bool dragging = false;
  late AnimationController _controller;
  void _onDragUpdate(DragUpdateDetails details) {
    double delta = details.primaryDelta ?? 0.0;
    setState(() {
      if (delta > 0) {
        progress += (0.005*delta);
      } else if (delta < 0) {
        progress += (0.005*delta);
      }
      progress = progress.clamp(-1.0, 1.0);
    });
    widget.set(progress);
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      dragging = false;
    });
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      dragging = true;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      if(widget.data['rotation']!=null) {
        progress = widget.data['rotation']['value'];
      }
    });
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width*0.9,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: (){
                setState(() {
                  progress=progress-0.25;
                  progress = progress.clamp(-1.0, 1.0);
                });
                widget.set(progress);
              }, icon: Icon(Icons.rotate_90_degrees_ccw)),
              IconButton(onPressed: (){
                setState(() {
                  progress=progress+0.25;
                  progress = progress.clamp(-1.0, 1.0);
                });
                widget.set(progress);
              }, icon: Icon(Icons.rotate_90_degrees_cw_outlined))
            ],),
          GestureDetector(
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width*0.9, 8), // Specify the size
                  painter: CustomLinearProgressPainter1(
                    value: progress,
                    circleRadius: dragging ? 10 : 8,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: Colors.blue,
                    animationValue: _controller.value,
                    textDirection: TextDirection.ltr,
                    indicatorBorderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(90, (index) {
                      int middleIndex = (90 - 1) ~/ 2;
                      if (index == 0 || index == middleIndex || index == 90 - 1) {
                        return const Column(
                          children: [
                            Text("|"),
                            Text("|"),
                          ],
                        );
                      } else {
                        return const Text("|");
                      }
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("0°"),
                      Text("${(progress*180+180).toStringAsFixed(1)}°"),
                      Text("360°"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class AddText extends StatefulWidget {
  TextStyle style;
  Trimmer trimmer;
  Function(TextStyle style) setText;
  AddText({super.key,
    required this.setText,
    required this.style,required this.trimmer,});

  @override
  State<AddText> createState() => _AddTextState();
}

class _AddTextState extends State<AddText> {
  TextEditingController textSize=TextEditingController(text: "14.0");
  TextStyle textStyle=TextStyle();
  Color color = Colors.black;
  Color bcolor = Colors.black;
  Color selectedcolor = Colors.black;
  List<Color> colors = [
    Colors.black,
    Colors.blue,
    Colors.purple,
    Colors.brown,
    Colors.red,
    Colors.white,
    Colors.green,
    Colors.indigo,
    Colors.orange,
    Colors.blueGrey,
    Colors.green,
    Colors.grey,
    Colors.amber,
    Colors.cyan,
    Colors.deepOrange,
    Colors.indigo,
    Colors.pink,
    Colors.teal,
    Colors.yellow,
    Colors.lime
  ];
  double fsize=14.0;
  List<double>fsizes=[
    10,12,14,16,18,20,24,28,32,36,40,45,50
  ];
  Color? backgroundColor;
  List<Widget>fontwidgets=[];
  bool isbold=false;
  bool style =false;
  bool isEnabled=true;
  @override
  void initState() {
    super.initState();
    setState(() {
      textStyle = widget.style;
      if(textStyle.fontSize!=null) {
        fsize = textStyle.fontSize!;
        textSize.text=textStyle.fontSize.toString();
      }
      if(textStyle.backgroundColor!=null){
        backgroundColor=textStyle.backgroundColor;
      }
      if(textStyle.color!=null){
        color=textStyle.color!;
        selectedcolor=textStyle.color!;
      }
      if(textStyle.fontWeight!=null&&textStyle.fontWeight==FontWeight.bold){
        isbold=true;
      }
      if(textStyle.fontStyle!=null&&textStyle.fontStyle==FontStyle.italic){
        style=true;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(
              width: MediaQuery.of(context).size.width*0.25,
              height: MediaQuery.of(context).size.height*0.25,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Font Size",style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.2,
                    height: 35,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      controller: textSize,
                      onChanged: (value){
                        setState(() {
                          fsize=double.parse(value);
                          textStyle=TextStyle(backgroundColor: backgroundColor,color: color,fontWeight: isbold?FontWeight.bold:FontWeight.normal,fontSize: fsize,fontStyle: style?FontStyle.italic:FontStyle.normal);
                        });
                        widget.setText(textStyle);},
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 2,horizontal: 2),
                        border:OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Colors
                                  .grey),
                          borderRadius: BorderRadius
                              .circular(8),
                        ),
                        suffix:PopupMenuButton<double>(
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 2,vertical: 1)),
                            minimumSize: WidgetStateProperty.all<Size>(Size.zero), // Removes the default size constraints
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(),
                          position: PopupMenuPosition.under,
                          icon: const Icon(
                            Icons.arrow_drop_down,color: Colors.black,size: 30,),
                          onSelected: (value) {
                            setState(() {
                              fsize = value;
                              textSize.text=value.toString();
                              textStyle=TextStyle(backgroundColor: backgroundColor,color: color,fontWeight: isbold?FontWeight.bold:FontWeight.normal,fontSize: fsize,fontStyle: style?FontStyle.italic:FontStyle.normal);
                            });
                            widget.setText(textStyle);
                          },
                          itemBuilder: (BuildContext context) {
                            return fsizes.map<PopupMenuEntry<double>>((item) {
                              return PopupMenuItem<double>(
                                value: item,
                                child: Text(item.toString()),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                  Text("Font Styles",style: TextStyle(fontWeight: FontWeight.bold),),
                  Wrap(
                    children: [
                      InkWell(
                        onTap:(){
                          setState(() {
                            isbold=!isbold;
                            textStyle=TextStyle(backgroundColor: backgroundColor,color: color,fontWeight: isbold?FontWeight.bold:FontWeight.normal,fontSize: fsize,fontStyle: style?FontStyle.italic:FontStyle.normal);
                          });
                          widget.setText(textStyle);
                        },             child: Container(
                          height: 30,width: 30,
                          color:isbold?Colors.black12:Colors.white,
                          child: Center(child: Text("B",style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: isbold?FontWeight.bold:FontWeight.normal),))),
                      ),
                      SizedBox(width: 10,),
                      InkWell(
                        onTap:(){
                          setState(() {
                            style=!style;
                            textStyle=TextStyle(backgroundColor: backgroundColor,color: color,fontWeight: isbold?FontWeight.bold:FontWeight.normal,fontSize: fsize,fontStyle: style?FontStyle.italic:FontStyle.normal);
                          });
                          widget.setText(textStyle);
                        },
                        child: Container(
                          height: 30,width: 30,
                          color:style?Colors.black12:Colors.white,
                          child: Center(child: Text("I",style: TextStyle(fontSize: 16,fontStyle: FontStyle.italic),)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(
              width: MediaQuery.of(context).size.width*0.74,
              height: MediaQuery.of(context).size.height*0.25,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Text Color",style: TextStyle(fontWeight: FontWeight.bold),),
                          IconButton(
                            style: ButtonStyle(
                              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(horizontal: 8,)),
                              minimumSize: WidgetStateProperty.all<Size>(Size.zero), // Removes the default size constraints
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints.tightFor(), // This removes any additional padding
                            onPressed: () {
                              setState(() {
                                if(isEnabled){
                                  isEnabled=false;
                                }else{
                                  isEnabled=true;
                                }
                              });
                            },
                            icon: Icon(
                              isEnabled ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: isEnabled ? Colors.purple : Colors.black54,
                            ),
                          ),
                        ],
                      ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Highlight Color",style: TextStyle(fontWeight: FontWeight.bold),),
                          IconButton(
                              style: ButtonStyle(
                                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(horizontal: 8,)),
                                minimumSize: WidgetStateProperty.all<Size>(Size.zero), // Removes the default size constraints
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints.tightFor(),
                              onPressed: (){
                                setState(() {
                                  if(isEnabled){
                                    isEnabled=false;
                                    if(backgroundColor!=null){
                                      selectedcolor=backgroundColor!;
                                    }
                                  }else{
                                    isEnabled=true;
                                  }
                                });
                              },icon:Icon(
                            isEnabled ? Icons.radio_button_unchecked:Icons.radio_button_checked,
                            color:isEnabled?Colors.black54:Colors.purple,
                          )),
                          InkWell(
                              onTap: (){
                                setState(() {
                                  backgroundColor=null;
                                  isEnabled=true;
                                  textStyle=TextStyle(backgroundColor: backgroundColor,color: color,fontWeight: isbold?FontWeight.bold:FontWeight.normal,fontSize: fsize,fontStyle: style?FontStyle.italic:FontStyle.normal);
                                });
                                widget.setText(textStyle);
                              },
                              child: Icon(Icons.close,color: Colors.black,)),
                        ],
                      ),
                    ],
                  ),
                  Wrap(
                    children: colors.map((c) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if(isEnabled) {
                              if (c == Colors.black) {
                                bcolor = Colors.white;
                              } else {
                                bcolor = Colors.black;
                              }
                              color=c;
                            }else{
                              if (c == Colors.black) {
                                bcolor = Colors.white;
                              } else {
                                bcolor = Colors.black;
                              }
                              backgroundColor = c;
                            }
                            selectedcolor=c;
                            textStyle=TextStyle(backgroundColor: backgroundColor,color: color,fontWeight: isbold?FontWeight.bold:FontWeight.normal,fontSize: fsize,fontStyle: style?FontStyle.italic:FontStyle.normal);
                          });
                          widget.setText(textStyle);
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: c,
                            border: Border.all(
                              color: selectedcolor == c ? bcolor : Colors.transparent,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Crop extends StatefulWidget {
  void Function(double wR,double wL,double lL,double lR) setD;
  Trimmer trimmer;
  Map<String,dynamic>data;
  Crop({super.key,required this.setD,required this.trimmer,required this.data});

  @override
  State<Crop> createState() => _CropState();
}

class _CropState extends State<Crop> with SingleTickerProviderStateMixin {
  double progressWr = 0.05;
  double progressWl = 0.05;
  double progressLl = 0.05;
  double progressLr = 0.05;
  bool draggingWr = false;
  bool draggingWl = false;
  bool draggingLl = false;
  bool draggingLr = false;
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    setState(() {
      if(widget.data['crop']!=null){
        progressWr = widget.data['crop']['wr'];
        progressWl = widget.data['crop']['wl'];
        progressLl = widget.data['crop']['ll'];
        progressLr = widget.data['crop']['lr'];
      }
    });
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _controller.repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void _onDragUpdateWr(DragUpdateDetails details) {
    double delta = details.primaryDelta ?? 0.0;
    setState(() {
      if (delta > 0) {
        progressWr += (0.003*delta);
      } else if (delta < 0) {
        progressWr += (0.003*delta);
      }
      progressWr = progressWr.clamp(0.0, 1.0);
    });
    widget.setD(progressWr,progressWl,progressLl,progressLr);
  }
  void _onDragUpdateWl(DragUpdateDetails details) {
    double delta = details.primaryDelta ?? 0.0;
    setState(() {
      if (delta > 0) {
        progressWl += (0.003*delta);
      } else if (delta < 0) {
        progressWl += (0.003*delta);
      }
      progressWl = progressWl.clamp(0.0, 1.0);
    });
    widget.setD(progressWr,progressWl,progressLl,progressLr);
  } void _onDragUpdateLl(DragUpdateDetails details) {
    double delta = details.primaryDelta ?? 0.0;
    setState(() {
      if (delta > 0) {
        progressLl += (0.003*delta);
      } else if (delta < 0) {
        progressLl += (0.003*delta);
      }
      progressLl = progressLl.clamp(0.0, 1.0);
    });
    widget.setD(progressWr,progressWl,progressLl,progressLr);
  } void _onDragUpdateLr(DragUpdateDetails details) {
    double delta = details.primaryDelta ?? 0.0;
    setState(() {
      if (delta > 0) {
        progressLr += (0.003*delta);
      } else if (delta < 0) {
        progressLr += (0.003*delta);
      }
      progressLr = progressLr.clamp(0.0, 1.0);
    });
    widget.setD(progressWr,progressWl,progressLl,progressLr);
  }
  void _onDragEndWr(DragEndDetails details) {
    setState(() {
      draggingWr = false;
    });
  }

  void _onDragStartWr(DragStartDetails details) {
    setState(() {
      draggingWr = true;
    });
  }
  void _onDragEndWl(DragEndDetails details) {
    setState(() {
      draggingWl = false;
    });
  }

  void _onDragStartWl(DragStartDetails details) {
    setState(() {
      draggingWl = true;
    });
  }  void _onDragEndLl(DragEndDetails details) {
    setState(() {
      draggingLl = false;
    });
  }

  void _onDragStartLl(DragStartDetails details) {
    setState(() {
      draggingLl = true;
    });
  }  void _onDragEndLr(DragEndDetails details) {
    setState(() {
      draggingLr= false;
    });
  }

  void _onDragStartLr(DragStartDetails details) {
    setState(() {
      draggingLr = true;
    });
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width*0.9,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onHorizontalDragStart: _onDragStartWr,
            onHorizontalDragUpdate: _onDragUpdateWr,
            onHorizontalDragEnd: _onDragEndWr,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width*0.9, 8), // Specify the size
                  painter: CustomLinearProgressPainter(
                    value: progressWr,
                    circleRadius: draggingWr ? 10 : 8,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: Colors.blue,
                    animationValue: _controller.value,
                    textDirection: TextDirection.ltr,
                    indicatorBorderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 5),
                Text("Right=>${(progressWr * MediaQuery.of(context).size.width).toStringAsFixed(1)}"),
              ],
            ),
          ),
          GestureDetector(
            onHorizontalDragStart: _onDragStartWl,
            onHorizontalDragUpdate: _onDragUpdateWl,
            onHorizontalDragEnd: _onDragEndWl,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width*0.9, 8), // Specify the size
                  painter: CustomLinearProgressPainter(
                    value: progressWl,
                    circleRadius: draggingWl ? 10 : 8,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: Colors.blue,
                    animationValue: _controller.value,
                    textDirection: TextDirection.ltr,
                    indicatorBorderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 5),
                Text("Left=>${(progressWl * MediaQuery.of(context).size.width).toStringAsFixed(1)}"),
              ],
            ),
          ),
          GestureDetector(
            onHorizontalDragStart: _onDragStartLr,
            onHorizontalDragUpdate: _onDragUpdateLr,
            onHorizontalDragEnd: _onDragEndLr,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width*0.9, 8), // Specify the size
                  painter: CustomLinearProgressPainter(
                    value: progressLr,
                    circleRadius: draggingLr ? 10 : 8,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: Colors.blue,
                    animationValue: _controller.value,
                    textDirection: TextDirection.ltr,
                    indicatorBorderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 5),
                Text("Top=>${(progressLr * MediaQuery.of(context).size.height*0.5).toStringAsFixed(1)}"),
              ],
            ),
          ),
          GestureDetector(
            onHorizontalDragStart: _onDragStartLl,
            onHorizontalDragUpdate: _onDragUpdateLl,
            onHorizontalDragEnd: _onDragEndLl,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width*0.9, 8), // Specify the size
                  painter: CustomLinearProgressPainter(
                    value: progressLl,
                    circleRadius: draggingLr ? 10 : 8,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: Colors.blue,
                    animationValue: _controller.value,
                    textDirection: TextDirection.ltr,
                    indicatorBorderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 5),
                Text("Bottom=>${(progressLl * MediaQuery.of(context).size.height*0.5).toStringAsFixed(1)}"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class CustomLinearProgressPainter extends CustomPainter {
  final double circleRadius;
  final Color backgroundColor;
  final Color valueColor;
  final double? value;
  final double animationValue;
  final TextDirection textDirection;
  final BorderRadiusGeometry indicatorBorderRadius;

  CustomLinearProgressPainter({
    required this.circleRadius,
    required this.backgroundColor,
    required this.valueColor,
    required this.animationValue,
    required this.textDirection,
    required this.indicatorBorderRadius,
    this.value,
  });

  static const Curve line1Head = Interval(
    0.0,
    750.0 / _kIndeterminateLinearDuration,
    curve: Cubic(0.2, 0.0, 0.8, 1.0),
  );
  static const Curve line1Tail = Interval(
    333.0 / _kIndeterminateLinearDuration,
    (333.0 + 750.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.4, 0.0, 1.0, 1.0),
  );
  static const Curve line2Head = Interval(
    1000.0 / _kIndeterminateLinearDuration,
    (1000.0 + 567.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.0, 0.0, 0.65, 1.0),
  );
  static const Curve line2Tail = Interval(
    1267.0 / _kIndeterminateLinearDuration,
    (1267.0 + 533.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.10, 0.0, 0.45, 1.0),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final Paint progressPaint = Paint()
      ..color = valueColor
      ..style = PaintingStyle.fill;
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    final Paint circlePaint = Paint()
      ..color = valueColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height / 2 - 4, size.width, 8),
      backgroundPaint,
    );
    double progressLineWidth = size.width * value!;
    if (value != null) {
      progressLineWidth = clampDouble(value!, 0.0, 1.0) * size.width;
      canvas.drawRect(
        Rect.fromLTWH(0, size.height / 2 - 4, progressLineWidth, 8),
        progressPaint,
      );
      double circlePosition = progressLineWidth;
      canvas.drawCircle(
        Offset(circlePosition, size.height / 2),
        circleRadius,
        circlePaint,
      );
    } else {
      final double x1 = size.width * line1Tail.transform(animationValue);
      final double width1 = size.width * line1Head.transform(animationValue) - x1;
      final double x2 = size.width * line2Tail.transform(animationValue);
      final double width2 = size.width * line2Head.transform(animationValue) - x2;
      drawBar(canvas, size, x1, width1, progressPaint);
      drawBar(canvas, size, x2, width2, progressPaint);
    }
  }

  void drawBar(Canvas canvas, Size size, double x, double width, Paint paint) {
    if (width <= 0.0) {
      return;
    }
    double left;
    if (textDirection == TextDirection.rtl) {
      left = size.width - width - x;
    } else {
      left = x;
    }
    final Rect rect = Offset(left, 0.0) & Size(width, size.height);
    if (indicatorBorderRadius != BorderRadius.zero) {
      final RRect rrect = indicatorBorderRadius.resolve(textDirection).toRRect(rect);
      canvas.drawRRect(rrect, paint);
    } else {
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(CustomLinearProgressPainter oldDelegate) {
    return oldDelegate.circleRadius != circleRadius ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.valueColor != valueColor ||
        oldDelegate.value != value ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.indicatorBorderRadius != indicatorBorderRadius;
  }
}

class CustomLinearProgressPainter1 extends CustomPainter {
  final double circleRadius;
  final Color backgroundColor;
  final Color valueColor;
  final double? value;
  final double animationValue;
  final TextDirection textDirection;
  final BorderRadiusGeometry indicatorBorderRadius;

  CustomLinearProgressPainter1({
    required this.circleRadius,
    required this.backgroundColor,
    required this.valueColor,
    required this.animationValue,
    required this.textDirection,
    required this.indicatorBorderRadius,
    this.value,
  });

  static const Curve line1Head = Interval(
    0.0,
    750.0 / _kIndeterminateLinearDuration,
    curve: Cubic(0.2, 0.0, 0.8, 1.0),
  );
  static const Curve line1Tail = Interval(
    333.0 / _kIndeterminateLinearDuration,
    (333.0 + 750.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.4, 0.0, 1.0, 1.0),
  );
  static const Curve line2Head = Interval(
    1000.0 / _kIndeterminateLinearDuration,
    (1000.0 + 567.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.0, 0.0, 0.65, 1.0),
  );
  static const Curve line2Tail = Interval(
    1267.0 / _kIndeterminateLinearDuration,
    (1267.0 + 533.0) / _kIndeterminateLinearDuration,
    curve: Cubic(0.10, 0.0, 0.45, 1.0),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final Paint progressPaint = Paint()
      ..color = valueColor
      ..style = PaintingStyle.fill;
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    final Paint circlePaint = Paint()
      ..color = valueColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height / 2 - 4, size.width, 8),
      backgroundPaint,
    );
    double centerX = size.width / 2;

    if (value != null) {
      double progressLineWidth = clampDouble(value!.abs(), 0.0, 1.0) * size.width / 2;
      if (value! > 0) {
        canvas.drawRect(
          Rect.fromLTWH(centerX, size.height / 2 - 4, progressLineWidth, 8),
          progressPaint,
        );
        canvas.drawCircle(
          Offset(centerX + progressLineWidth, size.height / 2),
          circleRadius,
          circlePaint,
        );
      } else if (value! < 0) {
        canvas.drawRect(
          Rect.fromLTWH(centerX - progressLineWidth, size.height / 2 - 4, progressLineWidth, 8),
          progressPaint,
        );

        canvas.drawCircle(
          Offset(centerX - progressLineWidth, size.height / 2),
          circleRadius,
          circlePaint,
        );
      } else {
        canvas.drawCircle(
          Offset(centerX, size.height / 2),
          circleRadius,
          circlePaint,
        );
      }
    } else {
      final double x1 = size.width * line1Tail.transform(animationValue);
      final double width1 = size.width * line1Head.transform(animationValue) - x1;
      final double x2 = size.width * line2Tail.transform(animationValue);
      final double width2 = size.width * line2Head.transform(animationValue) - x2;
      drawBar(canvas, size, x1, width1, progressPaint);
      drawBar(canvas, size, x2, width2, progressPaint);
      canvas.drawCircle(
        Offset(centerX, size.height / 2),
        circleRadius,
        circlePaint,
      );
    }
  }

  void drawBar(Canvas canvas, Size size, double x, double width, Paint paint) {
    if (width <= 0.0) {
      return;
    }
    double left;
    if (textDirection == TextDirection.rtl) {
      left = size.width - width - x;
    } else {
      left = x;
    }
    final Rect rect = Offset(left, 0.0) & Size(width, size.height);
    if (indicatorBorderRadius != BorderRadius.zero) {
      final RRect rrect = indicatorBorderRadius.resolve(textDirection).toRRect(rect);
      canvas.drawRRect(rrect, paint);
    } else {
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(CustomLinearProgressPainter1 oldDelegate) {
    return oldDelegate.circleRadius != circleRadius ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.valueColor != valueColor ||
        oldDelegate.value != value ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.indicatorBorderRadius != indicatorBorderRadius;
  }
}





enum TrimmerEvent { initialized }


class TrimViewer extends StatefulWidget {
  final Trimmer trimmer;
  final double viewerWidth;
  final double viewerHeight;
  final Duration maxVideoLength;
  final Duration trimduration;
  final bool showDuration;
  final TextStyle durationTextStyle;
  final DurationStyle durationStyle;
  final Function(double startValue)? onChangeStart;
  final Function(double endValue)? onChangeEnd;
  final Function(bool isPlaying)? onChangePlaybackState;
  final Function(Map<String,dynamic>data) addData;
  final double paddingFraction;
  final TrimEditorProperties editorProperties;
  final TrimAreaProperties areaProperties;
  final VoidCallback? onThumbnailLoadingComplete;
  Map<String,dynamic>data;
  TrimViewer({
    super.key,
    required this.trimduration,
    required this.trimmer,
    required this.maxVideoLength,
    this.viewerWidth = 50 * 8,
    this.viewerHeight = 50,
    this.showDuration = true,
    this.durationTextStyle = const TextStyle(color: Colors.black),
    this.durationStyle = DurationStyle.FORMAT_HH_MM_SS,
    this.onChangeStart,
    this.onChangeEnd,
    this.onChangePlaybackState,
    this.paddingFraction = 0.2,
    required this.addData,
    required this.data,
    this.editorProperties = const TrimEditorProperties(),
    this.areaProperties = const TrimAreaProperties(),
    this.onThumbnailLoadingComplete,
  });

  @override
  State<TrimViewer> createState() => _TrimViewerState();
}

class _TrimViewerState extends State<TrimViewer> with TickerProviderStateMixin {
  bool? _isScrollableAllowed;

  @override
  void initState() {
    super.initState();
    widget.trimmer.eventStream.listen((event) {
      if (event == TrimmerEvent.initialized) {
        final totalDuration = widget.trimmer.videoPlayerController!.value.duration;
        final maxVideoLength = widget.maxVideoLength;
        final paddingFraction = widget.paddingFraction;
        final trimAreaDuration = Duration(
            milliseconds: (widget.trimduration.inMilliseconds +
                ((paddingFraction * widget.trimduration.inMilliseconds) * 2)
                    .toInt()));
        final shouldScroll = trimAreaDuration <= totalDuration &&
            maxVideoLength.compareTo(const Duration(milliseconds: 0)) != 0;
        setState(() => _isScrollableAllowed = shouldScroll);
      }
    });

  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //check();
  }
  void check(){
    showDialog(context: context, builder: (context)=>AlertDialog(content: Column(
      children: [
        Text("MaxvideoLenth: ${widget.trimmer.videoPlayerController!.value.duration}"),
        Text("trimduration: ${widget.trimduration}"),
        //_isScrollableAllowed!?Text("scrollable"):Text("not scrollable")
      ],
    ),));
  }
  @override
  Widget build(BuildContext context) {
    final fixedTrimViewer = FixedTrimViewer(
      trimduration: widget.trimduration,
      trimmer: widget.trimmer,
      maxVideoLength: widget.maxVideoLength,
      viewerWidth: widget.viewerWidth,
      viewerHeight: widget.viewerHeight,
      showDuration: widget.showDuration,
      durationTextStyle: widget.durationTextStyle,
      durationStyle: widget.durationStyle,
      onChangeStart: widget.onChangeStart,
      onChangeEnd: widget.onChangeEnd,
      onChangePlaybackState: widget.onChangePlaybackState,
      editorProperties: widget.editorProperties,
      areaProperties: FixedTrimAreaProperties(
        thumbnailFit: widget.areaProperties.thumbnailFit,
        thumbnailQuality: widget.areaProperties.thumbnailQuality,
        borderRadius: widget.areaProperties.borderRadius,
      ),
      onThumbnailLoadingComplete: () {
        if (widget.onThumbnailLoadingComplete != null) {
          widget.onThumbnailLoadingComplete!();
        }
      }, addData:widget.addData, data:widget.data,
    );

    return  fixedTrimViewer;
  }
}

class TrimAreaProperties {
  final BoxFit thumbnailFit;
  final int thumbnailQuality;
  final bool blurEdges;
  final Color blurColor;
  final Widget? startIcon;
  final Widget? endIcon;
  final double borderRadius;
  const TrimAreaProperties({
    this.thumbnailFit = BoxFit.fitHeight,
    this.thumbnailQuality = 75,
    this.blurEdges = false,
    this.blurColor = Colors.black,
    this.startIcon,
    this.endIcon,
    this.borderRadius = 4.0,
  });
  factory TrimAreaProperties.fixed({
    BoxFit thumbnailFit,
    int thumbnailQuality,
    double borderRadius,
  }) = FixedTrimAreaProperties;
  factory TrimAreaProperties.edgeBlur({
    BoxFit thumbnailFit,
    int thumbnailQuality,
    bool blurEdges,
    Color blurColor,
    Widget? startIcon,
    Widget? endIcon,
    double borderRadius,
  }) = _TrimAreaPropertiesWithBlur;
}

class FixedTrimAreaProperties extends TrimAreaProperties {
  const FixedTrimAreaProperties({
    super.thumbnailFit,
    super.thumbnailQuality,
    super.borderRadius,
  });
}

class _TrimAreaPropertiesWithBlur extends TrimAreaProperties {
  _TrimAreaPropertiesWithBlur({
    super.thumbnailFit,
    super.thumbnailQuality,
    blurEdges,
    super.blurColor,
    super.borderRadius,
    endIcon,
    startIcon,
  }) : super(
    blurEdges: true,
    startIcon: const Icon(
      Icons.arrow_back_ios_new_rounded,
      color: Colors.white,
      size: 16,
    ),
    endIcon: const Icon(
      Icons.arrow_forward_ios_rounded,
      color: Colors.white,
      size: 16,
    ),
  );
}


class TrimEditorProperties {
  final double circleSize;
  final double circleSizeOnDrag;
  final double borderWidth;
  final double scrubberWidth;
  final double borderRadius;
  final Color circlePaintColor;
  final Color borderPaintColor;
  final Color scrubberPaintColor;
  final int sideTapSize;
  const TrimEditorProperties({
    this.circleSize = 5.0,
    this.circleSizeOnDrag = 8.0,
    this.borderWidth = 3.0,
    this.scrubberWidth = 0.5,
    this.borderRadius = 4.0,
    this.circlePaintColor = Colors.white,
    this.borderPaintColor = Colors.white,
    this.scrubberPaintColor = Colors.white,
    this.sideTapSize = 24,
  });
}


class VideoViewer extends StatefulWidget {
  final Trimmer trimmer;
  final Function(bool isPlaying)? onChangePlaybackState;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets padding;
  const VideoViewer({
    super.key,
    required this.trimmer,
    required this.onChangePlaybackState,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0.0,
    this.padding = const EdgeInsets.all(0.0),
  });

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  VideoPlayerController? get videoPlayerController =>
      widget.trimmer.videoPlayerController;

  @override
  void initState() {
    widget.trimmer.eventStream.listen((event) {
      if (event == TrimmerEvent.initialized) {
        setState(() {});
      }
    });
    super.initState();
    videoPlayerController!.addListener(() {
      final bool isPlaying = videoPlayerController!.value.isPlaying;
      if (isPlaying) {
        widget.onChangePlaybackState?.call(true);
      } else {
        widget.onChangePlaybackState?.call(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = videoPlayerController;
    return controller == null
        ? Container()
        : Padding(
      padding: const EdgeInsets.all(0.0),
      child: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: controller.value.isInitialized
              ? Container(
            foregroundDecoration: BoxDecoration(
              border: Border.all(
                width: widget.borderWidth,
                color: widget.borderColor,
              ),
            ),
            child: VideoPlayer(controller),
          )
              : const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.trimmer.dispose();
    super.dispose();
  }
}


class FixedTrimViewer extends StatefulWidget {
  final Trimmer trimmer;
  final double viewerWidth;
  final double viewerHeight;
  final Duration maxVideoLength;
  final Duration trimduration;
  final bool showDuration;
  final TextStyle durationTextStyle;
  final DurationStyle durationStyle;
  final Function(double startValue)? onChangeStart;
  final Function(double endValue)? onChangeEnd;
  final Function(bool isPlaying)? onChangePlaybackState;
  final Function(Map<String,dynamic>data) addData;
  final double paddingFraction;
  final TrimEditorProperties editorProperties;
  final TrimAreaProperties areaProperties;
  final VoidCallback onThumbnailLoadingComplete;
  Map<String,dynamic>data;
  FixedTrimViewer({
    super.key,
    required this.trimduration,
    required this.trimmer,
    required this.maxVideoLength,
    this.viewerWidth = 50 * 8,
    this.viewerHeight = 50,
    this.showDuration = true,
    this.durationTextStyle = const TextStyle(color: Colors.black),
    this.durationStyle = DurationStyle.FORMAT_HH_MM_SS,
    this.onChangeStart,
    this.onChangeEnd,
    this.onChangePlaybackState,
    this.paddingFraction = 0.2,
    required this.addData,
    required this.data,
    this.editorProperties = const TrimEditorProperties(),
    this.areaProperties = const TrimAreaProperties(),
    required this.onThumbnailLoadingComplete,
  });

  @override
  State<FixedTrimViewer> createState() => _FixedTrimViewerState();
}

class _FixedTrimViewerState extends State<FixedTrimViewer>
    with TickerProviderStateMixin {
  final _trimmerAreaKey = GlobalKey();
  File? get _videoFile => widget.trimmer.currentVideoFile;

  double _videoStartPos = 0.0;
  double _videoEndPos = 0.0;

  Offset _startPos = const Offset(0, 0);
  Offset _endPos = const Offset(0, 0);

  double _startFraction = 0.0;
  double _endFraction = 1.0;

  int _videoDuration = 0;
  int _currentPosition = 0;

  double _thumbnailViewerW = 0.0;
  double _thumbnailViewerH = 0.0;

  int _numberOfThumbnails = 0;

  late double _startCircleSize;
  late double _endCircleSize;
  late double _borderRadius;
  double? maxLengthPixels;

  FixedThumbnailViewer? thumbnailWidget;
  Animation<double>? _scrubberAnimation;
  AnimationController? _animationController;
  late Tween<double> _linearTween;
  VideoPlayerController get videoPlayerController => widget.trimmer.videoPlayerController!;
  EditorDragType _dragType = EditorDragType.left;
  bool _allowDrag = true;
  double endx=0.0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startCircleSize = widget.editorProperties.circleSize;
    _endCircleSize = widget.editorProperties.circleSize;
    _borderRadius = widget.editorProperties.borderRadius;
    _thumbnailViewerH = widget.viewerHeight;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _initializeVideoController();
      setState(() {
        final renderBox = _trimmerAreaKey.currentContext?.findRenderObject() as RenderBox?;
        final trimmerActualWidth = renderBox?.size.width;
        if (trimmerActualWidth == null) return;
        _thumbnailViewerW = (trimmerActualWidth*widget.maxVideoLength.inMilliseconds)/240000;
        if(_thumbnailViewerW<trimmerActualWidth){
          _thumbnailViewerW=trimmerActualWidth;
        }
        _numberOfThumbnails = _thumbnailViewerW ~/ _thumbnailViewerH;
        _videoDuration=videoPlayerController.value.duration.inMilliseconds;
        final FixedThumbnailViewer thumbnailWidget = FixedThumbnailViewer(
          videoFile: _videoFile!,
          videoDuration: widget.maxVideoLength.inMilliseconds,
          fit: widget.areaProperties.thumbnailFit,
          thumbnailHeight: _thumbnailViewerH,
          numberOfThumbnails: _numberOfThumbnails,
          quality: widget.areaProperties.thumbnailQuality,
          onThumbnailLoadingComplete: widget.onThumbnailLoadingComplete,
        );
        this.thumbnailWidget = thumbnailWidget;
        endx=trimmerActualWidth*0.5;
        if( widget.maxVideoLength.inSeconds>120&& widget.maxVideoLength.inSeconds<240){
          double  perc=(widget.maxVideoLength.inSeconds*100)/240;
          endx=(perc/100)*_thumbnailViewerW;
        }else if(widget.maxVideoLength.inSeconds<120){
          endx=_thumbnailViewerW;
        }
        _endPos = Offset(endx,
          _thumbnailViewerH,
        );
        _videoDuration = videoPlayerController.value.duration.inMilliseconds;
        if (widget.maxVideoLength > const Duration(milliseconds: 0)) {
          _endFraction = (_endPos.dx) / _thumbnailViewerW;
          _endFraction = _endFraction.clamp(0, 1.0);
          _videoEndPos = _videoDuration * _endFraction;
          _videoEndPos= _videoEndPos.clamp(0.0, _videoDuration.toDouble());
          widget.onChangeEnd!(_videoEndPos);
        } else {
          maxLengthPixels = _thumbnailViewerW;
        }
        videoPlayerController.seekTo(const Duration(milliseconds:0));
        _linearTween = Tween(begin: _startPos.dx, end: _endPos.dx);
        _animationController = AnimationController(
          vsync: this,
          duration:
          Duration(milliseconds: (_videoEndPos - _videoStartPos).toInt()),
        );
        _scrubberAnimation = _linearTween.animate(_animationController!)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _animationController!.stop();
            }
          });
      });
    });
  }
  void d(){
    showDialog(context: context, builder: (context)=>AlertDialog(content: Column(
      children: [
        Text("FixedTrimmer"),
        Text("endpos: dy${_endPos.dy} dx${_endPos.dx}"),
        Text("start: dy${_startPos.dy} dx${_startPos.dx}"),
        Text("_thumbnailViewerH: $_thumbnailViewerH,"),
        Text("maxLengthPixels: $maxLengthPixels,"),
        Text("Videoend: $_videoDuration,"),
        Text("currentpostion: $_currentPosition"),
        Text("videoendpos: $_videoEndPos,"),
        Text("videostartpos: $_videoStartPos,"),
        Text("maxvideoLength: ${widget.maxVideoLength},"),
        Text("videoduration: $_videoDuration,"),
        Text("Number of thumbnail: $_numberOfThumbnails"),
        Text("thumbnailViewerWidth: $_thumbnailViewerW"),
        videoPlayerController==null?Text("videocontroller is null"):Text("videocontroller is not null"),
        Text("video file: ${_videoFile}")
      ],
    ),));
  }
  Future<void> _initializeVideoController() async {
    //d();
    if (_videoFile != null) {
      videoPlayerController.play();
      videoPlayerController.addListener(() {
        final bool isPlaying = videoPlayerController.value.isPlaying;
        _currentPosition = videoPlayerController.value.position.inMilliseconds;
        if (isPlaying) {
          widget.onChangePlaybackState?.call(true);
          if (_currentPosition>_videoEndPos.toInt()) {
            videoPlayerController.pause();
            widget.onChangePlaybackState?.call(false);
            _animationController?.stop();
          } else {
            if (!_animationController!.isAnimating) {
              _animationController!.forward();
            }
          }
        } else {
          if (videoPlayerController.value.isInitialized) {
            if (_animationController != null) {
              if ((_scrubberAnimation?.value ?? 0).toInt() == _endPos.dx.toInt()) {
                _animationController!.reset();
              }
              _animationController!.stop();
            }
            widget.onChangePlaybackState?.call(false);
          }
        }
      });
      videoPlayerController.setVolume(1.0);
    }
    setState(() {});
  }

  void _onDragStart(DragStartDetails details) {
    final startDifference = _startPos.dx - details.localPosition.dx;
    final endDifference = _endPos.dx - details.localPosition.dx;
    if (startDifference <= widget.editorProperties.sideTapSize &&
        endDifference >= -widget.editorProperties.sideTapSize) {
      _allowDrag = true;
    } else {
      _allowDrag = false;
      return;
    }
    if (details.localPosition.dx <= _startPos.dx + widget.editorProperties.sideTapSize) {
      _dragType = EditorDragType.left;
    } else if (details.localPosition.dx <=
        _endPos.dx - widget.editorProperties.sideTapSize) {
      _dragType = EditorDragType.center;
    } else {
      _dragType = EditorDragType.right;
    }
  }
  double scrollextent=0.0;
  double currentpos=0.0;
  double x_increament=0.0;
  void _onDragUpdate(DragUpdateDetails details) {
    if (!_allowDrag) return;
    double width=(MediaQuery.of(context).size.width*0.99);
    if (_dragType == EditorDragType.left) {
      _startCircleSize = widget.editorProperties.circleSizeOnDrag;
      if ((_startPos.dx + details.delta.dx >= 0) &&
          (_startPos.dx + details.delta.dx <= _endPos.dx)
          && !(_endPos.dx - _startPos.dx - details.delta.dx > endx)) {
        _startPos += details.delta;
        _onStartDragged();
      }else{
        _startPos += details.delta;
        _endPos += details.delta;
        if(width-(_endPos.dx + details.delta.dx) <= 1){
          x_increament=x_increament+0.015;
          x_increament = x_increament.clamp(0.0, 1.0);
          controller.animateTo(controller.position.maxScrollExtent*x_increament, duration: const Duration(milliseconds: 400), curve:Curves.linear);
        }else if(x_increament>0.0&&_startPos.dx<=1){
          x_increament=x_increament-0.015;
          x_increament = x_increament.clamp(0.0, 1.0);
          controller.animateTo(controller.position.maxScrollExtent*x_increament, duration: const Duration(milliseconds: 400), curve:Curves.linear);
        }
        _onStartDragged();
        _onEndDragged();
      }
    } else if (_dragType == EditorDragType.center) {
      _startCircleSize = widget.editorProperties.circleSizeOnDrag;
      _endCircleSize = widget.editorProperties.circleSizeOnDrag;
      if ((_startPos.dx + details.delta.dx >= 0) &&
          (_endPos.dx + details.delta.dx <= width)) {
        _startPos += details.delta;
        _endPos += details.delta;
        controller.animateTo(details.delta.dx, duration: const Duration(milliseconds: 400), curve:Curves.linear);
        _onStartDragged();
        _onEndDragged();
        if(width-(_endPos.dx + details.delta.dx) <= 1){
          x_increament=x_increament+0.015;
          x_increament = x_increament.clamp(0.0, 1.0);
          controller.animateTo(controller.position.maxScrollExtent*x_increament, duration: const Duration(milliseconds: 400), curve:Curves.linear);
        }else if(x_increament>0.0&&_startPos.dx<=1){
          x_increament=x_increament-0.015;
          x_increament = x_increament.clamp(0.0, 1.0);
          controller.animateTo(controller.position.maxScrollExtent*x_increament, duration: const Duration(milliseconds: 400), curve:Curves.linear);
        }
      }
    } else {
      _endCircleSize = widget.editorProperties.circleSizeOnDrag;
      if ((_endPos.dx + details.delta.dx <= width) &&
          (_endPos.dx + details.delta.dx >= _startPos.dx) &&
          !(_endPos.dx - _startPos.dx + details.delta.dx > endx)) {
        _endPos += details.delta;
        _onEndDragged();
      }else{
        _startPos += details.delta;
        _endPos += details.delta;
        if(width-(_endPos.dx + details.delta.dx) <= 1){
          x_increament=x_increament+0.015;
          x_increament = x_increament.clamp(0.0, 1.0);
          controller.animateTo(controller.position.maxScrollExtent*x_increament, duration: const Duration(milliseconds: 400), curve:Curves.linear);
        }else if(x_increament>0.0&&_startPos.dx<=1){
          x_increament=x_increament-0.015;
          x_increament = x_increament.clamp(0.0, 1.0);
          controller.animateTo(controller.position.maxScrollExtent*x_increament, duration: const Duration(milliseconds: 400), curve:Curves.linear);
        }
        _onStartDragged();
        _onEndDragged();
      }
    }
    controller.addListener((){
      scrollextent=controller.position.maxScrollExtent;
      currentpos=controller.position.pixels;
    });
    setState(() {});
  }

  void _onStartDragged() {
    _startFraction = (_startPos.dx+currentpos) / _thumbnailViewerW;
    _startFraction = _startFraction.clamp(0.0, 1.0);
    _videoStartPos = _videoDuration * _startFraction;
    _videoStartPos= _videoStartPos.clamp(0.0, _videoDuration.toDouble());
    widget.onChangeStart!(_videoStartPos);
    _linearTween.begin = _startPos.dx;
    _animationController!.duration =
        Duration(milliseconds: (_videoEndPos - _videoStartPos).toInt());
    _animationController!.reset();
  }

  void _onEndDragged() {
    _endFraction = (_endPos.dx+currentpos) / _thumbnailViewerW;
    _endFraction = _endFraction.clamp(0, 1.0);
    _videoEndPos = _videoDuration * _endFraction;
    _videoEndPos= _videoEndPos.clamp(0.0, _videoDuration.toDouble());
    widget.onChangeEnd!(_videoEndPos);
    _linearTween.end = _endPos.dx;
    _animationController!.duration =
        Duration(milliseconds: (_videoEndPos - _videoStartPos).toInt());
    _animationController!.reset();
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _startCircleSize = widget.editorProperties.circleSize;
      _endCircleSize = widget.editorProperties.circleSize;
      videoPlayerController.seekTo(Duration(milliseconds: _videoStartPos.toInt()));
    });
  }
  ScrollController controller=ScrollController();
  @override
  void dispose() {
    widget.onChangePlaybackState!(false);
    if (_videoFile != null) {
      widget.onChangePlaybackState!(false);
      _animationController?.dispose();
    }
    super.dispose();
  }
  Map<String,dynamic>data={};
  bool empty=true;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              widget.showDuration
                  ? SizedBox(
                width: _thumbnailViewerW,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0,left: 4,right: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        Duration(milliseconds: _videoStartPos.toInt()).format(widget.durationStyle),
                        style: widget.durationTextStyle,
                      ),
                      videoPlayerController.value.isPlaying
                          ? Text(
                        Duration(milliseconds: _currentPosition.toInt())
                            .format(widget.durationStyle),
                        style: widget.durationTextStyle,
                      )
                          : Container(),
                      Text(
                        Duration(milliseconds:_videoEndPos.toInt())
                            .format(widget.durationStyle),
                        style: widget.durationTextStyle,
                      ),
                    ],
                  ),
                ),
              )
                  : Container(),
              CustomPaint(
                foregroundPainter: TrimEditorPainter(
                  startPos: _startPos,
                  endPos: _endPos,
                  scrubberAnimationDx: _scrubberAnimation?.value ?? 0,
                  startCircleSize: _startCircleSize,
                  endCircleSize: _endCircleSize,
                  borderRadius: _borderRadius,
                ),
                child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(widget.areaProperties.borderRadius),
                  child: Padding(
                    padding:const EdgeInsets.symmetric(horizontal: 4),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        controller: controller,
                        child: Container(
                          key: _trimmerAreaKey,
                          color: Colors.grey[900],
                          height: _thumbnailViewerH,
                          width: _thumbnailViewerW == 0.0 ? widget.viewerWidth : _thumbnailViewerW,
                          child: thumbnailWidget ?? Container(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
            height: 79,
            child: AddAudio(trimmer: widget.trimmer,data:widget.data,
                addData:(Map<String,dynamic>d){
                  widget.addData(d);
                }))
      ],
    );
  }
}
enum EditorDragType {
  left,
  center,
  right
}


class FixedThumbnailViewer extends StatelessWidget {
  final File videoFile;
  final int videoDuration;
  final double thumbnailHeight;
  final BoxFit fit;
  final int numberOfThumbnails;
  final VoidCallback onThumbnailLoadingComplete;
  final int quality;
  const FixedThumbnailViewer({
    super.key,
    required this.videoFile,
    required this.videoDuration,
    required this.thumbnailHeight,
    required this.numberOfThumbnails,
    required this.fit,
    required this.onThumbnailLoadingComplete,
    this.quality = 75,
  });

  Stream<List<Uint8List?>> generateThumbnail() async* {
    final String videoPath = videoFile.path;
    double eachPart = videoDuration / numberOfThumbnails;
    List<Uint8List?> byteList = [];
    Uint8List? lastBytes;
    for (int i = 1; i <= numberOfThumbnails; i++) {
      Uint8List? bytes;
      try {
        bytes = await VideoThumbnail.thumbnailData(
          video: videoPath,
          imageFormat: ImageFormat.JPEG,
          timeMs: (eachPart * i).toInt(),
          quality: quality,
        );
      } catch (e) {
        debugPrint('ERROR: Couldn\'t generate thumbnails: $e');
      }
      if (bytes != null) {
        lastBytes = bytes;
      } else {
        bytes = lastBytes;
      }
      byteList.add(bytes);
      if (byteList.length == numberOfThumbnails) {
        onThumbnailLoadingComplete();
      }
      yield byteList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Uint8List?>>(
      stream: generateThumbnail(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Uint8List?> imageBytes = snapshot.data!;
          return Row(
            mainAxisSize: MainAxisSize.max,
            children: List.generate(
              numberOfThumbnails,
                  (index) => SizedBox(
                height: thumbnailHeight,
                width: thumbnailHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: 0.2,
                      child: Image.memory(
                        imageBytes[0] ?? kTransparentImage,
                        fit: fit,
                      ),
                    ),
                    index < imageBytes.length
                        ? FadeInImage(
                      placeholder: MemoryImage(kTransparentImage),
                      image: MemoryImage(imageBytes[index]!),
                      fit: fit,
                    )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Container(
            color: Colors.grey[900],
            height: thumbnailHeight,
            width: double.maxFinite,
          );
        }
      },
    );
  }
}

enum DurationStyle {
  FORMAT_HH_MM_SS,
  FORMAT_MM_SS,
  FORMAT_SS,
  FORMAT_HH_MM_SS_MS,
  FORMAT_MM_SS_MS,
  FORMAT_SS_MS,
}

extension DurationFormatExt on Duration {
  String format(DurationStyle style) {
    final formatPart = style.toString().split('.')[1].split('_');
    formatPart.removeAt(0);
    final millisecondTime = inMilliseconds;
    final hoursStr = _getDisplayTimeHours(millisecondTime);
    final mStr = _getDisplayTimeMinute(millisecondTime, hours: true);
    final sStr = _getDisplayTimeSecond(millisecondTime);
    final msStr = _getDisplayTimeMillisecond(millisecondTime);
    var result = '';
    final hours = formatPart.contains('HH');
    final minute = formatPart.contains('MM');
    final second = formatPart.contains('SS');
    final milliSecond = formatPart.contains('MS');
    if (hours) {
      result += hoursStr;
    }
    if (minute) {
      if (hours) {
        result += ':';
      }
      result += mStr;
    }
    if (second) {
      if (minute) {
        result += ':';
      }
      result += sStr;
    }
    if (milliSecond) {
      if (second) {
        result += '.';
      }
      result += msStr;
    }
    return result;
  }

  static String _getDisplayTimeHours(int mSec) {
    return _getRawHours(mSec).floor().toString().padLeft(2, '0');
  }

  static String _getDisplayTimeMinute(int mSec, {bool hours = false}) {
    if (hours) {
      return _getMinute(mSec).floor().toString().padLeft(2, '0');
    } else {
      return _getRawMinute(mSec).floor().toString().padLeft(2, '0');
    }
  }

  static String _getDisplayTimeSecond(int mSec) {
    final s = (mSec % 60000 / 1000).floor();
    return s.toString().padLeft(2, '0');
  }

  static String _getDisplayTimeMillisecond(int mSec) {
    final ms = (mSec % 1000 / 10).floor();
    return ms.toString().padLeft(2, '0');
  }

  static int _getRawHours(int milliSecond) =>
      (milliSecond / (3600 * 1000)).floor();

  static int _getMinute(int milliSecond) =>
      (milliSecond / (60 * 1000) % 60).floor();

  static int _getRawMinute(int milliSecond) => (milliSecond / 60000).floor();
}
class TrimEditorPainter extends CustomPainter {
  final Offset startPos;
  final Offset endPos;
  final double scrubberAnimationDx;
  final double borderRadius;
  final double startCircleSize;
  final double endCircleSize;
  final double borderWidth;
  final double scrubberWidth;
  final bool showScrubber;
  final Color borderPaintColor;
  final Color circlePaintColor;
  final Color scrubberPaintColor;
  final Icon leftIcon;
  final Icon rightIcon;

  TrimEditorPainter({
    required this.startPos,
    required this.endPos,
    required this.scrubberAnimationDx,
    this.startCircleSize = 0.5,
    this.endCircleSize = 0.5,
    this.borderRadius = 4,
    this.borderWidth = 3,
    this.scrubberWidth = 4,
    this.showScrubber = true,
    this.borderPaintColor = Colors.white70,
    this.circlePaintColor = Colors.white70,
    this.scrubberPaintColor = Colors.white70,
    this.leftIcon = const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
    this.rightIcon = const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 20),
  });

  @override
  void paint(Canvas canvas, Size size) {
    var borderPaint = Paint()
      ..color = borderPaintColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var circlePaint = Paint()
      ..color = circlePaintColor
      ..strokeWidth = 1
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    var scrubberPaint = Paint()
      ..color = scrubberPaintColor
      ..strokeWidth = scrubberWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromPoints(startPos, endPos);
    final roundedRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    if (showScrubber) {
      if (scrubberAnimationDx.toInt() > startPos.dx.toInt()) {
        canvas.drawLine(
          Offset(scrubberAnimationDx, 0),
          Offset(scrubberAnimationDx, 0) + Offset(0, endPos.dy),
          scrubberPaint,
        );
      }
    }
    canvas.drawRRect(roundedRect, borderPaint);
    canvas.drawCircle(
        startPos + Offset(0, endPos.dy / 2), startCircleSize, circlePaint);
    canvas.drawCircle(
        endPos + Offset(0, -endPos.dy / 2), endCircleSize, circlePaint);

    final leftIconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(leftIcon.icon!.codePoint),
        style: TextStyle(
          fontSize: startCircleSize * 2.5, // Adjust icon size
          color: leftIcon.color,
          fontFamily: leftIcon.icon!.fontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    final rightIconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(rightIcon.icon!.codePoint),
        style: TextStyle(
          fontSize: endCircleSize * 2.5, // Adjust icon size
          color: rightIcon.color,
          fontFamily: rightIcon.icon!.fontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    leftIconPainter.layout();
    rightIconPainter.layout();

    // Adjust the offset to reduce distance between the icon and the circle
    double iconOffset = 2.0; // Adjust this value as needed

    // Correct the offset for the right icon
    leftIconPainter.paint(
      canvas,
      startPos + Offset(-leftIcon.size! / 2 - iconOffset, endPos.dy / 2 - leftIcon.size! / 2),
    );
    rightIconPainter.paint(
      canvas,
      endPos + Offset(leftIcon.size! / 2 - iconOffset, -endPos.dy / 2 - rightIcon.size! / 2),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}


class TrimEditorPainter1 extends CustomPainter {
  final Offset startPos;
  final Offset endPos;
  final double scrubberAnimationDx;
  final double borderRadius;
  final double startCircleSize;
  final double endCircleSize;
  final double borderWidth;
  final double scrubberWidth;
  final bool showScrubber;
  final Color borderPaintColor;
  final Color circlePaintColor;
  final Color scrubberPaintColor;
  final Icon leftIcon;
  final Icon rightIcon;

  TrimEditorPainter1({
    required this.startPos,
    required this.endPos,
    required this.scrubberAnimationDx,
    this.startCircleSize = 0.5,
    this.endCircleSize = 0.5,
    this.borderRadius = 4,
    this.borderWidth = 3,
    this.scrubberWidth = 4, // Increased thickness
    this.showScrubber = true,
    this.borderPaintColor = Colors.black54,
    this.circlePaintColor = Colors.black54,
    this.scrubberPaintColor = Colors.black54,
    this.leftIcon = const Icon(Icons.arrow_back_ios, color: Colors.black,size:20),
    this.rightIcon = const Icon(Icons.arrow_forward_ios, color: Colors.black,size:20),
  });
  @override
  void paint(Canvas canvas, Size size) {
    var borderPaint = Paint()
      ..color = borderPaintColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var circlePaint = Paint()
      ..color = circlePaintColor
      ..strokeWidth = 1
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    var scrubberPaint = Paint()
      ..color = scrubberPaintColor
      ..strokeWidth = scrubberWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromPoints(startPos, endPos);
    final roundedRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    if (showScrubber) {
      if (scrubberAnimationDx.toInt() > startPos.dx.toInt()) {
        canvas.drawLine(
          Offset(scrubberAnimationDx, 0),
          Offset(scrubberAnimationDx, 0) + Offset(0, endPos.dy),
          scrubberPaint,
        );
      }
    }
    canvas.drawRRect(roundedRect, borderPaint);
    canvas.drawCircle(
        startPos + Offset(0, endPos.dy / 2), startCircleSize, circlePaint);
    canvas.drawCircle(
        endPos + Offset(0, -endPos.dy / 2), endCircleSize, circlePaint);

    final leftIconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(leftIcon.icon!.codePoint),
        style: TextStyle(
          fontSize: startCircleSize * 2.5, // Adjust icon size
          color: leftIcon.color,
          fontFamily: leftIcon.icon!.fontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    final rightIconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(rightIcon.icon!.codePoint),
        style: TextStyle(
          fontSize: endCircleSize * 2.5, // Adjust icon size
          color: rightIcon.color,
          fontFamily: rightIcon.icon!.fontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    leftIconPainter.layout();
    rightIconPainter.layout();

    // Adjust the offset to reduce distance between the icon and the circle
    double iconOffset = 2.0; // Adjust this value as needed

    // Correct the offset for the right icon
    leftIconPainter.paint(
      canvas,
      startPos + Offset(-leftIcon.size! / 2 - iconOffset, endPos.dy / 2 - leftIcon.size! / 2),
    );
    rightIconPainter.paint(
      canvas,
      endPos + Offset(leftIcon.size! / 2 - iconOffset, -endPos.dy / 2 - rightIcon.size! / 2),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}



class M extends StatefulWidget {
  const M({super.key});

  @override
  State<M> createState() => _MState();
}

class _MState extends State<M> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width,300),
      painter: RPSCustomPainter(),
    );
  }
}
class RPSCustomPainter extends CustomPainter{

  @override
  void paint(Canvas canvas, Size size) {



    // Layer 1

    Paint paint_fill_0 = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..style = PaintingStyle.fill
      ..strokeWidth = size.width*0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;
    paint_fill_0.shader = ui.Gradient.linear(Offset(size.width*0.21,size.height*0.70),Offset(size.width*0.70,size.height*0.70),[Color(0xffdd0b0b),Color(0xffffffff)],[0.00,1.00]);

    Path path_0 = Path();
    path_0.moveTo(size.width*0.2066667,size.height*0.7857143);
    path_0.cubicTo(size.width*0.2289000,size.height*0.5628286,size.width*0.2251917,size.height*0.6340286,size.width*0.2358167,size.height*0.5461714);
    path_0.cubicTo(size.width*0.3283250,size.height*0.4653714,size.width*0.6364583,size.height*0.4779571,size.width*0.6666667,size.height*0.6400000);
    path_0.cubicTo(size.width*0.6985167,size.height*0.8112000,size.width*0.2409083,size.height*0.9306000,size.width*0.2066667,size.height*0.7857143);
    path_0.close();

    canvas.drawPath(path_0, paint_fill_0);


    // Layer 1

    Paint paint_stroke_0 = Paint()
      ..color = const Color.fromARGB(255, 255, 51, 51)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width*0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;



    canvas.drawPath(path_0, paint_stroke_0);



    // Text Layer 1

    canvas.save();
    final pivot_2898119310097 = Offset(size.width*0.33,size.height*0.43);
    canvas.translate(pivot_2898119310097.dx,pivot_2898119310097.dy);
    canvas.rotate(0);
    canvas.translate(-pivot_2898119310097.dx,-pivot_2898119310097.dy);
    TextPainter tp_2898119310097 = TextPainter(
      text:  TextSpan(text: """FA""", style: TextStyle(
        fontSize: size.width*0.17,
        fontWeight: FontWeight.normal,
        color: Color(0xff000000),
        fontStyle: FontStyle.normal,
        decoration: TextDecoration.none,
      )),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    )..layout(maxWidth: size.width*0.19, minWidth: size.width*0.19);
    tp_2898119310097.paint(canvas,pivot_2898119310097);
    canvas.restore();


    // Layer 1

    Paint paint_fill_2 = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..style = PaintingStyle.fill
      ..strokeWidth = size.width*0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;


    Path path_2 = Path();
    path_2.moveTo(size.width*0.2341667,size.height*0.5457143);
    path_2.quadraticBezierTo(size.width*0.4775500,size.height*0.8130857,size.width*0.5585417,size.height*0.6759286);
    path_2.quadraticBezierTo(size.width*0.5262000,size.height*0.5715857,size.width*0.3268583,size.height*0.6398000);

    canvas.drawPath(path_2, paint_fill_2);


    // Layer 1

    Paint paint_stroke_2 = Paint()
      ..color = const Color.fromARGB(255, 255, 51, 51)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width*0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;



    canvas.drawPath(path_2, paint_stroke_2);


  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}


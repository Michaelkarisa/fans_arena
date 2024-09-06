import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:fans_arena/reusablewidgets/v.dart';
import 'package:fans_arena/reusablewidgets/video_trimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:fans_arena/clubs/screens/clubsphotopostpage.dart';
import 'package:fans_arena/clubs/screens/clubsvideopostpage.dart';
import 'package:fans_arena/joint/screens/poststory1.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:custom_image_crop/custom_image_crop.dart';



class TrimmerView extends StatefulWidget {
  bool isfanstv;
  bool isPosting;
  final List<String> imagePath;
  TrimmerView({super.key,required this.imagePath,required this.isfanstv,required this.isPosting});

  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  late PageController _pageController;
  List<Widget>widgets=[];
  List<String>urls=[];
  @override
  void initState() {
    super.initState();
    //loadData();
    _pageController = PageController(initialPage: currentindex);
    List<Widget>iWidgets=List.generate(widget.imagePath.length,(index){
      final url = widget.imagePath[index];
      bool isVideo = url.toLowerCase().endsWith('.mp4');
      if(isVideo){
        return EditorPanel(video: widget.imagePath[index], setvideo: (value){
          setState(() {
            imageP.add(value);
          });
        }, index: index);
      }else{
      return ImageCropper1(image: widget.imagePath[index],
        setimage: (MemoryImage image)async {
          final Uint8List pngBytes = image.bytes;
          final String dir = (await getApplicationDocumentsDirectory()).path;
          final String fullPath = '$dir/${DateTime.now().millisecond}.png';
          File capturedFile = File(fullPath);
          await capturedFile.writeAsBytes(pngBytes);
          setState(() {
            imageP.add(capturedFile.path);
          });
        },  index: currentindex,);
    }});
    setState(() {
      widgets=[...iWidgets];
    });
    getThumbnails();
  }
  final BaseCacheManager cacheManager = DefaultCacheManager();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //loadData();
    _pageController = PageController(initialPage: currentindex);
    List<Widget>iWidgets=List.generate(widget.imagePath.length,(index){
      final url = widget.imagePath[index];
      bool isVideo = url.toLowerCase().endsWith('.mp4');
      if(isVideo){
        return EditorPanel(video: widget.imagePath[index], setvideo: (value){
          setState(() {
            imageP.add(value);
          });
        }, index: index);
      }else{
        return ImageCropper1(image: widget.imagePath[index],
          setimage: (MemoryImage image)async {
            final Uint8List pngBytes = image.bytes;
            final String dir = (await getApplicationDocumentsDirectory()).path;
            final String fullPath = '$dir/${DateTime.now().millisecond}.png';
            File capturedFile = File(fullPath);
            await capturedFile.writeAsBytes(pngBytes);
            setState(() {
              imageP.add(capturedFile.path);
            });
          },  index: currentindex,);
      }});
    setState(() {
      widgets=[...iWidgets];
    });
    getThumbnails();
  }
  Future<void> getThumbnails() async {
    List<String>images= await generateThumbnail();
    setState(() {
      urls =[...images];
    });
  }
 Future<List<String>> generateThumbnail() async {
    List<String> images = [];
    for (var path in widget.imagePath) {
      bool isVideo = path.toLowerCase().endsWith('.mp4');
      if(isVideo){
      Uint8List? bytes;
      try {
        bytes = await VideoThumbnail.thumbnailData(
          video: path,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 240,
          maxWidth: 160,
          quality: 25,
          timeMs: 1500,
        );
        final Uint8List? pngBytes = bytes;
        final String dir = (await getApplicationDocumentsDirectory()).path;
        final String fullPath = '$dir/${DateTime
            .now()
            .millisecond}.png';
        File capturedFile = File(fullPath);
        await capturedFile.writeAsBytes(pngBytes!);
        images.add(capturedFile.path);

      } catch (e) {
        debugPrint('ERROR: Couldn\'t generate thumbnails: $e');
      }
      }else{
        images.add(path);
      }
      // if current thumbnail is null use the last thumbnail
    }
    return images;
  }



  void changepage(int index){
    _pageController.jumpToPage(index);
    //_pageController.animateToPage(page, duration: duration, curve: curve)
  }
  List<Widget> listWidgets=[];
  @override
  void dispose() {
    _pageController.dispose();
    imagePaths.clear();
    imageP.clear();
    super.dispose();
  }
  bool isvideo=true;
  String set='';
  String video='';
  String image='';
  Set<String>imageP={};
  List<String>imagePaths=[];
  int currentindex=0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Editor"),
          actions: [
            IconButton(onPressed: (){
              setState(() {
                imagePaths.addAll(imageP);
              });
              Navigator.push(context, MaterialPageRoute(builder: (context){
                if(widget.isfanstv){
                  return ClubsvideoPostpage(videoPath:imagePaths[0]??"ph");
                }else if(widget.isPosting){
                  return ClubPhotoPostPage(imagePath: imagePaths);
                }else{
                  return Poststory1(imagePath: imagePaths);
                }
              }));
            }, icon: const Icon(Icons.arrow_forward,color: Colors.black,))
          ],
        ),
        body:  Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.72,
              child:PageView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  onPageChanged:(index){
                    setState(() {
                      currentindex=index;
                    });
                  },
                  itemCount: widgets.length,
                  itemBuilder: (context,index){
                    if(widgets.isEmpty){
                      return Container();
                    }else {
                      return widgets[index];
                    }}),
            ),

            SizedBox(
              width: MediaQuery.of(context).size.width*0.99,
              child: SizedBox(
                height: 150,
                child:urls.isEmpty?Center(child: SizedBox(height:30,width: 30,child: CircularProgressIndicator())):ListView.builder(
                    shrinkWrap: true,
                    itemCount: urls.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      bool isVideo = urls[index].toLowerCase().endsWith('.mp4');
                      return w(urls[index],isVideo, index);
                    }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget w(String url,bool isVideo,int index){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: (){
          setState(() {
            set=url;
            currentindex=index;
          });
          changepage(index);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: Colors.black,
            height: 150,
            width: 150,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            width: 4,
                            color:index==currentindex?Colors.blue:Colors.white38
                        )
                    ),
                    height: 150,
                    width: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child:Image.file(
                        File(url),
                        fit: BoxFit.fill,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 6),
                    child: SizedBox(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              height: 40,
                              width: 40,
                              child: Icon(isVideo?Icons.video_file:Icons.image,color: Colors.white,)
                          ),
                          InkWell(
                            onTap: (){
                              setState(() {
                                urls.remove(url);
                                widgets.remove(widgets[index]);
                              });
                            },
                            child: const SizedBox(
                                height: 40,
                                width: 40,
                                child: Icon(Icons.close,color: Colors.white,)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class ImageCropper1 extends StatefulWidget {
  String image;
  int index;
  void Function(MemoryImage image) setimage;
  ImageCropper1({
    Key? key,required this.image,
    required this.setimage,
    required this.index,
  }) : super(key: key);

  @override
  _ImageCropper1State createState() => _ImageCropper1State();
}

class _ImageCropper1State extends State<ImageCropper1> {
  CustomImageCropController controller=CustomImageCropController();
  CustomCropShape _currentShape = CustomCropShape.Square;
  CustomImageFit _imageFit = CustomImageFit.fillCropSpace;
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();

  double _width = 16;
  double _height = 9;
  double _radius = 4;

  @override
  void initState() {
    super.initState();
    controller.reset;
  }

  @override
  void dispose() {
    controller.dispose();
    controller.reset;
    super.dispose();
  }

  void _changeCropShape(CustomCropShape newShape) {
    setState(() {
      _currentShape = newShape;
    });
  }
  void _changeImageFit(CustomImageFit imageFit) {
    setState(() {
      _imageFit = imageFit;
    });
  }

  void _updateRatio() {
    setState(() {
      if (_widthController.text.isNotEmpty) {
        _width = double.tryParse(_widthController.text) ?? 16;
      }
      if (_heightController.text.isNotEmpty) {
        _height = double.tryParse(_heightController.text) ?? 9;
      }
      if (_radiusController.text.isNotEmpty) {
        _radius = double.tryParse(_radiusController.text) ?? 4;
      }
    });
    FocusScope.of(context).unfocus();
  }
  void showToastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
    );
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        padding: const EdgeInsets.only(bottom: 2.0),
        child: Builder(
            builder: (context) {
              return Column(
                children: [
                  Expanded(
                    child: CustomImageCrop(
                      cropController: controller,
                      // image: const AssetImage('assets/test.png'),
                      image:  FileImage(File(widget.image)),
                      shape: _currentShape,
                      ratio: _currentShape == CustomCropShape.Ratio
                          ? Ratio(width: _width, height: _height)
                          : null,
                      canRotate: true,
                      canMove: true,
                      canScale: true,
                      borderRadius:
                      _currentShape == CustomCropShape.Ratio ? _radius : 0,
                      customProgressIndicator: const CupertinoActivityIndicator(),
                      imageFit: _imageFit,
                      pathPaint: Paint()
                        ..color = Colors.red
                        ..strokeWidth = 4.0
                        ..style = PaintingStyle.stroke
                        ..strokeJoin = StrokeJoin.round,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.refresh), onPressed: controller.reset),
                      IconButton(
                          icon: const Icon(Icons.zoom_in),
                          onPressed: () =>
                              controller.addTransition(CropImageData(scale: 1.33))),
                      IconButton(
                          icon: const Icon(Icons.zoom_out),
                          onPressed: () =>
                              controller.addTransition(CropImageData(scale: 0.75))),
                      IconButton(
                          icon: const Icon(Icons.rotate_left),
                          onPressed: () =>
                              controller.addTransition(CropImageData(angle: -pi / 4))),
                      IconButton(
                          icon: const Icon(Icons.rotate_right),
                          onPressed: () =>
                              controller.addTransition(CropImageData(angle: pi / 4))),
                      PopupMenuButton(
                        icon: const Icon(Icons.crop_original),
                        onSelected: _changeCropShape,
                        itemBuilder: (BuildContext context) {
                          return CustomCropShape.values.map(
                                (shape) {
                              return PopupMenuItem(
                                value: shape,
                                child: getShapeIcon(shape),
                              );
                            },
                          ).toList();
                        },
                      ),
                      PopupMenuButton(
                        icon: const Icon(Icons.fit_screen),
                        onSelected: _changeImageFit,
                        itemBuilder: (BuildContext context) {
                          return CustomImageFit.values.map(
                                (imageFit) {
                              return PopupMenuItem(
                                value: imageFit,
                                child: Text(imageFit.label),
                              );
                            },
                          ).toList();
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.save,
                          color: Colors.green,
                        ),
                        onPressed: () async {
                          final image = await controller.onCropImage();
                          if (image != null) {
                            widget.setimage(image);
                            showToastMessage('Image Saved successfully');
                          }
                        },
                      ),
                    ],
                  ),
                  if (_currentShape == CustomCropShape.Ratio) ...[
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _widthController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Width'),
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _heightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Height'),
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _radiusController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Radius'),
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          ElevatedButton(
                            onPressed: _updateRatio,
                            child: const Text('Update Ratio'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            }
        ),
      ),
    );
  }

  Widget getShapeIcon(CustomCropShape shape) {
    switch (shape) {
      case CustomCropShape.Square:
        return const Icon(Icons.square_outlined);
      case CustomCropShape.Circle:
        return const Icon(Icons.circle_outlined);
      case CustomCropShape.Ratio:
        return const Icon(Icons.crop_16_9_outlined);
    }
  }
}

extension CustomImageFitExtension on CustomImageFit {
  String get label {
    switch (this) {
      case CustomImageFit.fillCropSpace:
        return 'Fill crop space';
      case CustomImageFit.fitCropSpace:
        return 'Fit crop space';
      case CustomImageFit.fillCropHeight:
        return 'Fill crop height';
      case CustomImageFit.fillCropWidth:
        return 'Fill crop width';
      case CustomImageFit.fillVisibleSpace:
        return 'Fill visible space';
      case CustomImageFit.fitVisibleSpace:
        return 'Fit visible space';
      case CustomImageFit.fillVisibleHeight:
        return 'Fill visible height';
      case CustomImageFit.fillVisibleWidth:
        return 'Fill visible width';
    }
  }
}

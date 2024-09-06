import 'package:flutter/material.dart';



class UsernameDO extends StatefulWidget {
  String username;
  String collectionName;
  TextStyle? style;
  double maxSize;
  double width;
  double height;
  bool aligncenter;
  UsernameDO({super.key,
    required this.username,
    required this.collectionName,
    required this.maxSize,
    required this.width,
    required this.height,
    this.aligncenter=false,
    this.style});

  @override
  _UsernameDOState createState() => _UsernameDOState();
}

class _UsernameDOState extends State<UsernameDO> {
  String cname(){
    if(widget.collectionName=="Professional"){
      return 'P';
  }else if(widget.collectionName=="Club"){
      return 'C';
    }else {
      return '';
    }
}

  @override
  Widget build(BuildContext context) {
    String c=cname();
    return Padding(
      padding: const EdgeInsets
          .only(left: 5),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Row(
          mainAxisAlignment:widget.aligncenter?MainAxisAlignment.center :MainAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                constraints:  BoxConstraints(
                  minWidth: 10.0,
                  maxWidth: widget.maxSize,
                ),
                child: Text(
                  widget.username,
                  style: widget.style ?? const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
            // Adjust the spacing between the OverflowBox and Aligned container
           c.isNotEmpty?Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child:  Container(
                  width:20 ,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:  Center(child: Text(c,style: const TextStyle(color: Colors.white),)),),
              ),
            ):const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
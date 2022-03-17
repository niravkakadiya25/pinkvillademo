import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final Future<bool> Function(bool) onClicked;

  final bool? isFav;
  final bool? isComment;
  final bool? isShare;

  CustomButton(
      {Key? key,
      required this.onClicked,
      this.isFav = false,
      this.isComment = false,
      this.isShare = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CustomButtonState();
  }
}

class _CustomButtonState extends State<CustomButton>
    with TickerProviderStateMixin {
  final bool _isClicked = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        value: _isClicked ? 1.0 : 0.0,
        duration: Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        var s = widget.onClicked(_isClicked);
        if (s == null) return;
        if (_isClicked) {
          _controller.animateTo(1.0, duration: Duration(milliseconds: 300));
        } else {
          _controller.animateBack(0, duration: Duration(milliseconds: 300));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          (widget.isFav ?? false)
              ? Icons.favorite_border
              : (widget.isComment ?? false)
                  ? Icons.comment
                  : Icons.share_outlined,
          color: Colors.grey,
          size: 20,
        ),
        width: 40,
        height: 40,
      ),
    );
  }
}

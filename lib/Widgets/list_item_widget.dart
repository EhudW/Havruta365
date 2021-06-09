import 'package:flutter/material.dart';

class ListItemWidget extends StatelessWidget {
  final String item;
  final Animation<double> animation;
  final VoidCallback onClicked;

  const ListItemWidget({
    this.item,
    this.animation,
    this.onClicked,
    Key key,
  }) : super(key: key);

  /*
    SlideTransition(
    position: Tween<Offset>(
      begin: Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn)),
    child:
    */

  @override
  Widget build(BuildContext context) => SizeTransition(
        // key: ValueKey(item.urlImage),
        sizeFactor: animation,
        child: buildItem(),
      );

  Widget buildItem() => Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: const Icon(
            Icons.perm_contact_cal,
            color: Colors.green,
          ),
          title: Text(
            item,
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red, size: 32),
            onPressed: onClicked,
          ),
        ),
      );
}

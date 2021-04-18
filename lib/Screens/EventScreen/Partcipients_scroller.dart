import 'package:flutter/material.dart';
import 'package:havruta_project/DataBase_auth/User.dart';

class ParticipentsScroller extends StatelessWidget {
  ParticipentsScroller(this.users);
  final List<User> users;

  Widget _buildActor(BuildContext ctx, int index) {
    var participent = users[index];

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(participent.avatar),
            radius: 40.0,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(participent.name),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              'משתתפים',
              style: textTheme.subhead.copyWith(fontSize: 18.0),
            ),
          ),
        ),
        SizedBox.fromSize(
          size: const Size.fromHeight(120.0),
          child: ListView.builder(
            itemCount: users.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(top: 12.0, left: 20.0),
            itemBuilder: _buildActor,
          ),
        ),
      ],
    );
  }
}

# Havruta+

<img src="https://github.com/fe1493/Havruta365/blob/master/images/AppIcon2.png?raw=true" width="300" height="300">

## Vision
The vision of Havruta+ is to connect people that wish to study Tora.
In Havruta users can post their lessons and manage them, in addition people can find themselves partners for studying together.
This platform overcomes the geographical distance between people.


## Structure
The directories structure is focused on the main parts/features of the app:
- [Authentication](lib/auth) - this folder manage the authentication processes including signup, signin and recover password (currently the app only use google authentication, but email auth can be available).
- [Chats](lib/chat) - this folder manage the chat ui and model.
- [Database](lib/data_base/) - this folder contains [data representations](lib/data_base/data_representations/) for all the entities that the database contain, a wrapper for the mongo agents (that make the connection stable) and an 'API's that handle the communication with the database so that the rest of the app could use it easily.
- [Events](lib/event/) - this folder contain the logic and ui related to the events (lessons and havrutas): the recommendation system, the feed, event page, details page..
- [Notifications](lib/notifications/) - contains 2 kinds of 'notifications'- [the first](lib/notifications//notifications/) handle the UI and logic of the notifications seen on the 'bell' in the home page, [the second](/lib/notifications//push_notifications/) send messsages to the server whenever it should be notify about something. Another explanation can be found in the notification's readme.
- [Users](lib/users/) - handles the users entities inside the application (mostly UI).
- The [homepage](lib/home_page.dart) is the first screen a connected user will see and The [login screen](lib/auth/screens/login_screen.dart) is the first screen an unlogged user will see.




## Future developers
Notice you have a deeper explaination in the drive.

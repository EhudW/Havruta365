# Notifications Terminology
* Mongodb has 5 collection:
- Chats
- Events
- Notification
- Topics
- Users
* Android support push notification: notification that pop from top bar
* [flutter_local_notification](https://pub.dev/packages/flutter_local_notifications): package that trigger anroid/ios push notification
* fcm/gcm: service that send data to phone 
   and let your app handle it even when the app is terminated

# Flow:
  1.  something changed/related in (a.):
	MyServer run[every 2 hours] ['Event' collection] 
 	OR user accept user to havruta ['Notifications' collection]
 	OR user send msg ['Chats' collections]
2. in my phone http.get(to MyServer)
3. MyServer -> firebase
4. firebase [fcm(d.)]-> android[my/friend phone]
5. android background(d.) -> [invoke flutter_local_notification(c.)]
6. -> push notification(b.) with text about collection(that caused 1.) 
	Events/Notifications/Chats 

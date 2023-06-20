# Notifications Terminology
* Mongodb has 5 collection:
	- Notification
	- Chats
	- Events
	- Topics
	- Users
* Android support push notification: notification that pop from top bar
* [flutter_local_notification](https://pub.dev/packages/flutter_local_notifications): package that trigger anroid/ios push notification
* fcm/gcm: service that send data to phone 
   and let your app handle it even when the app is terminated

# Flow:
1.  An event related to the database occur:
	- MyServer detect that a reminder about havruta or lesson should be sent [check every 2 hours] ['Event' collection].
 	- User accept another user to his havruta ['Notifications' collection].
 	- User sent msg ['Chats' collections].
2. If the origin of the event was from a user action then his local app activate http.get (to MyServer).
3. MyServer direct the request to firebase.
4. Firebase, using fcm(d.), notify the targeted users local android.
5. Targeted users local android receive the notification with an handler (android background(d.) process) [invoke flutter_local_notification(c.)]
6. The handler pop a push notification to the general android UI with relevant information.

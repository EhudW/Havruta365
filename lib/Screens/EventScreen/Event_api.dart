import 'package:havruta_project/DataBase_auth/Event.dart';
import 'package:havruta_project/DataBase_auth/User.dart';


final Event testEvent = Event(
    eventImage: 'https://moreshet-maran.com/wp-content/uploads/2020/04/%D7%94%D7%93%D7%A3-%D7%94%D7%99%D7%95%D7%9E%D7%99.jpg',
    creatorUser: creatorUser,
    type: 'lesson',
    topic: 'הדף היומי',
    book: 'תלמוד בבלי',
    lecturer: 'הרב אליהו אורנשטיין',
    starRating: 4,
    date: '18.04.21',
    frequency: 'יומי',
    participants: participants,
    link: 'https://www.dirshu.co.il/31469-2/',
    description: 'דרשו מגיש:\nשיעורי הדף היומי בגמרא בצורה פשוטה ובהירה,\nמפי הרב אליהו אורנשטיין שליט"א'
);

User creatorUser = User.fromUser('Creator', '4yonatan4@gmail.com', 'male');

User user1 = User.fromUser('יניב', '4yonatan4@gmail.com', 'male');
User user2 = User.fromUser('אפרים', '4yonatan4@gmail.com', 'male');
User user3 = User.fromUser('אסי', '4yonatan4@gmail.com', 'male');
User user4 = User.fromUser('יונתן', '4yonatan4@gmail.com', 'male');
User user5 = User.fromUser('מיכל', '4yonatan4@gmail.com', 'female');
User user6 = User.fromUser('שמואל', '4yonatan4@gmail.com', 'male');
User user7 = User.fromUser('יוסי', '4yonatan4@gmail.com', 'male');
User user8 = User.fromUser('גל', '4yonatan4@gmail.com', 'female');

List<User> participants = [user1, user5, user2, user3, user4, user6,
  user7, user8];



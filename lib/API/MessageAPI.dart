import 'package:timepass/API/BasicAPI.dart';
import 'package:timepass/main.dart';
import 'package:http/http.dart' as http;

class MessageAPI {
  getMessages(String roomid) async {
    try {
      var url = Uri.parse('$weburl/conversations/$roomid');
      var response;
      if (xAccessToken != null) {
        response = await http.get(
          url,
          headers: {
            'x-access-token': xAccessToken!,
          },
        );
        if (response.statusCode == 200) {
          return response.body;
        } else {
          throw Exception("Oops! Something went wrong");
        }
      } else {
        throw Exception("Oops! Something went wrong");
      }
    } catch (e) {
      throw Exception("Oops! Something went wrong");
    }
  }

  getMessagesupdate(String roomid) async {
    try {
      var url = Uri.parse('$weburl/conversations/message/$roomid');
      var response;
      if (xAccessToken != null) {
        response = await http.patch(
          url,
          body: {
            "sender": userid,
            "message": "How are you?",
          },
          headers: {
            'x-access-token': xAccessToken!,
          },
        );

        if (response.statusCode == 200) {
          return response.body;
        } else {
          throw Exception("Oops! Something went wrong");
        }
      } else {
        throw Exception("Oops! Something went wrong");
      }
    } catch (e) {
      throw Exception("Oops! Something went wrong");
    }
  }
}

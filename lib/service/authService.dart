import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/core/config/serviceLocator.dart';
import 'package:todoapp/model/authModel.dart';
import 'package:todoapp/model/errorHandling.dart';
import 'package:todoapp/service/coreService.dart';

abstract class AuthService extends CoreSerivce {
  String baseurl = 'https://dummyjson.com/auth/login';

  Future<ResultModel> logIn(UserModel user);
}

class AuthServiceImp extends AuthService {
  @override
  Future<ResultModel> logIn(UserModel user) async {
    try {
      response = await dio.post(baseurl, data: user.toMap());


      String? accessToken = response.data['accessToken'];
      String? refreshToken = response.data['refreshToken'];

      if (response.statusCode == 200 &&
          accessToken != null &&
          refreshToken != null) {

        core.get<SharedPreferences>().setString("token", accessToken);
        core.get<SharedPreferences>().setString("refreshToken", refreshToken);
        return DataSuccess();
      } else {
        return DataError();
      }
    } catch (e) {
      return DataError();
    }
  }
}

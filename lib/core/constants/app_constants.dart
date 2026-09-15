class ApiConstants {
  // Android emulator only: 10.0.2.2 maps to your host machine's localhost.
  // Swap this for your Railway URL once deployed, or your PC's local IP
  // for physical device testing.
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Auth
  static const String register = 'auth/register';
  static const String verify = 'auth/verify';
  static const String login = 'auth/login';
  static const String logout = 'profile/logout';
  static const String me = 'profile';
  static const String firebaseLogin = 'auth/firebase/verify';
  static const String firebaseRegister = 'auth/register';
}
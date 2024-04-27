// Package imports:

class EndpointManager {
  static final EndpointManager _instance = EndpointManager._internal();

  //Factory ConstConstructor, use the factory keyword when you need the ConstConstructor to not create a new object each time.
  factory EndpointManager() => _instance;

  //Internal ConstConstructor
  EndpointManager._internal();
  //! Endpoint Manager base url for the API
  static String baseUrl = "";

  init() async {
    //
  }

  //! Authentication
  static String register = '$baseUrl/register';
  static String verifyEmailOtp = '$baseUrl/register/email-confirm';
  static String resendOtp = '$baseUrl/register/resend-email-verification';
  static String setPassword = '$baseUrl/register/password';
  static String login = '$baseUrl/login';
  static String logOut = '$baseUrl/logout';
  static String forgotPassword = '$baseUrl/forgot-password';
  static String verifyToken = '$baseUrl/verify-token';
  static String resetPassword = '$baseUrl/users/forgot-password';
  static String sendMultipleJobs =
      '$baseUrl/opportunities/save_multiple_job_interests';
  static String popularJobs = '$baseUrl/opportunities/popular';
  static String googleLogin = '$baseUrl/social_login';
  static String googleRegister = '$baseUrl/social_register';

  //! Profile
  static String updateProfile = '$baseUrl/account/update_profile';
  static String userDetails = '$baseUrl/account/profile';
  static String checkUsername = '$baseUrl/account/check-username';
  static String changeUsername = '$baseUrl/account/change-username';
  static String updatePassword = '$baseUrl/account/change-password';
  static String updateEmail = '$baseUrl/account/change-email';
  static String deleteAccount = '$baseUrl/account/delete-account';
  static String verifyNewEmail = '$baseUrl/account/verify-new-email';
  static String logout = '$baseUrl/logout';
  static String feedback = '$baseUrl/account/feedback';

  //! Notifications
  static String fetchNotifications = '$baseUrl/notification/fetch';
  static String getNotificationCount = '$baseUrl/notification/fetch_count';
  static String markAsRead = '$baseUrl/notification/mark_read';
  static String fetchPreferences = '$baseUrl/notification/preferences';
  static String emailPreferences = '$baseUrl/notification/push_preference';
  static String pushPreferences = '$baseUrl/notification/email_preference';

  //! Education
  static String addEducation = '$baseUrl/account/add_education';
  static String updateEducation = '$baseUrl/account/edit_education';
  static String deleteEducation = '$baseUrl/account/delete_education';
  static String getEducation = '$baseUrl/account/list_education';

  //! Experience
  static String addExperience = '$baseUrl/account/add_experience';
  static String editExperience = '$baseUrl/account/edit_experience';
  static String deleteExperience = '$baseUrl/account/delete_experience';
  static String getAllExperience = '$baseUrl/account/list_experience';

  //!Skills
  static String addCoreSkills = '$baseUrl/account/skills/core';
  static String addSoftSkills = '$baseUrl/account/skills/soft';
  static String addSkills = '$baseUrl/account/add_skill';
  static String deleteSkills = '$baseUrl/account/delete_skill';

  //! Documents
  static String allDocuments = '$baseUrl/account/documents';
  static String uploadDocuments = '$baseUrl/account/upload';
  static String uploadMultipleDocuments =
      '$baseUrl/account/documents/upload-multiple';
  static String deleteDocuments = '$baseUrl/account/documents/delete';
}

class EndPointConstant {
  static final EndPointConstant _instance = EndPointConstant._internal();

  //Factory Constructor, use the factory keyword when you need the Constructor to not create a new object each time.
  factory EndPointConstant() => _instance;

  //Internal Constructor
  EndPointConstant._internal();

  late String loginUrl, singUpUrl, returnAwbUrl, returnProcurementUrl;

  late Map<String, dynamic> defaultHeader;

  init() async {
    // _collectionOfApi(baseUrl: dotenv.env['BASE_URL']!);
    // defaultHeader = _defaultHeader(token: dotenv.env['HEADER_API_KEY']);
  }

  void _collectionOfApi({required String baseUrl}) {
    //SIGN UP API
    loginUrl = '${baseUrl}login';
    singUpUrl = '${baseUrl}signUp';
    returnAwbUrl = '${baseUrl}return';
    returnProcurementUrl = '${baseUrl}returnProcurement';
  }

  Map<String, dynamic> _defaultHeader({String? token}) =>
      {'AUTH_KEY': token, 'Content-Type': 'application/json'};
}

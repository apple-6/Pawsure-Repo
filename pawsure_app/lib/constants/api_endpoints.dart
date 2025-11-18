class ApiEndpoints {
  static const String baseUrl = 'http://localhost:3000';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';

  // Pet Endpoints
  static const String pets = '/pets';
  static String petById(String id) => '/pets/$id';
  static const String addPet = '/pets';
  static String updatePet(String id) => '/pets/$id';
  static String deletePet(String id) => '/pets/$id';

  // Health Endpoints
  static const String healthRecords = '/health-records';
  static String healthRecordsByPet(String petId) =>
      '/health-records/pet/$petId';
  static const String addHealthRecord = '/health-records';
  static String updateHealthRecord(String id) => '/health-records/$id';
  static String deleteHealthRecord(String id) => '/health-records/$id';

  // Activity Endpoints
  static const String activities = '/activities';
  static String activitiesByPet(String petId) => '/activities/pet/$petId';
  static const String addActivity = '/activities';

  // Community Endpoints
  static const String posts = '/posts';
  static String postById(String id) => '/posts/$id';
  static const String addPost = '/posts';
  static String updatePost(String id) => '/posts/$id';
  static String deletePost(String id) => '/posts/$id';
  static String getComments(String postId) => '/posts/$postId/comments';
  static const String addComment = '/comments';

  // User Endpoints
  static const String userProfile = '/users/profile';
  static String updateUserProfile(String userId) => '/users/$userId';
}

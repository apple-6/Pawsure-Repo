import 'package:get/get.dart';
import 'package:pawsure_app/services/api_service.dart';

class CommunityController extends GetxController {
  final ApiService _apiService = ApiService();

  var posts = <dynamic>[].obs;
  var isLoading = false.obs;
  var activeTab = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  /// Fetch posts from the API
  Future<void> fetchPosts({String tab = 'all'}) async {
    try {
      isLoading.value = true;
      activeTab.value = tab;

      final fetchedPosts = await _apiService.getPosts(tab: tab);
      posts.assignAll(fetchedPosts);
    } catch (e) {
      print('❌ Error fetching posts: $e');
      Get.snackbar('Error', 'Failed to load posts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a new post
  Future<void> createPost({
    required String content,
    required bool isUrgent,
    String? locationName,
    List<String>? mediaPaths,
  }) async {
    try {
      isLoading.value = true;

      await _apiService.createPost(
        content: content,
        isUrgent: isUrgent,
        locationName: locationName,
        mediaPaths: mediaPaths,
      );

      Get.snackbar('Success', 'Post created successfully!');

      // Refresh posts list
      await fetchPosts(tab: activeTab.value);
    } catch (e) {
      print('❌ Error creating post: $e');
      Get.snackbar('Error', 'Failed to create post: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

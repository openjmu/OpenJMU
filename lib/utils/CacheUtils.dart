import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheUtils {
  static Future remove(String url) async {
    return await DefaultCacheManager().removeFile(url);
  }
  static Future clear() async {
    return await DefaultCacheManager().emptyCache();
  }
}
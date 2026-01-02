class IpAddress {
  // 본인이 사용하는 HostIP 
  static const String host = '172.16.250.193';
  
  // FastAPI 사용할때 $baseURL로 바꿔서 사용하면 됩니다
  static const String baseUrl = 'http://$host:8008';
}
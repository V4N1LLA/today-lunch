Map<String, String> createHealthPayload({required String version}) {
  return <String, String>{
    'status': 'ok',
    'version': version,
  };
}

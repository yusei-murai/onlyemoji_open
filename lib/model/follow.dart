class Follow {
  String id;
  String fromUserId; //フォローしてるID
  String toUserId; //フォローされてるID
  DateTime? createdTime;

  Follow({required this.id,required this.fromUserId,required this.toUserId,this.createdTime});
}
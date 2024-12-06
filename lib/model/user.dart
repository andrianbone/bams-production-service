class User {
  String? userid;
  String? username;
  String? usermail;
  String? orgid;
  String? orgname;
  String? orgcode;
  String? package;

  User(
      {this.userid,
      this.username,
      this.usermail,
      this.orgid,
      this.orgname,
      this.orgcode,
      this.package});

  User.fromJson(Map<String, dynamic> json) {
    userid = json['userid'];
    username = json['username'];
    usermail = json['usermail'];
    orgid = json['orgid'];
    orgname = json['orgname'];
    orgcode = json['orgcode'];
    package = json['package'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userid'] = userid;
    data['username'] = username;
    data['usermail'] = usermail;
    data['orgid'] = orgid;
    data['orgname'] = orgname;
    data['orgcode'] = orgcode;
    data['package'] = package;
    return data;
  }
}

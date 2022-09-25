class DBInfo {
  int id;
  String title;
  int checked;
  String url1;
  String url2;
  String url3;
  String urlp;
  int notification;

  DBInfo(
      {this.id,
      this.title,
      this.checked,
      this.url1,
      this.url2,
      this.url3,
      this.urlp,
      this.notification});

  factory DBInfo.fromMap(Map<String, dynamic> json) => DBInfo(
        id: json["id"],
        title: json["title"],
        checked: json["checked"],
        url1: json["url1"],
        url2: json["url2"],
        url3: json["url3"],
        urlp: json["urlp"],
        notification: json['notification'],
      );
  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "checked": checked,
        "url1": url1,
        "url2": url2,
        "url3": url3,
        "urlp": urlp,
        "notification": notification,
      };
}

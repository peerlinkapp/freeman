import 'dart:convert';

import 'package:freeman/model/v2_tim_elem.dart';

import '../common/utils.dart';


class V2TimImage{

  int _width = 0;
  int _height = 0;
  String? _url;

  int get width => _width;
  int get height => _height;
  String? get url=>_url;

  void setUrl(String? url)
  {
    _url = url;
  }

}

/// V2TimTextElem
///
/// {@category Models}
class V2TimImageElem extends V2TIMElem {
  List<V2TimImage>? imageList;


  V2TimImageElem({
    this.imageList,
  });

  V2TimImageElem.fromJson(Map json) {
    json = Utils.formatJson(json);

    if (json['nextElem'] != null) {
      nextElem = Utils.formatJson(json['nextElem']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (nextElem != null) {
      data['nextElem'] = nextElem;
    }
    return data;
  }

  formatJson(jsonSrc) {
    return json.decode(json.encode(jsonSrc));
  }
  String toLogString() {
    String res = "";
    return res;
  }
}

// {
//   "text":""
// }

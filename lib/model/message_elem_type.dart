/// 消息类型
///
/// {@category Enums}
///
// ignore_for_file: constant_identifier_names

enum MessageElemType {
  ///没有元素
  ///
  V2TIM_ELEM_TYPE_NONE,

  ///文本消息
  ///
  V2TIM_ELEM_TYPE_TEXT,

  ///自定义消息
  ///
  V2TIM_ELEM_TYPE_CUSTOM,

  ///图片消息
  ///
  V2TIM_ELEM_TYPE_IMAGE,

  ///语音消息
  ///
  V2TIM_ELEM_TYPE_VOICE,

  ///视频消息
  ///
  V2TIM_ELEM_TYPE_VIDEO,

  ///文件消息
  ///
  V2TIM_ELEM_TYPE_FILE,

  ///地理位置消息
  ///
  V2TIM_ELEM_TYPE_LOCATION,

  ///表情消息
  ///
  V2TIM_ELEM_TYPE_FACE,

  ///群 Tips 消息（存消息列表）
  ///
  V2TIM_ELEM_TYPE_GROUP_TIPS,

  // 合并消息
  V2TIM_ELEM_TYPE_MERGER,

  //
  V2TIM_ELEM_TYPE_P2P

}

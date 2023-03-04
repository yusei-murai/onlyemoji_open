import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';

const String emptyStr = "入力してください";
const String notEmojiStr = "絵文字のみが使用可能です";
const String notEmojiOver20Str = "20文字まで、絵文字のみが使用可能です";
const String notEmojiOver200Str = "200文字までです";
const String invalidEmailStr = "Emailアドレスを入力してください";
const String invalidPassStr = "パスワードは8文字以上、半角英数を含むようにしてください";

class InputValidator{
  static String? emptyValidator(value){
    if(value == null || value.isEmpty) {
      return emptyStr;
    }
    return null;
  }

  static String? emojiValidator(value){
    final notEmojiReg = RegExp(r'[^\u{2000}-\u{200a}\u{00a0}\u{3000}\u{00a0}\u{0020}\u{0085}\u{000c}\u{000b}\u{000a}\u{000d}\u{200d}\u{2b50}\u{2700}-\u{27bf}\u{203c}\u{2049}\u{2139}\u{2194}-\u{21AA}\u{1F000}-\u{1FFFF}\u{FE0F}\u{2328}\u{200D}\u{E0062}-\u{E007F}\u{2600}-\u{26FF}]+', unicode: true);
    var str = Characters(value);

    if(value == null || value!.trim().isEmpty) {
      return emptyStr;
    }
    if(notEmojiReg.hasMatch(value)){
      return notEmojiStr;
    }
    if(str.length > 200){
      return notEmojiOver200Str;
    }
    return null;
  }

  static String? nameValidator(value){
    final emojiReg = RegExp(r'[^\u{200d}\u{2b50}\u{2700}-\u{27bf}\u{203c}\u{2049}\u{2139}\u{2194}-\u{21AA}\u{1F000}-\u{1FFFF}\u{FE0F}\u{2328}\u{200D}\u{E0062}-\u{E007F}\u{2600}-\u{26FF}]+', unicode: true);
    var str = Characters(value);

    if(value == null || value.isEmpty) {
      return emptyStr;
    }
    if(emojiReg.hasMatch(value) || str.length > 20){
      return notEmojiOver20Str;
    }
    return null;
  }

  static String? replyValidator(value){
    final emojiReg = RegExp(r'[^\u{200d}\u{2b50}\u{2700}-\u{27bf}\u{203c}\u{2049}\u{2139}\u{2194}-\u{21AA}\u{1F000}-\u{1FFFF}\u{FE0F}\u{2328}\u{200D}\u{E0062}-\u{E007F}\u{2600}-\u{26FF}]+', unicode: true);
    var str = Characters(value);

    if(emojiReg.hasMatch(value) || str.length > 20){
      return notEmojiOver20Str;
    }
    return null;
  }


  static String? emailValidator(value){
    if ((value == null) || !EmailValidator.validate(value)) {
      return invalidEmailStr;
    }
    return null;
  }

  static String? passValidator(value){
    RegExp passRegex = RegExp(r'^(?=.*[0-9])(?=.*[a-zA-Z])([a-zA-Z0-9]+)$');
    if ((value == null) || !passRegex.hasMatch(value) || value.length < 8) {
      return invalidPassStr;
    }
    return null;
  }

}
import 'package:flutter_test/flutter_test.dart';
import 'package:onlyemoji/utils/validator/input_validator.dart';

void main(){
  const String emptyStr = "入力してください";
  const String notEmojiStr = "絵文字のみが使用可能です";
  const String notEmojiOver20Str = "20文字まで、絵文字のみが使用可能です";
  const String notEmojiOver200Str = "200文字までです";
  const String invalidEmailStr = "Emailアドレスを入力してください";
  const String invalidPassStr = "パスワードは8文字以上、半角英数を含むようにしてください";

  group("emoji validation test", (){
    test("only char",(){
      expect(InputValidator.emojiValidator("this is only char"),notEmojiStr);
    });
    test("contains 😁",(){
      expect(InputValidator.emojiValidator("aaaa😁"),notEmojiStr);
    });
    test("only emoji",(){
      expect(InputValidator.emojiValidator("😁🥺"),null);
    });
    test("emoji and empty",(){
      expect(InputValidator.emojiValidator("😁🥺 "),null);
    });
    test("empty",(){
      expect(InputValidator.emojiValidator(""),emptyStr);
    });
    test("empty2",(){
      expect(InputValidator.emojiValidator(" "),emptyStr);
    });
  });
}
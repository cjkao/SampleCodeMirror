import 'dart:html';
import 'package:SampleCodeMirror/mirror-example.dart';
CodeViewer cv;
void main() {
  querySelector("#sample_text_id")
      ..text = "Click me!"
      ..onClick.listen(reverseText);
  cv=new CodeViewer();
}
void reverseText(MouseEvent event) {
  HttpRequest.getString('sample.cc')
          .then((data){
    cv.setCode(data);
  });


}


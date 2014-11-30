import 'dart:html';
import 'package:codemirror/codemirror.dart';
import 'dart:async';
import 'package:dnd/dnd.dart';

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

class CodeViewer{

  StreamSubscription _ss;
  static const  String _template=
      ''' 
<div draggable class="panel panel-default" class='\${containerId}'>
       <div class="panel-heading">\${title}
 <button type="button" class="close" ><span aria-hidden="true">&times;</span></button>
</div>
      <div class="panel-body">
          <div class='textContainer'></div>
      </div>
    </div>
''';
  Element _root;
  CodeMirror _editor;
  /**
   * @param externalStyle: default : use internal style
   */
  CodeViewer([String docStr='', String tit='code', String containerId='code-mirror-viewer', bool extStyle=false]){
    String ctnId= containerId;
    _root=querySelector('.$ctnId');
    String title=tit;
    //document.documentElement
    if(_root==null){
      if(!extStyle)   _prepareStyle(ctnId);
      _root= _createElem(document.lastChild,templateStr: _template, clz:ctnId);
      Draggable draggable = new Draggable(_root, avatarHandler: new AvatarHandler.original());
      Element editorElem=_root.querySelector('.textContainer');
      Map options = {  'mode':  'clike',   'lineNumbers': true, 'theme':'xq-light', 'styleActiveLine': true,
                       'matchBrackets': true, 'foldGutter': true,
                       'gutters': ["CodeMirror-linenumbers", "CodeMirror-foldgutter"]   };
      _editor = new CodeMirror.fromElement(   editorElem, options: options);
      _setupCloseListener();
      _root.classes..add('show-code');
      _root.hidden=true;
    }

    //if(ss!=null) ss.cancel();


  }
  setCode(String str){
    //_editor.getDoc().setValue(str);
    _root.hidden=false;
    _editor.swapDoc(new Doc(str,'clike'));
//    _editor.setReadOnly(true);
//    _editor.focus();
    _editor.refresh();
  }
  /**
   * remove self from doc
   */
  detach(){
    if(_ss!=null) _ss.cancel();
    _root.detached();
  }
  Element _createElem(Element parentNode,{String templateStr, String clz:'', int tabIndex:0,Map style,bool hideFocus:false}){
      DivElement div=new DivElement();
      div.innerHtml=templateStr;
      if(style!=null)
        style.forEach((key,value)=> div.style.setProperty(key, value));
      div.classes.addAll(clz.split(' '));
      div.tabIndex=tabIndex;
      if(hideFocus) div.attributes['hideFocus']='true';
      if(parentNode!=null){
        parentNode.append(div);
      }

      return div;

    }
  /**
   * default internal style
   */
  void _prepareStyle(String containerId){
    StyleElement styleElement = new StyleElement();
    document.head.append(styleElement);
          // use the styleSheet from that
    CssStyleSheet sheet = styleElement.sheet;

    sheet.insertRule('''
    div.${containerId}.show-code {
      z-index: 1001;
      width: 90%;
      height: 80%;
      position: fixed;
      top: 80px;
      padding: 10px;
      border-radius: 5px;
     
    } ''', 0);
   // sheet.insertRule('.hidden{display:none;}',1);
    sheet.insertRule('div.${containerId} div.panel-body{padding: 0; box-shadow: 2px 2px 5px #CCCCCC;}',1);
    sheet.insertRule('div.${containerId} button{line-height: 0.5px; height:12px;}',2);
    sheet.insertRule('div.${containerId} div.panel-heading{padding: 5px;}',3);
  }
  void _setupCloseListener(){
    _ss = document.onKeyUp.listen( (_){
             if (_.which == 27) {
            //   _root.classes..add('hide');
               _root.hidden=true;
             }
        });
        _root.onBlur.listen((_)=>  _root.hidden=true);
        _root.querySelector('button.close').onClick.listen((_)=> _root.hidden=true);
  }
}

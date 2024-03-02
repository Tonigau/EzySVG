'   *.bi linguist-language=Freebasic
' ezySVG.bi
' Make SVG from Freebasic code            ToniG      Create: 2023.12.20
'                                         File Version 0.92.1  2023.02.16 

'This lib creates SVG elements, it is minimal & can be expanded to include additional functionality.

'Supported Elements:
'                      Line, Polyline, Polygon, Text, Rectangle, Circle, Elipse, Path, Image
'Supported Attributes:
'                      Many (to name a few... Fill, Stroke, Font-Family, Font-Size, Font-Weight, Font-Style)

'                      Transform - Rotate, Scale, Translate, SkewX, SkewY, Matrix(not tested)
'                      Transform-Origin (minimal tested)

'Special function:
'                      Quadratic Curve, Quadratic Curve Multi, SVG Group, Text on Path, Gradient fill
'                      DropShadow, GaussianBlur, SVG Comment, SVG_CRLF, SVG_RAW

'Notes:
'     Some SVG functionality(transform, +other) may only work in a web browser (or capable viewer). 
'     Import to CAD may need to keep simple as possible or explicity create elements. Test & see what works.
'     Use an online SVG converter to make vector cad (AI, EPS, PDF) 
'     For now the Element co-ordinates & size are Integer, for screen rendering 
'     if want to use  dp precision then as Single needed. 

'USAGE:    Refer example bas files & SVG reference info.

'-----------------------------------
' Can use Ucase or Lcase for style strings as the lib will convert to Lcase. (except some specific Ucase requirements) 

' Setting the style string with fixed values can be done with just 1 string eg. " stroke=rgb(0,0,0), stroke-width=0.5"
' to add variables for style attribute value(parameter) use eg. "stroke-width=" +Str(VarValue)
'
' To rotate a path, create the path points in a virtual bounding box (Min Max X&Y values) then use the mid point XY
' in the Transform=rotate(R,X,Y) Its not easy to resolve XY mid from complex path values. (SVG renderers do it though)

'-----------------------------------
' Changes:  Since V0.10
'   V0.12 2024-02-07    Change Group parameter to Style set = Group Start, Style Null = Group End
'   V0.13 2024-02-10    Fixed Bug in transform Case Else (Element attr killed if Transform active) 
'   V0.90 2024-02-10    Add Text on Path, Gradient fill. 
'   V0.91 2024-02-15    Add Drop Shadow filter, change style separator from"_" to "__". 
'                       Add code to escape "&" --> "&#38;" in text strings only.
'                       Fix Var type PolyBB & rename PolyBBox
'                       Fix 'File path check' in Sub SVG_Image (filename only/Full path/online resource)
'   V0.92 2024-02-15    Add GaussianBlur, change blur param to Single (also for drop shadow)
'   V0.92.1 2024-02-16  Change order of SVG_Qbezier parameters to [x1,x2, Qx,Qy, x2,y2,...] to be consistent with "path points"
'   V0.92.2 2024-02-16  Change SVG_Qbezier to use SVG_Path sub, Add CRLF indenting for SVGpath string.
'                       Add optional parameter 7 "xmlns" to SVG_Start, some minor fixes 
'         
'ToDoo:
'      1. Fix Indenting in path cmd

'Issues:
'      1. There May be an issue with Style string left part processing for non Transform attributes

'-----------------------------------

Declare Sub SVG_Start(SVGoutFile As String, SVG_SizeX As Long, SVG_SizeY As Long, Offset_X As integer=0, Offset_Y As integer=0, HTML_ON As String="", SVGstr As String="")
Declare Sub SVG_End(HTML_ON As String="")
Declare Sub SVG_PolyLine(SVGpoints As String, ByVal StyleSVG As String="", RotateVal As Integer=0, StyleFmt As UByte=1)
Declare Sub SVG_Line(X1 As Long, Y1 As Long, X2 As Long, Y2 As Long, ByVal StyleSVG As String="", RotateVal As Integer=0, StyleFmt As UByte=1) 

Declare Sub SVG_Group(ByVal StyleSVG As String="")
Declare Sub SVG_Text(X As Long, Y As Long, TXTstr As String, ByVal StyleSVG As String="", RotateVal As Integer=0, StyleFmt As UByte=1)
Declare Sub SVG_Rect(X As Long, Y As Long, W As Long, H As Long, ByVal StyleSVG As String="", RotateVal As Integer=0, StyleFmt As UByte=1)
Declare Sub SVG_Circle(Cx As Long, Cy As Long, R As Long, ByVal StyleSVG As String="", RotateVal As Integer=0, StyleFmt As UByte=1)  

Declare Sub SVG_Ellipse(Cx As Long, Cy As Long, Rx As Long, Ry As long, ByVal StyleSVG As String="", RotateVal As Integer=0, StyleFmt As UByte=1)
Declare Sub SVG_Polygon(SVGpoints As String, ByVal StyleSVG As String="", RotateVal As Integer=0, StyleFmt As UByte=1)
Declare Sub SVG_Qbezier(X1 As Long, Y1 As Long, X2 As Long, Y2 As Long, QX As Long, QY As Long, ByVal StyleSVG As String="", RotateVal As Integer=0, StyleFmt As UByte=1)
' Obsolete Declare Sub SVG_QbezierM(ByVal QbezStr As String, ByVal StyleSVG As String="", StyleFmt As UByte=1)
        
Declare Sub SVG_Path(ByVal SVGpathStr As String, ByVal StyleSVG As String="", RotateVal As Integer=0, StyleFmt As UByte=1)
Declare Sub SVG_TextPath(Path_ID As String, PathPoints As String, Path_Style As String, TXTstr As String, Text_Style As String,  Strt_Pos As UByte=10, ShowPath As Integer=1)
Declare Sub SVG_GradientL(Grad_ID As String, Color_1 As String, Color_2 As String, Stop1 As Integer, Stop2 As Integer, X1pc As Integer, X2pc As Integer, Y1pc As Integer, Y2pc As Integer)
Declare Sub SVG_DropShadow(DS_ID As String, Color_1 As String, DX As Integer=10, DY As Integer=10, Blur As Single=2, feOffset As Integer= -20, feSize As Integer=180)    
Declare Sub SVG_GaussianBlur(DS_ID As String, DX As Integer=10, DY As Integer=10, Blur As Single=2, feOffset As Integer= -20, feSize As Integer=180)
Declare Sub SVG_Image(X As Long, Y As Long, W As Long, H As Long, ByVal KeepAspect As String="", ByVal ImgPathFile As String, RotateVal As Integer=0, StyleFmt As UByte=1)
Declare Sub SVG_Comment(TXTstr As String, LFCR As UByte=0)
Declare Sub SVG_CRLF(n_ As Ubyte =1)
Declare Sub SVG_RAW(TextIn As String)

Declare Function SVG_StyleRet1(ByVal AttVal_1 As String="", ByVal AttVal_2 As String="", ByVal AttVal_3 As String="", ByVal AttVal_4 As String="", ByVal AttVal_5 As String="") As String    
Declare Function SVG_StyleRet2(ByVal AttName_1 As String="", ByVal AttValu_1 As Single=0, ByVal AttName_2 As String="", ByVal AttValu_2 As Single=0, _
                               ByVal AttName_3 As String="", ByVal AttValu_3 As Single=0, ByVal AttName_4 As String="", ByVal AttValu_4 As Single=0) As String
Declare Function SVG_GetPolyMid(byVal PolyPts As String, PolyBBox() As Long) As Integer

 'Internal functions (not for main program use)
Declare Function FormatStyle(ByVal StyleSVG As String, ByVal Xs As Integer, ByVal Ys As Integer, ByVal StyleFmt As Ubyte) As String 
Declare Function FormatStyle2(ByVal StyleSVG As String, ByVal Xs As Integer, ByVal Ys As Integer, ByVal StyleFmt As UByte, Byval Part As Ubyte) As String
Declare Function FindAndChr(String1 As String) As String

Dim Shared As Ubyte SVG_Fnum     ' SVG File Number

#Define CR_LF Chr(13,10)
#Define DQ    Chr(34)


Sub SVG_Start(SVGoutFile As String, SVG_SizeX As Long, SVG_SizeY As Long, Offset_X As Integer = 0, Offset_Y As Integer = 0, HTML_ON As String = "", SVGstr As String="")
    Dim As String   HTML_head
    HTML_head = "<!DOCTYPE html>" +CR_LF + _ ' easier to open for browser
                "<html>" +CR_LF + _
                "<body>" +CR_LF
    SVG_Fnum = FreeFile
      If UCase(Trim(HTML_ON)) = "HTML" Then SVGoutFile += ".html" 
    Open SVGoutFile for Output As #SVG_Fnum
      If UCase(Trim(HTML_ON)) = "HTML" Then Print #SVG_Fnum, HTML_head
      'SVG 
      Print #SVG_Fnum,         "<svg";
      Print #SVG_Fnum,  " width="; DQ; Str(SVG_SizeX); DQ ;
      Print #SVG_Fnum,  " height="; DQ; Str(SVG_SizeY); DQ ;
      Print #SVG_Fnum,  " viewbox=" +DQ +Str(Offset_X) +"," +Str(Offset_Y) +"," +Str(SVG_SizeX) +"," +Str(SVG_SizeY)+DQ +" " +SVGstr;
      Print #SVG_Fnum,            ">"
End Sub


Sub SVG_End(HTML_ON As String = "")
      Dim As String  HTML_End
      HTML_End = CR_LF +"</body>" +CR_LF _
                       +"</html>"
      Print #SVG_Fnum, "</svg>"
      If UCase(Trim(HTML_ON)) = "HTML" Then  Print #SVG_Fnum, HTML_End
   Close SVG_Fnum
End Sub


'   With Style set is Group start, with Style NULL(or less than 6 chrs) = Group End
Sub SVG_Group(ByVal Style As String = "")
   Dim As String  TmpStr 'RetSep(1 To 2)
   If  Len(Trim(Style)) < 6 Then Style = ""
   If Style <> "" Then
      TmpStr = "<g" +CR_LF +FormatStyle(Style, 0, 0, 0)
      Print #SVG_Fnum, TmpStr +CR_LF +">"
   Else
      Print #SVG_Fnum, "</g>" +CR_LF   ' group end
   EndIf
End Sub  

'  Alternate Group End
Sub SVG_GroupEnd()
      Print #SVG_Fnum, "</g>" +CR_LF   ' group end
End Sub  


Sub SVG_Rect(X As Long, Y As Long, W As Long, H As Long, ByVal StyleSVG As String="", RotateVal As Integer=0, StyleFmt As UByte=1)
  Dim As UByte Pos1
  Dim As String Indent1, ElemAttr1, ElementStr1, ElemAttr2, TmpStr
    Indent1 = "" : If StyleFmt = 0 Then Indent1 = "   " '
    ElementStr1 = Indent1 +"<rect"
    ElemAttr1 = " x=" +DQ +Str(X) +DQ +" y=" +DQ +Str(Y) +DQ +" width=" +DQ +Str(W) +DQ +" height=" +DQ +Str(H) +DQ
   If RotateVal <> 0 Then ElemAttr2 = " transform=""rotate(" +Str(RotateVal) +"," +Str(X+W/2) +"," +Str(Y+H/2)  +")"""
    ElementStr1 &= ElemAttr1 + ElemAttr2                                  ' Rotate replaces x y with a translate(x,y)
   If StyleSVG <> "" Then TmpStr = FormatStyle(StyleSVG, X, Y, StyleFmt) 
    Print #SVG_Fnum, ElementStr1; TmpStr; "/>" '+ CR_LF
End Sub


Sub SVG_PolyLine(SVGpoints As String, ByVal StyleSVG As String="", RotateVal As Integer=0, StyleFmt As UByte=1)
  Dim As UByte Pos1
  Dim As Long PolyBBox(1 To 10) ' polygon bounding box(MinMax & CTR)
  Dim As String Indent1, ElemAttr1, ElementStr1, ElemAttr2, TmpStr
    Indent1 = "" : If StyleFmt = 0 Then Indent1 = "   " '
    ElementStr1 = Indent1 +"<polyline points= "   '< change this for other element type & edit ElemAttr1, ElemAttr2 
    ElemAttr1   = DQ+ SVGpoints +DQ     
   SVG_GetPolyMid(SVGpoints, PolyBBox()) ' find centre
   If RotateVal <> 0 Then 
      ElemAttr2 = " transform=""rotate(" +Str(RotateVal) +"," +Str(PolyBBox(1)) +"," +Str(PolyBBox(2)) +")"""
   End If 
    Print #SVG_Fnum, ElementStr1 +ElemAttr1' +CR_LF 
   TmpStr = FormatStyle(StyleSVG, PolyBBox(1), PolyBBox(2), StyleFmt)
    Print #SVG_Fnum, ElemAttr2 +TmpStr; "/>" '+ CR_LF
End Sub


Sub SVG_Polygon(SVGpoints As String, ByVal StyleSVG As String="", RotateVal As Integer=0, StyleFmt As UByte=1)
  Dim As UByte Pos1
  Dim As Long PolyBBox(1 To 10) ' polygon bounding box(MinMax & CTR)
  Dim As String Indent1, ElemAttr1, ElementStr1, ElemAttr2, TmpStr
    Indent1 = "" : If StyleFmt = 0 Then Indent1 = "   " '
    ElementStr1 = Indent1 +"<polygon points= "
    ElemAttr1   = DQ+ SVGpoints +DQ
   SVG_GetPolyMid(SVGpoints, PolyBBox()) ' find centre
   If RotateVal <> 0 Then 
      ElemAttr2 = " transform=""rotate(" +Str(RotateVal) +"," +Str(PolyBBox(1)) +"," +Str(PolyBBox(2)) +")"""
   End If 
    Print #SVG_Fnum, ElementStr1 +ElemAttr1' +CR_LF 
   TmpStr = FormatStyle(StyleSVG, PolyBBox(1), PolyBBox(2), StyleFmt) 
    Print #SVG_Fnum, ElemAttr2 +TmpStr; "/>" '+ CR_LF
End Sub


Sub SVG_Line(X1 As Long, Y1 As Long, X2 As Long, Y2 As Long, ByVal StyleSVG As String="", RotateVal As Integer=0, StyleFmt As UByte=1)
  Dim As UByte Pos1
  Dim As String Indent1, ElemAttr1, ElementStr1, ElemAttr2, TmpStr
    Indent1 = "" : If StyleFmt = 0 Then Indent1 = "   " : StyleFmt = 2
    ElementStr1 = Indent1 +"<Line"
    ElemAttr1   = " x1=" +DQ +Str(X1) +DQ +" y1=" +DQ +Str(Y1) +DQ + " x2=" +DQ +Str(X2) +DQ +" y2=" +DQ +Str(Y2) +DQ
     If RotateVal <> 0 Then ElemAttr2 = " transform=""rotate(" +Str(RotateVal) +"," +Str(X1) +"," +Str(Y1) +")"""
    ElementStr1 &= ElemAttr1 + ElemAttr2            '            
   If StyleSVG <> "" Then TmpStr = FormatStyle(StyleSVG, X1, Y1, StyleFmt) ' X1 Y1 = element pos for rotate
    Print #SVG_Fnum, ElementStr1; TmpStr; "/>" '+ CR_LF
End Sub


Sub SVG_Circle(Cx As Long, Cy As Long, R As Long, ByVal StyleSVG As String="", RotateVal As Integer=0, StyleFmt As UByte=1)
  Dim As UByte Pos1
  Dim As String Indent1, ElemAttr1, ElementStr1, ElemAttr2, TmpStr
    Indent1 = "" : If StyleFmt = 0 Then Indent1 = "   " '
    ElementStr1 = Indent1 +"<circle"
    ElemAttr1   = " cx=" +DQ +Str(Cx) +DQ +" cy=" +DQ +Str(Cy) +DQ + " r=" +DQ +Str(R) +DQ
    ElementStr1 &= ElemAttr1 + ElemAttr2                                  ' Rotate enabled for consistency
    TmpStr = FormatStyle(StyleSVG, Cx, Cy, StyleFmt) 
    Print #SVG_Fnum, ElementStr1; TmpStr; "/>" '+ CR_LF
End Sub


Sub SVG_Ellipse(Cx As Long, Cy As Long, Rx As Long, Ry As long, ByVal StyleSVG As String="", RotateVal As Integer=0, StyleFmt As UByte=1)
  Dim As UByte Pos1
  Dim As String Indent1, ElemAttr1, ElementStr1, ElemAttr2, TmpStr
    Indent1 = "" : If StyleFmt = 0 Then Indent1 = "   " '
    ElementStr1 = Indent1 +"<ellipse"
    ElemAttr1 = " cx=" +DQ +Str(Cx) +DQ +" cy=" +DQ +Str(Cy) +DQ +" rx=" +DQ +Str(Rx) +DQ +" ry=" +DQ +Str(Ry) +DQ 
   If RotateVal <> 0 Then ElemAttr2 = " transform=""rotate(" +Str(RotateVal) +"," +Str(Cx) +"," +Str(cy)  +")"""
    ElementStr1 &= ElemAttr1 + ElemAttr2                                  ' Rotate replaces x y with a translate(x,y)
   If StyleSVG <> "" Then TmpStr = FormatStyle(StyleSVG, Cx, Cy, StyleFmt) 
    Print #SVG_Fnum, ElementStr1; TmpStr; "/>" '+ CR_LF
End Sub


Sub SVG_Text(X As Long, Y As Long, TXTstr As String, ByVal StyleSVG As String="", RotateVal As Integer=0, StyleFmt As UByte=1)
 Dim As UByte Pos1
 Dim As String Indent1, ElemAttr1, ElementStr1, ElemAttr2, TmpStr
    TXTstr = FindAndChr(TXTstr)
    Indent1 = "" : If StyleFmt = 0 Then Indent1 = "   " '
    ElementStr1 = Indent1 +"<text"
    ElemAttr1   = " x=" +DQ +Str(X) +DQ +" y=" +DQ +Str(Y) +DQ 
   If RotateVal <> 0 Then ElemAttr2 = " transform=""rotate(" +Str(RotateVal) +"," +Str(X) +"," +Str(Y) +")"""
    ElementStr1 &= ElemAttr1 + ElemAttr2
      TmpStr =   FormatStyle(StyleSVG, X, Y, StyleFmt)   'X Y need not for text ?? 
    Print #SVG_Fnum, ElementStr1; " "; TmpStr; ">"; TXTstr; "</text>" '+ CR_LF
End Sub


Sub SVG_TextPath(Path_ID As String, PathPoints As String, Path_Style As String, TXTstr As String, Text_Style As String, Strt_Pos As UByte=10, ShowPath As Integer=1)
   Dim As String Def_Str, Text_Str, Indent1 = "  "
    TXTstr = FindAndChr(TXTstr) 
    Def_Str = "<defs>" +CR_LF  +"  <path id=" +DQ  +Path_ID +DQ +" d=" +DQ +PathPoints +DQ +" "
    Def_Str &= FormatStyle(Path_Style, 0, 0, 1)  +"></path>" +CR_LF + "</defs>" +CR_LF 
    If ShowPath = 1 Then Def_Str &= "  <use href=" +DQ +"#" +Path_ID +DQ +"></use>" 
      Text_Str = "<text " +FormatStyle(Text_Style, 0, 0, 1)  +">" +CR_LF   
      Text_Str &= Indent1  +"<textPath  href=" +DQ +"#" +Path_ID +DQ +" startOffset=" +DQ +Str(Strt_Pos) +"%"">" +CR_LF
      Text_Str &= Indent1  +Indent1 +TXTstr +CR_LF
      Text_Str &= Indent1 +"</textPath>" +CR_LF
      Text_Str &= "</text>" +CR_LF
   Print #SVG_Fnum, Def_Str
   Print #SVG_Fnum, Text_Str  
End Sub


'   Quadratic Bezier curve (using path)
Sub SVG_Qbezier(X1 As Long, Y1 As Long, QX As Long, QY As Long, X2 As Long, Y2 As Long, ByVal StyleSVG As String="", RotateVal As Integer=0, StyleFmt As UByte=1)
   Dim As String ElemAttr1, TmpStr = ""
    ElemAttr1   = "M " +Str(X1) +"," +Str(Y1)  +" Q " +Str(QX) +"," +Str(QY) +" " +Str(X2) +"," +Str(Y2)
   If RotateVal <> 0 AndAlso InStr(LCase(StyleSVG), "rotate") = 0 Then  ' check if rotate set
      TmpStr = "Rotate=(" +Str(RotateVal) +"," +Str(X1) +"," +Str(Y1) +")" 
      If InStr(StyleSVG, "__") = 0 Then TmpStr &= "__" Else TmpStr &= " " ' check if left part exist
   EndIf
    StyleSVG = TmpStr +StyleSVG
    SVG_Path( ElemAttr1, StyleSVG, RotateVal, StyleFmt)
End Sub


'   Path Element
Sub SVG_Path(ByVal SVGpathStr As String, ByVal StyleSVG As String="", RotateVal As Integer=0, StyleFmt As UByte=1)
 Dim As String Indent1 ="", ElemAttr1 = "", ElemAttr2, ElementStr1, TmpStr
 Dim As Integer Pos1 = 0
    ElementStr1 = Indent1 +"<path d=" +DQ '+CR_LF 
      TmpStr = SVGpathStr
      Pos1 = InStr(TmpStr, CR_LF)
   Do While Pos1 <> 0          '  Indent path points if CRLF in PathString
      ElemAttr1 &= Indent1 +Left(TmpStr, Pos1-1)
      TmpStr = Right(TmpStr, Len(TmpStr)-(Pos1+1))
      Pos1 = InStr(TmpStr, CR_LF)
      Indent1 = CR_LF +Space(9)
      If Pos1 = 0 AndAlso Len(TmpStr) > 1 Then ElemAttr1 &= Indent1 +TmpStr' +CR_LF
   Loop 
    If TmpStr = SVGpathStr Then ElemAttr1 = SVGpathStr ' If no CRLF   
    ElementStr1 &= ElemAttr1 +DQ
   ElemAttr2 = FormatStyle(StyleSVG, 0, 0, StyleFmt) ' transform rotate is default ViewBox 0,0
   Print #SVG_Fnum, ElementStr1; CR_LF; ElemAttr2 +"/>" 
End Sub

 
'   Linear Gradient
Sub SVG_GradientL(Grad_ID As String, Color_1 As String, Color_2 As String, Stop1 As Integer, Stop2 As Integer, X1pc As Integer, X2pc As Integer, Y1pc As Integer, Y2pc As Integer)
   Dim As String Def_Str, Text_Str, Indent1 = "   "
    Def_Str = " <defs>" +CR_LF
    Def_Str &= Indent1 +"<linearGradient id=" +DQ + Grad_ID +DQ 
      Def_Str &= " x1=" +DQ +Str(X1pc) +"%" +DQ
      Def_Str &= " x2=" +DQ +Str(X2pc) +"%" +DQ 
      Def_Str &= " y1=" +DQ +Str(Y1pc) +"%" +DQ
      Def_Str &= " y2=" +DQ +Str(Y2pc) +"%" +DQ +">"  +CR_LF
    Def_Str &= Indent1 +Indent1 +"<stop offset=" +DQ +Str(Stop1) +"%" +DQ +" stop-color=" +DQ +Color_1 +DQ +" />" +CR_LF
    Def_Str &= Indent1 +Indent1 +"<stop offset=" +DQ +Str(Stop2) +"%" +DQ +" stop-color=" +DQ +Color_2 +DQ +" />" +CR_LF
    Def_Str &= Indent1 +"</linearGradient>" +CR_LF
    Def_Str &= " </defs>" +CR_LF
   Print #SVG_Fnum, Def_Str  
End Sub

'   DropShadow
Sub SVG_DropShadow(DS_ID As String, Color_1 As String, DX As Integer=10, DY As Integer=10, Blur As Single=2, feOffset As Integer= -20, feSize As Integer=180)
   Dim As String Def_Str, Text_Str, Indent1 = "   "
    Def_Str = " <defs>" +CR_LF
    Def_Str &= Indent1 +"<filter id=" +DQ + DS_ID +DQ 
      Def_Str &= " x=" +DQ +Str(feOffset) +"%" +DQ
      Def_Str &= " y=" +DQ +Str(feOffset) +"%" +DQ 
      Def_Str &= " width=" +DQ +Str(feSize) +"%" +DQ
      Def_Str &= " height=" +DQ +Str(feSize) +"%" +DQ +">"  +CR_LF   
    Def_Str &= Indent1 +Indent1 +"<feDropShadow" +" dx=" +DQ +Str(DX) +DQ  +" dy=" +DQ +Str(DY) +DQ _
                                +" stdDeviation=" +DQ +Str(Blur) +DQ +" flood-color=" +DQ +Str(Color_1) +DQ  +" />" +CR_LF
    Def_Str &= Indent1 +"</filter>" +CR_LF
    Def_Str &= " </defs>" +CR_LF
   Print #SVG_Fnum, Def_Str     
End Sub


'   GaussianBlur 
Sub SVG_GaussianBlur(DS_ID As String, DX As Integer=0, DY As Integer=0, Blur As Single=2, feOffset As Integer= -20, feSize As Integer=150)
   Dim As String Def_Str, Text_Str, Indent1 = "   "
    Def_Str = " <defs>" +CR_LF
    Def_Str &= Indent1 +"<filter id=" +DQ + DS_ID +DQ 
      Def_Str &= " x=" +DQ +Str(feOffset) +"%" +DQ
      Def_Str &= " y=" +DQ +Str(feOffset) +"%" +DQ 
      Def_Str &= " width=" +DQ +Str(feSize) +"%" +DQ
      Def_Str &= " height=" +DQ +Str(feSize) +"%" +DQ +">"  +CR_LF   
    Def_Str &= Indent1 +Indent1 +"<feGaussianBlur" +" stdDeviation=" +DQ +Str(Blur) +DQ +" result=" +DQ + DS_ID +DQ +" />" +CR_LF  
    Def_Str &= Indent1 +Indent1 +"<feOffset " +"dx=" +DQ +Str(DX) +DQ  +" dy=" +DQ +Str(DY) +DQ +" />" +CR_LF
    Def_Str &= Indent1 +"</filter>" +CR_LF
    Def_Str &= " </defs>" +CR_LF
   Print #SVG_Fnum, Def_Str     
End Sub

'   <defs>
'      <filter id="shadow1" x="-20%" y="-20%" width="140%" height="140%">
'        <feGaussianBlur stdDeviation="1.5" result="shadow1"/>
'	      <feOffset dx="-6" dy="6"/>
'      </filter>
'   </defs>


Sub SVG_Image(X As Long, Y As Long, W As Long, H As Long, ByVal KeepAspect As String="", ByVal ImgPathFile As String, RotateVal As Integer=0, StyleFmt As UByte=1)
   Dim As String Indent1, ElemAttr1, ElementStr1, ElemAttr2, TmpStr
   ElementStr1 = Indent1 +"<image href=" +DQ
   If InStr(ImgPathFile,"http") = 0 Then ' local file
      ElementStr1 &= "file:" 
      If InStr(ImgPathFile,":") <> 0 Or InStr(ImgPathFile,"\") <> 0 Then ElementStr1 &= "//" ' with full path    
   End If
   ElementStr1 &= ImgPathFile +DQ
   ElemAttr1 = " x=" +DQ +Str(X) +DQ +" y=" +DQ +Str(Y) +DQ +" width=" +DQ +Str(W) +DQ +" height=" +DQ +Str(H) +DQ
   If RotateVal <> 0 Then ElemAttr2 = " transform=""rotate(" +Str(RotateVal) +"," +Str(X+W/2) +"," +Str(Y+H/2)  +")" +DQ
    ElementStr1 &= ElemAttr1                                 ' Rotate replaces x y with a translate(x,y)
   If KeepAspect <> "" Then ElemAttr2 &= " preserveAspectRatio=" +DQ +Trim(KeepAspect) +DQ     'FormatStyle(StyleSVG, X, Y, StyleFmt) 
    Print #SVG_Fnum, ElementStr1; ElemAttr2; TmpStr; "/>"
End Sub
    ' ref
   '<image href="file:mdn_logo_only_color.png" x="550" y="280" width="150" height="200"
   '<image href="file://d:\Data\FBedit\DataGraph\mdn_logo_only_color.png" x="600" y="300" width="150" height="150"/>
   '<image href="https://i.postimg.cc/qqT64fy9/mdn-logo-only-color.png" x="550" y="280" width="150" height="200"



'                  Misc. Subs
'----------------------------------------------------------
Sub SVG_Comment(TXTstr As String, LFCR As UByte=0)
    If LFCR > 0 Then Print #SVG_Fnum, ""
    Print #SVG_Fnum, "<!-- "; TXTstr; " -->"
End Sub

Sub SVG_CRLF(n_ As Ubyte =1)
    Dim As UByte Lp1
    For Lp1 = 1 To n_ : Print #SVG_Fnum, : Next
End Sub

  ' make SVG line from TextIn (must be Valid SVG syntax string)
Sub SVG_RAW(TextIn As String)
    Print #SVG_Fnum, TextIn
End Sub


' Find un-escaped "&" & escape it 
Function FindAndChr(String1 As String) As String
   Dim As Integer Pos1 = 0
   Dim As String TempStr = "", EscAnd = "&#38;"  '"&amp;"
     Pos1 = InStr(String1,"&")
     If Pos1 = 0 Or Mid(String1,Pos1,5) = EscAnd Then ' no "&" or it escaped
        TempStr = String1
     Else
        TempStr = Left(String1,Pos1-1) +EscAnd +Right(String1, Len(String1)-Pos1)   
     EndIf
   Function = TempStr
End Function



'                  Utility Functions
'---------------------------------------------------------
'        Get the XY Center & XY Min Max for polygon points
Function SVG_GetPolyMid(byVal PolyPts As String, PolyBBox() As Long) As Integer 
   Dim As UInteger Lp1, MaxVal_X, MaxVal_Y, MinVal_X = &hFFFFFF, MinVal_Y = &hFFFFFF
   Dim As String Chr1, ValStr, Xval, Yval   
   Xval = "" : Yval = ""

   For Lp1 = 1 To Len(PolyPts)   
         Chr1 = Mid(PolyPts, Lp1,1)
      If (Chr1 <> " " AndAlso Chr1 <> ",") Then ValStr &= Chr1   ' get the number chr's (only chr(32) whitespace allowed)
      If Lp1 = Len(PolyPts) Andalso ValStr <> "" Then chr1 = " " 
       ' Get X val
    	If Chr1 = ","  AndAlso Len(ValStr) > 0 Then   
         Xval = ValStr : ValStr = "" ': XvalFound =  TRUE
         If MaxVal_X < Val(Xval) Then MaxVal_X = Val(Xval)
         If MinVal_X > Val(Xval) Then MinVal_X = Val(Xval)
         Yval = ""
    	EndIf
       ' Get Y val         
      If Chr1= " " AndAlso Len(ValStr) > 0 AndAlso Len(Xval) Then' AndAlso Xval > 0 Then            ' Get Y val
         Yval = ValStr : ValStr = "" ': YvalFound =  TRUE
         If MaxVal_y < Val(Yval) Then MaxVal_Y = Val(Yval)
         If MinVal_y > Val(Yval) Then MinVal_Y = Val(Yval)
         Xval = ""
      EndIf
   Next
   '           Array Return ByRef - Bounding Box
   PolyBBox(1) = MinVal_X + ((MaxVal_X - MinVal_X) / 2) ' Mid X
   PolyBBox(2) = MinVal_Y + ((MaxVal_Y - MinVal_Y) / 2) ' Mid Y
   PolyBBox(3) = MinVal_X : PolyBBox(4) =  MaxVal_X       ' MinMax X
   PolyBBox(5) = MinVal_Y : PolyBBox(6) =  MaxVal_Y       ' MinMax Y
End Function


' ---------- Warning: Dont mix Style Left & Right parts when calling these 2 Functions ---------
' Convert separate style strings from program to single style string. (might be useful)
' use for inserting variables in style string.
'       Return Style string from "String" +Str(Value),"String" +Str(Value), ...
Function SVG_StyleRet1(ByVal AttVal_1 As String="", ByVal AttVal_2 As String="", ByVal AttVal_3 As String="", ByVal AttVal_4 As String="", ByVal AttVal_5 As String="") As String
    Dim As String AttributeVal(1 to 6) = {AttVal_1, AttVal_2, AttVal_3, AttVal_4, AttVal_5,""}
    Dim As String StyleSVG = ""
    Dim As UByte Lp1
   For Lp1 = 1 To 5
      If Lp1 <> 1 AndAlso AttributeVal(Lp1) <> "" Then StyleSVG &=  ", "
      If AttributeVal(Lp1) <> "" Then StyleSVG &= AttributeVal(Lp1)
   Next   
    SVG_StyleRet1 = StyleSVG 
End Function

 '       Return Style string from "Str",Valu,"Str",Valu, ...     (might be useful)
Function SVG_StyleRet2(ByVal AttName_1 As String="", ByVal AttValu_1 As Single=0, ByVal AttName_2 As String="", ByVal AttValu_2 As Single=0, _
                       ByVal AttName_3 As String="", ByVal AttValu_3 As Single=0, ByVal AttName_4 As String="", ByVal AttValu_4 As Single=0) As String
    Dim As String AttributeName(1 to 4) = {AttName_1, AttName_2, AttName_3, AttName_4}
    Dim As Single AttributeValu(1 to 4) = {AttValu_1, AttValu_2, AttValu_3, AttValu_4}
    Dim As String StyleSVG = ""
    Dim As UByte Lp1
   For Lp1 = 1 To 5
      If Lp1 <> 1 AndAlso AttributeName(Lp1) <> "" Then StyleSVG &=  ", "
      If AttributeName(Lp1) <> "" Then StyleSVG &= AttributeName(Lp1) + Str(AttributeValu(Lp1))' +", " 
   Next
    SVG_StyleRet2 = StyleSVG 
End Function
'------------------------------------------------




'         Formatting Attributes & Values for Transform & Style
'=====================================================================
'       Separate Transform & Style, format each then return formatted string
Private Function FormatStyle(ByVal Style As String, ByVal Xs As Integer = 0, ByVal Ys As Integer = 0, ByVal StyleFmt As Ubyte = 0) As String
   Dim As UByte Pos1, Part
   Dim As String TransF, Style1, TmpStr
       'Style = 
      Pos1 = Instr(Style , "__") 
      If Pos1 > 0 Then
         TransF = left(Style, Pos1-1)             ' Transform part
         Style1 = Right(Style, (Len(Style)-(Pos1+1))) ' Style part
         Part = 1 : TmpStr =  FormatStyle2(TransF, Xs, Ys, 1, Part)          ' Transform(& other) part
      Else
         Style1 = Style   
      EndIf
         Part = 2 : TmpStr & = FormatStyle2(Style1, Xs, Ys, StyleFmt, Part)  ' Style part
      FormatStyle = TmpStr
'Print #5, "Style ret L+R--"; TmpStr ' DEBUG
End Function 


   Const LB = "(" : Const RB = ")"
'       Format Style (or Element attributes)  
Private Function FormatStyle2(ByVal StyleSVG As String, ByVal Xs As Integer = 0, ByVal Ys As Integer = 0, _
                              ByVal StyleFmt As UByte = 1, Byval Part As Ubyte) As String
   Dim As String Chr1, TmpStr, Attr_Add, TranslateOriginPart
   Dim As UByte BrktL, CSF1, CSF2, StrLen, Lp1, Lp2, Pos1, PartCnt1
   Dim As String StylePart(20,3), RotatePart, SkewXpart, SkewYpart, ScalePart, TranslatePart, MatrixPart
      If StyleSVG = "" Then Exit Function
      BrktL = 0 : CSF1 = 1 : CSF2 = 1 : PartCnt1 = 1
    ' Find CS Values (CSV) 
      StrLen = Len(StyleSVG)
   For Lp1 = 1 To StrLen   
      Chr1 = Mid(StyleSVG, Lp1,1)
      If Chr1 = "(" Then BrktL = Lp1                                  ' 
      If Chr1 = ")" AndAlso BrktL > 0 Then BrktL = 0                  '
      If (Chr1= "," Andalso BrktL = 0) Then CSF2 = LP1                ' Ignore "," between brackets
      If Lp1 = StrLen And Right(StyleSVG,1) <> "," Then CSF2 = LP1+1  ' Get the last CS Val 
         
    	If CSF2 > CSF1 Then
         TmpStr = Trim(Mid(StyleSVG, CSF1, CSF2-CSF1))  ' Extract CSV data
         Pos1 = Instr(TmpStr , "=")
       ' Store style in array
#IfDef L_case                   ' Attrib part
         StylePart(PartCnt1,1) = LCase(left(TmpStr, Pos1-1))       ' Force Lcase left of =
#Else
         StylePart(PartCnt1,1) = left(TmpStr, Pos1-1)              ' MixedCase
#EndIf
         StylePart(PartCnt1,2) = Right(TmpStr, (Len(TmpStr)-Pos1)) ' Value part
          TmpStr = ""
          PartCnt1 +=1
          CSF1 = CSF2+1 
      EndIf
   Next

      If Part = 1 Then  ' Format Element values or Transform="    "
         If PartCnt1 < 1 Then Exit Function
'Print #5, "StyleSVG In=" +StyleSVG  ' DEBUG
            Attr_Add = ""
         For Lp1 = 1 To PartCnt1-1
              'Remove value Brakets
               Pos1 = InStr(StylePart(Lp1,2),"(")
               If Pos1 > 0  Then Mid(StylePart(Lp1,2), Pos1,1) = " "
               Pos1 = InStr(StylePart(Lp1,2),")")
               If Pos1 > 0  Then Mid(StylePart(Lp1,2), Pos1,1) = " "' : StylePart(Lp1,2) = Trim(StylePart(Lp1,2))
               StylePart(Lp1,2) = Trim(StylePart(Lp1,2)) 
 
'Print #5, "Part1_Len= " +Str(Len(StylePart(Lp1,2))) ' DEBUG
'Print #5, "Part1_2= " +StylePart(Lp1,1); " _ " +StylePart(Lp1,2) : #EndIf' DEBUG

               'TmpStr = StylePart(Lp1,1)
               TmpStr = LCase(StylePart(Lp1,1))
            Select Case TmpStr 'StylePart(Lp1,1)               
               Case Is = "scale"
                  ScalePart = "translate(" +Str(Xs) +"," +Str(Ys) +") " _
                                 +"scale(" +Str(StylePart(Lp1,2)) +") " _
                             +"translate(" +Str(-Xs) +"," +Str(-Ys) +") "
               Case Is = "rotate"
                  RotatePart = "rotate(" +StylePart(Lp1,2) +"," +Str(Xs) +"," +Str(Ys) +") "
                  If InStr(StylePart(Lp1,2)," ") OrElse InStr(StylePart(Lp1,2),",") Then ' rotate point is in rotate val
                     RotatePart = "rotate(" +StylePart(Lp1,2) +") "
                  EndIf  
               Case Is = "skewx"
                  SkewXpart = "skewX(" +StylePart(Lp1,2) +") " 'must be Ucase "X"
               Case Is = "skewy"
                  SkewYpart = "skewY" +StylePart(Lp1,2) +") "  '      "       "Y"
               Case Is = "matrix"
                  MatrixPart = "matrix(" +StylePart(Lp1,2) +") "   ' not tested yet 2024.01.06
               Case Is = "translate"
                  TranslatePart = "translate(" +StylePart(Lp1,2) +") "
               Case Is = "transform-origin"
                  TranslateOriginPart = "transform-origin" +StylePart(Lp1,2) ' Not working yet, puts inside main " "
                 
               Case Else ' Non style attributes, but not part of Transform="    " 
'Print #5, "Not Transform attr = " +TmpStr 'DEBUG
                  If StylePart(Lp1,1) = "rx" Then Attr_Add &= " rx=" +DQ +Str(StylePart(Lp1,2)) +DQ
                  If StylePart(Lp1,1) = "ry" Then Attr_Add &= " ry=" +DQ +Str(StylePart(Lp1,2)) +DQ
               '     For additional element attributes, add them here...
            End Select
         Next
                    ' Concatenate in order  [SVG Transform evaluates Left <-- Right]
            TmpStr = ""
            TmpStr= TranslatePart +RotatePart +TranslateOriginPart +SkewXpart +SkewYpart +ScalePart +MatrixPart 
            If TmpStr <> "" Then TmpStr= " transform=" +DQ +Trim(TmpStr) +DQ
            
            FormatStyle2 = Attr_Add +TmpStr
         Exit Function                '< already formatted (is fixed type)
      EndIf

   '         Build style string       'Look at using following code block with transform=... ? (Part = 1)
            StyleSVG = "" : PartCnt1 -=1 
   For Lp1 = 1 To PartCnt1
'Print #5, "STpart_2= " +StylePart(Lp1,2)
      
'     Enable use of brackets or "," in Dasharray value input eg. (3,5) or (3 5) or 3 5
      Chr1 = "" : TmpStr = ""
      If InStr(StylePart(Lp1,1), "stroke-dasharray") AndAlso InStr(StylePart(Lp1,2), "(") Then
         For Lp2 = 1 To Len(StylePart(Lp1,2))
            Chr1 = Mid(StylePart(Lp1,2),Lp2,1)
     	      If Chr1 = "," Then Chr1 = " " 
     	      If Chr1 = ")" Then Exit For  ' we are done
     	      If Chr1 <> "(" Then TmpStr &= Chr1  
         Next
         StylePart(Lp1,2) = TmpStr
      EndIf

'     Format style
      Select Case StyleFmt
         Case 0 ' [<g  >] Group style format (each attribute on newline) 
            StyleSVG &= "   " + StylePart(Lp1,1) + "=""" + StylePart(Lp1,2) + """" '+ CR_LF
            If Lp1 <> PartCnt1 Then StyleSVG &= CR_LF 
         Case 1 ' [: ;] style format
            If Lp1 = 1 Then StyleSVG = " style="""
            StyleSVG &= StylePart(Lp1,1) + ":" + StylePart(Lp1,2) 
            If Lp1 <> PartCnt1 Then StyleSVG &= ";" : Else StyleSVG &= """"  :EndIf
         Case 2 ' [=" "] DQ style format
            StyleSVG &= " " +StylePart(Lp1,1) + "=""" + StylePart(Lp1,2) + """"
      End Select
   Next
      FormatStyle2 = StyleSVG
End Function

#Undef CR_LF
#UnDef DQ

'   ---------END-------------------

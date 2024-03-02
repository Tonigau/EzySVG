'   TestSVG_1.bas  - Freebasic Code

'Example for ezySVG Library
'   This code is just a list of examples to show usage, it's not meant to be a structured program.
'   Makes SVG in the app run folder.  
'   To see result, click on the output .html file or drop on browser. 'View Page Source' to check/debug SVG code 
'   All drawing is done in the SVG ViewBox that sits on the virtual canvas default top left, the size & offset is set in  'SVG_Start'
'   The SVG contains Elements (Line, rect, circle etc...) & they each have parameters(values) for position, size etc.
'   Elements also have other attributes & style attributes. 

'     Many style attributes are optional & often have a default value (some may result in an Element part not rendered.) 
'     Be mindful tha not all SVG render apps are equal, what works in 1 may not in another.

'    To set style attributes you refer to SVG style reference, same when using named colors (CSS)
'    Typically all Style attributes are lower case, however you may use first letter Ucase for clarity but a few need to be case sensitive
'    such as stroke-dasharray must be Lcase(tested in fireFox), some have Ucase parts. Just lookup a reference to be sure.

'     Most values can have space or comma separator,     stroke=rgb(130 130 130) stroke=rgb(130,130,130) <- both are valid in ezySVG lib
'     Only parameters with more than 1 value have brackets &  "," or " " separators.
'     with the exception of stroke-dasharray=(3,5)  or =(3 5) or =3 5 
'		Rotate(in style string) has 2 modes Rotate=-12 uses default Element point Rotate=(-12,100,220) uses points set.                      

'   Sometimes when drawing an Element or making changes, it seems to disapear but it could just be outside the viewbox
'   somewhere on the canvas (canvas has no size limit) or there is a typo.

' Color values(RGB) are string either  #C0FFE9 or RGB(255,89,130)
' Element position & size values are number(long), Element attributes are string, Style is a string
' Style string has optional left part (non style attributes) with separator "__"(Double Underscore). 
' These are for Transform & additionakl Element attributes.

'   V0.90 2024-02-15   

#Define L_Case       ' Use to turn on Lcase formatting of SVG Style Names (must be before #Include "ezySVG.bi")
#Include "ezySVG.bi"
 
 Dim As String  TempStr, StyleStr
 Dim As UInteger VboxSizeX, VboxSizeY, Lp1
 Dim As Uinteger FillCol, LineCol, LineW, X, Y
 Dim As String SVGstyle, HexRGB1, HexRGB2
   Dim As string PolyPoints, PathPts, TxtStr
   Dim As Integer PolyMid(1 To 10) ' polygon virtual bounding box(MinMax & CTR)
   Dim As Integer XS, YS, Rote, SkewXval, SkewYval

'  Open "debug2.txt" For Output As #5

   VboxSizeX = 1000
   VboxSizeY = 500
Const CR_LF = Chr(13,10)
Const    DQ = Chr(34)
Const html_ = "html" ' choose "svg in html"  
'Const html_ = ""    '      or "svg"
      
'      SVG_Start("TestSVG_1.SVG", VboxSizeX, VboxSizeY, -500, -250, "html") ' with offset
      SVG_Start("TestSVG_1.SVG", VboxSizeX, VboxSizeY, 0, 0, html_)
     'SVG_Start("TestSVG_1.SVG", VboxSizeX, VboxSizeY, 0, 0)
'      SVG_Rect(-20, -20, 20, 20, "rx=5, ry=5_fill=silver, stroke=black, stroke-width=2")   ' test offset

       ' Rectangle to fit SVG ViewBox
       StyleStr = "Fill=Silver, stroke=black, stroke-width=2"', fill-opacity=1, stroke-opacity=1"
       SVG_Comment("   This rect fills the ViewBox", 1)
       SVG_Rect(0, 0, VboxSizeX, VboxSizeY, StyleStr) 
        SVG_CRLF  '<- put a newline in SVG code to improve structure (no effect on graphic)
       SVG_Line(VboxSizeX/2, 0, VboxSizeX/2, VboxSizeY, "stroke=rgb(130 130 130), stroke-width=1, stroke-dasharray=(8,12)")
       SVG_Line(0, VboxSizeY/2, VboxSizeX, VboxSizeY/2, "stroke=rgb(130,130,130), stroke-width=1, stroke-dasharray=(8 12)")
        SVG_CRLF
       ' Text at ViewBox X centre
       TempStr = "ezySVG Test  2024.02.11"
       SVG_Text(VboxSizeX/2, 25, TempStr,  "font-family=verdana, font-size=18px, Font-Weight=bold, fill=navy, text-anchor=middle",,1)
      ' various Text styles
      SVG_Text(25, VboxSizeY/2, "Rotate Left (middle anchor)", "text-anchor=middle",-90)
      SVG_Text(VboxSizeX-25, VboxSizeY/2, "Rotated Right (middle anchor)", "font-family=verdana, fill=purple,  text-anchor=middle",90)   
      SVG_Text(520, 75, "Text - Outline only", "font-family=verdana, font-size=24px, Font-Weight=bold, Fill=none, Stroke-width=1, stroke=black")
      SVG_Text(10, VboxSizeY-10, "If viewing this graphic in a web browser, view page source to see SVG code(syntax color'd)", "font-style=italic ,font-size=12px")
      SVG_Text(1,10, "0,0", "Font-style=italic ,font-size=12px")
      SVG_Text(501,260, "500,250", "Font-style=italic ,font-size=12px")      
       SVG_CRLF
      SVG_Comment(" some lines...")
      ' 2nd line is rotated 5deg.
      SVG_Line(10, 40, 200, 40, "stroke=green, stroke-width=2")   
      SVG_Line(600, 40, 700, 40, "stroke=green, stroke-width=2",5) 

'-----------------------------      
      ' Apply style to a group  
      SVG_Comment("   This is a style group", 1)
      StyleStr = "stroke=blue, stroke-width=2, stroke-dasharray=(8,2)"   
      SVG_Group(StyleStr) ' group start
         For Lp1 =  60 To 100 Step 10
            If Lp1 = 80 Then StyleStr = "Stroke=Purple, stroke-width=3, stroke-dasharray=0" : Else StyleStr = "" 
            SVG_Line(10, Lp1, 200, Lp1, StyleStr,,0)  ' set the Style format "0" adds indent
         Next
      SVG_Line(10, 110, 200, Lp1,"rotate=5, scale=1.5__Stroke=yellow, Stroke-Width=1, stroke-dasharray=(3,5)",,0)' override group style for this element
      SVG_Group("End")           ' group close - End or Null param   

      SVG_Text(10, 125, "6 lines above are in a style group,  2 lines have style override", "font-size=12px",5)
      SVG_Line(230, 40, 475, 90, "stroke=red, stroke-width=5") 

'-----------------------------
      ' Rectangle  rounded corners & fill transparancy 60%
      StyleStr = "fill=#C0E2D5, stroke=black, stroke-width=2, fill-opacity=0.6"' , stroke-opacity=1"
      SVG_Rect(250, 40, 200, 50, StyleStr)
      
      
      LineW = 1 : LineCol = 24000  ' LineCol might come from a color map
      FillCol = 764345
      HexRGB1 = "#" + Hex(FillCol,6)
      HexRGB2 = "#" + Hex(LineCol,6)                                  '                
'Print #5, "FillCol "; FillCol; "  "; HexRGB1      
      SVG_Ellipse(80, 180, 25, 15, "fill=#E2C0D5, Stroke=RGB(00,175,255), Stroke-Width=" +Str(LineW+2) )
      SVG_Ellipse(80, 220, 25, 15, "fill=#E2C0D5, Stroke=RGB(00,75,255), Stroke-Width=2",45)     ' rotated 45deg
      SVG_Circle(160, 200, 25, "fill=#E2C0D5, Stroke=RGB(00,00,255), Stroke-Width=3")
      SVG_Circle(200, 200, 30, "fill=none, stroke=black, stroke-width=2, Stroke-opacity=0.5")    ' outline only
      SVG_CRLF


'-------------------------------------------------------      
      ' These lines have variables for each attribute value   
            SVGstyle = "stroke=" +HexRGB2 +", Fill=" +HexRGB1 +", stroke-width=" +Str(LineW)
      '     SVGstyle = "stroke=#" +Hex(LineCol,6) +", Fill=#" +Hex(FillCol,6) +", stroke-width=" +Str(LineW)
      
      '------------------------------------------------------
      ' Using SVG_StyleRet1() may be easier...
      ' !!! Dont mix Style Left__right parts
      SVGstyle = SVG_StyleRet1("stroke=" +HexRGB2, "Fill=" +HexRGB1, "stroke-width=" +Str(LineW))
      'SVG_Line(45, 373, 500, 373, SVGstyle)
      SVG_Rect(950, 45, 30,8, SVGstyle)    
      
      ' Using SVG_StyleRet2() may be easier... but not many attributes
      ' !!! Dont mix Style Left__right parts
'      SVGstyle = SVG_StyleRet2("Rotate=", Rote, "Skew=", SkewXval, "stroke-width=", LineW, "Stroke-Opacity=", 0.6)
      SVGstyle = SVG_StyleRet2("stroke-width=", LineW, "Stroke-Opacity=", 0.6)
      SVG_Line(45, 371, 500, 371, SVGstyle +", stroke=red")
      SVG_Line(45, 372, 500, 372, SVGstyle +", stroke=green")  '< Note the comma in string for additional style
      SVG_Line(45, 373, 500, 373, SVGstyle +", stroke=blue")
      '------------------------------------------------------
      
      SVG_Text(950, 30, " Some tiny text to see", "font-size=3px") ' SVG does not do multiline text !!! (CRLF not work) 
      SVG_Text(950, 35, " Zoom in to read","font-size=3px")   
      SVG_Text(950, 40, " SVG Doesnt do MultiLine Text!","font-size=3px")

      Rote = 20
   PolyPoints = "350,100 379,181 469,161 397,215 423,301 350,250 277,301 303,215 231,161 321,181"
   SVG_Polygon(PolyPoints, "fill=none, stroke=red, stroke-width=1, stroke-dasharray=(2,3)")
   SVG_Polygon(PolyPoints, "fill=none, stroke=blue, stroke-width=1, stroke-dasharray=(4,8)",Rote)
   SVG_Polygon(PolyPoints, "Rotate=-12__fill=none, stroke=green, stroke-width=1, stroke-dasharray=(4,4)") ',Rote-8
   'Polygon & PolyPoints are very similar. PP need extra point to close, Both need fill=none for line only.
   SVG_Text(350, 340, "PolyGon (rotated)", "font-size=13px")
   
   SVG_Comment("   Poly Line", 1)
   'PolyLine
   SVG_PolyLine("300,400 350,450 400,400 300,400", "Rotate=(2,350,450)__stroke=blue, stroke-width=2")
   '                                                In above fill is not specified so default is fill=black 
   '                                                Rotate origin is specified
   SVG_PolyLine("300,400 350,450 400,400 300,400", "Rotate=90__stroke=yellow, stroke-width=1, fill=none")
   '                                                Rotate origin is not specified (uses polypoints xy mid)
   SVG_Text(400, 465, "PolyLine", "font-size=13px")
   
   '  Testing PolyMid
      SVG_GetPolyMid(PolyPoints, PolyMid()) ' get polygon/polyline centre & XY min/max (bounding box)
      XS = 40 : YS = 40 
      SVG_Rect(PolyMid(1)-XS/2, PolyMid(2), XS, YS, StyleStr, 45) '< put a rectangle in the polygon centre
      SVG_Circle(PolyMid(1), PolyMid(2), 5, "fill=none, stroke=black, stroke-width=1, Stroke-opacity=0.9")
   
   SVG_Comment("   Quad Bezier curve",1 )  ' 3 points (X1, Y1, X2, Y2, QX, QY)
'/'
 Rote = 15
   StyleStr = "stroke=white, stroke-width=3, fill=none"
   SVG_Qbezier(520, 150, 560, 30, 620, 150, "stroke=black, stroke-width=2, fill=purple, Fill-opacity=0.4", Rote)
   SVG_Qbezier(520, 150, 570, 150, 620, 150, StyleStr, Rote)
'/   
   
'   SVG_Qbezier(520, 150, 560, 30, 620, 150, "stroke=black, stroke-width=2, fill=purple, Fill-opacity=0.4")
'   SVG_Qbezier(520, 150, 570, 150, 620, 150, "Rotate=(12,520,150)__stroke=white, stroke-width=3, fill=none")
   
              ' Str(Y2-(Y2-Y1/2)
''SVG_Path("M620,150 Q650,70 680,150" ,StyleStr) ' see Test Qbezier.bas

   SVG_Text(520, 190, "Quad Bezier curve (1 control point)", "font-size=13px")
   SVG_Text(520, 205, "Rotated 15deg. with fill &#38; Baseline", "font-size=13px") ' Note: &#38; = "&" (& is illegal chr)
   
   SVG_CRLF
   SVG_Rect(700, 100, 80, 40, "rx=8, ry=8__fill=darkblue, stroke=green, stroke-width=3") ' Note the radius attributes 
   SVG_Rect(800, 100, 80, 40, "rx=8, ry=8, SkewX=10__fill=none, stroke=black, stroke-width=1") '  in Transform part (left of separator "__")
   
   SVG_Comment("SVG Paths", 1) ' SVG Path (point values would typically be produced from geometric/math code)
   PathPts =    "  M 213,7" +CR_LF _
               +"  c -32-14-74,0-88,30" +CR_LF _
               +"  C 110,5,67-9,36,6" +CR_LF _
               +"  z"

      PathPts = "M 213,7" +" c -32 -14 -74,0 -88,30" +"  C 110,5,67 -9,36,6" +"  z" ' z = line to start point
   SVG_Path(PathPts, "Fill=none, Stroke=black")
    
   '   This path has the same xy points but is translated(moved) to Y= 420 * has rotate applied
   SVG_Path("M 213,7 c -32 -14 -74,0 -88,30 C 110,5,67 -9.5,36,6", "Rotate=(15,213,7), translate=(0,440)__Fill=none, Stroke=blue")
   SVG_Text(50, 465, "Path(2x C.Bezier curve)", "font-size=13px")
   ' Path points are like polyline & polygon points in that the previous segment end point is the next segment start point.
   ' this can be a bit hard to "see" the segment values when the type changes(line to bezier) especially Cubic beier.
   ' In above there are 3 line segments followed by 2 Quadratic(1 ctrl pt) bezier curves.
   ' Typically Ucase type(M L Q) is explicit point & Lcase type(m l q) is relative to previous point.
   
   '                                        BZstrt    BZctrl  BZEnd
   '               Moveto   Lineto  Lineto  Lineto            BZstrt  BZctrl  BZEnd
   PathPts = "M 50,300 L 100,300 120,325 150,325 Q 175,300 200,325 225,350 250,325" 'z"   (z is line to start)  
   SVG_Path(PathPts, "Fill=none, Stroke=black")
   SVG_Text(50, 355, "Path(3x lines, 2x Qbezier curve", "font-size=13px")
   SVG_Path("M 500,220 L 500, 280 M 470,250 L 530,250", "Fill=none, Stroke=black") ' crosshairs
   SVG_Path("M 100,400 Q 175,375 200,400 175,425 100,400", "Fill=none, Stroke=blue")
   SVG_CRLF
   
   '                     preserveAspectRatio xMinyMin, xMaxyMax not working !
   ' Raster Image
   SVG_Comment("    Raster Image in SVG",1)
   Dim As String FilePath = "" '"d:\Data\FBedit\DataGraph\"  ' full path
   Dim As String FileName
 ' choose your image source Filename (local or online)
'      FileName = "mdn_logo_only_color.png"                               ' file name only (img in Test ezySVG_1exe run folder)
     FileName = "https://i.postimg.cc/qqT64fy9/mdn-logo-only-color.png" ' online res
   SVG_Rect(550, 280, 150, 200, "Fill=none, Stroke=grey, stroke-dasharray=(1,3)") ' Just for ref.
   SVG_Image(550, 280, 150, 200, , FilePath +FileName, 0) 'Param 5: KeepAspect is default, or "none" to fit XY 
   SVG_Text(550, 475, "Raster image", "font-size=13px")
   

   ' Text on Path
   TxtStr = "Text Along a Path - Cool" 
   SVG_Comment("    Text on a Path",1)
   PathPts = "M 700,325 Q 750,300 800,325 850,345 900,325"
   SVG_TextPath("Path1" , PathPts, "Fill=none, Stroke=blue, stroke-width=1, stroke-dasharray=(2,2)", TxtStr, "font-size=17px",8)
   
   ' Drop Shadow
   SVG_Comment("    Drop Shadow effect",1)
   SVG_DropShadow("DSf1", "grey", 5, 10, 2)  
   SVG_PolyLine("700,230 750,230 770,210 728,210 700,230", "filter=url(#DSf1), stroke=brown, stroke-width=1, fill=navy, fill-opacity=0.75")
   
   ' GaussianBlur
   SVG_Comment("    GaussianBlur effect",1)   
   SVG_GaussianBlur("GB1", 2, 2, 0.35) '(filter ID, Xoffset, Yoffset, blur)
   ' applied to a text Element to create DropShadow
   SVG_Group("text-anchor= middle, font-size=24px font-weight=bold, font-family=verdana")
    SVG_Text(820, 270, "TextShadow using GaussianBlur", "filter=url(#GB1), fill=#505050",,0) '< This is the shadow
    SVG_Text(820, 270, "TextShadow using GaussianBlur", "fill=navy",,0)     
   SVG_Group
'           Alternately we can set filter X Y offset=0 & position the shadow text

   ' Linear Gradient
   SVG_Comment("    Linear Gradient Fill",1)
   SVG_GradientL("Grad1", "blue", "red", 0, 100, 0, 100, 0, 0)
   SVG_DropShadow("DSf1", "grey", 12, 12, 1.5)
   SVG_Ellipse(850, 400, 100, 50, "fill=url(#Grad1), filter=url(#DSf1)",,2)
   SVG_Circle(850, 400, 30, "fill=url(#Grad1), stroke=black, stroke-width=2, Stroke-opacity=0.5",,2) 
   ' The chr case for ID name must match. ie: "Grad1" set & use "ul(#grad1)" will fail.
   
'   SVG_Text(750, 475, "Gradient Fill &#38; Drop Shadow", "font-size=13px")
   SVG_Text(750, 475, "Gradient Fill & Drop Shadow", "font-size=13px")
   SVG_Text(825, 200, "skewX Transform", "font-size=13px")
      
   SVG_CRLF
   'SVG_End("html")
   SVG_End(html_)
   'SVG_End()
   
 '  Beep   ' I am done  
 
' Close #5  '< DEBUG


End

' These 2 lines result in same SVG code
'     SVG_Line(600, 40, 700, 40, "stroke=green, stroke-width=2", 5)   or
'     SVG_Line(600, 40, 700, 40, "Rotate=5__stroke=green, stroke-width=2") note the underscore separator before style attributes.
   

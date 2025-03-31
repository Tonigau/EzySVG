' Read CSV Data file & plot values (max. 4ch)									ToniG 2023-12-11  V0.5
' This File is PRELIMINARY, Testig/Dev only
' There is no UI at this time, so options settings are hard coded or in the input file.

' This is an example for ezySVG lib
' Freebasic code

' ToDoo:
'			Round MaxScale to nearest 10 greater than MaxVal_ch.. - Done
'			Add Ch Type text - Done
'			Add Xaxis neme text - Done
'        Option to use last(or any) CSV data ch for X axis values, need to pick values out of x (may not be linear)
'        Runtime Error checking
'        If full screen, restore to FS (don't recenter)
'        Some more
'        
'			
'Issues
'-------------------------------			
'    
'    ?bug  in window9  BoxDraw "PS_INSIDEFRAME" always enabled
'    some stuff still hard coded for now...
'    portion of window wiped when move off screen
'    option to link MaxScale's, use largest MaxVal. (check boxes)
'    when window size shrunk, data does not fill (might be integer scale issue)
'    Line above Y TickVals smashes top value at some window size.
'    Ch names need more vertical separation - Done
' Y TickVals need format (to many digits after DP


#Include "window9.bi"
#include "vbcompat.bi"
#include "makesvg.bi"
'#Include "CSScolorNames.bi"  '< (some of these CSS/SVG names are a bit stupid)
'#Include "ReadCSV2.bi"

'Graph window              ' Shared Var vars - modify/use value in any sub.
Dim Shared As HWND hwnd
Dim As Integer event
Dim Shared As UInteger Form1SizeX, Form1SizeY
Dim Shared As UInteger Graf1PosX, Graf1PosY, Graf1SizeX, Graf1SizeY, Graf1EndPosX, Graf1EndPosY, TickLenX, TickLenY, GridX, GridY
Dim Shared As UInteger MaxVal_ch1, MaxVal_ch2, MaxVal_ch3, MaxVal_ch4, MaxVal_chX, MaxCnt_X, MarginY2
Dim Shared As UInteger ch1_Yscale, ch2_Yscale, ch3_Yscale, ch4_Yscale, chX_Yscale, RGB_, BGR_, LineW
Dim Shared As BOOLEAN   Init_State ', XfitWidth, X_DataEN
Dim Shared As UByte  XfitWidth, X_DataEN, SVG_EN
Dim Shared As UByte X_DataCh, OptionNum ' chn to use for X, option btn set
ReDim Shared As UByte ChkState(30)   ' chk btn state
'ReDim Shared As String SVGplotLine(10)

' Data processing
Dim Shared As String CSVline, CSVfilename, TempStr, XaxisName
ReDim Shared As String CSVdata(1000, 10) '
''Dim Shared As String CSVdata(1000, 10) '< TESTING issue
ReDim Shared As String chNames(10)
ReDim Shared As String chType(10)
ReDim Shared As Integer MaxVal(10)
ReDim Shared As Integer MaxScaleY(10)
ReDim Shared As UByte ch_on(10)      'enable/disable data channels
Dim Shared As Integer LineCnt, CSVLineCnt, ChCnt, ScaleX, nSamples, SkipSampl, SkipImgX
Dim Shared As Integer CSVcnt
'Dim Shared As String SVG_Style
'Dim As String SVG_Style

'Dim Shared As Ubyte FnumSVG
'ReDim Shared As String SVGplotLine(10)

'Dim Shared As Boolean GetData
 


Declare Sub DrawGrid         : Declare Sub DrawGraphBox : Declare Sub DrawTicks : Declare Sub DrawData
Declare Sub DrawTickVaL      : Declare Sub ReadCSV(Fnum As Integer, GetData As Boolean) : Declare Sub GetCSV
Declare Sub ReSizeGraph
Declare Sub RGB_BGR          : Declare Sub Set_chColor(Chn As UByte)
Declare Sub Get_ChInfo
Declare Sub DrawChName       : Declare Sub DrawChMaxVal
Declare Sub CreateGadgets
Declare Sub SetGadget_States : Declare Sub SetGadget_Color
Declare Sub BtnClicked(Btn_n As Integer)
Declare Sub Tool_Tips
Declare Sub ClearOptionBtn
Declare Sub ReloadData
Declare Sub SaveSettings     : Declare Sub ReadSettings
Declare Sub GetUI_Data       : Declare Sub SetUI_Data

'Declare Sub ReSizeGraph (Form1SizeX As Long, Form1SizeY As Long) 
'Declare Sub ReSizeGraph '(Form1SizeX, Form1SizeY) 

' CSS ColorNames(RGB),  Use here For now...  
   Const red        = &hff0000
   Const blue       = &h0000ff
   Const green      = &h008000
   Const darkviolet = &h9400d3
   Const silver     = &hc0c0c0 
   Const darkgrey   = &ha9a9a9 
   Const black      = &h000000
   Const navy       = &h800000
'-------------------

   Const Ch1 = 1   ' Unused
   Const Ch2 = 2
   Const Ch3 = 3
   Const Ch4 = 4
   Const Ch5 = 5
'   Const ChX_EN = 5
   Const CR_LF = Chr(13,10)
   Const DQ = Chr(34)
   Const TRUE_ = 1
   Const FALSE_ = 0 


'Init values & defaults (some re-set in resize)
'-------------------
''FormWidth = 1025 : FormHeight = 560
   Form1SizeX = 1500
   Form1SizeY = 600
   Graf1PosX  = 75
   Graf1PosY  = 100
   MarginY2 = 50
   TickLenX = 10
   TickLenY = 10 ' Graph Ticks
   MaxCnt_X = 2675  ' Just used for X scale (for now)

'Hard Code/init UI inputs
'-----------------------
   GridX = 30 ' num of grid lines
   GridY = 10

   LineW = 2
   XfitWidth = TRUE_  'Fit data to graph width
   X_DataEN = FALSE_
   ch_on(1) = TRUE_   'data channels enabled (Or found)
   ch_on(2) = TRUE_
   ch_on(3) = TRUE_
   ch_on(4) = FALSE_
'   CSVfilename = "TestData-PV_Pnl_2.csv"
'   CSVfilename = "AirCon 1 Cycle.csv"
'-------------------
   ' untill get from ini     Can set All on, then read file finds ch exist & set.
   ChkState(Ch1) = 1   ' enable plot ch 
   ChkState(Ch2) = 1
   ChkState(Ch3) = 1
   ChkState(Ch4) = 0
   ChkState(5) = 1     ' fitwidth
   ChkState(6) = 0     ' en Xdata



/'
Enum CheckBoxGadget
    Chek1 = 1
    Chek2 = 2
    Chek3 = 3
    Chek4 = 4
End Enum

Dim Shared CheckBox As CheckBoxGadget    
'/



Open "debug2.txt" For Output As #5

'--------------Main-----------------
   GetCSV
   MaxCnt_X = CSVlineCnt
   ReadSettings
   hwnd=OpenWindow("DataGraph",10,10,Form1SizeX,Form1SizeY)  ' WM_Message 'EventSize' sent from OpenWindow
   CenterWindow(hwnd)

   'Init_DebugPrint
   Init_State = True  '(app start)
 
    Do
         'event=WindowEvent() '< CPU hungry
         Var event=WaitEvent

      Select Case event
      
      	Case EventSize 'WM_SIZE     graph window size_changed
            If EventHwnd=hwnd Then 
             'If EventHwnd=hwnd Then ReSizeGraph (WindowWidth (hwnd), WindowHeight(hwnd))
             'Form1SizeX = WindowWidth(hwnd) : Form1SizeY = WindowHeight(hwnd)
              ReSizeGraph 
            EndIf
         Continue Do 'need?
   
         Case EventClose
            If Event=EventClose Then
            	SaveSettings
               End
            EndIf
    
''          Close #FnumDEBUG
   
         Case EventGadget
            Select Case EventNumber() ' WM_LBUTTONUP (Gadget n)
               ' CheckBoxes
            	Case 1 : BtnClicked(EventNumber()) ' ch1
            	Case 2 : BtnClicked(EventNumber()) ' ch2
            	Case 3 : BtnClicked(EventNumber()) ' ch3
            	Case 4 : BtnClicked(EventNumber()) ' ch4
            	Case 5 : BtnClicked(EventNumber()) ' FitWidth Data->Graph
            	Case 6 : BtnClicked(EventNumber()) ' X scale from chn Data 
            	Case 7 : BtnClicked(EventNumber()) ' Enable Make_CSV
               ' Option Buttons   ' Also event when other option buttons cleared by API? (just curious)
            	Case 101 : BtnClicked(EventNumber()) '    
            	Case 102 : BtnClicked(EventNumber()) '
            	Case 103 : BtnClicked(EventNumber()) '
            	Case 104 : BtnClicked(EventNumber()) '
            	Case 105 : BtnClicked(EventNumber()) '

            	Case 201 : BtnClicked(EventNumber()) 'Reload Button

            End Select
      End Select 
    Loop
'----------------End Main--------------------




' All buttons
Sub BtnClicked(Btn_n As Integer)  ', 1,2,3,4 are chn_on, 5 is Fitw, 6 is X from ch, 101 - 105 is XaxisDataSource
   
   Select Case Btn_n                      '(Gadget n)
      Case 1 To 99  'CheckBox's     
         ChkState(Btn_n) = 0 :  'X_DataEN = 0 'XfitWidth = 0  
         If GetGadgetState(Btn_n) =1 Then  
            ChkState(Btn_n) =1            ' (Used to restore after window resize)
         Else
            If Btn_n = 6 Then ClearOptionBtn ' if Btn_6 cleared
         End If
            If Btn_n < 5 Then Ch_ON(Btn_n) = ChkState(Btn_n) 
            If Btn_n = 5 Then XfitWidth = ChkState(Btn_n)'  state set 0 or 1 
            If Btn_n = 6 Then X_DataEN = ChkState(Btn_n) ' 
            If Btn_n = 7 Then SVG_EN = ChkState(Btn_n)   '
            'If X_DataEN = 0 Then  ClearOptionBtn
'            : Else X_DataEN = 0 : EndIf   ' enable Xaxis data from ch
            SetGadgetText(52,"SVG_EN=" + Str(SVG_EN)+CR_LF + _
                             "XfitWidth=" + Str(XfitWidth)+CR_LF + _
                             "X_DataEN=" + Str(X_DataEN))             '<DEBUG
            
   	Case 101 To 105 ' OptionBtn's (used for XaxisDataSource)
         OptionNum = 0 :  X_DataCh = 0
         If GetGadgetState(Btn_n)=1 Then
         	OptionNum = Btn_n             ' (Used to restore after window resize) 
            If ChkState(6) = 1 Then X_DataCh = Btn_n-100 Else ClearOptionBtn 
         EndIf
''SetGadgetText(52,"X_D_Ch=" + Str(X_DataCh))'Str(Ch_ON(Btn_n))) '< TESTING ONLY
 
      Case 201 'To 202 ' PushButtons
         ReloadData
   End Select
''      SetGadgetText(51,"Btn_n=" + Str(Btn_n) + "(" + Str(GetGadgetState(Btn_n)) +")")'<TEST ONLY
''      SetGadgetText(53, Str(Btn_n) + "_" +  Str(ChkState(Btn_n)))
'      SetGadgetText(52,"XfitW=" +  Str(Ch_ON(Btn_n)))
End Sub  

' Update values from UI input boxes
Sub GetUI_Data
	GridX = Val(GetGadgetText(301))
   GridY = Val(GetGadgetText(302))
   LineW = Val(GetGadgetText(303)) 
   CSVfilename = Trim(GetGadgetText(304))  
End Sub

Sub SetUI_Data
	SetGadgetText(301, Str(GridX))
   SetGadgetText(302, Str(GridY))
   SetGadgetText(303, Str(LineW))
   SetGadgetText(304, CSVfilename)
End Sub


Sub ReloadData
	GetUI_Data
	GetCSV
	If SVG_EN = 1 Then SVG_Start(CSVfilename, Form1SizeX+30, Form1SizeY, "html")
	ReSizeGraph
	If SVG_EN = 1 Then SVG_end("html")
End Sub


Sub ClearOptionBtn
   Dim As UByte Lp1
     SetGadgetState(OptionNum,0)   
     OptionNum = 0
   X_DataEN = 0
   X_DataCh = 0
End Sub


' for TESTING ONLY
/'
Sub ButtonClik
   Dim Var1 As Long
	Var1 = Val(Trim(GetLineTextEditor(52,0)))
   Var1 +=1
   SetGadgetText(52,Str(Var1))
End Sub
'/
'----------------------------

' Shared Var Modify: TempStr Form1SizeX Form1SizeY  Graf1SizeX Graf1SizeY Graf1EndPosX Graf1EndPosY
Sub ReSizeGraph '(Form1SizeX As Long, Form1SizeY As Long)
     Dim As ULong Graf1MidPosX 
     Dim As UShort Txt_L 
     Dim As String SVGStyle
     
     Form1SizeX = WindowWidth(hwnd)-20 : Form1SizeY = WindowHeight(hwnd)-50 '(values larger than actual?)
   '  Form1SizeX = WindowWidth(hwnd) : Form1SizeY = WindowHeight(hwnd)
     Graf1SizeX = Form1SizeX - (Graf1PosX * 2) 
     Graf1SizeY = Form1SizeY - (Graf1PosY  + MarginY2)    
     Graf1EndPosX = Graf1PosX + Graf1SizeX : Graf1EndPosY = Graf1PosY + Graf1SizeY
     Graf1MidPosX =  (Graf1SizeX/2)-Graf1PosX
      
   WindowStartDraw(hwnd,,,,)                  ' whole window
      FillRectDraw(1,1,silver)                ' form BG color (1,1 is xy pixel pos)
  	   SVGStyle = "Rx=10, Ry=10, fill=silver, stroke=black, stroke-width=2, fill-opacity=1, stroke-opacity=1"
  	   SVG_Rect(0, 0, Form1SizeX+30, Form1SizeY, SVGStyle,0)
'  	   SVG_Rect(X As Long, Y As Long, Width As Long, Height As Long, Rx As Long, Ry As Long, Style As String = "", SVG_GR As UByte= 0)
  	  ' Print #FnumSVG, "<rect x=""" + Str(0) + """ y=""" + Str(0) + """ width=""" + Str(Form1SizeX+30) + """ height=""" + Str(Form1SizeY) + DQ ' SVG
	   'Print #FnumSVG, "style=""fill:silver;stroke:black;stroke-width:2;fill-opacity:1;stroke-opacity:1"" />" + CR_LF                     ' SVG

      TempStr = "Solar PV Panel Volt Amp Power plot VS Resistance Load"
      Txt_L = Graf1MidPosX - (Len(TempStr)/2)*5 ' close enuf
   '   TextDraw(Txt_L,Graf1PosY-30, TempStr,-1,&h000000)
  SVG_Text(Txt_L, Graf1PosY-50, TempStr, "font-family=verdana, font-size=18px, Font-Weight=bold, Fill=navy", 0) 
''      SVG_Text(Txt_L, Graf1PosY-50, TempStr, "verdana", "18px", "bold", "navy", 0)
      TempStr = "DataPlot: " + CSVfilename
      TextDraw(Graf1EndPosX/2-100,Graf1PosY-18, TempStr,-1,&h000000) ' (-25 is half text with)
  SVG_Text(Graf1EndPosX/2-100,Graf1PosY-10, TempStr, "font-family=verdana, font-size=14px, Font-Weight=bold, Fill=navy", 0)
''      SVG_Text(Graf1EndPosX/2-100,Graf1PosY-10, TempStr, "verdana", "14px", "bold", "navy", 0)
      BoxDraw(Graf1PosX, Graf1PosY, Graf1SizeX, Graf1SizeY, &hffffff, &hfffae9, 1,PS_NULL, 250) 'no border
'     BoxDraw(Graf1PosX, Graf1PosY, Graf1SizeX, Graf1SizeY, &h000000, &hfffae9, 4,PS_INSIDEFRAME, 250) ' testing for invert option

      DrawGraphBox      '< (used while issue with PS_INSIDEFRAME)    'PS_INSIDEFRAME seems to be always active!
      DrawGrid
      DrawTicks
      DrawTickVaL
      DrawChName
      DrawChMaxVal  
      DrawData

'      If Init_State = TRUE Then CreateGadgets : Init_State = FALSE  ' reload Butn won't redraw
      CreateGadgets
      SetGadget_Color
      SetGadget_States 
   StopDraw ' finish drawing 
      Tool_Tips
      SetUI_Data
'If Init_State = TRUE Then SetUI_Data : Init_State = FALSE 
End Sub
' Info: It seems StartDraw needs to be active for SetGadgetColor (check/option buttons, TextGadget)

Sub CreateGadgets
   Dim As Long  Ypos1, L_Pos1, L_Pos2, L_Pos3, L_Pos4, L_Pos5, L_Pos6, BtnSpc1 'PosX,
   Dim As Long R_Row1, R_Row2, R_Row3, R_Row4, R_Row5
   Dim As UByte Lp1
'   Dim As String TmpStr
'   Dim As Boolean TempBit
   BtnSpc1 = 60 : Ypos1 = 7 
   L_Pos1 = Graf1PosX+50 : L_Pos2 = L_Pos1 +150 : L_Pos3 = L_Pos2 + (BtnSpc1*7)-30 : L_Pos4 = L_Pos3 + (BtnSpc1*2)+30 
   'L_Pos5 = L_Pos4 + BtnSpc1 : L_Pos6 = L_Pos4 + BtnSpc1
   R_Row1 = Graf1EndPosX-100 : R_Row2 = R_Row1 - 80 : R_Row3 = R_Row2 - 200 : 
   'Graf1EndPosX 130
   
   ButtonGadget(201,L_Pos2 +BtnSpc1*5,Ypos1+20,60,30,"Refresh",BS_PUSHBUTTON ) ' This buttn does not redraw
                                                                              ' maybe needs a set or color to redraw ?

	If Init_State = TRUE Then           ' Only on form load
	   'ch CheckBox's
	   CheckBoxGadget(1,L_Pos2,Ypos1+15,46,10,"ch1")
	   CheckBoxGadget(2,L_Pos2 +BtnSpc1*1, Ypos1+15,46,10,"ch2")
	   CheckBoxGadget(3,L_Pos2 +BtnSpc1*2,Ypos1+15,46,10,"ch3")
	   CheckBoxGadget(4,L_Pos2 +BtnSpc1*3,Ypos1+15,46,10,"ch4")
	   CheckBoxGadget(5,L_Pos1,Ypos1,90,10,"Fit Width X")
	   CheckBoxGadget(6,L_Pos1,Ypos1+35,130,10,"X axis from  ---->")
	   CheckBoxGadget(7,L_Pos2 +BtnSpc1*5,Ypos1,90,10,"Make SVG")

	   ' OptionButton's
	   OptionGadget(101,L_Pos2,Ypos1+30,40,12)
	   OptionGadget(102,L_Pos2 +BtnSpc1*1,Ypos1+30,40,12)
	   OptionGadget(103,L_Pos2 +BtnSpc1*2,Ypos1+30,40,12)
	   OptionGadget(104,L_Pos2 +BtnSpc1*3,Ypos1+30,40,12) 
	   OptionGadget(105,L_Pos2 +BtnSpc1*4,Ypos1+30,40,12,"")
	
	   TextGadget(355, L_Pos2 +BtnSpc1*4,Ypos1+12,30,15, "ch5")   
	   GroupGadget(41,L_Pos2-10,0,245,60,"Plot Data channel") 
	'   ButtonGadget(201,L_Pos2 +BtnSpc1*5,Ypos1+20,60,30,"Reload",BS_PUSHBUTTON )
	   
	   ' InputBox's
	   StringGadget(301, L_Pos3+80, Ypos1+10,50,20, Str(GridX),ES_NUMBER) ' Grid X value inputBox
	   StringGadget(302, L_Pos3+80, Ypos1+35,50,20, Str(GridY),ES_NUMBER) '      Y
	   
	   StringGadget(303, L_Pos4+80, Ypos1+10,100,20, "LineWidth", ES_NUMBER)     ' Data FileName
	   StringGadget(304, L_Pos4+80, Ypos1+35,300,20, "FileName", ES_AUTOHSCROLL) ' Graph data Line width
	   
	
	   ' Names for InputBox
	   TextGadget(351, L_Pos3, Ypos1+13,70,16,"GridCnt X", SS_RIGHT)
	   TextGadget(352, L_Pos3, Ypos1+37,70,16,"GridCnt Y", SS_RIGHT)
	   TextGadget(353, L_Pos4, Ypos1+13,70,16,"Plot Line", SS_RIGHT)
	   TextGadget(354, L_Pos4, Ypos1+37,70,16,"Input File", SS_RIGHT)
	
	
	'   StringGadget(2,10,50,100,20,"96754",ES_RIGHT Or ES_NUMBER)
	   
	   'TESTING ONLY
'/'	
'      EditorGadget(51,Graf1EndPosX-400,Ypos1+60,90,21, "DEBUG")
	   EditorGadget(52,Graf1EndPosX-400,Ypos1+100,90,150, "")
'	   EditorGadget(53,Graf1EndPosX-500,Ypos1+60,90,21, "DEBUG")
'/	   
      Init_State = FALSE
	End If

End Sub   

Sub SetGadget_Color       ' This is needed as can't make BG transparent
	   Dim As UInteger Lp1
   ' Set ChkBox txt BG/FG color 
   For Lp1 = 1 To 7 'CheckBox
      SetGadgetColor(Lp1,silver,&h800000,3)
   Next
   For Lp1 = 101 To 105 ' OptionBox (radio)
      SetGadgetColor(Lp1,silver,&h800000,3)
   Next
   
   SetGadgetColor(41,silver,&h800000,3)' -1 not work with SetGadgetColor BG, so set BG to window fill color.
SetGadgetColor(52,silver,&h800000,3)  'TEST ONLY
   SetGadgetColor(351,silver,&h800000,3)
   SetGadgetColor(352,silver,&h800000,3)
   SetGadgetColor(353,silver,&h800000,3)
   SetGadgetColor(354,silver,&h800000,3)
   SetGadgetColor(355,silver,&h800000,3)  ' ch5
End Sub

Sub SetGadget_States   '  restore btn states after window resize
      Dim As UByte Lp1
   'Set Check States 
   For Lp1 = 1 To 7
      SetGadgetstate(Lp1, ChkState(Lp1))
''      SetGadgetText(52,TmpStr + Str(Lp1) +" " +Str(ChkState(Lp1)) + CR_LF) 'TESTING ONLY
   Next

   ' Set OptionBox state (only 1 is set as just 1 group)
   If OptionNum > 0 Then SetGadgetstate(OptionNum, 1)
End Sub

Sub Tool_Tips
   GadgetToolTip(1,"Plot ch1 Data")
   GadgetToolTip(2,"Plot ch2 Data")
   GadgetToolTip(3,"Plot ch3 Data")
   GadgetToolTip(4,"Plot ch4 Data")
   GadgetToolTip(355,"Use ch5 Data for X axis")
   GadgetToolTip(5,"Fit data to graph width")
   GadgetToolTip(6,"Enables ch Data for use on X axis")
   GadgetToolTip(7,"Enable, then click Reload" + CR_LF + "          to make SVG file")
   GadgetToolTip(301,"X grid count")
   GadgetToolTip(302,"Y grid count")
   GadgetToolTip(303,"Plot line width")
   GadgetToolTip(304,"Type the file name here")
   GadgetToolTip(201,"Refresh data or Graph" + CR_LF + " after making changes...")
   GadgetToolTip(101,"Use this ch for X" + CR_LF + "(enable X data first)")
   GadgetToolTip(102,"Use this ch for X")
   GadgetToolTip(103,"Use this ch for X")
   GadgetToolTip(104,"Use this ch for X")
   GadgetToolTip(105,"Use this ch for X")
End Sub


'Set colors For - Data ch & data text
Sub Set_chColor(Chn As UByte) 'Shared Var Modify: RGB_
        Select Case Chn
        	   Case 1 : RGB_ = blue
				Case 2 : RGB_ = green
				Case 3 : RGB_ = red
				Case 4 : RGB_ = darkviolet
        End Select
    RGB_BGR
End Sub

 
'Window9 uses BGR color code [&hbbggrr]
Sub RGB_BGR 'Shared Var Modify: BGR_
	Dim As UByte BL_, GN_, RD_
	Dim As String BGRTmp
      BL_ = RGB_ And 255
      GN_ = RGB_ Shr 8 And 255 
      RD_ = RGB_ Shr 16 And 255
      BGRTmp = "&h" + Hex(BL_,2) + Hex(GN_,2) + Hex(RD_,2)
		BGR_ = Val(BGRTmp)
End Sub

Sub GetCSV 'Shared Var Modify: nSamples GetData
	  Dim FnumCSV As Integer : Dim As Boolean GetData
	  FnumCSV = FreeFile
	  ' Just get info about CSV data first (num of Records/data fields, field names, MaxVal, ...)
  Open CSVfilename for Input as #FnumCSV
      GetData = FALSE 
      ReadCSV(FnumCSV, GetData)
      nSamples = CSVLineCnt  
      ReDim As String CSVdata(nSamples+10, ChCnt+1)
  Close #FnumCSV 
  
     ' Now get the data
  Open CSVfilename for Input as #FnumCSV   
     GetData = TRUE
     ReadCSV(FnumCSV, GetData)
  Close #FnumCSV
End Sub



Sub ReadCSV(Fnum As Integer, GetData As Boolean) 'Shared Var Modify: CSVdata() MaxVal() CSVcnt LINEcnt
	   Dim As String CSVdataTMP
	   Dim As UByte ChrIn
	   Dim As Integer CSF1, CSF2, STRlen, Lp1
	   LINEcnt = 0 : CSVLineCnt = 0
	   MaxVal(1) = 0 : MaxVal(2) = 0 : MaxVal(3) = 0 : MaxVal(4) = 0 : MaxVal(5) = 0 

   Do WHILE NOT EOF(1)
       LINE INPUT #Fnum, CSVline
       StrLen = Len(CSVline)
       CSF1 = 0 : CSF2 = 0 : CSVcnt = 0
       
    	For Lp1 = 1 To StrLen    ' test for CS & extract values as string 
    	  ChrIn = Asc(CSVline, Lp1)
    	  If (ChrIn = 44) Then
    			 CSF2 = Lp1 : CSVcnt += 1
    			   If GetData = TRUE Then
    			   	CSVdataTMP =  Mid(CSVline, CSF1+1, CSF2-1-CSF1)  ' Extract data
    			   	CSVdata(CSVLineCnt+1, CSVcnt) = CSVdataTMP
                  If MaxVal(CSVcnt) < Val(CSVdataTMP) Then MaxVal(CSVcnt) = Val(CSVdataTMP)
    			   EndIf
    		    
    		    CSF1 = CSF2												 ' (should be able to improve this code)	
    	  EndIf                                     
    	     If Lp1 > StrLen-1 AndAlso CSF2 > 0 Then           ' get the last CSV line value 
    	     	  CSVcnt += 1
    	         If GetData = TRUE Then
    	            CSVdataTMP = Mid(CSVline, CSF1+1, StrLen-CSF1)
    	            CSVdata(CSVLineCnt+1, CSVcnt) = CSVdataTMP
    	            If MaxVal(CSVcnt) < Val(CSVdataTMP) Then MaxVal(CSVcnt) = Val(CSVdataTMP)
    	         EndIf
    	     EndIf 
    	Next
        If CSVcnt > 0 Then   CSVLineCnt += 1
              	
      If GetData = False Then ' get info of data 
         Get_ChInfo
      EndIf
       LINEcnt +=1
   Loop
End Sub
'----------------------------------

Sub Get_ChInfo 'Shared Var Modify: chType() XaxisName
	Dim As UByte Lp1, Eqlpos
	If CSVLineCnt > 3 Then Exit Sub
	If CSVLineCnt = 2 Then ChCnt = CSVcnt ' use 1st Data line
         
      Eqlpos = InStr(CSVline,"=")
      If InStr(LCase(CSVline),"ch1=") > 0 Then chType(1) = Right(Trim(CSVline),Len(CSVline)-Eqlpos)
      If InStr(LCase(CSVline),"ch2=") > 0 Then chType(2) = Right(Trim(CSVline),Len(CSVline)-Eqlpos)
      If InStr(LCase(CSVline),"ch3=") > 0 Then chType(3) = Right(Trim(CSVline),Len(CSVline)-Eqlpos)
      If InStr(LCase(CSVline),"ch4=") > 0 Then chType(4) = Right(Trim(CSVline),Len(CSVline)-Eqlpos)
      If InStr(LCase(CSVline),"xaxisname=") > 0 Then XaxisName = Right(Trim(CSVline),Len(CSVline)-Eqlpos) 
End Sub
'-----------------------------




'  Draw Graph in window
'-----------------------------
        '  (comment SVGplotLine(1) = "" lines doubles plot points in SVG) 
Sub DrawData  'Input:  LineW,      Modify:
	  Dim As Integer Lp1, Lp2, DataX1, DataX2
	  Dim As Single Data_X1, Data_X2, DataCount, GraphXCount
	  Dim As Integer DataY1(10), DataY2(10) 'each ch previous y point
	  Dim As String SVGplotLine(10)         'PolyLine points
	  Dim As String SVGStyle
	     DataCount = CSVLineCnt-1
	     GraphXCount = Graf1SizeX   
	     DataX1 = Graf1PosX
	     SVGplotLine(1) = "" : SVGplotLine(2) = "" 
	     SVGplotLine(3) = "" : SVGplotLine(4) = ""
	     SVG_Comment(" __Graph Plot lines (PolyLine)__ ")
	     
	   SVGStyle =  "   stroke-width="     """2""" _
	              '+ "   stroke-dasharray=" """0 0"""  
	 '  SVG_Group(1, SVG_Style)    ' set SVG group start & styles   
	For Lp1 = 2 To CSVLineCnt-1
		   If  XfitWidth = True_ Then 
		     DataX2 = Graf1PosX + (Lp1-1)*(GraphXCount/DataCount) 'Fit Data To graph
		   Else
			  DataX2 = Graf1PosX + (Lp1-1)
		  EndIf
		For Lp2 = 1 To CSVcnt    ' each channel
			If Ch_ON(Lp2) = TRUE_ Then
			   If Lp1 =2 Then ' First data point 
	            DataY1(Lp2) = Graf1SizeY - Val(CSVdata(Lp1, Lp2)) * (Graf1SizeY / MaxScaleY(Lp2)) + Graf1PosY
			   EndIf
			     Set_chColor(Lp2)
			    DataY2(Lp2) = Graf1SizeY - Val(CSVdata(Lp1, Lp2)) * (Graf1SizeY / MaxScaleY(Lp2)) + Graf1PosY  '"Graf1SizeY -" (=invert)
             LineDraw(DataX1, DataY1(Lp2), DataX2, DataY2(Lp2), LineW, BGR_, PS_SOLID)
             SVGplotLine(Lp2) &= Str(DataX1)+ "," + Str(DataY1(Lp2)) + " " 'SVG
             
             DataY1(Lp2) = DataY2(Lp2)
			EndIf
			   If Lp1 > Graf1SizeX Then Exit For '< this only relative to 1:1 plot 	
		Next : DataX1 = DataX2
	Next
	      For Lp1 = 1 To CSVcnt       ' Make SVG PolyLines
	         If ch_on(Lp1) = 1 Then
	            Set_chColor(Lp1)
	            'SVG_PolyLine(SVGplotLine(Lp1),, RGB_,,1)			' style as group
	            SVG_PolyLine(SVGplotLine(Lp1),  LineW, RGB_,,0) ' separate 
	         EndIf
	      Next
End Sub

Sub DrawGrid 'Shared Var Modify: None
	   Dim As Integer Lp1
	   Dim As Single GridW
	   Dim As String SVGStyle
	   SVG_Comment(" __Graph Grid (Lines)__ ")
	   SVGStyle = "stroke=rgb(130,130,130), stroke-width=0.25, stroke-dasharray=4-4"   
	   SVG_Group(1, SVGStyle)     ' set SVG group start & group styles
        'X
	For Lp1 = 1 To GridX-1	      ' num of grid lines
	   GridW = Graf1SizeX/GridX   ' Grid spacing in pixels
	   LineDraw(Graf1PosX+GridW*Lp1, Graf1PosY, Graf1PosX+GridW*Lp1, Graf1EndPosY, 1, darkgrey,PS_DOT)
	   SVG_Line(Graf1PosX+GridW*Lp1, Graf1PosY, Graf1PosX+GridW*Lp1, Graf1EndPosY,,1)
''	   SVG_Line(Graf1PosX+GridW*Lp1, Graf1PosY, Graf1PosX+GridW*Lp1, Graf1EndPosY,,1) 
	Next
        'Y
	For Lp1 = 1 To GridY-1
	   GridW = Graf1SizeY/GridY              'Ref:  LineDraw(x1,y1,x2,y2,Width,Color,style)
	   LineDraw(Graf1PosX,Graf1PosY+GridW*Lp1, Graf1EndPosX, Graf1PosY+GridW*Lp1, 1, darkgrey,PS_DOT)
	   SVG_Line(Graf1PosX,Graf1PosY+GridW*Lp1, Graf1EndPosX, Graf1PosY+GridW*Lp1,,1) 'SVG
	Next
	SVG_Group(0)                  ' End SVG Group
End Sub                 

Sub DrawTicks 'Shared Var Modify: None
    Dim As UInteger Lp1
    Dim As Single GridW
    Dim As String SVGStyle
	   SVG_Comment(" __Graph Ticks (Lines)__ ")
      SVGStyle = "   stroke=rgb(0,0,0), stroke-width=0.5"
	   SVG_Group(1, SVGStyle)
   'X (Lower)
	For Lp1 = 0 To GridX	         ' num of grid lines
	   GridW = Graf1SizeX/GridX   ' Grid width in pixels
	   LineDraw(Graf1PosX+(GridW*Lp1), Graf1EndPosY, Graf1PosX+(GridW*Lp1), Graf1EndPosY+TickLenX, 1, black,PS_SOLID)
	   SVG_Line(Graf1PosX+(GridW*Lp1), Graf1EndPosY, Graf1PosX+(GridW*Lp1), Graf1EndPosY+TickLenX,,1) 'SVG  
	Next

   'y1 (L&R)
	For Lp1 = 0 To GridY
	   GridW = Graf1SizeY/GridY
	   LineDraw(Graf1PosX+3, Graf1PosY+(GridW*Lp1), Graf1PosX-TickLenY, Graf1PosY+(GridW*Lp1), 1, black,PS_SOLID)
	   SVG_Line(Graf1PosX+3, Graf1PosY+(GridW*Lp1), Graf1PosX-TickLenY, Graf1PosY+(GridW*Lp1),,1) 'SVG
	   LineDraw(Graf1EndPosX, Graf1PosY+(GridW*Lp1), Graf1EndPosX+TickLenY, Graf1PosY+(GridW*Lp1),1, black,PS_SOLID)
	   SVG_Line(Graf1EndPosX, Graf1PosY+(GridW*Lp1), Graf1EndPosX+TickLenY, Graf1PosY+(GridW*Lp1),,1) 'SVG  
	Next
      SVG_Group(0)
End Sub

Sub DrawTickVaL 'Shared Var Modify:    MaxScaleY(Lp2)
	Dim As Integer Lp1, Lp2, RN,  InvertPosY, MaxScale_X, OffSet, TxtPosX, TxtPosY, Stp', TickVal
	Dim As Single TickVal,  GridW 
	Dim As String TmpStr, SVGStyle
	Dim As Ubyte SVGgrp
'	   SVGgrp = 1 ' enable group style
	   SVG_Comment(" __Graph Tick Values (Text)__ ")
      SVGStyle = "   fill=navy,font-size=10px ,font-weight=normal ,font-family=Arial"
	   SVG_Group(1, SVGStyle)
	   
	   SVGStyle = "   fill=" + """navy""" + CR_LF _
	             + "   font-size=" + """12px""" + CR_LF + _ 
	               "   font-weight=" + """normal""" + CR_LF +  _
	               "   font-family=" + """Arial"""
'	   If SVGgrp = 1 Then SVG_Group(1, SVGStyle)    ' set SVG group start & styles

   OffSet = Graf1PosY-15

	'Y TickVals          ' Set MaxVal_ch1 to eg 10000
	   SVG_Comment("      __Y values__      ",0)
   For Lp1 = 0 To GridY
   	For Lp2 = 1 To CSVcnt
''   		ch_on(Lp2) = True_
         If MaxVal(Lp2) < 10000 Then RN = 1000 : If MaxVal(Lp2) < 1000 Then RN = 100
         If MaxVal(Lp2) < 100 Then RN = 10     : If MaxVal(Lp2) < 10 Then RN = 1 ' rounding multiplier
		   MaxScaleY(Lp2) = RN*INT((MaxVal(Lp2)*1.05)/RN)+RN ' add 5% & RoundUP
''		   SetGadgetText(52, TmpStr + Str(MaxScaleY(Lp2)) + CR_LF)
		  If ch_on(Lp2) = TRUE_ Then                        ' only selected ch

		     GridW = Graf1SizeY/GridY                      ' Grid height in pixels
		 	  TickVal = (MaxScaleY(Lp2)/GridY)*Lp1          ' Value at each tick
           'InvertPosY =  (Graf1PosY+(GridW*Lp1)-OffSet) ' align to tickmarks [Not invert]
		     Select Case Lp2 'Set X pos
		  	     Case 1 : TxtPosX = Graf1PosX-25 : TxtPosY = Graf1PosY -OffSet -10
		     	  Case 2 : TxtPosX = Graf1PosX-60 : TxtPosY = Graf1PosY -OffSet 
		     	  Case 3 : TxtPosX = Graf1EndPosX + 10 : TxtPosY = Graf1PosY -OffSet -10
		     	  Case 4 : TxtPosX = Graf1EndPosX + 50 : TxtPosY = Graf1PosY -OffSet 
		     End Select
		                  ' align to tickmarks & invert
	          InvertPosY = Graf1EndPosY - (Graf1PosY+(GridW*Lp1)-OffSet) 
	          TextDraw(TxtPosX, InvertPosY, Str(TickVal), -1, &h800000, 255)'navy)
         SVG_Text(TxtPosX, InvertPosY+13, Str(TickVal),"", 1)
''             SVG_Text(TxtPosX, InvertPosY+13, Str(TickVal),"verdana", "10px", "normal", "navy", 1)
''	          SVG_Text(TxtPosX, InvertPosY+13, Str(TickVal),"verdana", "10px", "normal", "navy", SVGgrp)  
		  EndIf   
   	Next             '    SET THE STYLE PARAMETERS For non SVG Group
   Next
      
''DebugPrint("ch_Types = " + chType(1) + " " + chType(2) + " " + chType(3) + " " + chType(4))

'         TextDraw(Graf1EndPosX/2, Graf1EndPosY+30 , XaxisName,-1,&h000000,255)
'         SVG_Text(Graf1EndPosX/2, Graf1EndPosY+40 , XaxisName, "verdana", "12px", "bold", "navy", 0)
         
	' X TickVals                          This block will need some more work for various Input Data range
	   SVG_Comment("     __X values__      ",0)    
		   Stp = 1
		   If X_DataEN = 1 And X_DataCh > 0 Then 
            MaxCnt_X = MaxVal(X_DataCh)
		   Else
		   	MaxCnt_X = CSVlineCnt
		   EndIf
		   	     'If MaxCnt_X > GridX Then Stp = GridX / MaxCnt_X 
		   GridW = Graf1SizeX/GridX     
		For Lp1 = 0 To GridX Step Stp
			
			'Get values from data ch or num of samples
         If X_DataEN = 1 And X_DataCh > 0 Then  
         	TickVal = (MaxCnt_X)/GridX*Lp1
'			   TickVal = Format(TickVal, "#0.00##")
			   TempStr = Str(Format(TickVal, "0.0"))
	         TextDraw(Graf1PosX+(GridW*Lp1)-3, Graf1EndPosY+10, TempStr, -1,&h800000,255)'navy)
	         SVG_Text(Graf1PosX+(GridW*Lp1)-3, Graf1EndPosY+20, TempStr, "", 1)
''	         SVG_Text(Graf1PosX+(GridW*Lp1)-3, Graf1EndPosY+20, TempStr, "verdana", "10px", "normal", "navy", 1)
         Else
         	TickVal = (MaxCnt_X-1)/GridX*Lp1
	         TextDraw(Graf1PosX+(GridW*Lp1)-3, Graf1EndPosY+10, Str(Format(TickVal,"##")), -1,&h800000,255)'navy)
	     SVG_Text(Graf1PosX+(GridW*Lp1)-3, Graf1EndPosY+20, Str(Format(TickVal,"##")), "", 1)
''	         SVG_Text(Graf1PosX+(GridW*Lp1)-3, Graf1EndPosY+20, Str(Format(TickVal,"##")), "verdana", "10px", "normal", "navy", 1)
		   EndIf
		Next
		   SVG_Group(0)
         TextDraw(Graf1EndPosX/2, Graf1EndPosY+30 , XaxisName,-1,&h000000,255)
     SVG_Text(Graf1EndPosX/2, Graf1EndPosY+40 , XaxisName, "font-family=verdana, font-size=12px, Font-Weight=bold, fill=navy", 0)
''         SVG_Text(Graf1EndPosX/2, Graf1EndPosY+40 , XaxisName, "verdana", "12px", "bold", "navy", 0)
End Sub

Sub DrawChName 'Shared Var Modify: BGR_ 
	Dim As UInteger  Lp2, OffSet, TxtPosX, TxtPosY, InvertPosY
	Dim As String ChName(5)
	 Dim As String SVGstyle
''	Dim As Ubyte SVGgrp
	SVG_Comment(" __Graph ch names(Text) & Anchor(Line)__ ")
''	SVGgrp = 0
''	For Lp2 = 1 To CSVcnt         '< TEST ONLY
''		ChName(Lp2) = CSVdata(1, Lp2)
''	Next
	
'Open "debug2.txt" For Output As #5
	
	       OffSet = 30
	   For Lp2 = 1 To CSVcnt 
		   If ch_on(Lp2) = TRUE_ Then                        ' only selected ch
		   		  
		      Select Case Lp2 'Set X pos
		      	Case 1 : TxtPosX = Graf1PosX-25 : TxtPosY = Graf1PosY -OffSet -20
		      	Case 2 : TxtPosX = Graf1PosX-60 : TxtPosY = Graf1PosY -OffSet 
		      	Case 3 : TxtPosX = Graf1EndPosX + 10 : TxtPosY = Graf1PosY -OffSet -20
		      	Case 4 : TxtPosX = Graf1EndPosX + 50 : TxtPosY = Graf1PosY -OffSet 
		      End Select
		     
	        'ch names (CSVline 1)                 ' ----Hiding Bug here somewhere----
             Set_chColor(Lp2) ' text color same as data trace
            'TextDraw(TxtPosX -5, TxtPosY-5, Trim(CSVdata(1, Lp2)), &hfffae9, BGR_,254)'navy)
          '  TextDraw(TxtPosX -5, TxtPosY-5, Trim("____"), &hfffae9, BGR_,254)          '< This Text Draws 4th string 
            TextDraw(TxtPosX -5, TxtPosY-5, Trim(CSVdata(1, Lp2)), &hfffae9, BGR_,250) '< Last array val not draw
        SVG_Text(TxtPosX -5, TxtPosY+8, Trim(CSVdata(1, Lp2)),"Font-Family=verdana, Font-Size=14px, Font-Weight=normal, Fill=" + "#" + hex(RGB_,6), 0)
''            SVG_Text(TxtPosX -5, TxtPosY+8, Trim(CSVdata(1, Lp2)),"verdana", "14px", "normal", "#"+hex(RGB_,6), 0)
         '   TextDraw(TxtPosX -5, TxtPosY-5, Trim(CSVdata(1, Lp2)), &hfffae9, BGR_,255) '< Last array val draw ok (no BG)
         ''   TempStr = Trim(CSVdata(1, Lp2))
         ''   TextDraw(TxtPosX -5, TxtPosY-5, TempStr, &hfffae9, &h000000,254)
          '  TextDraw(TxtPosX -5, TxtPosY-5, ChName(1), &hfffae9, &h000000,255)
''  DebugPrint("ch_Name = " + Trim(CSVdata(1, Lp2)))                                     '< Check the array val ok
''  DebugPrint("ch_Name = " + Trim(ChName(Lp2)))
             

             'Line above Y TickVal
             SVGstyle = "stroke=" + Str(RGB_) + ", stroke-width=2"
             LineDraw(TxtPosX, Graf1PosY-15, TxtPosX+15, Graf1PosY-15, 2, BGR_,PS_SOLID) ' horiz
             LineDraw(TxtPosX+7, Graf1PosY-15, TxtPosX+7, TxtPosY+11, 2, BGR_,PS_SOLID)  ' vert (draw up)
             SVG_Line(TxtPosX, Graf1PosY-15, TxtPosX+15, Graf1PosY-15, SVGstyle, 0)
	          SVG_Line(TxtPosX+7, Graf1PosY-15, TxtPosX+7, TxtPosY+11, SVGstyle, 0)
		   EndIf
	   Next              
             Close #5
End Sub

'  TextDraw Issue: 
'     4th value from array does not draw, use same array element(1,1) is the same issue,  replace with fixed text ok, 
'     Use intermediate temp string is the same issue.
'  print the Array string is ok so its not? array mem issue.
'  I found that if I write a new string to CSVdata(1, Lp2), some text ok, other same issue. 
'  If I change the transparency value from anyVal to 255 it now draw ok.  (but I lose background color)
'
'  I tried copy  CSVdata(1, Lp2) to new 1D temp array but same issue.
 
Sub DrawChMaxVal 'Input:	...				Modify: BGR_  TempStr 
	Dim As Integer Lp2,  TxtPosX
	Dim As Ubyte SVGgrp
	SVG_Comment(" __Graph ch MaxVal (Text)__ ")
''	SVGgrp = 0
	     'Max ch Values (above graph)
      For Lp2 = 1 To CSVcnt
      	Select Case Lp2 'Set X pos
      		Case 1 : TxtPosX = Graf1PosX+30 
      		Case 2 : TxtPosX = Graf1PosX+150  
      		Case 3 : TxtPosX = Graf1EndPosX-260 
      		Case 4 : TxtPosX = Graf1EndPosX-140  
      	End Select
      	Set_chColor(Lp2)
      	TempStr = Str(MaxVal(Lp2)) + chType(Lp2)
      	TextDraw(TxtPosX,Graf1PosY-20,"Max. ch" + Str(Lp2) + ": " + TempStr,-1,BGR_)'&h000000)
     SVG_Text(TxtPosX,Graf1PosY-7,"Max. ch" + Str(Lp2) + ": " + TempStr,"Font-Family=verdana, Font-Size=12px, Font-Weight=bold, Fill=" + "#" + hex(RGB_,6), 0)
''      	SVG_Text(TxtPosX,Graf1PosY-7,"Max. ch" + Str(Lp2) + ": " + TempStr,"verdana", "12px", "bold", "#"+hex(RGB_,6), 0)
      Next
End Sub



            ' [BoxDraw(Graph1PosX, Graph1PosY, Graph1SizeX, Graph1SizeY, &h000000, &hfffae9, 1,, 250)]
'This draws a box With outlline on size (not inside)
Sub DrawGraphBox 'Shared Var Modify:  None
	Dim as Integer LineW = 1
	Dim As String SVGStyle
	LineDraw(Graf1PosX, Graf1PosY, Graf1PosX + Graf1SizeX, Graf1PosY,LineW, black,PS_SOLID)
	LineDraw(Graf1PosX, Graf1PosY + Graf1SizeY,Graf1EndPosX,Graf1EndPosY,LineW, black,PS_SOLID)
	LineDraw(Graf1PosX, Graf1PosY, Graf1PosX, Graf1EndPosY,LineW, black,PS_SOLID)
	LineDraw(Graf1EndPosX, Graf1PosY, Graf1EndPosX,Graf1EndPosY,LineW, black,PS_SOLID)
	'SVG
'	Print #FnumSVG, "<rect x=";DQ + Str(Graf1PosX) + """ y=""" + Str(Graf1PosY) + """ width=""" + Str(Graf1SizeX) + """ height=""" + Str(Graf1SizeY) + DQ
'	Print #FnumSVG, "style=""fill:#e9faff;stroke:black;stroke-width:2;fill-opacity:1;stroke-opacity:1"" />" + CR_LF

  	   SVGStyle = "Rx=5, Ry=5, fill=#e9faff, stroke=black, stroke-width=2"
  	   SVG_Rect(Graf1PosX, Graf1PosY, Graf1SizeX, Graf1SizeY, SVGStyle,0)
	                             '&hfffae9 R233 G250 B255
End Sub
'----------------------------------


Sub SaveSettings
   Dim As Integer FnumSET 
   FnumSET = FreeFile
   Open "DATAGRAPH_4ch.ini" for Output as #FnumSET
   Print #FnumSET, "DATAGRAPH_4ch Settings File"
   Print #FnumSET, ""
'   Print #FnumSET, "Load_Ini=" +  Str(CheckBox_GetCheck(Check(0))) 
   Print #FnumSET, "FileName="  + CSVfilename
   Print #FnumSET, "Ch1_ON="    + Trim(Str(ChkState(1)))
   Print #FnumSET, "Ch2_ON="    + Trim(Str(ChkState(2)))
   Print #FnumSET, "Ch3_ON="    + Trim(Str(ChkState(3)))
   Print #FnumSET, "Ch4_ON="    + Trim(Str(ChkState(4)))
   Print #FnumSET, "XfitWidth=" + Trim(Str(ChkState(5)))
   Print #FnumSET, "XfromCh="   + Trim(Str(ChkState(6)))
   Print #FnumSET, "SVG_EN="    + Trim(Str(ChkState(7)))
   Print #FnumSET, "X_DataCh="  + Trim(Str(X_DataCh)) 
   Print #FnumSET, "WindowX="   + Str(WindowWidth(hwnd)-20)
   Print #FnumSET, "WindowY="   + Str(WindowHeight(hwnd)-50)
'Form1SizeX = WindowWidth(hwnd)-20 : Form1SizeY = WindowHeight(hwnd)-50
   Print #FnumSET, "GridCntX="  + Str(GridX)
   Print #FnumSET, "GridCntY="  + Str(GridY)
   Print #FnumSET, "LineWidth=" + Trim(Str(LineW))
   Print #FnumSET, "OptionBtn=" + Trim(Str(OptionNum))
'   If StartHelp = FALSE Then Print #FnumSET, "StartHelp=0"
   Print #FnumSET, ""
   
'   For LP1 = 1 To 9
'     Print #FnumSET, "Check_" + Str(LP1) + "=" + Str(CheckBox_GetCheck(Check(LP1)))
'   Next
'     Print #FnumSET, "Check_20" + "=" + Str(CheckBox_GetCheck(Check20))
   Close FnumSET
   Close #5  '< DEBUG
End Sub



Sub ReadSettings
   Dim As UInteger CurrLine, SettingVal, Eql_Pos, LineNo, FnumSET
   Dim As String SetName, SetVal, Line_Str
   
 If FileExists("DATAGRAPH_4ch.ini") = 0 Then Exit Sub ' (the next app exit will write ini)
   LineNo = 1
   FnumSET = FreeFile
   Open "DATAGRAPH_4ch.ini" for Input as #FnumSET


   ' check first line
   Line Input #FnumSET, Line_Str  
   Line_Str = UCase(Line_Str)
   If Instr(Line_Str, Ucase("DATAGRAPH_4ch Settings")) < 1 Then Exit Sub 
   
   ' Get settings
 Do until(EOF(FnumSET) )
    Line Input #FnumSET, Line_Str
    Line_Str = UCase(Line_Str)
''    TempStr = Line_Str + "  " 
    Eql_Pos = INSTR(Line_Str,"=")
   
   If Eql_Pos  <> 0 Then 'only line with = 
 ''     Data1TextBoxText = Line_Str
      SetName = Left(Line_Str, Eql_Pos -1)
      SetVal = Right(Line_Str,  Len(Line_Str) -(Eql_Pos))

         Select Case SetName 'INSTR(Line_Str, FindSetting)
  '          Case  "LOAD_INI" : If Val(SetVal) = 0 Then Exit Sub ' Dont load settings
         	Case  "FILENAME"  : CSVfilename = SetVal : 'SetGadgetText(304, CSVfilename)   "< Gadget is not exist yet 
         	Case UCase("Ch1_ON")    : ChkState(1) = Val(SetVal) : Ch_ON(1) = Val(SetVal)
         	Case UCase("Ch2_ON")    : ChkState(2) = Val(SetVal) : Ch_ON(2) = Val(SetVal)
         	Case UCase("Ch3_ON")    : ChkState(3) = Val(SetVal) : Ch_ON(3) = Val(SetVal)
         	Case UCase("Ch4_ON")    : ChkState(4) = Val(SetVal) : Ch_ON(4) = Val(SetVal)
         	Case UCase("XfitWidth") : ChkState(5) = Val(SetVal) : XfitWidth = Val(SetVal)
         	Case UCase("XfromCh")   : ChkState(6) = Val(SetVal) : X_DataEN = Val(SetVal)
         	Case UCase("SVG_EN")    : ChkState(7) = Val(SetVal) : SVG_EN = Val(SetVal)
         	Case UCase("X_DataCh")  : X_DataCh = Val(SetVal)     
         	Case UCase("OptionBtn") : OptionNum = Val(SetVal)    
         	Case UCase("GridCntX")  :  GridX = Val(SetVal)
         	Case UCase("GridCntY")  :  GridY = Val(SetVal)
         	Case UCase("LineWidth") :  LineW = Val(SetVal)
         	'Case UCase("WindowX") : Form1SizeX = Val(SetVal)
         	'Case UCase("WindowY") : Form1SizeY = Val(SetVal)
         	Case UCase("WindowX")   : Form1SizeX = Val(SetVal)+20   ' +.. may need tweaking
         	Case UCase("WindowY")   : Form1SizeY = Val(SetVal)+50   '

      End Select
   EndIf
 Loop
   Close #FnumSET
End Sub
'/


'  Ref:  Note: window9 Colors are BGR
'  LineDwaw(x1,y1,x2,y2,Width,Color,style)
'  BoxDraw(x,y,w,h,ColorPen,ColorBk,widthPen,StylePen)
'	TextDraw(x,y,"Text",ColorBK,ColorText,transparency [0 to 255])  

' Needs to be after CreateGadgets 
'   	TmpStr = GetGadgetText(52) 'DEBUG
'	   If Lp1 = 1 Then SetGadgetText(52, TmpStr + Str(TickVal) + CR_LF)  'DEBUG



/'
'                DEBUG Output to file
'==================================================
Sub Init_DebugPrint
         FnumDebug = 2 'FreeFile smashes CSV file
         Open "DEBUG_01.txt" for Output As #FnumDebug 'Append As #FnumDebug
         DebugPrint("")
         DebugPrint("")
         DebugPrint(Date + "  " + Time)
         DebugPrint("---------------------------------------")
End Sub

'-----------------
Sub DebugPrint(Text1 As String)
   Print #FnumDebug, Text1
End Sub
'==================================================
'  Debug out also can be to Gadget(52, DebugString)
'/

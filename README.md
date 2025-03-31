# EzySVG lib for freebasic  

**EzySVG.bi** is a simplified library with commands to enable creating SVG files in your FB code.  
See Test ezySVG_1.bas for example usage.  
I started this project as I needed to import vector data to CDRx4 from my logic analyzer to annotate the captured data graphically.   

To enable easy fast output for checking, set `Const html_ = "html"` , this produces a html file to load in web browser, after each compile refresh browser to see changes.  
Otherwise set `Const html_ = ""` for svg file output.  
Use browser 'view source' to see any SVG rendering errors.
  
  
  When using a winapi GUI lib (eg. window9) you can "shadow" the draw commands to create SVG elements...  
`TextDraw(Graf1PosX+(GridW*Lp1)-3, Graf1EndPosY+10, Str(Format(TickVal,"##")), -1,&h800000,255)'navy)`  
`SVG_Text(Graf1PosX+(GridW*Lp1)-3, Graf1EndPosY+20, Str(Format(TickVal,"##")), "verdana", "10px", "normal", "navy`  
  
  
  


DataGraph-W_SVG1.bas was used to create TESTDATA-PV_PNL_2.svg, AirCon 1 Cycle.svg (PNG images below) 

![TESTDATA-PV_PNL_2](https://github.com/user-attachments/assets/3cdf4456-56c5-450a-acd3-e18c46ae6cc0)




![AirCon 1 Cycle](https://github.com/user-attachments/assets/96b8c086-e0bd-470c-9b86-ace7665c2f3c)








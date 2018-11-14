Const UI = False
Const screenSize# = 10000
Const graphicsScreenSize# = Min(1000, screenSize)
Const screenScale# = screenSize/20
Const screenCenterX# = screenSize/2
Const screenCenterY# = screenSize/2
Const N# = 6
Const tStep# = 1/screenSize
Const tBound# = 2*Pi*N
Const tStepsPerDraw = 5
Const stripWidth# = 1/N
Const sStep# = 10/screenSize
Const inputFile$ = "earth.jpg"
Const outputFile$ = "eulerSpiralProjection.png"

Global earthImage:TPixmap = LoadPixmap(inputFile)
Global transformedEarthImage:TPixmap = CreatePixmap(screenSize, screenSize, PF_RGBA8888)
curve(tBound, tStep)
curve(-tBound, -tStep)
If UI
	SetGraphicsDriver(GLMax2DDriver())
	Graphics(graphicsScreenSize, graphicsScreenSize)
	DrawPixmap(transformedEarthImage, 0, 0)
	Flip()
	If WaitKey() = KEY_S Then SavePixmapPNG(transformedEarthImage, outputFile, 9)
Else
	SavePixmapPNG(transformedEarthImage, outputFile, 9)
EndIf

Function curve(tBound#, tStep#)
	xLine# = 0
	yLine# = 0
	For i = 0 To tBound/tStep
		t# = i * tStep
		dx# = xDeriv(t)
		dy# = yDeriv(t)
		If i Mod tStepsPerDraw = 0
			For s# = -stripWidth/2 To stripWidth/2 Step sStep
				color = getMapPointByParameters(t, s)
				plotScaled(xLine-dy*s, yLine+dx*s, color)
			Next
		EndIf
		xLine :+ dx * tStep
		yLine :+ dy * tStep
	Next
End Function

Function getMapPointByParameters(t#, s#)
	lat# = ASinR(t/tBound)
	lon# = -tBound*lat
	lat :+ s
	lon = wrapLongitude(lon)
	Return getMapPoint(lat, lon)
End Function

Function getMapPoint(lat#, Lon#)
	lat = lat/Pi+0.5
	lon = lon/2/Pi+0.5
	lat :* PixmapHeight(earthImage)
	lon :* PixmapWidth(earthImage)
	If lat > 0 And lat < PixmapHeight(earthImage) And lon > 0 And lon < PixmapWidth(earthImage)
		Return ReadPixel(earthImage, lon, lat)
	Else
		Return 0
	EndIf
End Function

Function plotScaled(x#, y#, color)
	If color <> 0
		WritePixel(transformedEarthImage, screenCenterX+screenScale*x, screenCenterY-screenScale*y, color)
	EndIf
End Function
	
Function xDeriv#(u#)
	Return CosR(Sqr(tBound^2 - u^2))
End Function

Function yDeriv#(u#)
	Return -SinR(Sqr(tBound^2 - u^2))
End Function

Function CosR#(r#)
	Return Cos(r*180/Pi)
End Function

Function SinR#(r#)
	Return Sin(r*180/Pi)
End Function

Function ASinR#(y#)
	Return ASin(y)*Pi/180
End Function

Function wrapLongitude#(lon#)
	While lon > Pi
		lon :- 2*Pi
	Wend
	While lon < -Pi
		lon :+ 2*Pi
	Wend
	Return lon
End Function

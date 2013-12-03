
/*
Snowflake 2.0

Open-source "snowflake" drawing app with true vector output.
Click the "save" button to create a PDF document of your snowflake,
suitable for editing in Inkscape, Corel, Illustrator, or so forth.

   
Written by Windell H. Oskay, www.evilmadscientist.com
Copyright 2009, all rights reserved.
Distributed under the GPL 3.0.

Saves files named "snowflake-####.pdf" in the directory where this .pde file
resides. 

 */




import processing.pdf.*;

int sides = 6;

float[] xPointList = {};
float[] yPointList = {};

void DrawVertex(float x,float y,float angle)
{    // Angle is in radians
  float newX = x*cos(angle) + y*sin(angle);
  float newY = y*cos(angle) - x*sin(angle);

  vertex(newX, newY);
  append(xPointList, newX);
  append(yPointList, newY);
}

boolean ReflectMode = true;


int SidesMax = 99;

float StartTime, InitTime;
float CircStartTime;


float timeNow;
float LastActiveTime;
float xValues[];
float yValues[];
int SideLength;
color circleColor;
color circleStroke;

color bgColor;
color symColor;
color segmentColor;
int CircleDia;
int mtCircleDia;
boolean dragging; 
int MovePoint;
boolean pointsActive;
boolean pointsActiveOld;
color emptyCircle;

PFont font_MB48;
PFont font_MB24;


boolean overCircle(int x, int y, int diameter) 
{
  float disX = x - mouseX;
  float disY = y - mouseY;
  if(sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } 
  else {
    return false;
  }
}


boolean overRect(int x, int y, int width, int height) 
{
  if (mouseX >= x && mouseX <= x+width &&  mouseY >= y && mouseY <= y+height) 
    return true; 
  else 
    return false;
  
}



 
void setup() 
{

  size(640, 640); 
  smooth();

  xValues = new float[2];
  yValues = new float[2];


  bgColor = #68A0B6;
  background(bgColor);
  
  StartTime = millis();
  
  InitTime=  millis();
  LastActiveTime = StartTime;
  dragging = false; 
  pointsActive = false;


  symColor = 0;  
  segmentColor = 255;
  CircleDia =  10;
  circleColor = color(255, 128, 0);

  mtCircleDia =  10;
  emptyCircle = color(255,128,0,0);

  SideLength = width*9/20;

   font_MB48  = loadFont("Miso-Bold-48.vlw");
 
   font_MB24  = loadFont("Miso-Bold-24.vlw");
  textFont( font_MB24, 20);  // MISO Typeface from http://omkrets.se/typografi/
  
  
   
  ClearShape();  
  
  stroke(255);
  circleStroke = 255;
 strokeWeight(1); 

  pushMatrix();
  translate(width/2,height/2);
  drawShape();
  popMatrix();

}




public void ClearShape() { 

  // This sets the initial shape and draws it on the screen,
  // with a triangular section highlighted.

  xValues = subset(xValues, 0, 2);
  yValues = subset(yValues, 0, 2); 

  xValues[0] = 0;
  xValues[1] = SideLength*sqrt(3)/4; 

  yValues[0] = -SideLength;
  yValues[1] = -0.75*SideLength; 
  

  pointsActive = true;
  StartTime = millis(); 
}







public void cursorMode(){
  document.getElementById('b').setAttribute('class', 'cursorMode');
}

public void endCursorMode(){
    document.getElementById('b').setAttribute('class', 'NOTcursorMode');
}
void mousePressed() { 

  int i,len,xt,yt; 

  len = xValues.length;
  dragging = false;

  i = 0;
  while (i < len)
  { 
    if (overCircle((int) xValues[i] + width/2, (int) yValues[i] + height/2, CircleDia))
    {
      dragging = true; 
      MovePoint = i; 
      i = len; // break
    } 
    i++; 
  }



  if ( dragging == false)
  {
    i = 0;
    while (( i + 1) < len) 
    { 
      xt = (int) (xValues[i] + xValues[i+1] )/2;
      yt = (int) (yValues[i] + yValues[i+1] )/2;    

      if (overCircle (xt + width/2, yt+ height/2,  CircleDia))
      {
        dragging = true; 
        MovePoint = i+1;

        xValues = splice(xValues, xt, i+1);
        yValues = splice(yValues, yt, i+1); 
        i = len; // break    
      } 
      i++;
    }
  } 
 



}

void mouseReleased() {
  dragging = false;
}



void drawShape()
{
xPointList = {};
yPointList = {};
  float angle;
  int i,j;
  fill(symColor); 
  beginShape(POLYGON);
  i = 0;
  while (i < sides)
  {

    angle = -i*TWO_PI/sides;

    if (ReflectMode){
      xValues = reverse(xValues);
      yValues = reverse(yValues);
      j = 0;
      while (j < xValues.length)
      { 
        DrawVertex(-1*xValues[j],yValues[j],angle); 
        j++;
      }

      xValues = reverse(xValues);
      yValues = reverse(yValues);

      j = 0;

      while (j < xValues.length)
      { 
        DrawVertex(xValues[j],yValues[j],angle);  
        j++;
      }  
      i++;
    } 
    else { 
      j = 0; 
      while (j < xValues.length)
      { 
        DrawVertex(xValues[j],yValues[j],angle);  
        j++;
      }  
      i++;
    }


  } 
  endShape(CLOSE);
if(recordShape){
exportSVG(xPointList, yPointList);
recordShape = false;
}
//console.log(xPointList, yPointList);
}
boolean recordShape = false;
public void record(){
recordShape = true;
}
void draw() 
{ 
  int i,j,len,xt,yt;
  float xf,yf;
  float TimeTemp;
  
  len = xValues.length;

  timeNow = millis(); 

  LastActiveTime = timeNow;
  if (pointsActive) 
    LastActiveTime = timeNow;

  if ((timeNow - LastActiveTime) < 20000)
    pointsActiveOld = true;
  else
    pointsActiveOld = false;

  pointsActive = false;



  pushMatrix();
  translate(width/2,height/2);
  background(bgColor);

  stroke(255);
  strokeWeight(1); 

  drawShape();
  popMatrix();


  if ((timeNow - CircStartTime) < 2550) 
  {
    j =  (int) (timeNow - CircStartTime) / 10;
    circleStroke =  color(255,255,255,255-j); 
  }



  if ((timeNow - StartTime) < 9525)// 6350
  { 
    j =  (int) (timeNow - StartTime) / 55;

    if (j < 176)
    {
      symColor = color(255,255,255,j); 
      CircStartTime = timeNow; 
    }
    else
    {
      symColor = color(255,255,255,176);  
    }

    if (j <= 255)
      segmentColor = color(255,255,255,255-j);    
    else
      segmentColor = color(255,255,255,0);    
 

    fill(segmentColor);
    strokeWeight(0);
    stroke(segmentColor);
    pushMatrix();
    translate(width/2,height/2);
    beginShape(POLYGON);
    DrawVertex(0,0,0);  

    i = 0;
    while (i < xValues.length)
    { 
      DrawVertex(xValues[i],yValues[i],0);  
      i++;
    }
    DrawVertex(0,0,0);  
    endShape(CLOSE);
    popMatrix();

    strokeWeight(1);
    stroke(circleStroke);


    i = 0;
    while (i < len)
    {  
      {

        pushMatrix();
        translate(width/2,height/2); 
        fill(red(circleColor),green(circleColor),blue(circleColor),255-j); 
        ellipse(xValues[i], yValues[i], CircleDia, CircleDia);
        popMatrix();
      }
      if (( i + 1) < len)
      {
        xt = (int) (xValues[i] + xValues[i+1] )/2;
        yt = (int) (yValues[i] + yValues[i+1] )/2;    
        {
          pushMatrix();
          translate(width/2,height/2); 
          ellipse(xt, yt,CircleDia, CircleDia);
          popMatrix();
        } 
      } 
      i++;
    }

  }
  else
  { 
    symColor = color(255,255,255,176);
    segmentColor = symColor; 
  }

  strokeWeight(1);
  stroke(255);





  if ( dragging)
  {

    pointsActive = true;
    CircStartTime = timeNow;

    if (MovePoint == 0)
    {
      xt = width/2;

      if (mouseY < height/2)
      {      
        yValues[MovePoint] = mouseY - height/2; 
        yt = mouseY;    
      }
      else
      {     
        yValues[MovePoint] = 0; 
        yt = height/2;    
      }
 

    } 
    else if (MovePoint == len -1)    // Last point in array.
    { 

      xf = mouseX - width/2;
      yf = mouseY - height/2; 

      xf = -yf/sqrt(3); 

      if (yf > 0)
      {
        xf = 0;
        yf = 0; 
      }
       
      xValues[MovePoint] = (int) xf;
      yValues[MovePoint] = (int) yf;

      xt = (int) ( width/2  + xf);
      yt = (int) ( height/2  + yf);   

    } 
    else
    {
      xValues[MovePoint] = mouseX - width/2;
      yValues[MovePoint] = mouseY - height/2;   
      xt = mouseX;
      yt = mouseY;

    }
    fill(circleColor);
    ellipse(xt, yt,CircleDia, CircleDia);  
  }
  else
  {
    i = 0;
    while (i < len)
    { 
      if (overCircle((int) xValues[i] + width/2, (int) yValues[i] + height/2, CircleDia))
      {
        pointsActive=true; 

        CircStartTime = timeNow;
        pushMatrix();
        translate(width/2,height/2);

        fill(circleColor);
        stroke(circleStroke);
        ellipse(xValues[i], yValues[i], CircleDia, CircleDia);
        popMatrix();
      }
      else if (pointsActiveOld) 
      {   
        pushMatrix();
        translate(width/2,height/2);
        fill(emptyCircle);
        stroke(circleStroke);
        ellipse(xValues[i], yValues[i], mtCircleDia, mtCircleDia);
        popMatrix(); 
      }

      if (( i + 1) < len)
      {

        xt = (int) (xValues[i] + xValues[i+1] )/2;
        yt = (int) (yValues[i] + yValues[i+1] )/2;    

        if (overCircle (xt + width/2,yt+ height/2,  CircleDia)) 
        {
          pointsActive=true; 

          CircStartTime = timeNow;
          pushMatrix();
          translate(width/2,height/2);
          fill(circleColor);
          ellipse(xt, yt,CircleDia, CircleDia);
          popMatrix();
        } 
        else if (pointsActiveOld) 
        { 
          pushMatrix();
          stroke(circleStroke);
          translate(width/2,height/2);
          fill(emptyCircle);
          ellipse(xt, yt,mtCircleDia, mtCircleDia);
          popMatrix(); 
        } 
      } 
      i++;
    } 
    if(pointsActive){        cursorMode();}
    else {        endCursorMode();}
  }
  pointsActive = true;


  // Draw text:

  fill(255,255,255,128);
  // text("Clear", 530, 630);
  // text("Save", 580, 630);
 
 

  if (overRect(525, 610, 40, 25) )
  {
    CircStartTime = timeNow;
    pointsActive=true; 
    //fill(circleColor);
    //rect(525, 610, 40, 25);
    fill(255);
    // text("Clear", 530, 630);
  }

  if (overRect(575, 610, 40, 25) )
  {
    CircStartTime = timeNow;
    pointsActive=true; 
    //fill(circleColor);
    //rect(575, 610, 40, 25);
    fill(255); 
    // text("Save", 580, 630);

  }




  if ((timeNow - InitTime) < 10540)// 6350
  {  
      
    
    TimeTemp = (timeNow - InitTime);
      
      if (TimeTemp > 8000)
      j = (int) ((TimeTemp - 8000) / 20);    
    else
      j = 0;  

 fill(255,255,255,128); 


 // textFont(font_MB48, 48); 
 // text("Snowflake 2.0", 10, 40); 
// text("SymmetriSketch", 176, 355); 
 
 // textFont( font_MB24, 20);  
  
  // text("Evil Mad Scientist Laboratories", 425, 25); 
  // text("www.evilmadscientist.com", 450, 42); 
 // fill(255);  
  } 
 



} 

// Added code
public void exportSVG(xPoints, yPoints) {
    var svg = '<?xml version="1.0" standalone="yes"?>';
svg += '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">';
svg += '<svg width="640px" height="640px" xmlns="http://www.w3.org/2000/svg" version="1.1"><path d="';
svg += "M"+xPoints[0]+","+yPoints[0]+" ";
for(var i=0; i<xPoints.length; i++) {
   svg += "L"+xPoints[(i+1)%xPoints.length]+","+yPoints[(i+1)%xPoints.length];
}
svg += "Z";

svg += '" stroke="#000" fill="#000" transform="translate(320,320)" /></svg>';
var blob = new Blob([svg], {type: "text/plain;charset=utf-8"});
saveAs(blob, "snowflake.svg");
}

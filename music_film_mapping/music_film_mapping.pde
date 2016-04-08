  
  
  
  NodeOutputOSC mNodeOutputOSC;
  import processing.video.*;
  import de.dennisppaul.strom.*;
  import netP5.*;
  import oscP5.*;
  import java.awt.Color;

  Movie mov;
  NodeSynth mSynth;
  Beat mBeat;
  //SHAPES <3
  int botCount = 16;
  PShape[] bots = new PShape[botCount]; 
  PShape all;
  
  //VIDEO 
  int cellWidth, cellHeight, cols, rows;
  int ColColor[];
  float[] colSum;
  float colAvg;
  boolean showLines = false;
  boolean showVideo = false;
  float[] redVals;
  float[] blueVals;
  float[] greenVals;
  float[] hueVals;
  float[] satVals;
  float[] briVals;
  float[] hsbVals = new float[3];
  String MOV_SRC = "";          // < put your video here, should be put in the /data folder
  
  //MUSIC
  float mNote;
  float[] mSeq;
  float[] mPitch;
  float[] mVolume;
  float[] tone;
  float[] pitch;
  float[] volume;
  int mIndex;
  float[] musicTone;
  float oldBPM;
  float newBPM;
  
  void setup() {
    mNodeOutputOSC = new NodeOutputOSC("netvis.local", 12121, "netvis/daan");
    fullScreen();
    mov = new Movie(this, MOV_SRC);
  
    mov.play();
    mov.loop();
    mov.speed(1);
    mov.volume(0);
    frameRate(60);
    cols = 16;
    rows = 1;
    cellWidth = width/cols;
    cellHeight = height/rows;
    ColColor  = new int[rows];
    colSum    = new float[3];
    redVals   = new float[cols];
    blueVals  = new float[cols];
    greenVals = new float[cols];
    hueVals   = new float[cols];
    satVals   = new float[cols];
    briVals   = new float[cols];
    tone = new float [cols];
    pitch = new float [cols];
    volume = new float [cols];
    musicTone = new float [cols];
    mSynth = new NodeSynth();
    mBeat = new Beat(this, "beat", 480);
  
  
    println(mBeat);
    //SHAPES
    fullScreen();
    for (int i=0; i<botCount; i++) {
      bots[i] = loadShape("layer_"+(i+1)+".svg");
    }
    all = loadShape("layer_all.svg");
  }
  void draw() {
  
  
    //MOVIE PART
    background(0);
    noStroke();
    noCursor();
    for (int i = 0; i < cols; i++) {
      for (int l=0; l<3; l++) {
        colSum[l] = 0;
      }
      for (int j = 0; j < rows; j++) {
        color c = mov.get(i*cellWidth, j*cellHeight);
        ColColor[j] = c;
  
        if (showLines) {
          if (mIndex == i) {
            noStroke();
            fill(c);
            rect(i*cellWidth, j*cellHeight, cellWidth, cellHeight);
          } else if (true) {
            noStroke();
            fill(c, 127);
            rect(i*cellWidth, j*cellHeight, cellWidth, cellHeight);
          }
        }
      }
      for (int j = 0; j < ColColor.length; j++) {
        colSum[0] += parseInt(red(ColColor[j]));
        colSum[1] += parseInt(green(ColColor[j]));
        colSum[2] += parseInt(blue(ColColor[j]));
      }
      redVals[i]   = colSum[0]/ColColor.length;
      greenVals[i] = colSum[1]/ColColor.length;
      blueVals[i]  = colSum[2]/ColColor.length;
      Color.RGBtoHSB(parseInt(redVals[i]), parseInt(greenVals[i]), parseInt(blueVals[i]), hsbVals);
      hueVals[i] = hsbVals[0];
      satVals[i] = hsbVals[1];
      briVals[i] = hsbVals[2];
    }
    if (showVideo) {
      image(mov, width-254, height-144, 254, 144);
    }
    
    //MUSIC PART
    for (int j = 0; j < tone.length; j++) {
      tone[j] = map(hueVals[j], 0, 1, 32, 50);
      pitch[j] = map(briVals[j], 0, 1, 40, 60);
      volume[j] = map(satVals[j], 0, 1, 30, 100);
    }
    mSeq = new float[] {
      tone[0], tone[1], tone[2], tone[3], 
      tone[4], tone[5], tone[6], tone[7], 
      tone[8], tone[9], tone[10], tone[11], 
      tone[12], tone[13], tone[14], tone[15], 
    };
    mPitch = new float[] {
      pitch[0], pitch[1], pitch[2], pitch[3], 
      pitch[4], pitch[5], pitch[6], pitch[7], 
      pitch[8], pitch[9], pitch[10], pitch[11], 
      pitch[12], pitch[13], pitch[14], pitch[15]
    };
    mVolume = new float[] {
      volume[0], volume[1], volume [2], volume[3], 
      volume[4], volume[5], volume[6], volume[7], 
      volume[8], volume[9], volume[10], volume[11], 
      volume[12], volume[13], volume[14], volume[15]
    };
    
    //IMAGE PART
    for (int i=0; i<botCount; i++) {
      bots[i].disableStyle();
      fill(redVals[i], greenVals[i], blueVals[i]);    
      stroke(0);          
      shape(bots[i]);
    }
    all.disableStyle();  
    noFill();
    stroke(0);          
    shape(all);
  }
  // Called every time a new frame is available to read
  void movieEvent(Movie m) {
    m.read();
  }
  void beat() {
    mIndex = mBeat.current_beat_count() % mSeq.length; 
    for (int j = 0; j < mVolume.length; j++) {
      mVolume[j] = map(briVals[j], 0, 1, 60, 100);
      mSynth.in(NodeSynth.CHANNEL_IN_AMPLITUDE, mVolume[j]);
    }
    for (int j = 0; j < mPitch.length; j++) {
      mPitch[j] = map(satVals[j], 0, 1, 2, 2.5);
      mNote = (mSeq[mIndex] * mPitch[j])/1.25;
      Strom.patch(mNote, mSynth);
      mNodeOutputOSC.in(mNote);
    }
  }
  
  void keyPressed() {
    if (key == 'p') {
      showVideo = !showVideo;
    }
    if (key == 'o') {
      showLines = !showLines;
    }
  }
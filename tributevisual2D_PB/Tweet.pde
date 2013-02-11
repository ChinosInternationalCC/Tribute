class Tweet {

  PVector p; //Posiiton in 2D space
  RGroup grp;
  float anitime = 2;
  float sc = 1;
  float tsc = 2;
  boolean scaling = false;
  Ani scaleani;
  AniSequence seq;
  int r, g, b, cloudradius, fadetime;
  PApplet prnt;
  boolean render = true;
  String t;
  boolean done = false;
  int pulsemaxtime = 3;
  float pulsemintime = 0.1;
  int tweetlf = 300; 

  Tweet(String inputText, PVector pos, PApplet parent) {
    prnt = parent;
    t = inputText;
    r=g=b=255;
    cloudradius = 300;
    fadetime = 300;    
    p = new PVector(pos.x, pos.y);
    ArrayList parr = new ArrayList();
    int lastspace = 0;
    boolean nextspace = false;
    for (int i = 0; i <= t.length()-1; i++) {
      if ( (i%20 == 0) && (i > 4) ) {
        nextspace = true;
      }
      if ((t.charAt(i) == ' ')&&(nextspace == true)) {
        parr.add(t.substring(lastspace, i));
        lastspace = i+1;
        nextspace = false;
      }
      if (i == t.length()-1) {
        parr.add(t.substring(lastspace, i+1));
      }
    }
    grp = new RGroup();
    for (int i = 0; i < parr.size(); i++) {
      String tstr = (String)parr.get(i);
      RGroup cgrp = font.toGroup(tstr);
      for (int j = 0; j < cgrp.countElements();j++) {
        RShape el = cgrp.elements[j].toShape();
        float oriy = el.getY();
        cgrp.elements[j].transform(el.getX(), (i*10)+(oriy), el.getOrigWidth(), el.getOrigHeight());
      }
      grp.addGroup(cgrp);
    }
    Ani.to(p, anitime, "x", 50);
    Ani.to(p, anitime, "y", 50);
    scaleani = new Ani(this, anitime, "sc", tsc, Ani.EXPO_IN_OUT, "onStart:scaleStart, onEnd:scaleEndCenter");
    scaleani.start();
  }

  void scaleStart() {
    scaling = true;
  }

  void scaleEnd() {
    scaling = false;
    Ani.to(p, tweetlf, "x", width/2-grp.getWidth()/2);
    Ani.to(p, tweetlf, "y", height/2-grp.getHeight()/2);
    Ani.to(this, tweetlf, "sc", 0.0, Ani.LINEAR, "onStart:scaleStart,onEnd:removeMe");
  }

  void scaleEndCenter() {
    scaling = false;
    Ani.to(p, anitime, "x", (width/2)-(grp.getOrigWidth()));
  }

  void display() {
    if (render) {
      RGroup tg = new RGroup(grp);
      tg.scale(sc);
      fill(r, g, b);
      pushMatrix();
      translate(p.x, p.y);
      tg.draw();
      popMatrix();
    }
  }
  void removeMe() {
    seq.pause();
    seq = null;
    render = false;
    done = true;
  }

  void sendToBack() {
    float ra = random(0, TWO_PI);
    float rd = random(-cloudradius, cloudradius);
    tsc = random(0.93, 0.97);
    Ani.to(p, anitime, "x", width/2+(cos(ra)*rd));
    Ani.to(p, anitime, "y", height/2+(sin(ra)*rd));
    scaleani = new Ani(this, anitime, "sc", tsc, Ani.SINE_OUT, "onStart:scaleStart, onEnd:scaleEnd");
    scaleani.start();
    float pulsetime = random(pulsemintime,pulsemaxtime);
    seq = new AniSequence(prnt);
    seq.beginSequence();  
    // step 0
    seq.beginStep();
    seq.add(Ani.to(this, pulsetime, "r", 100, Ani.SINE_IN_OUT));
    seq.add(Ani.to(this, pulsetime, "g", 150, Ani.SINE_IN_OUT));
    seq.add(Ani.to(this, pulsetime, "b", 175, Ani.SINE_IN_OUT));
    seq.endStep();
    //setp 1
    seq.beginStep();
    seq.add(Ani.to(this, pulsetime, "r", 200, Ani.SINE_IN_OUT));
    seq.add(Ani.to(this, pulsetime, "b", 255, Ani.SINE_IN_OUT));
    seq.add(Ani.to(this, pulsetime, "g", 250, Ani.SINE_IN_OUT, "onEnd:sequenceEnd"));
    seq.endStep();
    seq.endSequence();
    // start the whole sequence
    seq.start();
  }

  void sequenceEnd() {
    seq.start();
  }
}


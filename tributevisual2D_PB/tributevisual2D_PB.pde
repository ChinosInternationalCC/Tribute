import processing.serial.*;

import de.looksgood.ani.*;
import de.looksgood.ani.easing.*;

import geomerative.*;
import org.apache.batik.svggen.font.table.*;
import org.apache.batik.svggen.font.*;

ArrayList tweets;
PVector cpos; //Initial position of the last tweet;
static RFont font;
Tweet ctweet;
int[] screenBuf;
//String tt = "140 character example: Mentioning St Francis on twitter creates @nique context for constructing meaning #nlike oral or print communication";
String tt = "#AaronSwartz tribute";
PImage core;
float corersf;
AniSequence coreseq;
AniSequence ntseq;
float corepulsein = 0.5;
float corepulseout = 0.6;
float br,bg,bb;
int maxtweets = 5;
int tweetcount = 0;

ArrayList queue;

PrintWriter log;

Serial myPort; 


// This is where you enter your Oauth info
static String OAuthConsumerKey = "";
static String OAuthConsumerSecret = "";
// This is where you enter your Access Token info
static String AccessToken = "";
static String AccessTokenSecret = "";
String keywords[] = { "#AaronSwartz","#aaronswartz","aaron swartz","#pdftribute", "#openaccess","#opAngel","#OpenTeaching" }; // what to look for.

///////////////////////////// End Variable Config ////////////////////////////

TwitterStream twitter = new TwitterStreamFactory().getInstance();

void setup() {
myPort = new Serial(this, Serial.list()[0], 9600);

  size(1024, 768);
  smooth();
  frameRate(30);
  noFill();
  noStroke();
  br = 20;
  bg = 20;
  bb = 35;
  RG.init(this);
  Ani.init(this);
  core = loadImage("core.png");
  corersf = corepulsein;
  screenBuf = new int[width*height];
  font = new RFont("C64_User_Mono_v1.0-STYLE.ttf");
  RG.textFont(font,20);
  cpos = new PVector(width/2, height+20);
  font.setSize(10);
  font.forceAscii = true;
  font.align = RFont.LEFT;
  tweets = new ArrayList();
  ctweet = new Tweet(tt, cpos, this);
  tweets.add(ctweet);
  float coretime = 3;
  coreseq = new AniSequence(this);
  coreseq.beginSequence();
  coreseq.beginStep();  
  coreseq.add(Ani.to(this, coretime, "corersf", corepulseout, Ani.BACK_IN));
  coreseq.endStep();
  coreseq.beginStep();  
  coreseq.add(Ani.to(this, coretime, "corersf", corepulsein, Ani.BACK_OUT, "onEnd:coreSequenceEnd"));
  coreseq.endStep();
  coreseq.endSequence();
  coreseq.start();
  ntseq = new AniSequence(this);
  ntseq.beginSequence();
  ntseq.beginStep();  
  ntseq.add(Ani.to(this, 2, "corersf", 1, Ani.CIRC_IN));
  ntseq.add(Ani.to(this, 2, "br", 255, Ani.CIRC_IN));
  ntseq.add(Ani.to(this, 2, "bg", 255, Ani.CIRC_IN));
  ntseq.add(Ani.to(this, 2, "bb", 255, Ani.CIRC_IN,"onEnd:flashEnd"));
  ntseq.endStep();
  ntseq.beginStep();
  ntseq.add(Ani.to(this, 2, "corersf", corepulsein, Ani.CIRC_OUT, "onEnd:ntSequenceEnd"));
  ntseq.add(Ani.to(this, 2, "br", 20, Ani.CIRC_IN));
  ntseq.add(Ani.to(this, 2, "bg", 20, Ani.CIRC_IN));
  ntseq.add(Ani.to(this, 2, "bb", 35, Ani.EXPO_IN));
  ntseq.endStep();
  ntseq.endSequence();
  
  connectTwitter();
  twitter.addListener(listener);
  if (keywords.length==0) twitter.sample();
  else twitter.filter(new FilterQuery().track(keywords));
  queue = new ArrayList();
  log = createWriter("log.csv"); 
  loadPixels();
  println(Serial.list());
 
}

void draw() {
  
  
  background(br, bg, bb);
  pushMatrix();
  translate(315,20);
  RG.text("Latest #AaronSwartz mentions on Twitter:");
  popMatrix();
  PImage tc = createImage(core.width, core.height, ARGB);
  for (int i = 0; i < tc.pixels.length; i++) {
    tc.pixels[i] = core.pixels[i];
  }
  tc.resize(int(corersf*core.width), int(corersf*core.height));
  image(tc, width/2-tc.width/2, height/2-tc.height/2);
  g.removeCache(tc);
  for (int i=0; i<tweets.size(); i++) {
    Tweet ct = (Tweet)tweets.get(i);
    if (!ct.done) {
      ct.display();
    }
    else{
      tweets.remove(i);
      //println("Removed:"+i);
    }
  }
  if (frameCount % 300 == 0) {
    checkQueue();
  }
  text(frameRate,width-50,20);
}

void stop() {
  log.flush();
  log.close();
} 

void addTweet(String text) {
ctweet.sendToBack();
  ctweet = new Tweet(text, cpos, this);
  tweets.add(ctweet);
  coreseq.pause();
  ntseq.start();
String m1[] = match(text,"#OpenTeaching");
if (m1 != null) {   myPort.write("a"); println ("yes cabron");
}

}

void addQueue(String text){
  queue.add(text);
}

void checkQueue(){
  if(queue.size()>0){
    addTweet((String)queue.get(0));
    queue.remove(0);
  }
}

void coreSequenceEnd() {
  coreseq.start();
}
void ntSequenceEnd() {
  coreseq.start();
}

void flashEnd(){
  if(tweets.size()>maxtweets){
    //println("Maxtweets");
    Tweet ft = (Tweet)tweets.get(0);
    ft.seq.pause();
    ft.r = ft.g = ft.b = 255;
    ft.done = true;
  }  
}

// Initial connection
void connectTwitter() {
  twitter.setOAuthConsumer(OAuthConsumerKey, OAuthConsumerSecret);
  AccessToken accessToken = loadAccessToken();
  twitter.setOAuthAccessToken(accessToken);
}

// Loading up the access token
private static AccessToken loadAccessToken() {
  return new AccessToken(AccessToken, AccessTokenSecret);
}

// This listens for new tweet
StatusListener listener = new StatusListener() {
  
  public void onStatus(Status status) {
    //println(" @" + status.getUser().getScreenName() + " - " + status.getText());
    tweetcount++;
    String out = String.valueOf(day())+"-"+String.valueOf(month())+"-"+String.valueOf(year())+" "+String.valueOf(hour())+":"+String.valueOf(minute())+":"+String.valueOf(second())+";"+status.getUser().getScreenName()+";"+status.getText();
    println(out);
    logMsg(out);
    addQueue(status.getText());
  }

  public void onDeletionNotice(StatusDeletionNotice statusDeletionNotice) {
    //System.out.println("Got a status deletion notice id:" + statusDeletionNotice.getStatusId());
  }
  public void onTrackLimitationNotice(int numberOfLimitedStatuses) {
    //System.out.println("Got track limitation notice:" + numberOfLimitedStatuses);
  }
  public void onScrubGeo(long userId, long upToStatusId) {
    //System.out.println("Got scrub_geo event userId:" + userId + " upToStatusId:" + upToStatusId);
  }
  public void onStallWarning(StallWarning warning) {
    //System.out.println("Got a stall warning:" + warning);
  }
  public void onException(Exception ex) {
    ex.printStackTrace();
  }

};
void logMsg(String msg){
  log.println(msg);
  log.flush();
}
// 0a0
// aba
// 0a0
// 4*a + b in total, >>> c
void shiftBlur(final int[] s, final int[] t, final int a, final int b, final int c) {
  int yOffset;
  for (int i = 1; i < (width-1); ++i) {

    yOffset = width*(height-1);
    // top edge (minus corner pixels)
    t[i] = (((((s[i] & 0xFF) * b) + 
      ((s[i+1] & 0xFF) + 
      (s[i-1] & 0xFF) + 
      (s[i + width] & 0xFF) + 
      (s[i + yOffset] & 0xFF)) * a) >>> c)  & 0xFF) +
      (((((s[i] & 0xFF00) * b) + 
      ((s[i+1] & 0xFF00) + 
      (s[i-1] & 0xFF00) + 
      (s[i + width] & 0xFF00) + 
      (s[i + yOffset] & 0xFF00)) * a) >>> c)  & 0xFF00) +
      (((((s[i] & 0xFF0000) * b) + 
      ((s[i+1] & 0xFF0000) + 
      (s[i-1] & 0xFF0000) + 
      (s[i + width] & 0xFF0000) + 
      (s[i + yOffset] & 0xFF0000)) * a) >>> c)  & 0xFF0000) +
      0xFF000000; //ignores transparency

    // bottom edge (minus corner pixels)
    t[i + yOffset] = (((((s[i + yOffset] & 0xFF) * b) + 
      ((s[i - 1 + yOffset] & 0xFF) + 
      (s[i + 1 + yOffset] & 0xFF) +
      (s[i + yOffset - width] & 0xFF) +
      (s[i] & 0xFF)) * a) >>> c) & 0xFF) +
      (((((s[i + yOffset] & 0xFF00) * b) + 
      ((s[i - 1 + yOffset] & 0xFF00) + 
      (s[i + 1 + yOffset] & 0xFF00) +
      (s[i + yOffset - width] & 0xFF00) +
      (s[i] & 0xFF00)) * a) >>> c) & 0xFF00) +
      (((((s[i + yOffset] & 0xFF0000) * b) + 
      ((s[i - 1 + yOffset] & 0xFF0000) + 
      (s[i + 1 + yOffset] & 0xFF0000) +
      (s[i + yOffset - width] & 0xFF0000) +
      (s[i] & 0xFF0000)) * a) >>> c) & 0xFF0000) +
      0xFF000000;    

    // central square
    for (int j = 1; j < (height-1); ++j) {
      yOffset = j*width;
      t[i + yOffset] = (((((s[i + yOffset] & 0xFF) * b) +
        ((s[i + 1 + yOffset] & 0xFF) +
        (s[i - 1 + yOffset] & 0xFF) +
        (s[i + yOffset + width] & 0xFF) +
        (s[i + yOffset - width] & 0xFF)) * a) >>> c) & 0xFF) +
        (((((s[i + yOffset] & 0xFF00) * b) +
        ((s[i + 1 + yOffset] & 0xFF00) +
        (s[i - 1 + yOffset] & 0xFF00) +
        (s[i + yOffset + width] & 0xFF00) +
        (s[i + yOffset - width] & 0xFF00)) * a) >>> c) & 0xFF00) +
        (((((s[i + yOffset] & 0xFF0000) * b) +
        ((s[i + 1 + yOffset] & 0xFF0000) +
        (s[i - 1 + yOffset] & 0xFF0000) +
        (s[i + yOffset + width] & 0xFF0000) +
        (s[i + yOffset - width] & 0xFF0000)) * a) >>> c) & 0xFF0000) +
        0xFF000000;
    }
  }

  // left and right edge (minus corner pixels)
  for (int j = 1; j < (height-1); ++j) {
    yOffset = j*width;
    t[yOffset] = (((((s[yOffset] & 0xFF) * b) +
      ((s[yOffset + 1] & 0xFF) +
      (s[yOffset + width - 1] & 0xFF) +
      (s[yOffset + width] & 0xFF) +
      (s[yOffset - width] & 0xFF) ) * a) >>> c) & 0xFF) +
      (((((s[yOffset] & 0xFF00) * b) +
      ((s[yOffset + 1] & 0xFF00) +
      (s[yOffset + width - 1] & 0xFF00) +
      (s[yOffset + width] & 0xFF00) +
      (s[yOffset - width] & 0xFF00) ) * a) >>> c) & 0xFF00) +
      (((((s[yOffset] & 0xFF0000) * b) +
      ((s[yOffset + 1] & 0xFF0000) +
      (s[yOffset + width - 1] & 0xFF0000) +
      (s[yOffset + width] & 0xFF0000) +
      (s[yOffset - width] & 0xFF0000) ) * a) >>> c) & 0xFF0000) +
      0xFF000000;

    t[yOffset + width - 1] = (((((s[yOffset + width - 1] & 0xFF) * b) +
      ((s[yOffset] & 0xFF) +
      (s[yOffset + width - 2] & 0xFF) +
      (s[yOffset + (width<<1) - 1] & 0xFF) +
      (s[yOffset - 1] & 0xFF)) * a) >>> c) & 0xFF) +
      (((((s[yOffset + width - 1] & 0xFF00) * b) +
      ((s[yOffset] & 0xFF00) +
      (s[yOffset + width - 2] & 0xFF00) +
      (s[yOffset + (width<<1) - 1] & 0xFF00) +
      (s[yOffset - 1] & 0xFF00)) * a) >>> c) & 0xFF00) +
      (((((s[yOffset + width - 1] & 0xFF0000) * b) +
      ((s[yOffset] & 0xFF0000) +
      (s[yOffset + width - 2] & 0xFF0000) +
      (s[yOffset + (width<<1) - 1] & 0xFF0000) +
      (s[yOffset - 1] & 0xFF0000)) * a) >>> c) & 0xFF0000) +
      0xFF000000;
  }

  // corner pixels
  t[0] = (((((s[0] & 0xFF) * b) + 
    ((s[1] & 0xFF) + 
    (s[width-1] & 0xFF) + 
    (s[width] & 0xFF) + 
    (s[width*(height-1)] & 0xFF)) * a) >>> c)  & 0xFF) +
    (((((s[0] & 0xFF00) * b) + 
    ((s[1] & 0xFF00) + 
    (s[width-1] & 0xFF00) + 
    (s[width] & 0xFF00) + 
    (s[width*(height-1)] & 0xFF00)) * a) >>> c)  & 0xFF00) +
    (((((s[0] & 0xFF0000) * b) + 
    ((s[1] & 0xFF0000) + 
    (s[width-1] & 0xFF0000) + 
    (s[width] & 0xFF0000) + 
    (s[width*(height-1)] & 0xFF0000)) * a) >>> c)  & 0xFF0000) +
    0xFF000000;

  t[width - 1 ] = (((((s[width-1] & 0xFF) * b) + 
    ((s[width-2] & 0xFF) + 
    (s[0] & 0xFF) + 
    (s[(width<<1) - 1] & 0xFF) + 
    (s[width*height-1] & 0xFF) ) * a) >>> c) & 0xFF) +
    (((((s[width-1] & 0xFF00) * b) + 
    ((s[width-2] & 0xFF00) + 
    (s[0] & 0xFF00) + 
    (s[(width<<1) - 1] & 0xFF00) + 
    (s[width*height-1] & 0xFF00) ) * a) >>> c) & 0xFF00) +
    (((((s[width-1] & 0xFF0000) * b) + 
    ((s[width-2] & 0xFF0000) + 
    (s[0] & 0xFF0000) + 
    (s[(width<<1) - 1] & 0xFF0000) + 
    (s[width*height-1] & 0xFF0000) ) * a) >>> c) & 0xFF0000) +
    0xFF000000;

  t[width * height - 1] = (((((s[width*height-1] & 0xFF) * b) + 
    ((s[width-1] & 0xFF) + 
    (s[width*(height-1)-1] & 0xFF) + 
    (s[width*height-2] & 0xFF) + 
    (s[width*(height-1)] & 0xFF) ) * a) >>> c) & 0xFF) +
    (((((s[width*height-1] & 0xFF00) * b) + 
    ((s[width-1] & 0xFF00) + 
    (s[width*(height-1)-1] & 0xFF00) + 
    (s[width*height-2] & 0xFF00) + 
    (s[width*(height-1)] & 0xFF00) ) * a) >>> c) & 0xFF00) +
    (((((s[width*height-1] & 0xFF0000) * b) + 
    ((s[width-1] & 0xFF0000) + 
    (s[width*(height-1)-1] & 0xFF0000) + 
    (s[width*height-2] & 0xFF0000) + 
    (s[width*(height-1)] & 0xFF0000) ) * a) >>> c) & 0xFF0000) +
    0xFF000000;

  t[width *(height-1)] = (((((s[width*(height-1)] & 0xFF) * b) + 
    ((s[width*(height-1) + 1] & 0xFF) + 
    (s[width*height-1] & 0xFF) + 
    (s[width*(height-2)] & 0xFF) + 
    (s[0] & 0xFF) ) * a) >>> c) & 0xFF) +
    (((((s[width*(height-1)] & 0xFF00) * b) + 
    ((s[width*(height-1) + 1] & 0xFF00) + 
    (s[width*height-1] & 0xFF00) + 
    (s[width*(height-2)] & 0xFF00) + 
    (s[0] & 0xFF00) ) * a) >>> c) & 0xFF00) +
    (((((s[width*(height-1)] & 0xFF0000) * b) + 
    ((s[width*(height-1) + 1] & 0xFF0000) + 
    (s[width*height-1] & 0xFF0000) + 
    (s[width*(height-2)] & 0xFF0000) + 
    (s[0] & 0xFF0000) ) * a) >>> c) & 0xFF0000) +
    0xFF000000;
}


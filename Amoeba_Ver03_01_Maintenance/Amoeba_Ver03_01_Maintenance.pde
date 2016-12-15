// AMOEBA MORBUS | Ver 03.01
// TYLER YIN
// cargocollective.com/tyleryin

///////////////////////////////////////////////////////////////////////
// IMPORT LIBRARIES
///////////////////////////////////////////////////////////////////////

import java.util.*;
import processing.video.*;

///////////////////////////////////////////////////////////////////////
// DEFINE OBJECTS, VARIABLES, CONSTANTS
///////////////////////////////////////////////////////////////////////

// Constants
int NUM = 175;
int VAL = 20;
int RESET = 1800; // remove if you're going to go by counter rather than time

// Variables
int nodeCount, nodeMean, nodeStdDev;
float virusSpread;
float virusMotion = 105;
float virusForce = -0.5;
float virusAccel = 0; 
float virusVel = 0;
int counter = 0;
float alpha = 0;

// Booleans
boolean trigger = false;

// Display
int d = displayDensity();
PShape scope;

// Camera Vision
Capture video;
PImage prevFrame;

// Randomness
Random generator;

// Microbes
ArrayList<Microbe> microbes;

///////////////////////////////////////////////////////////////////////
// SET UP
///////////////////////////////////////////////////////////////////////

void setup() {
  // Display
  //size(1280, 720, P2D);  
  fullScreen(P2D); 
  pixelDensity(d);
  frameRate(30);
  noCursor();
  smooth(); 
  ellipseMode(CENTER);
  scope = loadShape("scope.svg");

  // Camera Vision
  //   Open GETTINGSTARTEDCAPTURE for list of available cameras
  //   Available cameras:
  //    [0] "name=FaceTime HD Camera (Built-in),size=1280x720,fps=30"
  //    [3] "name=FaceTime HD Camera (Built-in),size=640x360,fps=30"
  //    [6] "name=FaceTime HD Camera (Built-in),size=320x180,fps=30"
  //    [9] "name=FaceTime HD Camera (Built-in),size=160x90,fps=30"
  video = new Capture(this, 640, 360, "FaceTime HD Camera (Built-in)", 30);
  video.start();
  prevFrame = createImage(video.width, video.height, RGB);

  // Randomness
  generator = new Random();
  nodeMean = 11;
  nodeStdDev = nodeMean-3;

  // Microbes
  microbes = new ArrayList<Microbe>();
  createMicrobes();
}

///////////////////////////////////////////////////////////////////////
// DRAW
///////////////////////////////////////////////////////////////////////

void draw() {
  // Display
  background(0);

  // Camera Vision
  video.loadPixels();
  prevFrame.loadPixels();
  float totalMotion = 0;

  // Counter
  counter++; //remove if you're going to go by counter rather than time

  // Microbes
  for (int i = microbes.size()-1; i >= 0; i--) {
    Microbe microbe = microbes.get(i);
    microbe.drawShape();
    microbe.moveShape();
    microbe.colorChange();
    microbe.avoid(microbes);
    microbe.align(microbes);
    microbe.borders();
  }

  // Motion Sensing
  for (int i = 0; i < video.pixels.length; i++) {
    color current = video.pixels[i];
    color previous = prevFrame.pixels[i];
    float r1 = red(current); 
    float g1 = green(current);
    float b1 = blue(current);
    float r2 = red(previous); 
    float g2 = green(previous);
    float b2 = blue(previous);
    float diff = dist(r1, g1, b1, r2, g2, b2); //dist(r1, g1, r2, g2);
    totalMotion += diff;
  } 
  float avgMotion = totalMotion / video.pixels.length;

  // Virus               
  virusAccel = avgMotion;  
  virusVel += virusAccel + virusForce; 
  if (virusVel < -5) virusVel = -5;
  if (virusVel > 10) virusVel = 10;
  virusMotion += virusVel;

  if (virusMotion < 100) virusMotion = 100;
  if (virusMotion < 125) trigger = false;
  if (virusMotion >= 125) trigger = true;
  if (virusMotion > 500) virusMotion = 500;

  // ******************* BUGGY CODE *******************
  virusSpread = map(virusMotion, 0, 500, 200, 500);  // (virusMotion, 0, 500, 100, 700) 
  // ^^^^^^^^^^^^^^^^^^^ BUGGY CODE ^^^^^^^^^^^^^^^^^^^

  // Refresh
  if (counter > RESET || keyPressed) {
    alpha += 25.5;
    pushMatrix();
    fill(0, alpha);
    if (counter > RESET + 30 || keyPressed) {
      for (int i = microbes.size()-1; i >= 0; i--) microbes.remove(i);
      counter = 0;
      alpha = 0;
      createMicrobes();
      trigger = false;
    }
    rect(0, 0, width, height);
    popMatrix();
  }

  // Scope
  if (!mousePressed) {
    pushMatrix();
    //scale(0.5); // if DISPLAY is not fullscreen
    shape(scope, 0, 0);
    popMatrix();
  } 

  // Test -- Delete later
  else {
    fill(255);
    pushMatrix();
    scale(0.35);
    image(video, 0, 0);
    image(prevFrame, 0, video.height);
    popMatrix();
  }
  text("sensor: ", 50, 500);
  text(avgMotion, 100, 525); //totalMotion
  text("virus-v: ", 50, 550);
  text(virusVel, 100, 575);
  text(virusMotion, 100, 600);
  text("counter: ", 50, 625);
  text(counter, 100, 650);
  text("trigger: ", 50, 675);
  if (trigger == true) text("on", 100, 700);
  else text("off", 100, 700);
}

///////////////////////////////////////////////////////////////////////
// CREATE MICROBES
///////////////////////////////////////////////////////////////////////

void createMicrobes() {
  //Middle Class Microbes
  for (int i = 0; i < NUM; i++) { 
    nodeMean = 11;
    nodeStdDev = nodeMean-3;
    nodeCount = abs((int) generator.nextGaussian());
    nodeCount = nodeCount * nodeStdDev;
    nodeCount += nodeMean;
    microbes.add(new Microbe(random(width/4-50, 3*width/4+50), random(height), nodeCount));
  }

  //Lower-middle Class Microbes
  for (int i = 0; i < (NUM/3); i++) {
    nodeMean = 9;
    nodeStdDev = 5;
    nodeCount = abs((int) generator.nextGaussian());
    nodeCount = nodeCount * nodeStdDev;
    nodeCount += nodeMean;
    microbes.add(new Microbe(random(width/4-50, 3*width/4+50), random(height), nodeCount));
  }

  //Lower Class Microbes
  for (int i = 0; i < (NUM/2); i++) {
    nodeMean = 4;
    nodeStdDev = 3;
    nodeCount = abs((int) generator.nextGaussian());
    nodeCount = nodeCount * nodeStdDev;
    nodeCount += nodeMean;
    microbes.add(new Microbe(random(width/4-50, 3*width/4+50), random(height), nodeCount));
  }

  //Upper-middle Class Microbes
  for (int i = 0; i < (NUM/100); i++) {
    nodeMean = 27;
    nodeStdDev = 10;
    nodeCount = abs((int) generator.nextGaussian());
    nodeCount = nodeCount * nodeStdDev;
    nodeCount += nodeMean;
    microbes.add(new Microbe(random(width/4-50, 3*width/4+50), random(height), nodeCount));
  }

  //Upper Class Microbe
  for (int i = 0; i < 1; i++) {
    nodeMean = 35;
    nodeStdDev = 11;
    nodeCount = abs((int) generator.nextGaussian());
    nodeCount = nodeCount * nodeStdDev;
    nodeCount += nodeMean;
    microbes.add(new Microbe(random(width/4-50, 3*width/4+50), random(height), nodeCount));
  }
}

///////////////////////////////////////////////////////////////////////
// CAPTURE EVENT
///////////////////////////////////////////////////////////////////////

void captureEvent(Capture video) {
  prevFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
  prevFrame.updatePixels();
  video.read();
}
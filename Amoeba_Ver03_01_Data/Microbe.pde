///////////////////////////////////////////////////////////////////////
// MICROBE CLASS
///////////////////////////////////////////////////////////////////////

class Microbe {

  // MOVEMENT
  PVector location, velocity, acceleration;
  float r, maxforce, maxspeed;
  float scopeR, theta;

  // MEMBRANE MOTION
  int nodes;
  float baseRadius, rotAngle, radius[], angle[], frequency[], amp[];
  PVector node[], nodeStart[], nodeDot[];
  //????????? VALUES ?????????// 
  float baseFreq = random(0.045, 0.15);
  float baseAmp = 0.125*nodeCount/VAL;
  float rand = random(-0.15, 0.15);
  float rand_ = random(-0.15, 0.15);

  // CORE
  float prob;
  float random = random(1);
  float coreRandom = random(0.1, 0.45);
  Organelle[] organelles = new Organelle[int(random(2, 9))];

  // COLOR
  color c, c1, c2;
  float hue, saturation, brightness;

  // BEHAVIOR
  boolean panic = true; //false???

  Microbe(float x, float y, int nodes_) {

    // MOVEMENT
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);
    location = new PVector(x, y);
    r = 6;
    maxspeed = random(0.15, 0.3)*(0.3*nodeCount);
    maxforce = random(0.05, 0.1);
    scopeR = width/3.7;
    theta = asin(location.y/scopeR);

    // MEMBRANE MOTION
    nodes = nodes_;
    nodeStart = new PVector[nodes];
    radius = new float[nodes];
    node = new PVector[nodes];
    nodeDot = new PVector[nodes];
    angle = new float[nodes];
    frequency = new float[nodes];
    amp = new float[nodes]; 
    baseRadius = 550/nodeCount; 

    for (int i = 0; i < nodes; i++) {
      radius[i] = random(2.5*width/(VAL*baseRadius), 3.5*width/(VAL*baseRadius));
    }
    for (int i = 0; i < nodes; i++) {
      frequency[i] = baseFreq
        + random(-0.01, 0.05);
      //if frequency is decreased, then decrease amp as well
      amp[i] = 0.9*baseAmp;
    }

    // CORE
    prob = 0.3;
    for (int i = 0; i < organelles.length; i++) {
      organelles[i] = new Organelle();
    }

    // COLOR
    colorMode(RGB, 255);
    c2 = color(      
      195-50 + random(-45, 55) + (4*nodeCount), 
      85-60 + random(-55, 55) + (2*nodeCount), 
      85-60 + random(-45, 45) + (2*nodeCount));
    c1 = color(
      95-20 + random(-45, 45) + (4*nodeCount), 
      60+95-10 + random(-55, 55) + (4*nodeCount), 
      195-100-20 + random(-45, 55) + (3*nodeCount));
    hue = hue(c1);
    saturation = saturation(c1);
    brightness = brightness(c1);
  }

  void drawShape() {
    pushMatrix();
    colorMode(HSB, 255);
    stroke(c);
    strokeWeight(1);
    noFill();
    popMatrix();

    // NODES
    for (int i=0; i<nodes; i++) {
      node[i] = new PVector(
        location.x+cos((rotAngle + rand))*radius[i], 
        location.y+sin((rotAngle + rand_))*radius[i]);
      nodeDot[i] = new PVector(
        location.x+cos((rotAngle + rand))*coreRandom*radius[i], 
        location.y+sin((rotAngle + rand_))*coreRandom*radius[i]);
      rotAngle += TWO_PI/nodes;
      if (rotAngle >= TWO_PI) {
        rotAngle -= TWO_PI;
      }
      if (rotAngle <= TWO_PI) {
        rotAngle += TWO_PI;
      }
    }
    beginShape();
    for (int i=0; i<nodes; i++) {
      curveVertex(node[i].x, node[i].y);
    }
    for (int i=0; i<nodes; i++) {
      curveVertex(node[i].x, node[i].y);
    }
    endShape();

    // NUCLEUS
    if (random > prob) {
      beginShape();
      //fill(c);
      for (int i=0; i<nodes; i++) {
        curveVertex(nodeDot[i].x, nodeDot[i].y);
      }
      for (int i=0; i<nodes; i++) {
        curveVertex(nodeDot[i].x, nodeDot[i].y);
      }
      endShape();
    }

    // ORGANELLES
    if (nodes > nodeMean*0.5) {
      pushMatrix();
      noStroke();
      colorMode(HSB, 255);
      fill(c);
      popMatrix();

      for (int i = 0; i < organelles.length; i++) {
        organelles[i].oscillate();
        organelles[i].display();
      }
    }
  }

  void moveShape() {
    for (int i = 0; i < nodes; i++) {
      float coefAmp = 4.5;
      float coefFreq = 3.5;
      if (panic == true && trigger == true) {
        coefAmp = 9;
        coefFreq = 7;
      }
      radius[i] += coefAmp*amp[i]*sin(angle[i]);
      angle[i] += coefFreq*frequency[i];      

      if ((angle[i] >= TWO_PI)) {
        angle[i] -= TWO_PI;
      }
      if ((radius[i] >= amp[i]*sin(angle[i]))) {
        radius[i] -= amp[i]*sin(angle[i]);
      }
    }

    velocity.add(acceleration);
    velocity.limit(maxspeed);
    location.add(velocity);
    acceleration.mult(0);
  }

  void colorChange() {
    pushMatrix();
    colorMode(HSB, 255);
    c = color(hue, saturation, brightness);
    popMatrix();

    if (panic == true && trigger == true) {
      if (hue < hue(c2)) {
        hue += 4;
      } else {
        hue -= 4;
      }
      if (saturation < saturation(c2)) {
        saturation++;
      } else {
        saturation --;
      }
      if (brightness < brightness(c2)) {
        brightness++;
      } else {
        brightness --;
      }
    } else {
      if (hue < hue(c1)) {
        hue++;
      } else {
        hue--;
      }
      if (saturation < saturation(c1)) {
        saturation++;
      } else {
        saturation --;
      }
      if (brightness < brightness(c1)) {
        brightness++;
      } else {
        brightness --;
      }
    }
  }

  void applyForce(PVector force) {
    acceleration.add(force);
  }

  void avoid (ArrayList<Microbe> microbes) {
    PVector separateForce = separate(microbes);
    separateForce.mult(2);
    applyForce(separateForce);
  }

  PVector separate (ArrayList<Microbe> microbes) {
    // VALUES  
    float desiredseparation = 10*width/(VAL*baseRadius); //r*0.15*nodeCount;
    if (panic == true && trigger == true) {
      float panicSep = width/25; // 125
      desiredseparation = r*panicSep + 3*nodeCount;
    }
    PVector sum = new PVector();
    int count = 0;

    for (Microbe other : microbes) {
      float d = PVector.dist(location, other.location);
      if ((d > 0) && (d < desiredseparation)) {
        PVector diff = PVector.sub(location, other.location);
        diff.normalize();
        diff.div(d);
        sum.add(diff);
        count++;
      }
      // FUNCTIONALITY  
      // ******************* BUGGY CODE *******************
      // if ((d > 500 - virusSpread) && (d < 500 + 1.25*virusSpread)) panic = true;
      if ((d > 500 - 1.5*virusSpread) && (d < 500 + 1.5*virusSpread)) panic = true;
      else panic = false;
      // ^^^^^^^^^^^^^^^^^^^ BUGGY CODE ^^^^^^^^^^^^^^^^^^^
    }
    if (count > 0) {
      sum.div(count);
      sum.normalize();
      sum.mult(maxspeed);
      sum.sub(velocity);
      sum.limit(maxforce);
    }
    return sum;
  }

  void align (ArrayList<Microbe> microbes) {
    float neighbordist = 45;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Microbe other : microbes) {
      float d = PVector.dist(location, other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      applyForce(steer);
    }
  }

  // WRAP-AROUND
  void borders() {
    //CIRCLE
    if (dist(location.x, location.y, width/2, height/2) > scopeR) {
      theta = theta - PI;
      location.x = width/2 + 0.95*(scopeR * cos(theta));
      location.y = height/2 + 0.95*(scopeR * sin(theta));
    }
  }

  // ORGANELLE
  class Organelle {
    PVector angle;
    PVector velocity;
    PVector amplitude;
    PVector maxVel, minVel;

    Organelle () {
      angle = new PVector();
      velocity = new PVector(random(-0.15, 0.15), random(-0.15, 0.15));
      amplitude = new PVector(random(width/300, width/700), random(width/200, width/500));
      maxVel = new PVector(random(-0.35, 0.35), random(-0.35, 0.35));
      minVel = velocity.copy();
    }

    void oscillate() {
      angle.add(velocity);
      if (panic == true && trigger == true) {
        velocity.add(-0.05, 0.05);
        velocity.set(maxVel);
      } else {
        velocity.sub(-0.05, 0.05);
        velocity.set(minVel);
      }
    }   

    void display() {
      float x = sin(angle.x)*amplitude.x;
      float y = sin(angle.y)*amplitude.y;

      pushMatrix();
      translate(location.x, location.y);
      colorMode(HSB, 255);
      stroke(c);
      noFill();
      ellipse(x, y, width/(VAL*33), width/(VAL*33)); 
      popMatrix();
    }
  }
}
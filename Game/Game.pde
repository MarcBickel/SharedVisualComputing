void settings() {
  fullScreen(P3D);
}

void setup() {
  noStroke();
  mover = new Mover();
}

float angleX = 0f;
float angleZ = 0f;
float rotationSpeed = 0.005f;
float rX;
float rZ;
float cylinderX;
float cylinderY;
int lastMouseX;
int lastMouseY;

float boxThickness = 24f;
float boxSize = 800f;

Mover mover;
enum Mode {
  GAMER, PLACER
}
Mode mode = Mode.GAMER;
ArrayList<PVector> cylinders = new ArrayList();
Cylinder cylinder = new Cylinder();

void draw() {
  background(200); 
  camera();
  
  switch (mode) {
    case GAMER:
      directionalLight(255, 195, 0, 1, 1, 0);
      ambientLight(102, 102, 102);
      pushMatrix();
      fill(247, 202, 201);
      rX = map(angleX, -1, 1, -PI / 3, PI / 3);
      rZ = map(angleZ, -1, 1, -PI / 3, PI / 3);
      translate(width/2, height/2);
      rotateX(rX);
      rotateZ(rZ);
      for (PVector vect : cylinders) {
        cylinder.drawCylinder(vect);
      }
      fill(104, 100, 48);
      drawBoard();
      fill(0, 0, 0);
      mover.update();
      mover.checkEdges();
      mover.checkCylinderCollision();
      mover.display();
      popMatrix();
      break;
    case PLACER: 
      
      pushMatrix();
      directionalLight(50, 100, 125, -1, -1, -1);
      ambientLight(102, 102, 102);
      fill(104, 100, 48);
      translate(width/2, height/2,0);
      rotateX(-PI / 2);
      drawBoard();
      fill(247, 202, 201);
      for (PVector vect : cylinders) {
        cylinder.drawCylinder(vect);
      }
      cylinderX = mouseX - width/2;
      cylinderY = mouseY - height / 2;
      cylinder.drawCylinder(new PVector(cylinderX, cylinderY));
      
      fill(0, 0, 0);
      mover.display();
      popMatrix();
      break;
    default: 
      break;
  }
}

void drawBoard() {
  switch(mode) {
    case GAMER: 
      break;
    case PLACER :
      break;
    default: 
      break;  
  }  
  box(boxSize, boxThickness, boxSize);
}

boolean closerThan(PVector v1, PVector v2, float dist) {
  return dist(v1.x, v1.y, v2.x, v2.y) < dist;
}



void keyPressed() {
  if (keyCode == SHIFT) {
    mode = Mode.PLACER;
  }
}

void keyReleased() {
  if (keyCode == SHIFT) {
    mode = Mode.GAMER;
  }
}

void mouseDragged() {
  switch (mode) {
    case GAMER:
      // modifies the value of angleX, angleZ from -1 to 1
      angleZ += (mouseX - lastMouseX) * rotationSpeed;
      angleX -= (mouseY - lastMouseY) * rotationSpeed;
      if (angleX > 1) angleX = 1;
      if (angleX < -1) angleX = -1;
      if (angleZ > 1) angleZ = 1;
      if (angleZ < -1) angleZ = -1;
      lastMouseX = mouseX;
      lastMouseY = mouseY;
      break;
    case PLACER:
      break;
  }
}

void mousePressed() {
  switch (mode) {
    case GAMER: 
      lastMouseX = mouseX;
      lastMouseY = mouseY;
      break;
    case PLACER:
      PVector actual = new PVector(cylinderX, cylinderY);
      boolean adding = true;
      
      for (PVector vect : cylinders) {
        if (closerThan(actual, vect, cylinder.cylinderBaseSize * 2.5)) {
          adding = false;
        }
      }
      if (closerThan(new PVector(mover.location.x, mover.location.z), actual, mover.radiusSphere + cylinder.cylinderBaseSize)) {
        adding = false;
      }
      if (cylinderX > boxSize/2 || cylinderX < -boxSize/2 || cylinderY < -boxSize/2 || cylinderY > boxSize/2) {
        adding = false;
      }
      if (adding) {
        cylinders.add(actual);
      }
      break;
  }
  
}

void mouseWheel(MouseEvent event) {
  final float maxRotationSpeed = 0.010f;
  final float minRotationSpeed = 0.001f;
  float e = event.getCount();
  
  rotationSpeed -= (e / 6000f);
  if (rotationSpeed < minRotationSpeed) {
    rotationSpeed = minRotationSpeed;
  } else if (rotationSpeed > maxRotationSpeed) {
    rotationSpeed = maxRotationSpeed;
  }
}
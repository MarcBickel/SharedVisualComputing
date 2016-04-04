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
Mover mover;
enum Mode {
  GAMER, PLACER
}
Mode mode = Mode.GAMER;
ArrayList<PVector> cylinders = new ArrayList();
Cylinder cylinder = new Cylinder();

void draw() {
  background(200);
  
  switch (mode) {
    case GAMER: 
      camera(0, 0, 200, 0, 0, 0, 0, 1, 0);
      directionalLight(255, 195, 0, 1, 1, 0);
      ambientLight(102, 102, 102);
      pushMatrix();
      fill(247, 202, 201);
      rX = map(angleX, -1, 1, -PI / 3, PI / 3);
      rZ = map(angleZ, -1, 1, -PI / 3, PI / 3);
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
      camera(0, 0, 100, 0, 0, 0, 0, 1, 0);
      directionalLight(50, 100, 125, -1, -1, -1);
      ambientLight(102, 102, 102);
      fill(104, 100, 48);
      pushMatrix();
      rotateX(-PI / 2);
      cylinderX = map(mouseX, 0f, width, -50, 50);
      cylinderY = map(mouseY, 0f, height, -50, 50);
      drawBoard();
      fill(247, 202, 201);
      for (PVector vect : cylinders) {
        cylinder.drawCylinder(vect);
      }
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
  box(100, 3, 100);
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
        if (closerThan(actual, vect, cylinder.cylinderBaseSize * 2)) {
          adding = false;
        }
      }
      if (closerThan(new PVector(mover.location.x, mover.location.z), actual, mover.radiusSphere + cylinder.cylinderBaseSize)) {
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
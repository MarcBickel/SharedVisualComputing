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
int lastMouseX;
int lastMouseY;
Mover mover;
enum Mode {
  GAMER, PLACER
}
Mode mode = Mode.GAMER;

void draw() {
  background(200);
  switch (mode) {
    case GAMER: 
      camera(width / 2, height / 2, 200, width / 2, height / 2, 0, 0, 1, 0);
      directionalLight(50, 100, 125, 1, 1, 0);
      ambientLight(102, 102, 102);
      drawBoard();
      mover.update();
      mover.checkEdges();
      mover.display();
      break;
    case PLACER: 
      break;
    default: 
      break;
  }
}

void drawBoard() {
  pushMatrix();
  translate(width / 2, height / 2, 0);
  rX = map(angleX, -1, 1, -PI / 3, PI / 3);
  rZ = map(angleZ, -1, 1, -PI / 3, PI / 3);
  switch(mode) {
    case GAMER: 
      rotateX(rX);
      rotateZ(rZ);
      break;
    case PLACER :
      rotateX(0);
      rotateZ(0);
      break;
    default: 
      break;  
  }  
  box(100, 3, 100);
  popMatrix();
}

void keyPressed() {
  if (keyCode == SHIFT) {
    mode = Mode.PLACER;
  }
}

void mouseDragged() {
  // modifies the value of angleX, angleZ from -1 to 1
  angleZ += (mouseX - lastMouseX) * rotationSpeed;
  angleX -= (mouseY - lastMouseY) * rotationSpeed;
  if (angleX > 1) angleX = 1;
  if (angleX < -1) angleX = -1;
  if (angleZ > 1) angleZ = 1;
  if (angleZ < -1) angleZ = -1;
  lastMouseX = mouseX;
  lastMouseY = mouseY;
}

void mousePressed() {
  lastMouseX = mouseX;
  lastMouseY = mouseY;
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
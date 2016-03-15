void settings() {
  size(500, 500, P3D);
}

void setup() {
  noStroke();
}

float angleX = 0f;
float angleZ = 0f;
float rotationSpeed = 0.005f;
int lastMouseX;
int lastMouseY;
final float maxRotationSpeed = 0.010f;
final float minRotationSpeed = 0.001f;

void draw() {
  camera(width / 2, height / 2 - 50, 200, 250, 250, 0, 0, 1, 0);
  background(200);
  lights();
  translate(width / 2, height / 2, 0);
  float rX = map(angleX, -1, 1, -PI / 3, PI / 3);
  float rZ = map(angleZ, -1, 1, -PI / 3, PI / 3);
  rotateX(rX);
  rotateZ(rZ);
  box(100, 3, 100);
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
  float e = event.getCount();
  rotationSpeed -= (e / 6000f);
  if (rotationSpeed < minRotationSpeed) {
    rotationSpeed = minRotationSpeed;
  } else if (rotationSpeed > maxRotationSpeed) {
    rotationSpeed = maxRotationSpeed;
  }
}
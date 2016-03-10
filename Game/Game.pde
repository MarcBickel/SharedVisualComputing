void settings() {
  size(500, 500, P3D);
}

void setup() {
  noStroke();
}

float angleX = 0f;
float angleZ = 0f;
float rotationSpeed = 0.01f;
int mouseReleasedX = width / 2;
int mouseReleasedY = height / 2;

void draw() {
  camera(width / 2, height / 2 - 50, 200, 250, 250, 0, 0, 1, 0);
  background(255, 0, 255);
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
  angleX = map(mouseY, 0, height, 1, -1);
  angleZ = map(mouseX, 0, width, -1, 1);
}

void mouseReleased() {
  mouseReleasedX = mouseX;
  mouseReleasedY = mouseY;
}
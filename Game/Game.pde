void settings() {
  size(500, 500, P3D);
}

void setup() {
  //noStroke();
}

float angleX = 1f;
float angleZ = 0f;
float rotationSpeed = 1f;
float p = -1f;
float q = -1f;

void draw() {
  p += 0.01;
  q += 0.01;
  camera(width / 2, height / 2, 200, 250, 250, 0, 0, 1, 0);
  background(255, 255, 255);
  lights();
  translate(width / 2, height / 2, 0);
  if (p > 1) {
    noLoop();
  }
  float rX = map(p, -1, 1, -PI / 6, PI / 6);
  float rZ = map(q, -1, 1, -PI / 6, PI / 6);
  rotateX(rX);
  rotateZ(rZ);
  pushMatrix();
  box(100, 5, 100);
  popMatrix();
}

void mouseDragged() {
  // modifies the value of angleX, angleZ from 0 to 1
}
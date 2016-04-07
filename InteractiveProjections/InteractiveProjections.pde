class My2DPoint {
  float x;
  float y;
  My2DPoint(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

class My3DPoint {
  float x;
  float y;
  float z;
  My3DPoint(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

class My2DBox {
  My2DPoint[] s;
  My2DBox(My2DPoint[] s) {
    this.s = s;
  }
  void render() {
    drawLine(s[0], s[1]);
    drawLine(s[0], s[4]);
    drawLine(s[0], s[3]);
    drawLine(s[1], s[2]);
    drawLine(s[1], s[5]);
    drawLine(s[2], s[6]);
    drawLine(s[2], s[3]);
    drawLine(s[3], s[7]);
    drawLine(s[4], s[5]);
    drawLine(s[4], s[7]);
    drawLine(s[6], s[7]);
    drawLine(s[5], s[6]);
  }
  void drawLine(My2DPoint p1, My2DPoint p2) {
    line(p1.x, p1.y, p2.x, p2.y);
  }
}

class My3DBox {
  My3DPoint[] p;
  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ){
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[] {
                              new My3DPoint(x, y + dimY, z + dimZ),
                              new My3DPoint(x, y, z + dimZ),
                              new My3DPoint(x + dimX, y, z + dimZ),
                              new My3DPoint(x + dimX, y + dimY, z + dimZ),
                              new My3DPoint(x, y + dimY, z),
                              origin,
                              new My3DPoint(x + dimX, y, z),
                              new My3DPoint(x + dimX, y + dimY, z)
                             };
  }
  My3DBox(My3DPoint[] p) {
    this.p = p;
  }
} 

void settings() {
  size(700, 700, P2D);
}

void setup () {

}
  
My3DPoint eye = new My3DPoint(0, 0, -5000);
My3DPoint origin = new My3DPoint(150, 150, 150);
My3DBox input3DBox = new My3DBox(origin, 100, 100, 100);
float angleX = 0f;
float angleY = 0f;
float scale = 1f;
int lastX;

void draw() {
  background(255, 255, 255);
  lastX = mouseX;
  projectBox(eye, input3DBox).render();
}

My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
  float w = (eye.z - p.z) / eye.z;
  return new My2DPoint((p.x - eye.x) / w, (p.y - eye.y) / w);
}

My2DBox projectBox(My3DPoint eye, My3DBox box) {
  My2DPoint[] s = new My2DPoint[8];
  for (int i = 0; i < 8; ++i) {
    s[i] = projectPoint(eye, box.p[i]);
  }
  return new My2DBox(s);
}

float[] homogeneous3DPoint(My3DPoint p) {
  float[] result = { p.x, p.y, p.z, 1 };
  return result;
}

float[][] rotateXMatrix(float angle) {
  return new float[][] {
    { 1, 0, 0, 0 },
    { 0, cos(angle), sin(angle), 0 },
    { 0, -sin(angle), cos(angle), 0 },
    { 0, 0, 0, 1 }
  };
}

float[][] rotateYMatrix(float angle) {
  return new float[][] {
    { cos(angle), 0, sin(angle), 0 },
    { 0, 1, 0, 0 },
    { -sin(angle), 0, cos(angle), 0 },
    { 0, 0, 0, 1 }
  };
}

float[][] rotateZMatrix(float angle) {
  return new float[][] {
    { cos(angle), -sin(angle), 0, 0 },
    { sin(angle), cos(angle), 0, 0 },
    { 0, 0, 1, 0 },
    { 0, 0, 0, 1 }
  };
}

float[][] scaleMatrix(float x, float y, float z) {
  return new float[][] {
    { x, 0, 0, 0 },
    { 0, y, 0, 0 },
    { 0, 0, z, 0 },
    { 0, 0, 0, 1 }
  };
}

float[][] translationMatrix(float x, float y, float z) {
  return new float[][] {
    { 1, 0, 0, x },
    { 0, 1, 0, y },
    { 0, 0, 1, z },
    { 0, 0, 0, 1 }
  };
}

float[] matrixProduct(float[][] a, float[] b) {
  float[] c = new float[4];
  for (int i = 0; i < 4; ++i) {
    for (int j = 0; j < 4; ++j) {
      c[i] += a[i][j] * b[j];
    }
  }
  return c;
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  My3DPoint[] p = new My3DPoint[8];
  for (int i = 0; i < 8; ++i) {
    float[] temp = matrixProduct(transformMatrix, homogeneous3DPoint(box.p[i]));
    p[i] = new My3DPoint(temp[0], temp[1], temp[2]);
  }
  return new My3DBox(p);
}

My3DPoint euclidian3DPoint(float[] a) {
  My3DPoint result = new My3DPoint(a[0] / a[3],
                                   a[1] / a[3],
                                   a[2] / a[3]);
  return result;
}

void mouseDragged() {
  if (mouseX > lastX) {
    scale += 0.01;
  } else {
    scale -= 0.01;
  }
  input3DBox = transformBox(input3DBox, scaleMatrix(scale, scale, scale));
}

void keyPressed() {
  switch(keyCode) {
    case LEFT: angleY += 0.001; break;
    case RIGHT: angleY -= 0.001; break;
    case UP: angleX += 0.001; break;
    case DOWN: angleX -= 0.001; break;
    default: break;
  }
  input3DBox = transformBox(transformBox(input3DBox, rotateYMatrix(angleY)), rotateXMatrix(angleX));
}
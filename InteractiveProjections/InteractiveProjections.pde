void settings() {
  size (1000, 1000, P2D);
}
void setup() {
}
void draw() {
  background(255, 255, 255);
  projectBox(eye, input3DBox).render();
}


My3DPoint eye = new My3DPoint(0, 0, -5000);
My3DPoint origin = new My3DPoint(250, 250, 250);
My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);

void mouseDragged() {
  input3DBox = transformBox(input3DBox, scaleMatrix(1.1, 1.1, 1.1));
}

void mouseMoved() {
  input3DBox = transformBox(input3DBox, scaleMatrix(0.9, 0.9, 0.9));
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      input3DBox = transformBox(input3DBox, rotateXMatrix(-PI/200));
    } else if (keyCode == DOWN) {
      input3DBox = transformBox(input3DBox, rotateXMatrix(PI/200));
    } else if (keyCode == LEFT) {
      input3DBox = transformBox(input3DBox, rotateYMatrix(-PI/200));
    } else if (keyCode == RIGHT) {
      input3DBox = transformBox(input3DBox, rotateYMatrix(PI/200));
    }
  }
}

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

My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
  float c = eye.z / (eye.z - p.z);
  return new My2DPoint(c * (p.x - eye.x), c * (p.y - eye.y));
}

class My2DBox {
  My2DPoint[] s;
  My2DBox(My2DPoint[] s) {
    this.s = s;
  }
  void render(){
    line(s[0].x, s[0].y, s[1].x, s[1].y);
    line(s[0].x, s[0].y, s[4].x, s[4].y);
    line(s[0].x, s[0].y, s[3].x, s[3].y);
    line(s[1].x, s[1].y, s[2].x, s[2].y);
    line(s[1].x, s[1].y, s[5].x, s[5].y);
    line(s[4].x, s[4].y, s[5].x, s[5].y);
    line(s[4].x, s[4].y, s[7].x, s[7].y);
    line(s[5].x, s[5].y, s[6].x, s[6].y);
    line(s[3].x, s[3].y, s[7].x, s[7].y);
    line(s[3].x, s[3].y, s[2].x, s[2].y);
    line(s[7].x, s[7].y, s[6].x, s[6].y);
    line(s[6].x, s[6].y, s[2].x, s[2].y);
  }
}

class My3DBox {
  My3DPoint[] p;
  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ){
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[]{new My3DPoint(x,y+dimY,z+dimZ),
      new My3DPoint(x,y,z+dimZ),
      new My3DPoint(x+dimX,y,z+dimZ),
      new My3DPoint(x+dimX,y+dimY,z+dimZ),
      new My3DPoint(x,y+dimY,z),
      origin,
      new My3DPoint(x+dimX,y,z),
      new My3DPoint(x+dimX,y+dimY,z)
    };
  }
  My3DBox(My3DPoint[] p) {
    this.p = p;
  }
}

My2DBox projectBox (My3DPoint eye, My3DBox box) {
  My2DPoint[] tabel = new My2DPoint[8];
  for (int i = 0; i < box.p.length; ++i) {
    tabel[i] = projectPoint(eye, box.p[i]);
  }
  return new My2DBox(tabel);
}

float[] homogeneous3DPoint (My3DPoint p) {
  float[] result = {p.x, p.y, p.z , 1};
  return result;
}

float[][] rotateXMatrix(float angle) {
  return(new float[][] {{1, 0 , 0 , 0},
                        {0, cos(angle), sin(angle) , 0},
                        {0, -sin(angle) , cos(angle) , 0},
                        {0, 0 , 0 , 1}});
}
float[][] rotateYMatrix(float angle) {
  return(new float[][] {{cos(angle), 0 , sin(angle), 0},
                        {0, 1, 0 , 0},
                        { -sin(angle), 0, cos(angle) , 0},
                        {0, 0 , 0 , 1}});
}
float[][] rotateZMatrix(float angle) {
  return(new float[][] {{cos(angle), -sin(angle), 0, 0},
                        {sin(angle), cos(angle), 0 , 0},
                        {0, 0, 1, 0},
                        {0, 0 , 0 , 1}});
}
float[][] scaleMatrix(float x, float y, float z) {
  return(new float[][] {{x, 0, 0, 0},
                        {0, y, 0 , 0},
                        {0, 0, z, 0},
                        {0, 0 , 0 , 1}});
}
float[][] translationMatrix(float x, float y, float z) {
  return(new float[][] {{1, 0, 0, x},
                        {0, 1, 0 , y},
                        {0, 0, 1, z},
                        {0, 0 , 0 , 1}});
}

float[] matrixProduct(float[][] a, float[] b) {
  float[] result = new float[4];
  float sum = 0;
  for (int i = 0; i < 4; ++i) {
    sum = 0;
    for (int j = 0; j < 4; ++j) {
      sum += a[i][j] * b[j];
    }
    result[i] = sum;
  }
  return result;
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  My3DPoint[] result = new My3DPoint[8];
  for (int i = 0; i < box.p.length; ++i) {
    result[i] = euclidian3DPoint(matrixProduct(transformMatrix, homogeneous3DPoint(box.p[i])));
  }
  return new My3DBox(result);
  
}

My3DPoint euclidian3DPoint (float[] a) {
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
  return result;
}
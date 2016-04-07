class Cylinder {
  
  float cylinderBaseSize = 32;
  float cylinderHeight = 70;
  int cylinderResolution = 40;
  PShape openCylinder = new PShape();
  PShape t1 = new PShape();
  PShape t2 = new PShape();
  
  void setup() {
    float angle;
    float[] x = new float[cylinderResolution + 1];
    float[] y = new float[cylinderResolution + 1];
    
    //get the x and y position on a circle for all the sides
    for(int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      y[i] = cos(angle) * cylinderBaseSize;
    }
  
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    t1 =createShape();
    t1.beginShape(TRIANGLE_STRIP);
    t2 = createShape();
    t2.beginShape(TRIANGLE_STRIP);
    t1.vertex(0, 0, 0);
    t2.vertex(0, cylinderHeight, 0);
    
    for(int i = 0; i <= x.length; ++i) {
      t1.vertex(x[i % x.length], 0, y[i % x.length]);
      t1.vertex(0, 0, 0);
      t2.vertex(x[i % x.length], cylinderHeight, y[i % x.length]);
      t2.vertex(0, cylinderHeight, 0);
      if (i < x.length) {
        openCylinder.vertex(x[i], 0, y[i]);
        openCylinder.vertex(x[i], cylinderHeight, y[i]);
      }
      
    }
    t1.endShape();
    t2.endShape();
    openCylinder.endShape();  
}
    
  void drawCylinder(PVector coordinates) {  
    setup();
    pushMatrix();
    translate(coordinates.x, - (boxThickness/2 + cylinderHeight), coordinates.y);
    shape(openCylinder);
    shape(t1);
    shape(t2);
    popMatrix();
  }
}
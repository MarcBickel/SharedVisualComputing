class Cylinder {
  
  float cylinderBaseSize = 4;
  float cylinderHeight = 6;
  int cylinderResolution = 40;
  PShape openCylinder = new PShape();
  
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
    
    //draw the border of the cylinder
    
    for(int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], y[i] , 0);
      openCylinder.vertex(x[i], y[i], cylinderHeight);
    }
    for(int i = 0; i < x.length; ++i) {
    openCylinder.vertex(x[i], y[i], 0);
    openCylinder.vertex(0, 0, 0);
    }
    openCylinder.vertex(x[x.length - 1], y[x.length - 1], 0);
    openCylinder.vertex(x[x.length - 1], y[x.length - 1], cylinderHeight);
    openCylinder.vertex(0, 0, cylinderHeight);
  
      for(int i = 0; i < x.length; ++i) {
    openCylinder.vertex(x[i], y[i], cylinderHeight);
    openCylinder.vertex(0, 0, cylinderHeight);
    }
    
    openCylinder.endShape();
  }
  
  void drawCylinder(PVector coordinates) {
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
    
    //draw the border of the cylinder
    
    for(int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], 0 , y[i]);
      openCylinder.vertex(x[i], cylinderHeight, y[i]);
    }
    for(int i = 0; i < x.length; ++i) {
    openCylinder.vertex(x[i], 0, y[i]);
    openCylinder.vertex(0, 0, 0);
    }
    openCylinder.vertex(x[x.length - 1], 0, y[x.length - 1]);
    openCylinder.vertex(x[x.length - 1], cylinderHeight, y[x.length - 1]);
    openCylinder.vertex(0, cylinderHeight, 0);
  
      for(int i = 0; i < x.length; ++i) {
    openCylinder.vertex(x[i], cylinderHeight, y[i]);
    openCylinder.vertex(0, cylinderHeight, 0);
    }
    
    openCylinder.endShape();
    pushMatrix();
    translate(coordinates.x, -7.5, coordinates.y);
    shape(openCylinder);
    popMatrix();
  }
}
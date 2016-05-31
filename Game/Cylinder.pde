class Cylinder {  
  float cylinderBaseSize = 20;//1f/25f * boxSize;
  float cylinderHeight = 7f/80f * boxSize;
  int cylinderResolution = 40;
  
  Cylinder() {
    set();
  }
  
  void set() {
    float angle;
    float[] x = new float[cylinderResolution + 1];
    float[] y = new float[cylinderResolution + 1];
    
    //get the x and y position on a circle for all the sides
    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      y[i] = cos(angle) * cylinderBaseSize;
    }
    
    // We do not draw the bottom part of the cylinder since it allows us to save ressources
    openCylinder.beginShape(QUAD_STRIP);
    top.beginShape(TRIANGLE_FAN);
    top.vertex(0, 0, 0);
    
    for (int i = 0; i < x.length; ++i) {
      top.vertex(x[i % x.length], 0, y[i % x.length]);
      if (i < x.length) {
        openCylinder.vertex(x[i], 0, y[i]);
        openCylinder.vertex(x[i], cylinderHeight, y[i]);
      }   
    }    
    top.endShape();
    openCylinder.endShape();   
  }
    
  void drawCylinder(PVector coordinates) { 
    pushMatrix();
    translate(coordinates.x, - (boxThickness/2 + cylinderHeight), coordinates.y);
    shape(openCylinder);
    fill(242, 145, 0);
    shape(top);
    popMatrix();
  }
}
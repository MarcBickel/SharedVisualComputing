class Mover {
  PVector location;
  PVector velocity;
  float gravityConstant = 0.1;
  PVector gravityForce = new PVector(sin(rZ) * gravityConstant, 0, sin(rX) * gravityConstant);
  float reboundCoeff = 0.8f;
  float radiusSphere = 5.0f;
  float normalForce = 1;
  float mu = 0.01;
  float frictionMagnitude = normalForce * mu;
  
  


  
  Mover() {
    location = new PVector(width/2f, (height/2f) - radiusSphere - 1.5, 0);
    velocity = new PVector(0f, 0f, 0f);
  }
  void update() {
    location.add(velocity);
    PVector friction = velocity.get();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    velocity.x += friction.x;
    velocity.y += friction.y;
    velocity.z += friction.z;
  }
  void display() {
    pushMatrix();
    translate(location.x + velocity.x, location.x + velocity.y, location.z + velocity.z);
    sphere(5);
    popMatrix();
  }
  void checkEdges() {
    //TODO
  }
}
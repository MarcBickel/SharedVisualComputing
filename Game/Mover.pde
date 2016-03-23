class Mover {
  PVector location;
  PVector velocity;
  PVector gravityForce;
  PVector friction;
  
  float gravityConstant = 0.1;
  float reboundCoeff = 0.8f;
  float radiusSphere = 5.0f;
  float normalForce = 1;
  float mu = 0.01;
  float frictionMagnitude = normalForce * mu;
  
  Mover() {
    location = new PVector(0, -6.5, 0);
    velocity = new PVector(0f, 0f, 0f);
  }
  
  void update() {
    gravityForce = new PVector(sin(rZ) * gravityConstant, 0, - sin(rX) * gravityConstant);
    friction = velocity.copy();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    velocity.add(friction.add(gravityForce));
  }
  
  void display() {
    pushMatrix();
    location.add(velocity);
    translate(location.x, location.y, location.z);
    sphere(5);
    popMatrix();
  }
  
  void checkEdges() {
    if (location.x < -50) {
      location.x = -50;
      velocity.x = velocity.x * -1 * reboundCoeff;
    } else if (location.x > 50) {
      location.x = 50;
      velocity.x = velocity.x * -1 * reboundCoeff;
    } else if (location.z < -50) {
      location.z = -50;
      velocity.z = velocity.z * -1 * reboundCoeff;
    } else if (location.z > 50) {
      location.z = 50;
      velocity.z = velocity.z * -1 * reboundCoeff;
    }
  }
}
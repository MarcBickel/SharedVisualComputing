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
    location.add(velocity);
  }
  
  void display() {
    pushMatrix();
    translate(location.x, location.y, location.z);
    sphere(5);
    popMatrix();
  }
  
  void checkEdges() {
    if (location.x < -50) {
      location.x = -50;
      velocity.x = velocity.x * -1 * reboundCoeff;
    } 
    if (location.x > 50) {
      location.x = 50;
      velocity.x = velocity.x * -1 * reboundCoeff;
    } 
    if (location.z < -50) {
      location.z = -50;
      velocity.z = velocity.z * -1 * reboundCoeff;
    } 
    if (location.z > 50) {
      location.z = 50;
      velocity.z = velocity.z * -1 * reboundCoeff;
    }
  }
  
  void checkCylinderCollision() {
    PVector normal;
    for (PVector vect : cylinders) {
      if (closerThan(vect, new PVector(location.x, location.z), radiusSphere + cylinder.cylinderBaseSize)) {
        normal = new PVector(location.x - vect.x, 0, location.z - vect.y);
        normal.normalize();
        velocity.sub(normal.mult(velocity.dot(normal) * 2));
        normal.normalize();
        
        location.x = vect.x - normal.x * (cylinder.cylinderBaseSize + radiusSphere + 0.00000001 * cylinder.cylinderBaseSize);
        location.z = vect.y - normal.z * (cylinder.cylinderBaseSize + radiusSphere + 0.00000001 * cylinder.cylinderBaseSize);
      }
    }
    
    
  }
}
class Mover {
  PVector location;
  PVector velocity;
  PVector gravityForce;
  PVector friction;
  
  float gravityConstant = 0.8;
  float reboundCoeff = 0.8f;
  float radiusSphere = 5;//1f/20f * boxSize
  float normalForce = 1;
  float mu = 0.01;
  float frictionMagnitude = normalForce * mu;
  
  Mover() {
    location = new PVector(0, -(boxThickness / 2 + radiusSphere), 0);
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
    fill(255, 0, 0);
    translate(location.x, location.y, location.z);
    sphere(radiusSphere);
    popMatrix();
  }
  
  void checkEdges() {
    float velocity_norm =  (float)Math.sqrt(Math.pow(velocity.x, 2) + Math.pow(velocity.y, 2));
    if (location.x < -boxSize/2) {
     
      if (score > velocity_norm) {
        score -= velocity_norm;
        lastScore = velocity_norm;
      } else {
        lastScore = - score;
        score = 0;      
      }
      location.x = -boxSize/2;
      velocity.x = velocity.x * -1 * reboundCoeff;
    } 
    if (location.x > boxSize/2) {
      if (score > velocity_norm) {
        score -= velocity_norm;
        lastScore = velocity_norm;
      } else {
        lastScore = - score;
        score = 0;      
      }
      location.x = boxSize/2;
      velocity.x = velocity.x * -1 * reboundCoeff;
    } 
    if (location.z < -boxSize/2) {
      if (score > velocity_norm) {
        score -= velocity_norm;
        lastScore = velocity_norm;
      } else {
        lastScore = - score;
        score = 0;      
      }
      location.z = -boxSize/2;
      velocity.z = velocity.z * -1 * reboundCoeff;
    } 
    if (location.z > boxSize/2) {
      if (score > velocity_norm) {
        score -= velocity_norm;
        lastScore = velocity_norm;
      } else {
        lastScore = - score;
        score = 0;      
      }
      location.z = boxSize/2;
      velocity.z = velocity.z * -1 * reboundCoeff;
    }
    
  }
  
  void checkCylinderCollision() {
    PVector normal;
    ArrayList<PVector> fff = new ArrayList<PVector>();
    for (PVector vect : cylinders) {
      if (closerThan(vect, new PVector(location.x, location.z), radiusSphere + cylinder.cylinderBaseSize + 10)) {
        normal = new PVector(location.x - vect.x, 0, location.z - vect.y);
        normal.normalize();
        velocity.sub(normal.mult(velocity.dot(normal) * 2));
        normal.normalize();
        score += Math.sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y));
        lastScore = (float) Math.sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y));        
        location.x = vect.x - normal.x * (cylinder.cylinderBaseSize + radiusSphere + 0.001 * cylinder.cylinderBaseSize);
        location.z = vect.y - normal.z * (cylinder.cylinderBaseSize + radiusSphere + 0.001 * cylinder.cylinderBaseSize);
      }
      else {
        fff.add(vect);
      }
    }
    cylinders = fff;    
  }
}
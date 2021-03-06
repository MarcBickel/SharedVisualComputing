PShape openCylinder;
PShape top;

PGraphics bottomBackground;
PGraphics topView;
PGraphics scoreboard;
PGraphics barChart;

float angleX = 0f;
float angleZ = 0f;
float rotationSpeed = 0.005f;
float score = 0f;
float lastScore = 0f;
float rX;
float rZ;
float cylinderX;
float cylinderY;
int lastMouseX;
int lastMouseY;
int timer;
float barChartIntervalTimeRefresh = 0.5; //Time in seconds for the barChart to be refreshed
int maxWidthBarChart = 50; //Size of the bars in the chart
int scale = 1; //Scale of the barchart, for vertical resizing

float boxThickness = 24f;
float boxSize = 800f;

HScrollbar scrollbar;

Mover mover;
enum Mode {
  GAMER, PLACER
}
Mode mode = Mode.GAMER;

Cylinder cylinder;

ArrayList<PVector> cylinders = new ArrayList();
ArrayList<Float> scores = new ArrayList();

/*Capture to Movie in declaring the video class*/
Movie cam;

void settings() {
  fullScreen(P3D);
}

void setup() {
  noStroke();
  openCylinder = createShape();
  top = createShape(); 
  cylinder = new Cylinder();
  mover = new Mover();
  bottomBackground = createGraphics(width, height/5, P2D);
  topView = createGraphics(height/5 - 20, height/5 - 20, P2D);
  scoreboard = createGraphics(width / 5 - 20, height / 5 - 20, P2D);
  barChart = createGraphics(4 * width / 5 - height / 5 - 20, height / 5 - 20 - 30, P2D);
  scrollbar = new HScrollbar(height / 5 + width / 5, height - 30 - 5, 600, 30);
  timer = 0;
  
  //For last milestone
  cam = new Movie(this, "testvideo.mp4"); //Put the video in the same directory
  cam.loop();
}

void draw() {
  background(200); 
  camera();
  directionalLight(255, 240, 224, -1, 12, -9);
  ambientLight(46, 106, 255);
  
  if (cam.available() == true) {
    cam.read();
    img = cam.get();
    PImage image = sobel(antiGaussianBlur(intensityThresholding(gaussianBlur(colorThresholding(img)))));
    img.resize(320, 240);
    image(img, 0, 0);
    ArrayList<PVector> houghImage = hough(image, 4);
    getIntersections(houghImage);
    ArrayList<ArrayList<PVector>> tempo = displayQuads(houghImage);
    TwoDThreeD two = new TwoDThreeD(width, height);
    PVector rotations = new PVector();
    if (tempo.size() != 0) {
      rotations = two.get3DRotations(tempo.get(0));
    
      angleX = map(rotations.x, -PI / 3, PI / 3, -1, 1);
      angleZ = map(rotations.z, -PI / 3, PI / 3, -1, 1);
    }
  }
  
  switch (mode) {
    case GAMER:
      timer = (timer + 1);
      if (timer >= barChartIntervalTimeRefresh * 60) {
        timer = 0;
        scores.add(score);
      }
      pushMatrix();
      rX = map(angleX, -1, 1, -PI / 3, PI / 3);
      rZ = map(angleZ, -1, 1, -PI / 3, PI / 3);
      
      translate(width / 2, height / 2, 0);
      rotateX(rX);
      rotateZ(rZ);
      
      //Dessine tous les cylinders en orange
      
      fill(242, 145, 0);
      for (PVector vect : cylinders) {
        cylinder.drawCylinder(vect);
      }
      
      // Dessine la plaque en vert
      drawBoard();
      
      // Dessine la boule en rouge
      mover.update();
      mover.checkEdges();
      mover.checkCylinderCollision();
      mover.display();
      popMatrix();
      
      //Dessine tous les éléments de la week 6
      drawBottomBackground();
      image(bottomBackground, 0, height * 4f/5f);
      drawTopView();
      image(topView, 10, height * 4f/5f + 10);
      drawScoreboard();
      image(scoreboard, height / 5, height * 4f/5f + 10);
      drawBarChart();
      image(barChart, height /5 + width / 5, height * 4f/5f + 10);
      scrollbar.update();
      scrollbar.display();
      break;
      
    case PLACER:       
      pushMatrix();
      
      // Tourne la plaque en direction de la camera
      translate(width / 2, height / 2, 0);
      rotateX(-PI / 2);
      
      drawBoard();
      fill(242, 145, 0);
      for (PVector vect : cylinders) {
        cylinder.drawCylinder(vect);
      }
      cylinderX = mouseX - width/2;
      cylinderY = mouseY - height / 2;
      cylinder.drawCylinder(new PVector(cylinderX, cylinderY));

      // Dessine la plaque mais n'update pas la vitesse, position de la boule
      mover.display();
      popMatrix();
      break;
    default: 
      break;
  }
}

void drawBoard() {
  fill(42, 112, 37);
  box(boxSize, boxThickness, boxSize);
}

boolean closerThan(PVector v1, PVector v2, float dist) {
  return dist(v1.x, v1.y, v2.x, v2.y) < dist;
}

void drawBottomBackground() {
  bottomBackground.beginDraw();
  bottomBackground.background(210);
  bottomBackground.endDraw();
}

void drawTopView() {
  topView.beginDraw();
  topView.background(160);
  float topViewX = map(mover.location.x, -boxSize/2f, boxSize/2f, 0, height/5f - 20);
  float topViewY = map(mover.location.z, -boxSize/2f, boxSize/2f, 0, height/5f - 20);
  topView.fill(255, 0, 0);
  topView.ellipse(topViewX, topViewY, (height/5f - 20) * 0.05f * 2, (height/5f - 20) * 0.05f * 2);
  topView.fill(210);
  for (PVector vect : cylinders) {
        float topViewCylinderX = map(vect.x, -boxSize/2f, boxSize/2f, 0, height/5f - 20);
        float topViewCylinderY = map(vect.y, -boxSize/2f, boxSize/2f, 0, height/5f - 20);
        topView.ellipse(topViewCylinderX, topViewCylinderY, (height/5f - 20) * 1f/25f * 2, (height/5f - 20) * 1f/25f * 2);
      }
  topView.endDraw();
}

void drawScoreboard() {
  scoreboard.beginDraw();
  scoreboard.stroke(5);
  scoreboard.fill(210);
  scoreboard.rect(0, 0, width / 5 - 20 - 1, height / 5 - 20 - 1);
  scoreboard.textSize(22f * height/1080f);
  scoreboard.fill(0);
  scoreboard.text("Total Score:\n " + score + "\nLast Score:\n " + lastScore + "\nVelocity:\n" + norm(mover.velocity), 0, 0, height / 5, height * 4f/5f + 10);

  scoreboard.endDraw();
}

void drawBarChart() {
  barChart.stroke(10);
  barChart.beginDraw();
  barChart.background(160);
  barChart.fill(0, 0, 255);
  if (scores.size() > 1 && (scores.get(scores.size() - 1) >= (barChart.height - 5) * scale)) {
    scale = scale * 2;
  }
  for (int i = 0; i < scores.size(); ++i) {
    barChart.rect(i * (maxWidthBarChart + 2) * (scrollbar.getPos() + 0.1), (barChart.height - scores.get(i) / scale) - 5, maxWidthBarChart * scrollbar.getPos() + 0.1, scores.get(i) / scale);
  }
  barChart.endDraw();
}

void keyPressed() {
  if (keyCode == SHIFT) {
    mode = Mode.PLACER;
  }
}

void keyReleased() {
  if (keyCode == SHIFT) {
    mode = Mode.GAMER;
  }
}

void mouseDragged() {
  switch (mode) {
    case GAMER:
      if (lastMouseY < 4 * height / 5) {
        // modifies the value of angleX, angleZ from -1 to 1
        angleZ += (mouseX - lastMouseX) * rotationSpeed;
        angleX -= (mouseY - lastMouseY) * rotationSpeed;
        if (angleX > 1) angleX = 1;
        if (angleX < -1) angleX = -1;
        if (angleZ > 1) angleZ = 1;
        if (angleZ < -1) angleZ = -1;
        lastMouseX = mouseX;
        lastMouseY = mouseY;
      }
      break;
    case PLACER:
      break;
    default:
      break;
  }
}

void mousePressed() {
  switch (mode) {
    case GAMER: 
      // Enregistre les positions de la souris pour connaitre l'ampleur du drag
      lastMouseX = mouseX;
      lastMouseY = mouseY;
      break;
    case PLACER:
      PVector actual = new PVector(cylinderX, cylinderY);
      boolean adding = true;
      
      for (PVector vect : cylinders) {
        // Si il y a déjà un cylindre trop près
        if (closerThan(actual, vect, cylinder.cylinderBaseSize * 2.5)) {
          adding = false;
        }
      }
      // Si la balle et le cylindre sont trop proches
      if (closerThan(new PVector(mover.location.x, mover.location.z), actual, mover.radiusSphere + cylinder.cylinderBaseSize)) {
        adding = false;
      }
      if (cylinderX > boxSize/2 || cylinderX < -boxSize/2 || cylinderY < -boxSize/2 || cylinderY > boxSize/2) {
        adding = false;
      }
      if (adding) {
        cylinders.add(actual);
      }
      break;
    default:
      break;
  }
  
}

void mouseWheel(MouseEvent event) {
  final float maxRotationSpeed = 0.010f;
  final float minRotationSpeed = 0.001f;
  float e = event.getCount();
  
  rotationSpeed -= (e / 6000f);
  if (rotationSpeed < minRotationSpeed) {
    rotationSpeed = minRotationSpeed;
  } else if (rotationSpeed > maxRotationSpeed) {
    rotationSpeed = maxRotationSpeed;
  }
}

float norm(PVector a) {
  return (float) Math.sqrt(Math.pow(a.x, 2) + Math.pow(a.y, 2));
}
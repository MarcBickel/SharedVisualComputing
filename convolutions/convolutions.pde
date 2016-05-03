PImage img;
HScrollbar thresholdBar1;
HScrollbar thresholdBar2;

void settings() {
  size(800, 600);
}

void setup() {
  img = loadImage("board1.jpg");
  thresholdBar1 = new HScrollbar(0, 580, 800, 20);
  thresholdBar2 = new HScrollbar(0, 560, 800, 20);

}

void draw() {
/*float threshold = 255 * thresholdBar.getPos();
PImage result = createImage(width, height, RGB); // create a new, initially transparent, ’result’ image
for(int i = 0; i < img.width * img.height; i++) {
  int x = i % img.width;
  int y = (int)(i / img.width);    
  if(brightness(img.pixels[i]) > threshold) {
    result.pixels[i] = (img.pixels[i]);
  }
}
image(result, 0, 0);

thresholdBar.update();
thresholdBar.display();

float thresholdDown = 255 * thresholdBar1.getPos();
float thresholdUp = 255 * thresholdBar2.getPos();

PImage result = createImage(width, height, RGB); // create a new, initially transparent, ’result’ image
for(int i = 0; i < img.width * img.height; i++) {
    colorMode(HSB, 255);
    color c = (img.pixels[i]);
    float value = hue(c);
    if(value > thresholdDown && value < thresholdUp){
      result.set(i % img.width, (int)(i / img.width), img.pixels[i]);
    }
  }

image(result, 0, 0);

thresholdBar1.update();
thresholdBar2.update();
thresholdBar1.display();
thresholdBar2.display(); */

  image(sobel(img), 0, 0);
}

PImage convolute(PImage img, float[][] kernel, int weight) {
// create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);
// kernel size N = 3
  int kerWidth = kernel[0].length;
  int kerHeight = kernel.length;
  for(int y = (kerHeight / 2); y < img.height - (kerHeight / 2); ++y) {
    for(int x = (kerWidth / 2); x < img.width - (kerWidth / 2); ++x) {
      int value = 0;
      //float weight = 0f;      
      for(int i = 0; i < kerHeight; ++i) {
        for(int j = 0; j < kerWidth; ++j) {
          value += brightness(img.pixels[(y - (kerHeight / 2) + i) * img.width + x - (kerWidth / 2) + j]) * kernel[i][j];
          //weight += kernel[i][j];
        }
      }
      result.pixels[y * img.width + x] = color(value / weight);
    }
  }
  return result;
}

int max = 0;

float[] convolute2(PImage img) {
  
  float[][] hKernel = { 
    { 0,  1, 0 },
    { 0,  0, 0 },
    { 0, -1, 0 }
  };
  
  float[][] vKernel = { 
    { 0, 0,  0 },
    { 1, 0, -1 },
    { 0, 0,  0 }
  };  
// create a greyscale image (type: ALPHA) for output

  float[] buffer = new float[img.width * img.height];

// kernel size N = 3
  int kerWidth = 3;
  int kerHeight = 3;
  for(int y = (kerHeight / 2); y < img.height - (kerHeight / 2); ++y) {
    for(int x = (kerWidth / 2); x < img.width - (kerWidth / 2); ++x) {
      int valueH = 0;
      int valueV = 0;
      //float weight = 0f;      
      for(int i = 0; i < kerHeight; ++i) {
        for(int j = 0; j < kerWidth; ++j) {
          valueH += brightness(img.pixels[(y - (kerHeight / 2) + i) * img.width + x - (kerWidth / 2) + j]) * hKernel[i][j];
          valueH += brightness(img.pixels[(y - (kerHeight / 2) + i) * img.width + x - (kerWidth / 2) + j]) * vKernel[i][j];
          //weight += kernel[i][j];
        }
      }
      int value = (int)sqrt(pow(valueH, 2) + pow(valueV, 2));
      max = max(value, max);
      buffer[y * img.width + x] = value;
    }
  }
  return buffer;
}

PImage sobel (PImage img) {    
  float[][] gaussian = { 
    { 9,  12, 9  },
    { 12, 15, 12 },
    { 9,  12, 9  }
  };
 
  img = convolute(img, gaussian, 99);
 
  PImage result = createImage(img.width, img.height, ALPHA);
  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = color(0);
  }
  float[] buffer = convolute2(img);
  
  
    
  for (int y = 1; y < img.height - 1; y++) { // Skip top and bottom edges
    for (int x = 1; x < img.width - 1; x++) { // Skip left and right
      if (buffer[y * img.width + x] > (int)(max * 0.3f)) { // 30% of the max
        result.pixels[y * img.width + x] = color(255);
      } else {
        result.pixels[y * img.width + x] = color(0);
      }
    }
  }
  return result;
}
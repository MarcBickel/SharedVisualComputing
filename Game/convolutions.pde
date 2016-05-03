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

image(Sobel(img), 0, 0);
}

PImage convolute(PImage img, float[][] kernel) {
// create a greyscale image (type: ALPHA) for output
PImage result = createImage(img.width, img.height, ALPHA);
// kernel size N = 3
  int ker_width = kernel[0].length;
  int ker_height = kernel.length;
  for(int y = (ker_height /2); y < img.height - (ker_height /2); ++y) {
    for(int x = (ker_width /2); x < img.width - (ker_width /2); ++x) {
      int value = 0;
      float weight = 0f;      
      for(int i = 0; i < ker_height; ++i) {
        for(int j = 0; j < ker_width; ++j) {
          value += brightness(img.pixels[(y - (ker_height /2) + i) * img.width + x - (ker_height /2) + j]) * kernel[i][j];
          weight += abs(kernel[i][j]);
        }
      }
     // value = value / (int)weight; 
      result.pixels[y * img.width + x] = color(value / (int)weight);
    }
  }
return result;
}

PImage Sobel (PImage img) {  
  
  float[][] Gaussian = { 
  { 9, 12, 9 },
  { 12, 15, 12 },
  { 9, 12, 9} };
  
  float[][] hKernel = { 
  { 0, 1, 0 },
  { 0, 0, 0 },
  { 0, -1, 0 } };
  
  float[][] vKernel = { 
  { 0, 0, 0 },
  { 1, 0, -1 },
  { 0, 0, 0 } };  
 
  img = convolute(img, Gaussian);
  
  PImage result = createImage(img.width, img.height, ALPHA);
  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = color(0);
  }
  float[] buffer = new float[img.width * img.height];
  // *************************************
  // Implement here the double convolution
  // *************************************
  PImage image_h = convolute(img, hKernel); 
  PImage image_v = convolute(img, vKernel);
   
  float max_brightness = 0;
  for(int i = 0; i < img.height; ++i) {
    for(int j = 0; j < img.width; ++j) {
      float current_bright = sqrt(pow(brightness(color(image_h.pixels[i * img.width + j] )), 2) + pow(brightness(color(image_v.pixels[i * img.width + j] )), 2));
      max_brightness = max(max_brightness, current_bright);
      buffer[i * img.width + j] = sqrt(pow(brightness(image_h.pixels[i * img.width + j]), 2) + pow(brightness(image_v.pixels[i * img.width + j]), 2));
    }
  }
    
  for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; x++) { // Skip left and right
      if (buffer[y * img.width + x] > (int)(max_brightness * 0.3f)) { // 30% of the max
        result.pixels[y * img.width + x] = color(255);
      } else {
        result.pixels[y * img.width + x] = color(0);
      }
    }
  }
  return result;
}
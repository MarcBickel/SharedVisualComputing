PImage img;

void settings() {
  size(800, 600);
}

void setup() {
  img = loadImage("board1.jpg");
}

void draw() {
  image(sobel(gaussianBlur(img)), 0, 0);
}

float computeWeight(float[][] tab) {
  float result = 0;
  for (int i = 0; i < tab.length; ++i) {
    for (int j = 0; j < tab[0].length; ++j) {
      result += tab[i][j];
    }
  }
  
  return result;
}

PImage gaussianBlur(PImage img) {
  
  float[][] kernel = {
    {9f , 12f, 9f },
    {12f, 15f, 12f},
    {9f , 12f, 9f }
  };
  
  float weight = computeWeight(kernel);
  PImage result = createImage(img.width, img.height, ALPHA);
  
  for (int x = 1; x < (img.width - 1); ++x) {
    for (int y = 1; y < (img.height - 1); ++y) {
      
      float value = 0;
      //Now we iterate over the kernel
      for (int i = -1; i < 2; ++i) {
        for (int j = -1; j < 2; ++j) {
          value += brightness(img.pixels[(x + i) + (y + j) * img.width]) * kernel[i + 1][j + 1];
        }
      }
      
      result.pixels[x + y * img.width] = color(value / weight);
      
    }
  }
  
  return result;
}

PImage sobel(PImage img) {
  float[][] hKernel = { 
    { 0, 1 , 0 },
    { 0, 0 , 0 },
    { 0, -1, 0 } 
  };
  
  float[][] vKernel = { 
    { 0, 0, 0  },
    { 1, 0, -1 },
    { 0, 0, 0  } 
  };
  
  PImage result = createImage(img.width, img.height, ALPHA);
  
  float max = 0;
  float[] buffer = new float[img.width * img.height];
  float weight = 1f;
  
  for (int x = 1; x < (img.width - 1); ++x) {
    for (int y = 1; y < (img.height - 1); ++y) {
      
      float valueH = 0;
      float valueV = 0;
      //Now we iterate over the kernel
      for (int i = -1; i < 2; ++i) {
        for (int j = -1; j < 2; ++j) {
          valueH += brightness(img.pixels[(x + i) + (y + j) * img.width]) * hKernel[i + 1][j + 1];
          valueV += brightness(img.pixels[(x + i) + (y + j) * img.width]) * vKernel[i + 1][j + 1];
        }
      }
      float value = sqrt(pow(valueH, 2) + pow(valueV, 2));
      buffer[x + y * img.width] = color(value / weight);
      max = max(max, value);
    }
  }
  println(max);
  for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; x++) { // Skip left and right
      if (buffer[y * img.width + x] > (int)(max * 0.3f)) { // 30% of the max
        result.pixels[y * img.width + x] = color(255);
      } else {
        result.pixels[y * img.width + x] = color(0);
      }
    }
  }

  return result;
}
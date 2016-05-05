PImage img;

void settings() {
  size(800, 600);
}

void setup() {
  img = loadImage("board1.jpg");
}

void draw() {
  PImage image = sobel(gaussianBlur(colorThresholding(img)));
  //image(image, 0, 0);
  hough(image);
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

PImage colorThresholding(PImage img) {
  PImage result = createImage(img.width, img.height, RGB);
  
  for (int i = 0; i < img.width * img.height; ++i) {
    int current = img.pixels[i];
    if (hue(current) < 136 && hue(current) > 96 && saturation(current) > 50 && brightness(current) > 25) { //works for green only
      result.pixels[i] = color(current);
    } else {
      result.pixels[i] = 0;
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
  
  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = color(0);
  }

  
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
      float value = sqrt(valueH * valueH + valueV * valueV);
      buffer[x + y * img.width] = value / weight;
      max = max(max, value);
    }
  }
  
  for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; x++) { // Skip left and right
      if (buffer[y * img.width + x] > (int)(max * 0.30)) { // 30% of the max
        result.pixels[y * img.width + x] = color(255);
      } else {
        result.pixels[y * img.width + x] = color(0);
      }
    }
  }

  return result;
}

void hough(PImage edgeImg) {
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;
  
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  
  // our accumulator (with a 1 pix margin around)
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
  
  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
    // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        for (float phi = 0f; phi < Math.PI; phi = phi + discretizationStepsPhi) {
          float r = x * cos(phi) + y * sin(phi);
          if (r < 0) {
            r += (rDim - 1) / 2;
          }
          int currentPhi = (int) (phi / discretizationStepsPhi);
          int currentR = (int) (r / discretizationStepsR);
          //if (currentR < 0) {
            //currentR += (rDim -1) /2;
          //}
          accumulator[currentPhi * rDim + currentR] += 1;
        }
        
      }
    }
  }
  
  PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
  for (int i = 0; i < accumulator.length; i++) {
    houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
  // You may want to resize the accumulator to make it easier to see:
  houghImg.resize(800, 600);
  houghImg.updatePixels();
  image(houghImg, 0, 0);
}
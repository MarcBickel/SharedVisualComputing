import java.util.Collections;

PImage img;

void settings() {
  size(800, 600);
}

void setup() {
  img = loadImage("board1.jpg");
  noLoop();
}

void draw() {
  PImage image = sobel(gaussianBlur(colorThresholding(img)));
  image(img, 0, 0);
  hough(image, 4);
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
      result.pixels[i] = color(255);
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

void hough(PImage edgeImg, int nLines) {
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
        for (int phi = 0; phi < phiDim; ++phi) {
          float phiF = phi * discretizationStepsPhi;
          float rF = x * cos(phiF) + y * sin(phiF);
          
          int r = (int) (rF / discretizationStepsR);
          r += (rDim -1) /2;
          accumulator[(phi + 1) * (rDim + 2) + (r + 1)] += 1;
        }
        
      }
    }
  }
  
  
  //To display the accumulator
  /*PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
  for (int i = 0; i < accumulator.length; i++) {
    houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
  // You may want to resize the accumulator to make it easier to see:
  houghImg.resize(800, 600);
  houghImg.updatePixels();
  image(houghImg, 0, 0);*/
  
  //Adding the candidates that have more than a certain threshlod of votes
  ArrayList<Integer> bestCandidates = new ArrayList();
  
  // size of the region we search for a local maximum
  int neighbourhood = 10;
  // only search around lines with more that this amount of votes
  // (to be adapted to your image)
  int minVotes = 200;
  for (int accR = 0; accR < rDim; accR++) {
    for (int accPhi = 0; accPhi < phiDim; accPhi++) {
      // compute current index in the accumulator
      int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
      if (accumulator[idx] > minVotes) {
        boolean bestCandidate=true;
        // iterate over the neighbourhood
        for(int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
          // check we are not outside the image
          if( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
          for(int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {// check we are not outside the image
            if(accR+dR < 0 || accR+dR >= rDim) continue;
            int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
            if(accumulator[idx] < accumulator[neighbourIdx]) {
              // the current idx is not a local maximum!
              bestCandidate=false;
              break;
            }
          }
          if(!bestCandidate) break;
        }
        if(bestCandidate) {
        // the current idx *is* a local maximum
        bestCandidates.add(idx);
        }
      }
    }
  }
  
  //Sorting them by most votes
  Collections.sort(bestCandidates, new HoughComparator(accumulator));

  if (bestCandidates.size() > nLines) {
    for (int id = 0; id < nLines; id++) {
      int idx = bestCandidates.get(id);
      // first, compute back the (r, phi) polar coordinates:
      int accPhi = (int) (idx / (rDim + 2)) - 1;
      int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
      float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      
      // Cartesian equation of a line: y = ax + b
      // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      // => y = 0 : x = r / cos(phi)
      // => x = 0 : y = r / sin(phi)
      // compute the intersection of this line with the 4 borders of
      // the image
      int x0 = 0;
      int y0 = (int) (r / sin(phi));
      int x1 = (int) (r / cos(phi));
      int y1 = 0;
      int x2 = edgeImg.width;
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
      int y3 = edgeImg.width;
      int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
      
      // Finally, plot the lines
      stroke(204,102,0);
      
      if (y0 > 0) {
        if (x1 > 0) {
          line(x0, y0, x1, y1);
        } else if (y2 > 0) {
          line(x0, y0, x2, y2);
        } else {
          line(x0, y0, x3, y3);
        }
      } else {
        if (x1 > 0) {
          if (y2 > 0) {
            line(x1, y1, x2, y2);
          } else {
            line(x1, y1, x3, y3);
          }
        } else {
          line(x2, y2, x3, y3);
        }
      }
    
    }
  }
}
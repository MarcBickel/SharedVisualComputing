import java.util.Collections;
import java.util.List;
import java.util.Random;
import processing.video.*;
//Capture cam;

/*Capture to Movie in declaring the video class*/
//Capture cam;
Movie cam;

PImage img;
int[] accumulator;

//To draw the hough accumulator
int phiDim;
int rDim;

void settings() {
    size(800 + 600 + 800, 600);
}

void setup() {
  //String[] cameras = Capture.list();
  //if (cameras.length == 0) {
  //  println("There are no cameras available for capture.");
  //  exit();
  //} else {
  //  println("Available cameras:");
  //  for (int i = 0; i < cameras.length; i++) {
  //    println(cameras[i]);
  //  }

  //  cam = new Capture(this, cameras[0]);
  //  cam.start();
  //}
  
  
  
  //cam = new Capture(this, cameras[63]);
  //cam.start();
  cam = new Movie(this, "testvideo.mp4"); //Put the video in the same directory
  cam.loop();



    //img = loadImage("board4.jpg");
    //noLoop();
}

void draw() {
  if (cam.available() == true) {
    cam.read();
    img = cam.get();
    PImage image = sobel(antiGaussianBlur(intensityThresholding(gaussianBlur(colorThresholding(img)))));
    image(img, 0, 0);
    ArrayList<PVector> houghImage = hough(image, 4);
    getIntersections(houghImage);
    image(image, 800 + 400, 0);
    displayAccumulator(accumulator);
    ArrayList<ArrayList<PVector>> tempo = displayQuads(houghImage);
    TwoDThreeD two = new TwoDThreeD(width, height);
    if (tempo.size() != 0) {
      two.get3DRotations(tempo.get(0));
    }
  }
  
    
    
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
        if (hue(current) < 139 && hue(current) > 96 && saturation(current) > 112 && brightness(current) > 25) { //works for green only
            result.pixels[i] = color(255);
        } else {
            result.pixels[i] = 0;
        }
    }

    return result;
}

PImage intensityThresholding(PImage img) {
    PImage result = createImage(img.width, img.height, RGB);

    for (int i = 0; i < img.width * img.height; ++i) {
        int current = img.pixels[i];
        if ( brightness(current) > 25) {
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

PImage antiGaussianBlur(PImage img) {

    float[][] kernel = {
        {10f, 10f, 10f, 10f, 10f},
        {10f , 5f, 5f, 5f, 10f },
        {10f, 5f, 0f, 5f, 10f},
        {10f , 5f, 5f, 5f, 10f },
        {10f, 10f, 10f, 10f, 10f}
    };

    float weight = computeWeight(kernel);
    PImage result = createImage(img.width, img.height, ALPHA);

    for (int x = 2; x < (img.width - 2); ++x) {
        for (int y = 2; y < (img.height - 2); ++y) {

            float value = 0;
            //Now we iterate over the kernel
            for (int i = -2; i < 3; ++i) {
                for (int j = -2; j < 3; ++j) {
                    value += brightness(img.pixels[(x + i) + (y + j) * img.width]) * kernel[i + 2][j + 2];
                }
            }
            if (value / weight > 160) {
                result.pixels[x + y * img.width] = color(value / weight);
            }
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

ArrayList<PVector> hough(PImage edgeImg, int nLines) {
    float discretizationStepsPhi = 0.01f;
    float discretizationStepsR = 2.5f;

    // dimensions of the accumulator
    phiDim = (int) (Math.PI / discretizationStepsPhi);
    rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);

    // our accumulator (with a 1 pix margin around)
    accumulator = new int[(phiDim + 2) * (rDim + 2)];

    // pre-compute the sin and cos values
    float[] tabSin = new float[phiDim];
    float[] tabCos = new float[phiDim];
    float ang = 0;
    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
        // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
        tabSin[accPhi] = (float) Math.sin(ang);
        tabCos[accPhi] = (float) Math.cos(ang);
    }

    // Fill the accumulator: on edge points (ie, white pixels of the edge
    // image), store all possible (r, phi) pairs describing lines going
    // through the point.
    for (int y = 0; y < edgeImg.height; y++) {
        for (int x = 0; x < edgeImg.width; x++) {
            // Are we on an edge?
            if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
                for (int phi = 0; phi < phiDim; ++phi) {
                    float phiF = phi * discretizationStepsPhi;
                    float rF = x * tabCos[phi] + y * tabSin[phi];

                    int r = (int) (rF / discretizationStepsR);
                    r += (rDim -1) /2;
                    accumulator[(phi + 1) * (rDim + 2) + (r + 1)] += 1;
                }

            }
        }
    }


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

    //The return list
    ArrayList<PVector> result = new ArrayList();

    for (int id = 0; id < min(nLines, bestCandidates.size()); id++) {
        int idx = bestCandidates.get(id);
        // first, compute back the (r, phi) polar coordinates:
        int accPhi = (int) (idx / (rDim + 2)) - 1;
        int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
        float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
        float phi = accPhi * discretizationStepsPhi;
        result.add(new PVector(r, phi));

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
    return result;
}

void displayAccumulator(int[] accumulator) {

    //To display the accumulator
    PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
    for (int i = 0; i < accumulator.length; i++) {
        houghImg.pixels[i] = color(min(255, accumulator[i]));
    }
    // You may want to resize the accumulator to make it easier to see:
    houghImg.resize(400, 600);
    houghImg.updatePixels();
    image(houghImg, 800, 0);
}

ArrayList<PVector> getIntersections(List<PVector> lines) {
    ArrayList<PVector> intersections = new ArrayList<PVector>();
    for (int i = 0; i < lines.size() - 1; i++) {
        PVector line1 = lines.get(i);
        for (int j = i + 1; j < lines.size(); j++) {
            PVector line2 = lines.get(j);
            // compute the intersection and add it to ’intersections’
            float d = cos(line2.y) * sin(line1.y) - cos(line1.y) * sin(line2.y);

            float x = (line2.x * sin(line1.y) - line1.x * sin(line2.y)) / d;
            float y = (-line2.x * cos(line1.y) + line1.x * cos(line2.y)) / d;

            // draw the intersection
            fill(255, 128, 0);
            ellipse(x, y, 10, 10);
            intersections.add(new PVector(x, y));
        }
    }
    return intersections;
}

PVector intersection(PVector v1, PVector v2) {
    float d = cos(v2.y) * sin(v1.y) - cos(v1.y) * sin(v2.y);

    float x = (v2.x * sin(v1.y) - v1.x * sin(v2.y)) / d;
    float y = (-v2.x * cos(v1.y) + v1.x * cos(v2.y)) / d;
    return new PVector(x, y);
}

ArrayList<ArrayList<PVector>> displayQuads(ArrayList<PVector> lines) {

    QuadGraph quadGraph = new QuadGraph();
    quadGraph.build(lines, width, height);
    List<int[]> quads = quadGraph.findCycles();
    ArrayList<ArrayList<PVector>> retur = new ArrayList<ArrayList<PVector>>();

    for (int[] quad : quads) {
        PVector l1 = lines.get(quad[0]);
        PVector l2 = lines.get(quad[1]);
        PVector l3 = lines.get(quad[2]);
        PVector l4 = lines.get(quad[3]);
        // (intersection() is a simplified version of the
        // intersections() method you wrote last week, that simply
        // return the coordinates of the intersection between 2 lines)
        PVector c12 = intersection(l1, l2);
        PVector c23 = intersection(l2, l3);
        PVector c34 = intersection(l3, l4);
        PVector c41 = intersection(l4, l1);
        
        ArrayList<PVector> temp = new ArrayList<PVector>();
        temp.add(c12);
        temp.add(c23);
        temp.add(c34);
        temp.add(c41);
        

        if (quadGraph.isConvex(c12, c23, c34, c41) && quadGraph.validArea(c12, c23, c34, c41, 1920 * 1920, 20 * 20) && quadGraph.nonFlatQuad(c12, c23, c34, c41)) {
            // Choose a random, semi-transparent colour
            Random random = new Random();
            fill(color(min(255, random.nextInt(300)),
                       min(255, random.nextInt(300)),
                       min(255, random.nextInt(300)), 50));
            quad(c12.x,c12.y,c23.x,c23.y,c34.x,c34.y,c41.x,c41.y);
            retur.add((ArrayList) sortCorners(temp));
        }


    }
    
    return retur;
}
import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.Core;
import org.opencv.core.Mat;
import org.opencv.core.MatOfPoint;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.CvType;
import org.opencv.core.Point;
import org.opencv.core.Size;

import gab.opencv.*;
import processing.video.*;

OpenCV opencv;

PImage  src, dst, markerImg;
ArrayList<MatOfPoint> contours;
ArrayList<MatOfPoint2f> approximations;
ArrayList<MatOfPoint2f> markers;

boolean[][] markerCells;

Capture Face;
OpenCV System;

void setup() {
  size(640, 480);
  
  Face = new Capture(this, 640, 480);
  System = new OpenCV(this, 640, 480);  

  Face.start();
  noSmooth();
  //------------------------------
  

  contours = new ArrayList<MatOfPoint>();

  approximations = createPolygonApproximations(contours);

  markers = new ArrayList<MatOfPoint2f>();
  markers = selectMarkers(approximations);

  //// Mat markerMat = grat.submat();
  //  Mat warped = OpenCVPro.imitate(gray);
  //  
  MatOfPoint2f canonicalMarker = new MatOfPoint2f();
  Point[] canonicalPoints = new Point[4];
  canonicalPoints[0] = new Point(0, 350);
  canonicalPoints[1] = new Point(0, 0);
  canonicalPoints[2] = new Point(350, 0);
  canonicalPoints[3] = new Point(350, 350);
  canonicalMarker.fromArray(canonicalPoints);
  
  Mat unWarpedMarker = new Mat(50, 50, CvType.CV_8UC1);


  Imgproc.threshold(unWarpedMarker, unWarpedMarker, 125, 255, Imgproc.THRESH_BINARY | Imgproc.THRESH_OTSU);

  float cellSize = 350/7.0;

  markerCells = new boolean[7][7];

  for (int row = 0; row < 7; row++) {
    for (int col = 0; col < 7; col++) {
      int cellX = int(col*cellSize);
      int cellY = int(row*cellSize);
    }
  }

  for (int col = 0; col < 7; col++) {
    for (int row = 0; row < 7; row++) {
      if (markerCells[row][col]) {
        print(1);
      } 
      else {
        print(0);
      }
    }
    println();
  }

  dst  = createImage(350, 350, RGB);
}



ArrayList<MatOfPoint2f> selectMarkers(ArrayList<MatOfPoint2f> candidates) {
  float minAllowedContourSide = 50;
  minAllowedContourSide = minAllowedContourSide * minAllowedContourSide;

  ArrayList<MatOfPoint2f> result = new ArrayList<MatOfPoint2f>();

  for (MatOfPoint2f candidate : candidates) {

    if (candidate.size().height != 4) {
      continue;
    } 

    if (!Imgproc.isContourConvex(new MatOfPoint(candidate.toArray()))) {
      continue;
    }
    float minDist = src.width * src.width;
    Point[] points = candidate.toArray();
    for (int i = 0; i < points.length; i++) {
      Point side = new Point(points[i].x - points[(i+1)%4].x, points[i].y - points[(i+1)%4].y);
      float squaredLength = (float)side.dot(side);
      minDist = min(minDist, squaredLength);
    }


    if (minDist < minAllowedContourSide) {
      continue;
    }

    result.add(candidate);
  }

  return result;
}

ArrayList<MatOfPoint2f> createPolygonApproximations(ArrayList<MatOfPoint> cntrs) {
  ArrayList<MatOfPoint2f> result = new ArrayList<MatOfPoint2f>();

  for (MatOfPoint contour : cntrs) {
    MatOfPoint2f approx = new MatOfPoint2f();
    result.add(approx);
  }

  return result;
}

void drawContours(ArrayList<MatOfPoint> cntrs) {
  for (MatOfPoint contour : cntrs) {
    beginShape();
    Point[] points = contour.toArray();
    for (int i = 0; i < points.length; i++) {
      vertex((float)points[i].x, (float)points[i].y);
    }
    endShape();
  }
}

void drawContours2f(ArrayList<MatOfPoint2f> cntrs) {
  for (MatOfPoint2f contour : cntrs) {
    beginShape();
    Point[] points = contour.toArray();

    for (int i = 0; i < points.length; i++) {
      vertex((float)points[i].x, (float)points[i].y);
    }
    endShape(CLOSE);
  }
}

void draw() {
 background(0);
 System.loadImage(Face);
 System.calculateOpticalFlow();
  
 image(Face,0,0);

  noFill();
  noSmooth();
  strokeWeight(5);
  stroke(0, 255, 0);
  drawContours2f(markers);

  pushMatrix();
  strokeWeight(1);

  float cellSize = dst.width/7.0;
  for (int col = 0; col < 7; col++) {
    for (int row = 0; row < 7; row++) {
      if(markerCells[row][col]){
        fill(255,0);
      } else {
        fill(0,0);
      }
      stroke(0,255,0,0);
      rect(col*cellSize, row*cellSize, cellSize, cellSize);
    }
  }

  popMatrix();
}

void captureEvent(Capture c) {
  c.read();
}
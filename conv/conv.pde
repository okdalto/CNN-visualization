import peasy.PeasyCam;
PeasyCam cam;

Conv2D c1;
Conv2D c2;
Conv2D c3;
Conv2D c4;
MLP mlp1;
MLP mlp2;

TensorVisualizer[] tvs;
ConvVisualizer[] cvs;
ReshapeVisualizer rv;

PGraphics canvas;
PGraphics visualization;

float[][][][] inputMat;
float[][][][] ip;

void setup() {
  fullScreen(P3D);
  inputMat = new float[1][1][32][32];

  canvas = createGraphics(32, 32);
  canvas.beginDraw();
  canvas.background(0);
  canvas.endDraw();
  visualization = createGraphics(3*width/4, height, P3D);
  visualization.smooth(16);
  visualization.beginDraw();
  visualization.background(0);
  visualization.endDraw();
  cam = new PeasyCam(this, visualization, 400);

  String[] conv1Weight = loadStrings("conv1Weight.txt");
  String[] conv1Bias = loadStrings("conv1Bias.txt");
  c1 = new Conv2D(conv1Weight, conv1Bias);
  String[] conv2Weight = loadStrings("conv2Weight.txt");
  String[] conv2Bias = loadStrings("conv2Bias.txt");
  c2 = new Conv2D(conv2Weight, conv2Bias);
  String[] conv3Weight = loadStrings("conv3Weight.txt");
  String[] conv3Bias = loadStrings("conv3Bias.txt");
  c3 = new Conv2D(conv3Weight, conv3Bias);
  String[] conv4Weight = loadStrings("conv4Weight.txt");
  String[] conv4Bias = loadStrings("conv4Bias.txt");
  c4 = new Conv2D(conv4Weight, conv4Bias);
  String[] mlp1Weight = loadStrings("mlp1Weight.txt");
  String[] mlp1Bias = loadStrings("mlp1Bias.txt");
  mlp1 = new MLP(mlp1Weight, mlp1Bias, true);
  String[] mlp2Weight = loadStrings("mlp2Weight.txt");
  String[] mlp2Bias = loadStrings("mlp2Bias.txt");
  mlp2 = new MLP(mlp2Weight, mlp2Bias, false);

  String[] imgValueTest = loadStrings("randomTensor.txt");
  ip = parse4dTensor(imgValueTest);

  float[][][][] out1 = c1.forward(ip);
  float[][][][] out2 = c2.forward(out1);
  float[][][][] out3 = c3.forward(out2);
  float[][][][] out4 = c4.forward(out3);
  float[][] out5 = flatten(out4);
  float[][] out6 = mlp1.forward(out5);
  float[][] result = mlp2.forward(out6);

  printTensor(result);
  //result = softmax(result);

  float[][][][] out5Temp = new float[1][1][1][out5.length];
  out5Temp[0][0] = out5;
  float[][][][] out6Temp = new float[1][1][1][out6.length];
  out6Temp[0][0] = out6;
  float[][][][] resultTemp = new float[1][1][1][result.length];
  resultTemp[0][0] = result;

  float[][][][][] outs = new float[][][][][]{
    ip,
    out1,
    out2,
    out3,
    out4,
    out5Temp,
    out6Temp,
    resultTemp
  };

  PVector convBSize = new PVector(20, 20, 5);
  PVector filterBSize = new PVector(15, 15, 5);
  PVector mlpBsize = new PVector(2, 20, 20);

  PVector[] gridPositions = new PVector[]{
    new PVector(0, 0, -1400),
    new PVector(0, 0, -1000),
    new PVector(0, 0, -500),
    new PVector(0, 0, 0),
    new PVector(0, 0, 500),
    new PVector(0, 0, 800),
    new PVector(0, 0, 900),
    new PVector(0, 0, 1000),
  };

  PVector[] gridSizes = new PVector[]{
    new PVector(1000, 1000, 100),
    new PVector(400, 400, 400),
    new PVector(200, 200, 400),
    new PVector(100, 100, 400),
    new PVector(40, 40, 400),
    new PVector(1000, 1, 1),
    new PVector(1000, 1, 1),
    new PVector(500, 1, 1),
  };

  PVector[] boxSizes = new PVector[]{
    convBSize,
    convBSize,
    convBSize,
    convBSize,
    convBSize,
    mlpBsize,
    mlpBsize,
    convBSize,
  };

  tvs = new TensorVisualizer[gridPositions.length];
  for (int i = 0; i < tvs.length; i++) {
    tvs[i] = new TensorVisualizer(
      gridPositions[i],
      gridSizes[i],
      outs[i], // tensor
      boxSizes[i], //bSize
      0.1, // speedMin
      0.5, // speedMax
      0.3 // drag
      );
  }

  cvs = new ConvVisualizer[4];

  int interval = 30;

  for (int i = 0; i < cvs.length; i+=4) {
    cvs[i] = new ConvVisualizer(tvs[0], tvs[1], filterBSize, new PVector(), interval, 0);
    cvs[i+1] = new ConvVisualizer(tvs[1], tvs[2], filterBSize, new PVector(), interval, 0);
    cvs[i+2] = new ConvVisualizer(tvs[2], tvs[3], filterBSize, new PVector(), interval, 0);
    cvs[i+3] = new ConvVisualizer(tvs[3], tvs[4], filterBSize, new PVector(), interval, 0);
  }

  rv = new ReshapeVisualizer(tvs[4], tvs[5]);
}

void draw() {
  canvas.beginDraw();
  if (mousePressed) {
    forward();

    canvas.stroke(255);
    canvas.strokeWeight(2.4);
    //draw line on the canvas
    canvas.line(
      32*map(mouseX, visualization.width, width, 0, 1),
      32*map(mouseY, height/3, height/3 + width/4, 0, 1),
      32*map(pmouseX, visualization.width, width, 0, 1),
      32*map(pmouseY, height/3, height/3 + width/4, 0, 1)
      );
  }

  canvas.loadPixels();
  //canvas to 1d inputMat
  for (int i = 0; i < 32; i ++) {
    for (int j = 0; j < 32; j ++) {
      int row = 32 * i;
      int col = j;
      int idx = row + col;
      inputMat[0][0][i][j] = canvas.pixels[idx] >> 16 & 0xFF;
      inputMat[0][0][i][j] = (float)inputMat[0][0][i][j] / 255.0;
    }
  }

  canvas.endDraw();

  visualization.beginDraw();
  visualization.background(0);
  visualization.fill(255);
  for (int i = 0; i < tvs.length; i++) {
    tvs[i].draw();
  }

  for (int i = 0; i < cvs.length; i++) {
    cvs[i].draw();
  }

  for (int i = 0; i < 10; i++) {
    visualization.textSize(18);
    visualization.textAlign(CENTER, CENTER);
    visualization.fill(255);
    visualization.text(i, map(i, 0, 9, -250, 250), 20, 1000);
  }

  rv.draw();
  visualization.endDraw();
  background(0);
  image(visualization, 0, 0);
  stroke(255);
  rect(visualization.width, height/3, width/4-1, width/4-1);
  image(canvas, visualization.width, height/3, width/4-1, width/4-1);
}

void keyPressed() {
  canvas.beginDraw();
  canvas.background(0);
  canvas.endDraw();

  for (int i = 0; i < 32; i ++) {
    for (int j = 0; j < 32; j ++) {
      inputMat[0][0][j][i] = 0.0;
    }
  }
  forward();
}

void forward() {
  float[][][][] out1 = c1.forward(inputMat);
  float[][][][] out2 = c2.forward(out1);
  float[][][][] out3 = c3.forward(out2);
  float[][][][] out4 = c4.forward(out3);
  float[][] out5 = flatten(out4);
  float[][] out6 = mlp1.forward(out5);
  float[][] result = mlp2.forward(out6);
  result = softmax(result);

  float[][][][] out5Temp = new float[1][1][1][out5.length];
  out5Temp[0][0] = out5;
  float[][][][] out6Temp = new float[1][1][1][out6.length];
  out6Temp[0][0] = out6;
  float[][][][] resultTemp = new float[1][1][1][result.length];
  resultTemp[0][0] = result;

  float[][][][][] outs = new float[][][][][]{
    inputMat,
    out1,
    out2,
    out3,
    out4,
    out5Temp,
    out6Temp,
    resultTemp
  };

  for (int i = 0; i < tvs.length; i++) {
    tvs[i].setValue(outs[i]);
  }
}

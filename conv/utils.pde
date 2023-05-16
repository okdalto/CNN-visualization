void printTensor(float[][] tensor) {
  int outChNum = tensor.length;
  int inChNum = tensor[0].length;
  for (int i = 0; i < outChNum; i++) {
    println();
    for (int j = 0; j < inChNum; j++) {
      print(tensor[i][j] + " ");
    }
  }
  println();
  println("The shape of this image is : " + outChNum + ", " + inChNum);
}

void printTensor(float[][][][] tensor) {
  int outChNum = tensor.length;
  int inChNum = tensor[0].length;
  int kernelWNum = tensor[0][0].length;
  int kernelHNum = tensor[0][0][0].length;
  for (int i = 0; i < outChNum; i++) {
    println();
    for (int j = 0; j < inChNum; j++) {
      println();
      for (int k = 0; k < kernelWNum; k++) {
        println();
        for (int l = 0; l < kernelHNum; l++) {
          print(tensor[i][j][k][l] + " ");
        }
      }
    }
  }
  println();
  println("The shape of this image is : " + outChNum + ", " + inChNum + ", " + kernelWNum + ", " + kernelHNum);
}

float relu(float x) {
  return max(x, 0.0);
}

float[][][][] parse4dTensor(String[] tensor) {
  int outChNum = tensor.length;
  int inChNum = 0;
  int kernelWNum = 0;
  int kernelHNum = 0;
  for (int i = 0; i < outChNum; i++) {
    String[] inCh = tensor[i].split("!");
    inChNum = inCh.length;
    for (int j = 0; j < inChNum; j++) {
      String[] kernelW = inCh[j].split(",");
      kernelWNum = kernelW.length;
      for (int k = 0; k < kernelWNum; k++) {
        String[] kernelH = kernelW[j].split(" ");
        kernelHNum = kernelH.length;
      }
    }
  }
  println("The shape of this image is : " + outChNum + ", " + inChNum + ", " + kernelWNum + ", " + kernelHNum);
  float[][][][] tensorParsed = new float[outChNum][inChNum][kernelWNum][kernelHNum];
  for (int i = 0; i < outChNum; i++) {
    String[] inCh = tensor[i].split("!");
    for (int j = 0; j < inChNum; j++) {
      String[] kernelW = inCh[j].split(",");
      for (int k = 0; k < kernelWNum; k++) {
        String[] kernelH = kernelW[k].split(" ");
        for (int l = 0; l < kernelHNum; l++) {
          tensorParsed[i][j][k][l] = float(kernelH[l]);
        }
      }
    }
  }
  return tensorParsed;
}

float[][] flatten(float[][][][] tensor) {
  int outChNum = tensor.length;
  int inChNum = tensor[0].length;
  int kernelWNum = tensor[0][0].length;
  int kernelHNum = tensor[0][0][0].length;
  ArrayList<Float> arrList = new ArrayList<Float>();
  for (int i = 0; i < outChNum; i++) {
    for (int j = 0; j < inChNum; j++) {
      for (int k = 0; k < kernelWNum; k++) {
        for (int l = 0; l < kernelHNum; l++) {
          arrList.add(tensor[i][j][k][l]);
        }
      }
    }
  }
  float[][] floatArray = new float[arrList.size()][1];
  int i = 0;
  for (Float f : arrList) {
    floatArray[i++][0] = f;
  }
  return floatArray;
}


float[][] softmax(float[][] x) {
  float[][] val = new float[x.length][1];
  float div = 0;
  for (int i = 0; i < x.length; i++) {
    float tempX = x[i][0];
    val[i][0] = exp(tempX);
    div += Math.exp(tempX);
  }
  //println("");
  for (int i = 0; i < x.length; i++) {
    val[i][0] /= div;
    //val[i][0] *= 255.0;
    //println("number", i, "=", Math.round(val[i][0]*100), "%");
  }
  return val;
}

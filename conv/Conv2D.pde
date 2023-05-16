
class Conv2D {
  float[][][][] weights;
  int[] wShape;
  float[] bias;
  int stride = 2;

  Conv2D(String[] weights, String[] bias) {
    this.wShape = new int[4];
    this.weights = parseConvWeights(weights);
    this.bias = parseConvBias(bias);
  }
  
  float[] parseConvBias(String[] bias) {
    int outChNum = bias.length;
    float[] weightsParsed = new float[outChNum];
    for (int i = 0; i < outChNum; i++) {
      weightsParsed[i] = float(bias[i]);
    }
    println("The shape of this bias is : " + outChNum);
    return weightsParsed;
  }
  
  float[][][][] parseConvWeights(String[] weights) {
    int outChNum = weights.length;
    int inChNum = 0;
    int kernelWNum = 0;
    int kernelHNum = 0;
    for (int i = 0; i < outChNum; i++) {
      String[] inCh = weights[i].split("!");
      inChNum = inCh.length;
      for (int j = 0; j < inChNum; j++) {
        String[] kernelW = inCh[j].split(",");
        kernelWNum = kernelW.length;
        for (int k = 0; k < kernelWNum; k++) {
          String[] kernelH = kernelW[k].split(" ");
          kernelHNum = kernelH.length;
        }
      }
    }
    println("The shape of this Conv layer is : " + outChNum + ", " + inChNum + ", " + kernelWNum + ", " + kernelHNum);
    float[][][][] weightsParsed = new float[outChNum][inChNum][kernelWNum][kernelHNum];
    for (int i = 0; i < outChNum; i++) {
      String[] inCh = weights[i].split("!");
      for (int j = 0; j < inChNum; j++) {
        String[] kernelW = inCh[j].split(",");
        for (int k = 0; k < kernelWNum; k++) {
          String[] kernelH = kernelW[k].split(" ");
          for (int l = 0; l < kernelHNum; l++) {
            weightsParsed[i][j][k][l] = float(kernelH[l]);
          }
        }
      }
    }
    this.wShape[0] = outChNum;
    this.wShape[1] = inChNum;
    this.wShape[2] = kernelWNum;
    this.wShape[3] = kernelHNum;
    return weightsParsed;
  }

  float[][][][] forward(float[][][][] x) {
    int bSize = x.length;
    int imgSize = x[0][0].length/2;
    int[] inShape = new int[]{bSize, x[0].length, x[0][0].length, x[0][0][0].length};
    int[] outShape = new int[]{bSize, this.wShape[0], imgSize, imgSize};
    int kernelH = this.wShape[2];
    int kernelW = this.wShape[3];
    int kernelHSize = kernelH/2;
    int kernelWSize = kernelW/2;
    float[][][][] result = new float[outShape[0]][outShape[1]][outShape[2]][outShape[3]];
    // loop over every output channel
    for (int i = 0; i < outShape[1]; i++) {
      // loop over every pixel
      for (int j = 0; j < outShape[2]; j++) {
        for (int k = 0; k < outShape[3]; k++) {
          // loop over kernel
          for (int l = 0; l < this.wShape[1]; l++) {
            for (int m = 0; m < kernelH; m++) {
              for (int n = 0; n < kernelW; n++) {
                int offsetX = m-kernelHSize;
                int offsetY = n-kernelWSize;
                int newPosX = j*2 + offsetX;
                int newPosY = k*2 + offsetY;
                // handle padding 1
                if (newPosX < 0 || newPosY < 0 || newPosX >= inShape[2] || newPosY >= inShape[3]) {
                  //result[0][i][j][k] += 0;
                } else {
                  result[0][i][j][k] += x[0][l][j*this.stride + offsetX][k*this.stride + offsetY] * weights[i][l][m][n];
                }
              }
            }
          }
          result[0][i][j][k] += this.bias[i];
          result[0][i][j][k] = relu(result[0][i][j][k]);
        }
      }
    }
    return result;
  }
}

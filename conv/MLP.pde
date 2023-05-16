class MLP {
  float[][] weights;
  int[] wShape;
  float[] bias;
  boolean relu;
  MLP(String[] weights, String[] bias, boolean relu) {
    this.wShape = new int[2];
    this.weights = parse2dTensor(weights);
    this.bias = parseConvBias(bias);
    this.relu = relu;
  }
  float[][] parse2dTensor(String[] tensor) {
    int batchNum = tensor.length;
    int inChNum = tensor[0].split(" ").length;
    println("The shape of this tensor is : " + batchNum + ", " + inChNum);
    float[][] tensorParsed = new float[batchNum][inChNum];
    for (int i = 0; i < batchNum; i++) {
      String[] inCh = tensor[i].split(" ");
      inChNum = inCh.length;
      for (int j = 0; j < inChNum; j++) {
        tensorParsed[i][j] = float(inCh[j]);
      }
    }
    return tensorParsed;
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
  float[][] multMat(float[][] matrix1, float[][] matrix2) {
    int m1Rows = matrix1.length;
    int m1Cols = matrix1[0].length;
    int m2Cols = matrix2[0].length;

    // Check if the matrices can be multiplied
    if (m1Cols != matrix2.length) {
      throw new IllegalArgumentException("Invalid matrix dimensions");
    }

    float[][] result = new float[m1Rows][m2Cols];

    for (int i = 0; i < m1Rows; i++) {
      for (int j = 0; j < m2Cols; j++) {
        float sum = 0.0f;
        for (int k = 0; k < m1Cols; k++) {
          sum += matrix1[i][k] * matrix2[k][j];
        }
        result[i][j] = sum;
      }
      result[i][0] += bias[i];
      if (this.relu) {
        result[i][0] = relu(result[i][0]);
      }
    }

    return result;
  }

  float[][] forward(float[][] x) {
    return multMat(this.weights, x);
  }
}

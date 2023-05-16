class TensorVisualizer {
  float[][][][] tensor;
  PVector gridPos;
  PVector gridSize;
  PVector bSize;
  float speedMin;
  float speedMax;
  float drag;

  Box[][][] boxes;
  Box[] boxes1D;

  int tC;
  int tW;
  int tH;
  PVector gap;

  TensorVisualizer(PVector gridPos, PVector gridSize, float[][][][] tensor, PVector bSize, float speedMin, float speedMax, float drag) {
    this.gridPos = gridPos;
    this.gridSize = gridSize;
    this.tensor = tensor;
    this.speedMin = speedMin;
    this.speedMax = speedMax;
    this.drag = drag;
    this.tC = tensor[0].length;
    this.tW = tensor[0][0].length;
    this.tH = tensor[0][0][0].length;
    this.boxes1D = new Box[tC*tW*tH];
    this.bSize = bSize;
    this.boxes = new Box[this.tC][this.tW][this.tH];
    this.gap = new PVector(
      gridSize.x  / float(tW-1),
      gridSize.y  / float(tH-1),
      gridSize.z  / float(tC-1));
    for (int i = 0; i < this.tC; i++) {
      for (int j = 0; j < this.tW; j++) {
        for (int k = 0; k < this.tH; k++) {
          float z;
          float x;
          float y;
          if (this.tC == 1) {
            z = gridPos.z;
          } else {
            z = map(i, 0, this.tC-1, -gridSize.z/2, gridSize.z/2) + gridPos.z;
          }
          if (this.tW == 1) {
            x = gridPos.x;
          } else {
            x = map(j, 0, this.tW-1, -gridSize.x/2, gridSize.x/2) + gridPos.x;
          }
          if (this.tH == 1) {
            y = gridPos.y;
          } else {
            y = map(k, 0, this.tH-1, -gridSize.y/2, gridSize.y/2) + gridPos.y;
          }

          PVector pos;
          if (this.tH == 1) {
            // flip x and y
            pos = new PVector(x, y, z);
          } else {
            pos = new PVector(y, x, z);
          }
          float speedMapped = map(i*tW*tH + j*tH + k, 0, tC*tW*tH, speedMin, speedMax);
          Box newBox = new Box(
            pos,
            bSize,
            tensor[0][i][j][k],
            speedMapped,
            drag);

          this.boxes[i][j][k] = newBox;
          this.boxes1D[i*tW*tH + j*tH + k] = newBox;
        }
      }
    }
  }


  void setValue(float[][][][] value) {
    for (int z = 0; z < tC; z++) {
      for (int x = 0; x < tW; x++) {
        for (int y = 0; y < tH; y++) {
          //if (this.tH == 1) {
          //  this.boxes[z][x][y].value = value[0][z][x][y];
          //} else {
          this.boxes[z][x][y].trgValue.x = value[0][z][x][y];
          this.boxes[z][x][y].trgValue.y = value[0][z][x][y];
          this.boxes[z][x][y].trgValue.z = value[0][z][x][y];
          //}
        }
      }
    }
  }

  void draw() {
    for (int i = 0; i < this.boxes1D.length; i++) {
      this.boxes1D[i].update();
      this.boxes1D[i].draw();
    }
  }

  void setTargetPos(TensorVisualizer tv) {
    for (int i = 0; i < this.boxes1D.length; i++) {
      this.boxes1D[i].setTarget(tv.boxes1D[i]);
      this.boxes1D[i].curValue = tv.boxes1D[i].curValue;
      this.boxes1D[i].trgValue = tv.boxes1D[i].trgValue;
    }
  }
}

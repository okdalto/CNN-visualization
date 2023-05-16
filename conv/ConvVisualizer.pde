class ConvVisualizer {

  TensorVisualizer filter;
  TensorVisualizer tv1;
  TensorVisualizer tv2;
  int timing;
  int tC;
  int kernelSize;
  int padding;
  int stride;

  int srcX;
  int srcY;

  int trgX;
  int trgY;
  int trgZ;

  int interval;
  int intervalShift;

  PVector bSize;

  ConvVisualizer(
    TensorVisualizer tv1,
    TensorVisualizer tv2,
    PVector bSize,
    PVector offset,
    int interval,
    int intervalShift
    )
  {
    this.tv1 = tv1;
    this.tv2 = tv2;
    this.kernelSize = 3;
    this.padding = 1;
    this.stride = 2;
    this.tC = tv1.tC;
    this.bSize = bSize;

    this.interval = interval;
    this.intervalShift = intervalShift;

    this.srcX += offset.x;
    this.srcY += offset.y;

    this.trgX += offset.x/stride;
    this.trgY += offset.y/stride;
    this.trgZ += offset.z;

    this.srcX %= tv1.tW;
    this.srcY %= tv1.tH;

    this.trgX %= tv2.tW;
    this.trgY %= tv2.tH;
    this.trgZ %= tv2.tC;

    filter = new TensorVisualizer(
      new PVector(0, 0, 0),
      new PVector(1, 1, 1),
      new float[1][this.tC][this.kernelSize][this.kernelSize],
      this.bSize,
      0.3,
      0.3,
      0.4
      );
  }

  void setFilterTrgPosition(TensorVisualizer tv, int x, int y) {
    int ksh = this.kernelSize/2;
    for (int i = 0; i < this.tC; i++) {
      Box cb = tv.boxes[i][y][x];
      for (int j = -ksh; j < ksh+1; j++) {
        for (int k = -ksh; k < ksh+1; k++) {
          int newY = j+ksh;
          int newX = k+ksh;

          this.filter.boxes[i][newX][newY].trgPos.x = cb.curPos.x + float(j) * tv.gap.x;
          this.filter.boxes[i][newX][newY].trgPos.y = cb.curPos.y + float(k) * tv.gap.y;
          this.filter.boxes[i][newX][newY].trgPos.z = cb.curPos.z;

          int newYtv = j+y;
          int newXtv = k+x;

          if (newXtv >= tv.tW || newXtv < 0 || newYtv >= tv.tH || newYtv < 0) {
            this.filter.boxes[i][newY][newX].curValue = new PVector();
            this.filter.boxes[i][newY][newX].trgValue = new PVector();
          } else {
            tv.boxes[i][newYtv][newXtv].curValue.x = 10.0;
            tv.boxes[i][newYtv][newXtv].curValue.y = 10.0;
            tv.boxes[i][newYtv][newXtv].curValue.z = 10.0;

            this.filter.boxes[i][newY][newX].curValue.x = tv.boxes[i][newYtv][newXtv].curValue.x;
            this.filter.boxes[i][newY][newX].curValue.y = tv.boxes[i][newYtv][newXtv].curValue.y;
            this.filter.boxes[i][newY][newX].curValue.z = tv.boxes[i][newYtv][newXtv].curValue.z;
            this.filter.boxes[i][newY][newX].trgValue = tv.boxes[i][newYtv][newXtv].curValue;
          }
        }
      }
    }
  }

  void setFilterTrgPosition(Box trgBox) {
    int ksh = this.kernelSize/2;
    for (int i = 0; i < this.tC; i++) {
      for (int j = -ksh; j < ksh+1; j++) {
        for (int k = -ksh; k < ksh+1; k++) {
          Box srcBox = this.filter.boxes[i][j+ksh][k+ksh];
          srcBox.trgPos.x = trgBox.curPos.x;
          srcBox.trgPos.y = trgBox.curPos.y;
          srcBox.trgPos.z = trgBox.curPos.z;

          srcBox.trgValue = trgBox.trgValue;

          trgBox.curValue.x = 255;
          trgBox.curValue.y = 255;
          trgBox.curValue.z = 255;
        }
      }
    }
  }

  void update() {
    int frameCountNew = (frameCount + intervalShift) % interval;
    if (frameCountNew == interval/2) {
      srcX += 2;
      if (srcX >= tv1.tW) {
        srcX = 0;
        srcY += 2;
      }
      if (srcY >= tv1.tH) {
        srcY = 0;
      }
      setFilterTrgPosition(tv1, srcX, srcY);
    }

    if (frameCountNew == 0) {
      trgX ++;
      if (trgX >= tv2.tW) {
        trgX = 0;
        trgY ++;
        if (trgY >= tv2.tH) {
          trgY = 0;
          trgZ += 1;
        }
        if (trgZ >= tv2.tC) {
          trgZ = 0;
        }
      }
      setFilterTrgPosition(tv2.boxes[trgZ][trgY][trgX]);
      tv2.boxes[trgZ][trgY][trgX].curBSize = new PVector(0, 0, 0);
    }
  }

  void draw() {
    update();
    filter.draw();
  }
}

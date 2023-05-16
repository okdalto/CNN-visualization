class ReshapeVisualizer {
  TensorVisualizer tvSrc;
  TensorVisualizer tvTrg;
  TensorVisualizer tv;
  int interval = 100;
  ReshapeVisualizer(TensorVisualizer tvSrc, TensorVisualizer tvTrg) {
    this.tvSrc = tvSrc;
    this.tvTrg = tvTrg;
    this.tv = new TensorVisualizer(tvSrc.gridPos, tvSrc.gridSize, tvSrc.tensor, tvSrc.bSize, tvSrc.speedMin, tvSrc.speedMax, tvSrc.drag);
  }

  void draw() {
    this.tv.draw();
    if (frameCount % interval == 0) {
      tv.setTargetPos(tvSrc);
    } else if (frameCount % interval == interval/2) {
      tv.setTargetPos(tvTrg);
    }
  }
}

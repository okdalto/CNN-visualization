
class Box {
  PVector curPos;
  PVector trgPos;
  PVector vel;
  PVector curBSize;
  PVector trgBSize;
  PVector velBSize;

  float orgValue;
  PVector curValue;
  PVector trgValue;
  float speed;
  float drag;

  Box(PVector pos, PVector bSize, float value, float speed, float drag) {
    this.curPos = pos;
    this.trgPos = new PVector(pos.x, pos.y, pos.z);
    this.vel = new PVector();
    this.curBSize = new PVector();
    this.trgBSize = new PVector(bSize.x, bSize.y, bSize.z);
    this.velBSize = new PVector();
    this.orgValue = value;
    this.curValue = new PVector(0, 0, 0);
    this.trgValue = new PVector(value, value, value);

    this.speed = speed;
    this.drag = drag;
  }

  Box copy() {
    return new Box(
      new PVector(this.curPos.x, this.curPos.y, this.curPos.z),
      new PVector(this.curBSize.x, this.curBSize.y, this.curBSize.z),
      curValue.x,
      speed,
      drag
      );
  }

  void draw() {
    visualization.pushMatrix();
    visualization.translate(curPos.x, curPos.y, curPos.z);
    visualization.stroke(255);
    //visualization.fill(0);
    visualization.fill(this.curValue.x * 256.0, this.curValue.y * 256.0, this.curValue.z * 256.0);
    //visualization.fill(this.curValue.x, this.curValue.y, this.curValue.z);
    visualization.box(this.curBSize.x, this.curBSize.y, this.curBSize.z);
    //visualization.box(this.curValue.x, this.curValue.y, this.curBSize.z);
    visualization.popMatrix();
  }

  void update() {
    //this.vel.add(PVector.sub(this.trgPos, this.curPos).mult(this.speed));
    //this.vel.mult(this.drag);
    //this.curPos.add(this.vel);
    this.curPos.add(PVector.sub(this.trgPos, this.curPos).mult(this.speed));

    this.velBSize.add(PVector.sub(this.trgBSize, this.curBSize).mult(0.9));
    this.velBSize.mult(0.5);
    this.curBSize.add(this.velBSize);

    this.curValue.add(PVector.sub(this.trgValue, this.curValue).mult(0.3));
  }

  void setTarget(Box b) {
    this.trgPos.x = b.curPos.x;
    this.trgPos.y = b.curPos.y;
    this.trgPos.z = b.curPos.z;

    this.trgBSize.x = b.trgBSize.x;
    this.trgBSize.y = b.trgBSize.y;
    this.trgBSize.z = b.trgBSize.z;

    this.curValue = b.curValue;
  }
}

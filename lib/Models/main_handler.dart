class MainHandler {
  double x;
  double y;

  MainHandler(this.x, this.y);

  initCords(double x, double y) {
    this.x = x;
    this.y = y;
  }





  moveUp(double step) {
    if (y >= -0.9) {
      this.y -= step;
    }
  }

  moveDown(double step) {
    if (y <= 0.9) {
     this.y += step;
    }
  }

  moveRight(double step) {
    if (x<=0.9) {
      this.x += step;
    }
    if(x>0.9) {
      x = 0.9;
    }
  }

  moveLeft(double step) {
    if (x >= -0.9) {
      this.x -= step;
    }
    if(x<-0.9) {
      x = -0.9;
    }
  }
}

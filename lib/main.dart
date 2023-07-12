// The Android 11 easter egg, made in raw dart code.
// Copyright (C) 2022, 2023 Anurag Roy

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

// The view on which the easter egg will be drawn; initialized in the main
// method.
late final ui.FlutterView view;

double cnvtDegToRad(double degrees){
  return (degrees / 180) * math.pi;
}

ui.Color colorRGBO(int r, int g, int b, num o) {
  return ui.Color.fromRGBO(r, g, b, o.toDouble());
}

ui.Picture paint(ui.Rect paintBounds, double time) {
  // The time normalized from 0 to 2 * math.pi.
  final double twoPiTime = math.pi * (time % 2);

  // The state of the dial ticks is determined by whether sin(twoPiTime) is
  // negative or positive. As such, we want to make the thumb of the dial rotate
  // within "pi" time, so make its position twice as faster than twoPiTime, but
  // clamp the value between 0 and 2 * math.pi.
  double dialThumbPosition = (twoPiTime * 2) % (2 * math.pi);

  // Initialize recorder and canvas, set bounds to perform operations within.
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder, paintBounds);

  final ui.Offset center = paintBounds.center;

  // Radius of the dial.
  final double radius = paintBounds.shortestSide / 4.0;

  // The radius of the dial ticks, determined by the sine value of twoPiTime.
  late final double activeDialTickRadius;
  late final double inactiveDialTickRadius;
  // Whether the logo should be shown.
  late final bool shouldRevealLogo;
  if (math.sin(twoPiTime) > 0) {
    activeDialTickRadius = radius / 12;
    inactiveDialTickRadius = radius / 48;
    shouldRevealLogo = dialThumbPosition >= cnvtDegToRad(310);
  } else {
    activeDialTickRadius = radius / 48;
    inactiveDialTickRadius = radius / 12;
    shouldRevealLogo = dialThumbPosition < cnvtDegToRad(310);
  }

  // The background color.
  canvas.drawPaint(ui.Paint()..color = colorRGBO(6,47, 65, 1));
  canvas.translate(center.dx, center.dy);

  canvas.save();

  // Final rotation of the entire canvas, except the "11" moniker.
  canvas.rotate(cnvtDegToRad(-42));

  // The shadow beneath the dial.
  final ui.Gradient dialShadow = ui.Gradient.linear(
    ui.Offset.zero,
    ui.Offset(0, paintBounds.shortestSide),
    <ui.Color>[colorRGBO(4, 32, 54, 1), colorRGBO(6, 47, 65, 1)],
    <double>[0.0, 0.6],
  );

  canvas.drawRect(
    ui.Rect.fromLTRB(
      -radius,
      0,
      radius,
      paintBounds.shortestSide,
    ),
    ui.Paint()..shader = dialShadow,
  );

  // The dial.
  canvas.drawCircle(
    ui.Offset.zero,
    radius,
    ui.Paint()..color = colorRGBO(60, 219, 131, 1),
  );

  canvas.save();

  // Draw dial ticks; the size depends on the value of sin(twoPiTime) and
  // whether the dial thumb has moved past the position of the dial tick
  for(int i = 0; i < 10 ; ++i) {
    final double dialTickPosition = cnvtDegToRad(31);
    canvas.drawCircle(
      ui.Offset(0, radius + radius * 2 / 5),
      dialTickPosition * i <= dialThumbPosition
        ? activeDialTickRadius
        : inactiveDialTickRadius,
      ui.Paint()..color = colorRGBO(254, 254, 254, 1),
    );
    canvas.rotate(dialTickPosition);
  }

  canvas.restore();

  // Rotate the canvas in accordance to the dial thumb position.
  canvas.rotate(dialThumbPosition);

  canvas.translate(0, radius * 2 / 3);
  // Draw the dial thumb
  canvas.drawCircle(
    ui.Offset.zero,
    radius / 6,
    ui.Paint()..color = colorRGBO(254, 254, 254, 1),
  );

  canvas.restore();
  // Draw the logo if it should be revealed.
  if (shouldRevealLogo) {
    canvas.save();
    canvas.translate(radius + radius * 9 / 20, 0);

    // The "11" moniker is made using four rounded rectangles:
    // --------    --------
    // |   A  |    |   B  |
    // --------    --------
    //     |  |        |  |
    //     |  |        |  |
    //     |C |        |D |
    //     |  |        |  |
    //     |  |        |  |
    //     ----        ----
    //
    // Sizes are deterimined by eyeballing the native sizes, keeping in
    // accordance with dynamic sizing with respect to available screen size.

    // The rectangle "A".
    canvas.drawRRect(
      ui.RRect.fromRectAndCorners(
        ui.Rect.fromLTRB(
          - radius * 7 /25,
          - radius * 2 / 7,
          - radius / 21,
          - radius * 10 / 63,
        ),
        topLeft: ui.Radius.circular(4.0),
        topRight: ui.Radius.circular(4.0),
        bottomLeft: ui.Radius.circular(4.0),
      ),
      ui.Paint()..color = colorRGBO(247, 102, 51, 1),
    );
    // The rectangle "C".
    canvas.drawRRect(
      ui.RRect.fromRectAndCorners(
        ui.Rect.fromLTRB(
          - radius * 17 / 100,
          - radius * 11 / 63,
          - radius / 21,
          radius * 2 / 7,
        ),
        bottomLeft: ui.Radius.circular(4.0),
        bottomRight: ui.Radius.circular(4.0),
      ),
      ui.Paint()..color = colorRGBO(247, 102, 51, 1),
    );
    // The rectangle "B".
    canvas.drawRRect(
      ui.RRect.fromRectAndCorners(
        ui.Rect.fromLTRB(
          radius / 21,
          - radius * 2 / 7,
          radius * 7 / 25,
          - radius * 10 / 63,
        ),
        topLeft: ui.Radius.circular(4.0),
        topRight: ui.Radius.circular(4.0),
        bottomLeft: ui.Radius.circular(4.0),
      ),
      ui.Paint()..color = colorRGBO(247, 102, 51, 1),
    );
    // The rectangle "D".
    canvas.drawRRect(
      ui.RRect.fromRectAndCorners(
        ui.Rect.fromLTRB(
          radius * 17 / 100,
          - radius * 11 / 63,
          radius * 7 / 25,
          radius * 2 / 7,
        ),
        bottomLeft: ui.Radius.circular(4.0),
        bottomRight: ui.Radius.circular(4.0),
      ),
      ui.Paint()..color = colorRGBO(247, 102, 51, 1),
    );
    canvas.restore();
  }

  return recorder.endRecording();
}

ui.Scene composite(ui.Picture picture) {
  final double devicePixelRatio = view.devicePixelRatio;

  // This transforms the logical sizes to the physical size
  final Float64List deviceTransform = Float64List(16)
    ..[0] = devicePixelRatio
    ..[5] = devicePixelRatio
    ..[10] = 1.0
    ..[15] = 1.0;

  final ui.SceneBuilder sceneBuilder = ui.SceneBuilder()
    ..pushTransform(deviceTransform)
    ..addPicture(ui.Offset.zero, picture)
    ..pop();
  return sceneBuilder.build();
}

void beginFrame(Duration timeStamp) {
  final ui.Size logicalSize = view.physicalSize / view.devicePixelRatio;
  final ui.Rect paintBounds = ui.Offset.zero & logicalSize;
  // Time scaler.
  //
  // Increase to slow down time, decrease to speed up.
  final double timeScaler = 2.0;
  final double time = timeStamp.inMilliseconds / Duration.millisecondsPerSecond / timeScaler;
  final ui.Picture picture = paint(paintBounds, time);
  final ui.Scene scene = composite(picture);
  view.render(scene);
  ui.PlatformDispatcher.instance.scheduleFrame();
}

void main() {
  view = ui.PlatformDispatcher.instance.implicitView!;

  ui.PlatformDispatcher.instance
    ..onBeginFrame = beginFrame
    ..scheduleFrame();
}

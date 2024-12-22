import 'package:flutter/material.dart';
import 'package:intervals/core/network/intervals/data/events.dart' as intervals;
import 'package:intervals/lib/core/network/intervals/data/skyline_chart.pb.dart';
import 'package:intervals/ui/colours.dart';
import 'dart:math' as math;

class ActivityImage extends StatelessWidget {
  final SkylineChart skylineData;

  ActivityImage({
    super.key,
    required this.skylineData,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double maxWidth = constraints.maxWidth == double.infinity
            ? 400
            : constraints.maxWidth;
        double maxHeight = constraints.maxHeight == double.infinity
            ? 400
            : constraints.maxHeight;

        List<WorkoutImageEntry> data = createData(skylineData, maxWidth, maxHeight);

        return WorkoutImageEntryChart(data: data);
      },
    );
  }

  List<WorkoutImageEntry> createData(SkylineChart skylineData, double maxWidth, double maxHeight) {
    var totalWidth =
    skylineData.width.reduce((carry, widthItem) => carry + widthItem);
    var maxIntensity = skylineData.intensity
        .reduce((carry, intensity) => carry < intensity ? intensity : carry);
    if (maxIntensity < 150) {
      maxIntensity = 150;
    }
    // TODO Check the arrays are all the same length
    List<WorkoutImageEntry> data = [];

    for (final (index, width) in skylineData.width.indexed) {
      data.add(WorkoutImageEntry(
          width: (width / totalWidth) * maxWidth,
          height: (skylineData.intensity[index] / maxIntensity) * maxHeight,
          color: convertZoneToColour(
              skylineData.zone[index], skylineData.numZones)));
    }

    return data;
  }

  convertZoneToColour(int zone, int numZones) {
    if (numZones == 7) {
      switch (zone) {
        case 1:
          return const Color.fromRGBO(0, 158, 128, 1);
        case 2:
          return const Color.fromRGBO(0, 158, 0, 1);
        case 3:
          return const Color.fromRGBO(255, 203, 14, 1);
        case 4:
          return const Color.fromRGBO(255, 127, 14, 1);
        case 5:
          return const Color.fromRGBO(221, 4, 71, 1);
        case 6:
          return const Color.fromRGBO(102, 51, 204, 1);
        case 7:
          return const Color.fromRGBO(80, 72, 97, 1);
      }
    }
    return Colors.blue;
  }

}

class WorkoutDocImage extends StatelessWidget {
  final List<intervals.StepEntry> steps;

  final int totalSeconds;

  const WorkoutDocImage({
    super.key,
    required this.steps,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double maxWidth = constraints.maxWidth == double.infinity
            ? 400
            : constraints.maxWidth;
        double maxHeight = constraints.maxHeight == double.infinity
            ? 400
            : constraints.maxHeight;

        List<WorkoutImageEntry> data = createData(steps, maxWidth, maxHeight);

        return WorkoutImageEntryChart(data: data);
      },
    );
  }

  List<WorkoutImageEntry> createData(
      List<intervals.StepEntry> stepData, double maxWidth, double maxHeight) {
    int totalTime = 0;
    intervals.Power? maxPower;
    for (var step in stepData) {
      if (step.duration != null) {
        totalTime += step.duration!;
      }
      if ((step.power?.value?.valueInWatts ?? 0) >
          (maxPower?.value?.valueInWatts ?? 0)) {
        maxPower = step.power;
      }
    }

    double horizontalPixelsPerSecond = maxWidth / totalTime;
    double verticalPixelsPerPowerUnit =
        maxHeight / maxPower!.value!.valueInWatts;

    List<WorkoutImageEntry> data = [];

    for (final intervals.StepEntry step in stepData) {
      if (step.stepRepeat != null) {
        for (int i = 0; i < step.stepRepeat!.reps; i++) {
          for (final intervals.Step s in step.stepRepeat!.steps) {
            data.add(_convertToWorkoutImageEntry(
                s, horizontalPixelsPerSecond, verticalPixelsPerPowerUnit));
          }
        }
      } else {
        data.add(_convertToWorkoutImageEntry(
            step.step!, horizontalPixelsPerSecond, verticalPixelsPerPowerUnit));
      }
    }

    return data;
  }

  WorkoutImageEntry _convertToWorkoutImageEntry(intervals.Step step,
      double horizontalPixelsPerSecond, double verticalPixelsPerPowerUnit) {
    double? height;
    double? heightFinishesAt;

    if (step.power?.value?.valueInWatts != null) {
      height = step.power!.value!.valueInWatts!.toDouble() *
          verticalPixelsPerPowerUnit;
    } else if (step.ramp &&
        step.power != null &&
        step.power!.start != null &&
        step.power!.end != null) {
      height = step.power!.start!;
      heightFinishesAt = step.power!.end!;
    }

    return WorkoutImageEntry(
      color: step.power?.colour != null
          ? HexColor.fromHex(step.power!.colour!)
          : Colors.blue, //step.warmup ? Colors.red : Colors.blue,
      width: (step.duration?.toDouble() ?? 0) * horizontalPixelsPerSecond,
      height: height!,
      heightFinishesAt: heightFinishesAt,
    );
  }

  convertZoneToColour(int zone, int numZones) {
    if (numZones == 7) {
      switch (zone) {
        case 1:
          return const Color.fromRGBO(0, 158, 128, 1);
        case 2:
          return const Color.fromRGBO(0, 158, 0, 1);
        case 3:
          return const Color.fromRGBO(255, 203, 14, 1);
        case 4:
          return const Color.fromRGBO(255, 127, 14, 1);
        case 5:
          return const Color.fromRGBO(221, 4, 71, 1);
        case 6:
          return const Color.fromRGBO(102, 51, 204, 1);
        case 7:
          return const Color.fromRGBO(80, 72, 97, 1);
      }
    }
    return Colors.blue;
  }
}

class WorkoutImageEntryChart extends StatelessWidget {
  final List<WorkoutImageEntry> data;

  WorkoutImageEntryChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double maxWidth = constraints.maxWidth == double.infinity
            ? 400
            : constraints.maxWidth;
        double maxHeight = constraints.maxHeight == double.infinity
            ? 400
            : constraints.maxHeight;

        List<Widget> children = [];

        data.forEach((imageEntry) {
          children.add(WorkoutDocImageRod(
            entry: imageEntry,
          ));
        });

        return SizedBox(
            width: maxWidth,
            height: maxHeight,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: children));
      },
    );
  }
}

class WorkoutImageEntry {
  final Color color;

  final double width;

  final double height;

  double? heightFinishesAt;

  WorkoutImageEntry({
    required this.color,
    required this.width,
    required this.height,
    this.heightFinishesAt,
  });

  @override
  String toString() {
    return 'WorkoutImageEntry{width: $width, height: $height}';
  }
}

class WorkoutDocImageRod extends StatelessWidget {
  final WorkoutImageEntry entry;

  WorkoutDocImageRod({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    Widget box = Container(
      color: entry.color,
      width: entry.width,
      height: entry.height,
    );

    return Container(
      child: entry.heightFinishesAt != null
          ? ClipPath(
                clipper: _Clipper(entry.heightFinishesAt!),
                clipBehavior: Clip.antiAlias,
                child: box)
          : box,
    );
  }
}

class _Clipper extends CustomClipper<Path> {
  final double heightFinishesAt;

  _Clipper(this.heightFinishesAt);

  @override
  Path getClip(Size size) {
    Path path = Path();

    // Path starts from the top left of the container.
    // The left border has a total height of size.height
    // The right border has a total height of heightFinishesAt
    // The bottom border has a total width of size.width
    // The top border has a total width of size.width

    double startingHeight = 0.0; // Height would be 0 if size.height is larger than heightFinishesAt. Otherwise it's the +ve difference between them
    if (size.height < heightFinishesAt) {
      startingHeight = heightFinishesAt - size.height;
    }

    double finishingHeight = 0.0; // Height would be 0 if size.height is smaller than heightFinishesAt. Otherwise it's the +ve difference between them
    if (size.height > heightFinishesAt) {
      finishingHeight = size.height - heightFinishesAt;
    }

    path.moveTo(0.0, startingHeight);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, finishingHeight);

    // path.moveTo(0,size.height); // Top left.
    // path.lineTo(size.width,heightFinishesAt);
    // path.lineTo(size.width, size.height); // Bottom right.
    // path.lineTo(size.width, 0.0);
    // path.lineTo(size.width, heightFinishesAt);
    // path.lineTo(0.0, heightFinishesAt);
// print(path.getBounds());
    path.close();

    return path;
  }

  @override
  bool shouldReclip(_Clipper oldClipper) {
    return false;
    // return oldClipper.heightFinishesAt != heightFinishesAt;
  }
}

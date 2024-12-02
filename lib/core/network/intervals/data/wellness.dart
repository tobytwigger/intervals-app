class Wellness {
  final DateTime date;

  final double? ctl;

  final double? atl;

  final double? rampRate;

  final double? ctlLoad;

  final double? atlLoad;

  Wellness({
    required this.date,
    this.ctl,
    this.atl,
    this.rampRate,
    this.ctlLoad,
    this.atlLoad
  });

  factory Wellness.fromJson(Map<String, dynamic> json) {
    return Wellness(
        date: DateTime.parse(json['id']),
        ctl: json['ctl'],
        atl: json['atl'],
        rampRate: json['rampRate'],
        ctlLoad: json['ctlLoad'],
        atlLoad: json['atlLoad']
    );
  }
}
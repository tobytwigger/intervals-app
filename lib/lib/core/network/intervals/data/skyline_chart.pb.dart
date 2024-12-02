//
//  Generated code. Do not modify.
//  source: lib/core/network/intervals/data/skyline_chart.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class SkylineChart extends $pb.GeneratedMessage {
  factory SkylineChart({
    $core.int? numZones,
    $core.Iterable<$core.int>? width,
    $core.Iterable<$core.int>? intensity,
    $core.Iterable<$core.int>? zone,
    $core.int? type
  }) {
    final $result = create();
    if (numZones != null) {
      $result.numZones = numZones;
    }
    if (width != null) {
      $result.width.addAll(width);
    }
    if (intensity != null) {
      $result.intensity.addAll(intensity);
    }
    if (zone != null) {
      $result.zone.addAll(zone);
    }
    if (type != null) {
      $result.type = type;
    }
    return $result;
  }
  SkylineChart._() : super();
  factory SkylineChart.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SkylineChart.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SkylineChart', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'numZones', $pb.PbFieldType.OU3, protoName: 'numZones')
    ..p<$core.int>(2, _omitFieldNames ? '' : 'width', $pb.PbFieldType.KU3)
    ..p<$core.int>(3, _omitFieldNames ? '' : 'intensity', $pb.PbFieldType.KU3)
    ..p<$core.int>(4, _omitFieldNames ? '' : 'zone', $pb.PbFieldType.KU3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SkylineChart clone() => SkylineChart()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SkylineChart copyWith(void Function(SkylineChart) updates) => super.copyWith((message) => updates(message as SkylineChart)) as SkylineChart;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SkylineChart create() => SkylineChart._();
  SkylineChart createEmptyInstance() => create();
  static $pb.PbList<SkylineChart> createRepeated() => $pb.PbList<SkylineChart>();
  @$core.pragma('dart2js:noInline')
  static SkylineChart getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SkylineChart>(create);
  static SkylineChart? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get numZones => $_getIZ(0);
  @$pb.TagNumber(1)
  set numZones($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasNumZones() => $_has(0);
  @$pb.TagNumber(1)
  void clearNumZones() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get width => $_getList(1);

  @$pb.TagNumber(3)
  $core.List<$core.int> get intensity => $_getList(2);

  @$pb.TagNumber(4)
  $core.List<$core.int> get zone => $_getList(3);

  @$pb.TagNumber(5)
  $core.int get type => $_getIZ(4);
  @$pb.TagNumber(5)
  set type($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasType() => $_has(4);
  @$pb.TagNumber(5)
  void clearType() => clearField(5);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');

###############################################################################
#
#  03.2017 torte
#  All rights reserved
#
#  This script is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  any later version.
#
#  The GNU General Public License can be found at
#  http://www.gnu.org/copyleft/gpl.html.
#  A copy is found in the textfile GPL.txt and important notices to the license
#  from the author is found in LICENSE.txt distributed with these scripts.
#
#  This script is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#
###############################################################################
package main;

use strict;
use warnings;



my $version = "1.40";

sub XiaomiSmartHome_Device_updateSReading($);



#####################################
sub XiaomiSmartHome_Device_Initialize($)
{
  my ($hash) = @_;

  $hash->{Match}     = ".*magnet.*|.*motion.*|sensor_ht|.*switch.*|plug|.*cube.*|86sw1|86sw2|ctrl_neutral1|ctrl_neutral2|rgbw_light|curtain|ctrl_ln1|ctrl_ln2|86plug|natgas|smoke|weather.v1|sensor_wleak.aq1|vibration|remote.b186acn01|remote.b286acn01|remote.b1acn01";
  $hash->{DefFn}     = "XiaomiSmartHome_Device_Define";
  $hash->{SetFn}     = "XiaomiSmartHome_Device_Set";
  $hash->{UndefFn}   = "XiaomiSmartHome_Device_Undef";
  $hash->{ParseFn}   = "XiaomiSmartHome_Device_Parse";
  $hash->{FingerprintFn} = "XiaomiSmartHome_Device_Fingerprint";

  $hash->{AttrList}  = "follow-on-for-timer:1,0 follow-on-timer ".
                       "do_not_notify:1,0 ignore:1,0 dummy:1,0 showtime:1,0 valueFn:textField-long ".
					   "rnd_tmp:0,1,2,3 ".
					   "rnd_hum:0,1,2,3 ".
					   "rnd_bat:0,1,2,3 ".
					   "rnd_pres:0,1,2,3 ".
                       $readingFnAttributes ;
}
#####################################

sub XiaomiSmartHome_Device_mot($$)
{
	my ($hash, $mot) = @_;

	InternalTimer(gettimeofday()+$mot, "XiaomiSmartHome_Device_on_timeout",$hash, 0);

}
#####################################

sub XiaomiSmartHome_Device_Set($@)
{
	my ( $hash, $name, $cmd, @args ) = @_;

	return "\"set $name\" needs at least one argument" unless(defined($cmd));

	my $setlist = "";
	$setlist .= "motionOffTimer:1,5,10 " if ($hash->{MODEL} =~ /motion/);
	#$setlist = "open:noArg close:noArg " if ($hash->{MODEL} =~ /magnet/);
	$setlist .= "power:on,off " if ($hash->{MODEL} eq 'plug');
	$setlist .= "power:on,off " if ($hash->{MODEL} eq '86plug');
	$setlist .= "ctrl:on,off " if ($hash->{MODEL} eq 'ctrl_neutral1');
	$setlist .= "ctrl:on,off " if ($hash->{MODEL} eq 'ctrl_ln1');
	$setlist .= "channel_0:on,off channel_1:on,off " if ($hash->{MODEL} eq 'ctrl_neutral2');
	$setlist .= "channel_0:on,off channel_1:on,off " if ($hash->{MODEL} eq 'ctrl_ln2');
	$setlist .= "status:open,close,stop,auto level:slider,1,1,100 " if ($hash->{MODEL} eq 'curtain');

	if($cmd eq "power")
	{
	   if($args[0] eq "on")
	   {
			IOWrite($hash,"power","on",$hash) if ($hash->{MODEL} eq 'plug');
			IOWrite($hash,"86power","on",$hash) if ($hash->{MODEL} eq '86plug');
			return;
	   }
	   elsif($args[0] eq "off")
	   {
			IOWrite($hash,"power","off",$hash) if ($hash->{MODEL} eq 'plug');
			IOWrite($hash,"86power","off",$hash) if ($hash->{MODEL} eq '86plug');
			return;
	   }
	}
	if($cmd eq "ctrl")
	{
	   if($args[0] eq "on")
	   {
			IOWrite($hash,"ctrl","on",$hash) if ($hash->{MODEL} eq 'ctrl_neutral1');
			IOWrite($hash,"ctrl_ln1","on",$hash) if ($hash->{MODEL} eq 'ctrl_ln1');
			return;
	   }
	   elsif($args[0] eq "off")
	   {
			IOWrite($hash,"ctrl","off",$hash) if ($hash->{MODEL} eq 'ctrl_neutral1');
			IOWrite($hash,"ctrl_ln1","off",$hash) if ($hash->{MODEL} eq 'ctrl_ln1');
			return;
	   }
	}
	if($cmd eq "channel_0")
	{
	   if($args[0] eq "on")
	   {
			IOWrite($hash,"channel_0","on",$hash) if ($hash->{MODEL} eq 'ctrl_neutral2');
			IOWrite($hash,"ctrl_ln2_0","on",$hash) if ($hash->{MODEL} eq 'ctrl_ln2');
			return;
	   }
	   elsif($args[0] eq "off")
	   {
			IOWrite($hash,"channel_0","off",$hash) if ($hash->{MODEL} eq 'ctrl_neutral2');
			IOWrite($hash,"ctrl_ln2_0","off",$hash) if ($hash->{MODEL} eq 'ctrl_ln2');
			return;
	   }
	}
	if($cmd eq "channel_1")
	{
	   if($args[0] eq "on")
	   {
			IOWrite($hash,"channel_1","on",$hash) if ($hash->{MODEL} eq 'ctrl_neutral2');
			IOWrite($hash,"ctrl_ln2_1","on",$hash) if ($hash->{MODEL} eq 'ctrl_ln2');
			return;
	   }
	   elsif($args[0] eq "off")
	   {
			IOWrite($hash,"channel_1","off",$hash) if ($hash->{MODEL} eq 'ctrl_neutral2');
			IOWrite($hash,"ctrl_ln2_1","off",$hash) if ($hash->{MODEL} eq 'ctrl_ln2');
			return;
	   }
	}
	if($cmd eq "status")
	{
	   if($args[0] eq "open")
	   {
			IOWrite($hash,"status","open",$hash) ;
			return;
	   }
	   elsif($args[0] eq "close")
	   {
			IOWrite($hash,"status","close",$hash) ;
			return;
	   }
	   elsif($args[0] eq "stop")
	   {
			IOWrite($hash,"status","stop",$hash) ;
			return;
	   }
	   elsif($args[0] eq "auto")
	   {
			IOWrite($hash,"status","auto",$hash) ;
			return;
	   }
	}
	if($cmd eq "level")
	{
		IOWrite($hash,"level", $args[0] ,$hash) ;
		return;
	}
	# if($cmd eq "open")
	# {
		# readingsSingleUpdate($hash, "state", "open", 1 );
		# return;
	# }
	if($cmd eq "motionOffTimer")
	{
		readingsSingleUpdate($hash, "motionOffTimer", "$args[0]", 1 );;
		return;
	}

	return "Unknown argument $cmd, choose one of $setlist";

}


#####################################

sub XiaomiSmartHome_Device_on_timeout($){
	my ($hash) = @_;
	my $name = $hash->{LASTInputDev};
	if ($hash->{STATE} eq 'motion') {
		readingsSingleUpdate($hash, "state", "off", 1 );
		Log3 $name, 3, "$name: DEV_Timeout>" . " SID: " . $hash->{SID} . " Type: " . $hash->{MODEL}  . " Status: off";
		}
}
#####################################
sub XiaomiSmartHome_Device_Read($$$){
	my ($hash, $msg, $name) = @_;

	my $XMIround_tmp = AttrVal( $hash->{NAME}, "rnd_tmp", "2" );
	my $XMIround_hum = AttrVal( $hash->{NAME}, "rnd_hum", "2" );
	my $XMIround_bat = AttrVal( $hash->{NAME}, "rnd_bat", "1" );
	my $XMIround_pres = AttrVal( $hash->{NAME}, "rnd_pres", "2" );

	my $decoded = eval{decode_json($msg)};
	if ($@) {
		Log3 $name, 1, "$name: DEV_Read> Error while request: $@";
		return;
	}
	my $sid = $decoded->{'sid'};
	my $model = $decoded->{'model'};
	my $cmd = $decoded->{'cmd'};
	Log3 $name, 5, "$name: DEV_Read> SID: " . $hash->{SID} . " " . $hash->{TYPE};
	my $data = eval{decode_json($decoded->{data})};
	if ($@) {
		Log3 $name, 1, "$name: DEV_Read> Error while request data: $@";
		return;
	}
	readingsBeginUpdate( $hash );
		if (defined $data->{status}){
			Log3 $name, 3, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " Status: " . $data->{status};
			readingsBulkUpdate($hash, "state", "$data->{status}", 1 );
			if ($data->{status} eq 'motion' && $hash->{MODEL} =~ /motion/){
				readingsBulkUpdate($hash, "no_motion", "0", 1 );
				}
			if ($data->{status} eq 'close' && $hash->{MODEL} =~ /magnet/){
				readingsBulkUpdate($hash, "no_close", "0", 1 );
				}
			}

		if (defined $data->{no_motion}){
			Log3 $name, 4, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " NO_motion: " . $data->{no_motion};
			readingsBulkUpdate($hash, "no_motion", "$data->{no_motion}", 1 );
			}
		if (defined $data->{no_close}){
			Log3 $name, 4, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " NO_close: " . $data->{no_close};
			readingsBulkUpdate($hash, "no_close", "$data->{no_close}", 1 );
			}
		if (defined $data->{voltage}){
			my $bat = ($data->{voltage}/1000);
			Log3 $name, 4, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " Voltage: " . $data->{voltage};
			if ($bat < 2.2) {
				readingsBulkUpdate($hash, "batteryState", "low", 1 );
				}
				else {
					readingsBulkUpdate($hash, "batteryState", "ok", 1 )
				}
			$bat = XiaomiSmartHome_round($bat, $XMIround_bat, $name );
			readingsBulkUpdate($hash, "batteryVoltage", $bat, 1 );
			}
		if (defined $data->{temperature}){
			if ($data->{temperature} ne "10000"){
				my $temp = sprintf( "%#.4d", $data->{temperature});
				$temp =~ s/(^[-+]?\d+?(?=(?>(?:\d{2})+)(?!\d))|\G\d{3}(?=\d))/$1./g;
				$temp = XiaomiSmartHome_round($temp, $XMIround_tmp, $name );
				Log3 $name, 3, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " Temperature: " . $temp . " Round: " . $XMIround_tmp;
				readingsBulkUpdate($hash, "temperature", "$temp", 1 );
				}
			}
		if (defined $data->{humidity}){
			if ($data->{humidity} ne "0"){
				my $hum = $data->{humidity};
				$hum =~ s/(^[-+]?\d+?(?=(?>(?:\d{2})+)(?!\d))|\G\d{2}(?=\d))/$1./g;
				$hum = XiaomiSmartHome_round($hum, $XMIround_hum, $name );
				Log3 $name, 3, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " Humidity: " . $hum . " Round: " . $XMIround_hum;
				readingsBulkUpdate($hash, "humidity", "$hum", 1 );
				}
			}
		if (defined $data->{pressure}){
			if ($data->{pressure} ne "0"){
				my $pres = $data->{pressure};
				$pres =~ s/(^[-+]?\d+?(?=(?>(?:\d{3})+)(?!\d))|\G\d{3}(?=\d))/$1./g;
				$pres = XiaomiSmartHome_round($pres, $XMIround_pres, $name );
				Log3 $name, 3, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " Pressure: " . $pres . " Round: " . $XMIround_pres;
				readingsBulkUpdate($hash, "pressure", "$pres", 1 );
				}
			}
		if (defined $data->{lux}){
			my $lux = $data->{lux};
			Log3 $name, 3, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " Illuminance: " . $lux;
			readingsBulkUpdate($hash, "lux", "$lux", 1 );
			}
		#86sw1 + 86sw2 + ctrl_neutral1 + ctrl_neutral2 start
		if (defined $data->{channel_0}){
			Log3 $name, 3, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " Channel_0: " . $data->{channel_0};
			readingsBulkUpdate($hash, "channel_0", "$data->{channel_0}", 1 );
			}
		if (defined $data->{channel_1}){
			Log3 $name, 3, "$name: DEV_Read>" . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " Channel_1: " . $data->{channel_1};
			readingsBulkUpdate($hash, "channel_1", "$data->{channel_1}", 1 );
			}
		if (defined $data->{dual_channel}){
			Log3 $name, 3, "$name: DEV_Read>" . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " Dual_Channel: " . $data->{dual_channel};
			readingsBulkUpdate($hash, "dual_channel", "$data->{dual_channel}", 1 );
			}
		#86sw1 + 86sw2 + ctrl_neutral1 + ctrl_neutral2 end
		#plug & 86plug start
		if (defined $data->{load_voltage}){
			Log3 $name, 4, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " LOAD_Voltage: " . $data->{load_voltage};
			readingsBulkUpdate($hash, "LOAD_Voltage", "$data->{load_voltage}", 1 );
			}
		if (defined $data->{load_power}){
			Log3 $name, 4, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " LOAD_Power: " . $data->{load_power};
			readingsBulkUpdate($hash, "LOAD_Power", "$data->{load_power}", 1 );
			}
		if (defined $data->{power_consumed}){
			Log3 $name, 4, "$name:" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " POWER_Consumed: " . $data->{power_consumed};
			readingsBulkUpdate($hash, "POWER_Consumed", "$data->{power_consumed}", 1 );
			}
		if (defined $data->{inuse}){
			Log3 $name, 4, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " InUse: " . $data->{inuse};
			readingsBulkUpdate($hash, "inuse", "$data->{inuse}", 1 );
			}
		#plug & 86plug end
		#rgbw_light start
		if (defined $data->{level}){
			Log3 $name, 4, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " Level: " . $data->{level};
			readingsBulkUpdate($hash, "level", "$data->{level}", 1 );
			}
		if (defined $data->{hue}){
			Log3 $name, 4, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " Hue: " . $data->{hue};
			readingsBulkUpdate($hash, "hue", "$data->{hue}", 1 );
			}
		if (defined $data->{saturation}){
			Log3 $name, 4, "$name:" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " Saturation: " . $data->{saturation};
			readingsBulkUpdate($hash, "saturation", "$data->{saturation}", 1 );
			}
		if (defined $data->{color_temperature}){
			Log3 $name, 4, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " Color_temperature: " . $data->{color_temperature};
			readingsBulkUpdate($hash, "color_temperature", "$data->{color_temperature}", 1 );
			}
		if (defined $data->{x}){
			Log3 $name, 4, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " X: " . $data->{x};
			readingsBulkUpdate($hash, "x", "$data->{x}", 1 );
			}
		if (defined $data->{y}){
			Log3 $name, 4, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " Y: " . $data->{y};
			readingsBulkUpdate($hash, "y", "$data->{y}", 1 );
			}
		#rgbw_light end
		#cube start
		if (defined $data->{rotate}){
			Log3 $name, 3, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " Rotate: " . $data->{rotate};
			readingsBulkUpdate($hash, "rotate", "$data->{rotate}", 1 );
			readingsBulkUpdate($hash, "state", "rotate", 1 );
			}
		#cube end
		#smoke & natgast start
		if (defined $data->{alarm}){
			Log3 $name, 3, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " Alarm: " . $data->{alarm};
			readingsBulkUpdate($hash, "alarm", "$data->{alarm}", 1 );
			}
		if (defined $data->{density}){
			Log3 $name, 3, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " Density: " . $data->{density};
			readingsBulkUpdate($hash, "density", "$data->{density}", 1 );
			}
		#smoke & natgast end
		#curtain start
		if (defined $data->{curtain_level}){
			Log3 $name, 3, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " Curtain: " . $data->{curtain_level};
			readingsBulkUpdate($hash, "alarm", "$data->{curtain_level}", 1 );
			}
		#curtain end
    #vibration Start
    if (defined $data->{'coordination'}){
      Log3 $name, 3, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " Coordination: " . $data->{coordination};
      readingsBulkUpdate($hash, "coordination", "$data->{coordination}", 1 );
      }
    if (defined $data->{'final_tilt_angle'}){
      Log3 $name, 3, "$name: DEV_Read>" . " Name: " . $hash->{NAME} . " SID: " . $sid . " Type: " . $hash->{MODEL}  . " Final tilt angle: " . $data->{final_tilt_angle};
      readingsBulkUpdate($hash, "final_tilt_angle", "$data->{final_tilt_angle}", 1 );
      }
    #vibration end
		if ($decoded->{'cmd'} eq 'heartbeat'){
		readingsBulkUpdate($hash, 'heartbeat', $decoded->{'sid'} , 1 );
		}

	readingsEndUpdate( $hash, 1 );
	XiaomiSmartHome_Device_update($hash);
	return $hash->{NAME};
}
#####################################

sub XiaomiSmartHome_Device_Parse($$) {
	my ($io_hash, $msg) = @_;

	my $name = $io_hash->{NAME};
	my $decoded = eval{decode_json($msg)};
	if ($@) {
		Log3 $name, 1, "$name: DEV_Parse> Error while request: $@";
		return;
	}
	my $sid = $decoded->{'sid'};
	my $model = $decoded->{'model'};
	if ($modules{XiaomiSmartHome_Device}{defptr}{$sid}{IODev}->{NAME})
	{
		my $hash = $modules{XiaomiSmartHome_Device}{defptr}{$sid}->{IODev};
		Log3 $name, 5, "$name: DEV_Parse> IS DEFINED " . $model . " : " . $sid . " " . $modules{XiaomiSmartHome_Device}{defptr}{$sid}->{IODev};
		$hash = $modules{XiaomiSmartHome_Device}{defptr}{$sid};
		XiaomiSmartHome_Device_Read($hash, $msg, $name);
	}
	else
	{

		Log3 $name, 1, "$name: DEV_Parse> UNDEFINED " . $model . " : " .$sid;
		return "UNDEFINED XMI_$sid XiaomiSmartHome_Device $sid $model $name";
	}
}
#####################################

sub XiaomiSmartHome_Device_update($){
  my ($hash) = @_;
  my $model = $hash->{MODEL};
  my $name = $hash->{NAME};
  my $value_fn = AttrVal( $name, "valueFn", "" );
  #my $mot =  AttrVal( $name, "motionOffTimer", "5" );
  my $mot =  $hash->{READINGS}{motionOffTimer}{VAL} if ($hash->{READINGS}{motionOffTimer});
  if( $value_fn =~ m/^{.*}$/s ) {

    my $LASTCMD = ReadingsVal($name,"lastCmd",undef);

    my $value_fn = eval $value_fn;
    Log3 $name, 4, $name .": DEV_Update valueFn: ". $@ if($@);
    return undef if( !defined($value_fn) );
  }
  if( $model =~ /motion/) {
	XiaomiSmartHome_Device_mot($hash, $hash->{READINGS}{motionOffTimer}{VAL}) if( $hash->{READINGS}{motionOffTimer});
	}
  # Update delete old reading voltage & batterystate
  CommandDeleteReading( undef, "$name voltage" ) if(defined(ReadingsVal($name,"voltage",undef)));
  CommandDeleteReading( undef, "$name batterystate" ) if(defined(ReadingsVal($name,"batterystate",undef)));
  CommandDeleteReading( undef, "$name round" ) if(defined(ReadingsVal($name,"round",undef)));
  CommandDeleteReading( undef, "$name battery_level" ) if(defined(ReadingsVal($name,"battery_level",undef)));
  CommandDeleteReading( undef, "$name battery" ) if(defined(ReadingsVal($name,"battery",undef)));
  CommandDeleteReading( undef, "$name batteryLevel" ) if(defined(ReadingsVal($name,"batteryLevel",undef)));
}
#####################################


sub XiaomiSmartHome_Device_Define($$) {
	my ($hash, $def) = @_;
	my ($name, $modul, $sid, $type, $iodev) = split("[ \t]+", $def);
  	$hash->{TYPE} = $modul;
	$hash->{MODEL} = $type;
	$hash->{SID} = $sid;
	$hash->{NAME} = $name;
	$hash->{VERSION}  = $version;
	$hash->{STATE} = 'initialized';
	$modules{XiaomiSmartHome_Device}{defptr}{$sid} = $hash;
	AssignIoPort($hash,$iodev);
	my $room = $attr{$iodev}{room};

	if(defined($hash->{IODev}->{NAME})) {
        my $IOname = $hash->{IODev}->{NAME};
		Log3 $name, 4, $IOname . ": DEV_Define> " .$name. ": " . $type . " I/O device is " . $hash->{IODev}->{NAME};
      } else {
           Log3 $name, 1, "$name DEV_Define> $type - no I/O device";
    }
    $iodev = $hash->{IODev}->{NAME};

    my $d = $modules{XiaomiSmartHome_Device}{defptr}{$sid};

    return "XiaomiSmartHome device $hash->{SID} on XiaomiSmartHome $iodev already defined as $d->{SID}." if( defined($d) && $d->{IODev} == $hash->{IODev} && $d->{SID} ne $sid );

    Log3 $name, 4, $iodev . ": DEV_Define> " . $name . ": defined as ". $hash->{MODEL};
    $attr{$name}{room} = $room if( !defined( $attr{$name}{room} ) );
    if( $type =~ /motion/) {
    readingsSingleUpdate($hash, "state", "motion", 1 ) if( !defined( $attr{$name}{devStateIcon} ));
		$attr{$name}{devStateIcon}  = 'motion:motion_detector@red off:motion_detector@green no_motion:motion_detector@green' if( !defined( $attr{$name}{devStateIcon} ) );

	}
	elsif ( $type =~ /magnet/) {
		$attr{$name}{devStateIcon}  = 'open:fts_door_open@red close:fts_door@green' if( !defined( $attr{$name}{devStateIcon} ) );
	}
	elsif ( $type eq 'sensor_ht') {
		$attr{$name}{stateFormat}  = 'temperature °C, humidity %' if( !defined( $attr{$name}{stateFormat} ) );
	}
    elsif ( $type eq 'weather.v1') {
		$attr{$name}{stateFormat}  = 'temperature °C, humidity %, pressure kPa' if( !defined( $attr{$name}{stateFormat} ) );
	}

	if( $init_done ) {
		InternalTimer(gettimeofday() + 2, "XiaomiSmartHome_Device_updateSReading", $hash, 0 );
		Log3 $name, 4, $iodev . ": DEV_Define> " . $name . " Init Done set InternalTimer for Update";
	}
	return undef;
}
#####################################
sub XiaomiSmartHome_Device_Fingerprint($$){
	my ($io_name, $msg) = @_;
	Log3 $io_name, 4, "$io_name: Fingerprint> for $msg";
	return ($io_name, $msg );

}

#####################################
sub XiaomiSmartHome_Device_updateSReading($) {

    my $hash        = shift;
	my $name = $hash->{NAME};
	Log3 $name, 4, "$name: DEV_updateSReading> for $hash->{SID}";
	RemoveInternalTimer($hash,'XiaomiSmartHome_Device_updateSReading');
    IOWrite($hash,'read',"$hash->{SID}");
}
#####################################

#####################################
sub XiaomiSmartHome_Device_Undef($)
{
	my ($hash, $arg) = @_;
	my $name = $hash->{NAME};
	my $iodev = $hash->{IODev}->{NAME};
	my $sid = $hash->{SID};
	RemoveInternalTimer($hash);
	Log3 $name, 1, "$iodev: DEV_Undef> ". $hash->{SID} . " > " . $modules{XiaomiSmartHome_Device}{defptr}{$hash->{SID}} . " > " . $sid ." > " . $modules{XiaomiSmartHome_Device}{defptr}{$sid};
	my $error = delete ($modules{XiaomiSmartHome_Device}{defptr}{$sid});
    Log3 $name, 1, "$iodev: DEV_Undef> $name - device deleted " . $error;
    return undef;

}
#####################################

sub XiaomiSmartHome_round {
  my ($n, $p, $name) = @_;
  Log3 $name, 5, "$name: DEV_Round>" . " Value: " . $n . " points: " . $p;
  my $sign = ($n > 0) ? 1 : -1;

  $p ||= 0;
  $n *= 10 ** $p;
  $n = int($n + .5 * $sign);
  my $res =  sprintf( "%." . $p . "f", $n / 10**$p);
  Log3 $name, 5, "$name: DEV_Round>" . " Result_value: " . $res;
  return $res;
}


1;

=pod
=item device
=item summary Module to control XiaomiSmartHome Gateway
=item summary_DE Modul zum steuern des  XiaomiSmartHome Gateway


=begin html

<a name="XiaomiSmartHome_Device"></a>
<h3>XiaomiSmartHome</h3>
<ul>
    <i>XiaomiSmartHome</i> implements the XiaomiSmartHome Gateway and Sensors.
    <a name="XiaomiSmartHome"></a>
	<br/>
	<b>Prerequisite</b>
	<ul>
		<li>Installation of the following packages: apt-get install libio-socket-multicast-perl libjson-perl libcrypt-cbc-perl</li>
		<li>And with CPAN: cpan Crypt::Cipher::AES</li>
	</ul>
	<br/>
	<b>Define</b>
    <ul>
        <code>define &lt;name&gt; XiaomiSmartHome &lt;IP or Hostname&gt;</code>
        <br><br>
        Example: <code>define XiaomiSmartHome XiaomiSmartHome 192.168.1.xxx</code>
        <br><br>
    </ul>
	<br/>
	<b>Set Developermode on the gateway!</b>
    <ul>
		<p>Without the developer mode, no communication with the XiaomiSmartHome gateway is possible.
		<br/>You need an android or ios device. You must often click on the APP versionsnumber to activate the hidden menu.
		<br/>Here is how to turn on the developer mode.
		<br/>Android -> https://louiszl.gitbooks.io/lumi-gateway-local-api/content/device_discover.html
		<br/>IOS go here -> https://github.com/fooxy/homeassistant-aqara/wiki/Enable-dev-mode
		<br/>The password shown in the app must set on the FHEM XioamiSmartHome Gatewaydevice!</p>
    </ul>
	<br/>
	<b>Supported Sensors</b>
	<ul>
		<li>magnet: Window/Door magnetic sensor</li>
		<li>motion: Human body motion sensor</li>
		<li>sensor_motion.aq2: Aqara Human body motion sensor with lux readings</li>
		<li>sensor_ht: Temperature and humidity sensor</li>
		<li>weather.v1: Aqara Temperature, pressure and humidity sensor</li>
		<li>switch: Wireless sensor switch</li>
		<li>plug & 86plug: Smart socket</li>
		<li>cube: Cube sensor</li>
		<li>86sw1: Wireless switch single</li>
		<li>86sw2: Wireless switch double</li>
		<li>ctrl_neutral1: Single bond ignition switch</li>
		<li>ctrl_neutral2: Double bond ignition switch</li>
		<li>rgbw_light: Smart lights (report only)</li>
		<li>curtain: Curtain (Control only if device has reporte curtain_level)</li>
		<li>water: water detector</li>
		<li>smoke: smoke alarm detector</li>
		<ul>
			<li>0: disarm</li>
			<li>1: alarm</li>
			<li>8: battery alarm</li>
			<li>64: alarm sensitivity</li>
			<li>32768: ICC communication failure</li>
		</ul>
		<li>gas: gas alarm detector</li>
		<ul>
			<li>0: disarm</li>
			<li>1: alarm</li>
			<li>2: analog alarm</li>
			<li>64: alarm sensitivity</li>
			<li>32768: ICC communication failure</li>
		</ul>
	</ul>
	<br/>
	<b>Heartbeat</b>
	<ul>
		<li>The XiaomiSmartHome Gateway send every 10 seconds a heartbeat</li>
		<li>The XiaomiSmartHome Devices send every 60 minutes</li>
		<li>The Reading heartbeat will show the SID if a heartbeat received</li>
	</ul>
	<br/>
	<b>Set: Gateway</b>
	<ul>
		<li>password: without password no write to the gateway is possible. Use the MI APP to find the password</li>
		<li>RGB(Colorpicker): set the color</li>
		<li>PCT(Slider): set the brightness in percent</li>
		<li>intervals: set the gateway to on for an time eg. set intervals 07:00-08:00</li>
		<li>ringtone: set the ringtone 0-8,13,21-29,10001-.. | 10000 = off</li>
		<li>volume: set the volume 1-100, (100 is very loud)</li>
		<li>ringvol: set ringtone and volume in on step e.g. set [GWNAME] ringvol 21 10</li>
		<li>learn: set the gateway in learningmode to learn new sensors now push the button from the new sensor</li>
	</ul>
	<br/>
	<b>Set: Devices</b>
	<ul>
		<li>motionOffTimer:  (only motionsensor)
		<br/>You can set a motion Off Timer Attribut on the motion sensor device. You can set 1, 5 or 10 seconds after
		<br/>the motion sensors will automatically set to off. MotionOffTimer is set to 5 by default.
		<br/>Background: The motionsensors does not send off immediately.
		<br/>The Motionsensor send a no_motion after 120, 180, 300, 600, 1200 seconds no motion is detected.</li>
		<li>Power: (only smart soket) on off switch a plug on or off</li>
		<li>ctrl: (only single wirless switch) on off switch </li>
		<li>channel_0: (only double wirless switch) on off switch </li>
		<li>channel_1: (only double wirless switch) on off switch </li>
	</ul>
</ul>

=end html

=begin html_DE

<a name="XiaomiSmartHome_Device"></a>
<h3>XiaomiSmartHome</h3>
<ul>
    <i>XiaomiSmartHome</i> Steuern des XiaomiSmartHome Gateway und deren verbundener Sensoren.
    <a name="XiaomiSmartHome"></a>
	<br/>
	<b>Voraussetzungen</b>
	<ul>
		<li>Diese Pakete m&uuml;ssen installiert sein: apt-get install libio-socket-multicast-perl libjson-perl libcrypt-cbc-perl</li>
		<li>Und mit CPAN: cpan Crypt::Cipher::AES</li>
	</ul>
	<br/>
	<b>Define</b>
    <ul>
        <code>define &lt;name&gt; XiaomiSmartHome &lt;IP oder Name&gt;</code>
        <br><br>
        Example: <code>define XiaomiSmartHome XiaomiSmartHome 192.168.1.xxx</code>
        <br><br>
    </ul>
	<br/>
	<b>Entwicklermodus am Gateway setzen!</b>
    <ul>
		<p>Ohne Entwicklermodus ist keine Kommunikation mit dem Gateway m&ouml;glich.
		<br/>Zum setzen des Entwicklermodusses braucht man ein android oder ios Ger&auml;t mit installierter MI APP.
		<br/>Um das versteckte Men&uuml; zu &ouml;ffnen muss man mehrmals auf die Versionsnummer der MI APP klicken.
		<br/>Hier finden Sie eine Anleitung mit Bildern.
		<br/>Android -> https://louiszl.gitbooks.io/lumi-gateway-local-api/content/device_discover.html
		<br/>IOS  -> https://github.com/fooxy/homeassistant-aqara/wiki/Enable-dev-mode
		<br/>Das Passwort welches in der MI APP angezeigt wird muss im FHEM XiaomiSmartHome Gateway Device gesetzt werden!</p>
    </ul>
	<br/>
	<b>Unterstütze Sensoren</b>
	<ul>
		<li>magnet: Magnetischer Fenster/T&uuml;r Sensor</li>
		<li>motion: Bewegungsmelder</li>
		<li>sensor_ht: Temperatur und Luftdruck</li>
		<li>switch: Funkschalter</li>
		<li>plug & 86plug: Schaltbare Funksteckdose</li>
		<li>cube: W&uuml;rfel Sensor</li>
		<li>86sw1: Einfacher Wandfunkschalter</li>
		<li>86sw2: Wandfunkschalter doppelt</li>
		<li>ctrl_neutral1: Einfacher Wandschalter schaltbar</li>
		<li>ctrl_neutral2: Doppelter Wandschalter schaltbar</li>
		<li>rgbw_light: RBGW Lampe (nur Anzeige)</li>
		<li>curtain: Vorhangmotor (ohne dass das Device den curtain_level gemeldet hat ist ein Steuern nicht &ouml;glich)</li>
		<li>water: Wasser Sensor</li>
		<li>smoke: Rauchmelder</li>
		<ul>
			<li>0: disarm</li>
			<li>1: alarm</li>
			<li>8: battery alarm</li>
			<li>64: alarm sensitivity</li>
			<li>32768: ICC communication failure</li>
		</ul>
		<li>gas: Gasmelder</li>
		<ul>
			<li>0: disarm</li>
			<li>1: alarm</li>
			<li>2: analog alarm</li>
			<li>64: alarm sensitivity</li>
			<li>32768: ICC communication failure</li>
		</ul>
	</ul>
	<br/>
	<b>Heartbeat</b>
	<ul>
		<li>Das XiaomiSmartHome Gateway sendet alle 10 seconds einen heartbeat</li>
		<li>Jedes XiaomiSmartHome Devices sendet alle 60 Minuten einen heartbeat</li>
		<li>Das Reading heartbeat wird mit der SID des jeweiligen Gerätes beim Empfang eines Heartbeat aktualisiert</li>
	</ul>
	<br/>
	<b>Set: Gateway</b>
	<ul>
		<li>password: Ohne Passwort ist ein Schalten des GATEWAY nicht m&ouml;glich. Das Passwort findet man in der MI APP</li>
		<li>RGB(Colorpicker): Einstellen der LED Farbe des Gateways</li>
		<li>PCT(Slider): Einstellen der Helligkeit des Gateways</li>
		<li>intervals: Einschalten des Gateways für einen Zeitraum zb. set intervals 07:00-08:00</li>
		<li>ringtone: Wiedergeben eines Alarmtones 0-8,13,21-29,10001-.. Benutzerdefinierte| 10000 = aus</li>
		<li>volume: Einstellen der Lautst&auml;rke des Alarmtones 1-100, (100 ist sehr laut!)</li>
		<li>ringvol: Wiedergeben eines Arlamtones und gleichzeitiges ver&auml;ndern der Lautst&auml;rke set [GWNAME] ringvol 21 10</li>
		<li>learn: Anlernen neuer Sensoren, nach dem Set an dem neuen Sensor den Button dr&uuml;cken</li>
	</ul>
	<br/>
	<b>Set: Devices</b>
	<ul>
		<li>motionOffTimer:  (nur Bewegungsmelder)
		<br/>Durch setzen des Parameters ist es m&ouml;glich, dass das Reading des Bewegungsmelder nach 1, 5 oder 10 Sekunden
		<br/>automatisch wieder auf off gestellt wird.
		<br/>Hintergrund: Der Bewegungsmelder sendet selber kein off.
		<br/>Der Bewegungsmelder sendet no_motion nach 120, 180, 300, 600, 1200 Sekunden, wenn keine Bewegung festgestellt wurde.</li>
		<li>Power: (nur Funksteckdose) on off Funksteckdose ein oder ausschalten</li>
		<li>ctrl: (nur Funkschalter) on off Funkschalter </li>
		<li>channel_0: (nur Doppelter Wandschalter schaltbar) ein oder ausschalten </li>
		<li>channel_1: (nur Doppelter Wandschalter schaltbar) ein oder ausschalten </li>
	</ul>
</ul>

=end html_DE

=cut


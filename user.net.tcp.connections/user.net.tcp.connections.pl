#!/usr/bin/perl
# encoding: utf-8

# -----------------------------------------------------------------------------
# ESTABLISHED な接続の数を表示します。ZABBIX 用です。
#
#
#
# 1. /var/lib/zabbix/bin などに置いて zabbix:zabbix に。
#
# 2. /etc/zabbix/zabbix_agentd.d/ に active-connections.conf などを置きます。
#
# 3. 上記のファイルを下記のような感じで
#
# UserParameter=net.tcp.connections[*],/var/lib/zabbix/bin/tcp-active-connections.pl --port=$1
#
# (前提: ZABBIX をパッケージで入れた場合)
#
#
#
#
# -----------------------------------------------------------------------------

use strict;
use Getopt::Long;




###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
package out;

# sub new {}

sub println {

	print(@_, "\n");
}












###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
package reader;

use constant KEY_PORT => '.port';
use constant KEY_LINES => '.lines';

# sub new {}

sub new {

	my ($name, $port) = @_;



	my $this = bless({}, $name);
	$this->{KEY_PORT} = $port;
	return $this;
}

sub push {

	my ($this, $line) = @_;
}

sub read {

	my ($this, $line) = @_;



	my ($protocol, undef, undef, $local, $peer, $statue) = split(' ', $line);

	#	
	# port	
	#	
	if(0 < length($this->{KEY_PORT})) {
		my $port = $this->{KEY_PORT};
		if(!($local =~ m/\:$port\z/ms)) {
			return;
		}
	}

	#
	# MATCHED!
	#
	$this->{KEY_LINES}++;
}

sub dump {

	my ($this) = @_;



	my $lines = int($this->{KEY_LINES});

	out::println($lines);
}










###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
package application;

# sub new {}

sub run {

	my ($requested_port) = @_;



	my $command_text = sprintf('/bin/netstat -nta | /bin/grep ESTABLISHED |');

	my $stream = undef;
	if(!open($stream, $command_text)) {
		return;
	}

	my $sum = new reader($requested_port);

	while(my $line = <$stream>) {
		$sum->read($line);
	}

	close($stream);

	$sum->dump();
}









###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
package main;

# sub new {}

sub _usage {

	out::println('usage:');
	out::println('    --help: show this message.');
	out::println('    --port: port. (local)');
	out::println('');
	out::println('    tcp 接続のうち、ESTABLISHED の数を表示します。');
	out::println('    ターゲットとする環境は CentOS 6.5 です。');
	out::println('');
}

sub _main {

	my $action_help = 0;
	my $port = '';



	my $status = Getopt::Long::GetOptions(
		'help!', \$action_help,
		'port=i', \$port);

	if(!$status) {
		_usage();
	}
	elsif($action_help) {
		_usage();
	}
	else {
		application::run($port);
	}
}

_main(@ARGV);
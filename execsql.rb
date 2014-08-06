#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
#  Copyright 2014 agwlvssainokuni
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

require 'optparse'
require File.join(File.dirname(__FILE__), 'exec_sql/mysql')


Version = "1.0."
PARAM = {
  :klass => ExecSql::MySQL,
  :conf => nil,
  :force => false
}

basedir = File.dirname(__FILE__)

opt = OptionParser.new
opt.on("--mysql", "MySQL実行") {|p| PARAM[:klass] = ExecSql::MySQL }
opt.on("--conf=CONF", "接続設定ファイル") {|p| PARAM[:conf] = p }
opt.on("--[no-]force", "強制続行") {|p| PARAM[:force] = p }
opt.on("--[no-]syslog", "SYSLOG出力フラグ") {|p| ExecSql::Logger.syslog_enabled = p }
opt.on("--[no-]console", "コンソール出力フラグ") {|p| ExecSql::Logger.console_enabled = p }
opt.parse!(ARGV)

logger = ExecSql::Logger.new("")
logger.debug("class   = %s", PARAM[:klass].to_s)
logger.debug("conf    = %s", PARAM[:conf])
logger.debug("force   = %s", PARAM[:force])
logger.debug("syslog  = %s", ExecSql::Logger.syslog_enabled)
logger.debug("console = %s", ExecSql::Logger.console_enabled)

executor = PARAM[:klass].new(PARAM[:conf], File.dirname(__FILE__))
ok = executor.execute(ARGV, PARAM[:force])
exit(ok ? 0 : 1)

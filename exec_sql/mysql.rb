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

require 'open3'
require File.join(File.dirname(__FILE__), 'logger')

module ExecSql

  # MySQL対応
  class MySQL

    # インスタンス初期化
    def initialize(conf, basedir)
      @conf = (conf.nil? || conf.empty?) ? "#{basedir}/execsql-my.cnf" : conf
    end

    # SQL実行
    def execute(files, force)
      @logger = Logger.new("EXECSQL[MySQL]")
      @logger.debug("start")

      argv = ["--defaults-extra-file=#{@conf}"]
      argv << "--force" if force

      files = files.lazy unless force
      status = files.map {|f|
        @logger.debug("Executing %s", f)
        Open3.popen2e("mysql", *argv) {|si, so, th|

          IO.foreach(f) {|l| si << l}
          si.close_write

          so.each_line {|l|
            @logger.error("mysql < %s: %s", f, l.chomp) if l =~ /ERROR/
          }

          st = th.value
          if st.success?
            @logger.notice("mysql < %s: OK, status=%d", f, st)
          else
            @logger.error("mysql < %s: NG, status=%d", f, st)
          end

          st
        }
      }.find {|st|
        ! st.success?
      }

      if status.nil? || status.success?
        @logger.debug("end normally")
        return true
      else
        @logger.debug("end abnormally")
        return false
      end
    end

  end
end

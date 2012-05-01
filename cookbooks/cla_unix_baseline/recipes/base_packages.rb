#
# Cookbook Name:: cla_unix_baseline
# Recipe:: base_packages
#
# Copyright 2011, Joshua Buysse, (C) Regents of the University of Minnesota
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

lucid_only_plist = %w( libcompress-zlib-perl ia32-libs )
## ia32-libs currently broken in precise, bug # 923904 apt failing to calculate multiarch

ubuntu_lucid_plist = %w( python perl ispell wamerican tcl tk tix
blt tclreadline expect python-software-properties build-essential git-core git-svn
ruby-full libtcltk-ruby vim emacs vim-common nano openssh-server acct acl alpine-pico
apt-file apt-listchanges beav bsdgames bsdgames-nonfree buffer bvi bzip2 cadaver
cpio curl dconf debget debhelper detox devscripts dialog enscript extract file fortune-mod
fortunes-bofh-excuses fortunes fortunes-spam gdb gnupg gnupg-doc gnuplot gnuplot-doc
gnuplot-x11 gobjc graphviz graphviz-dev graphviz-doc indent ksh ldap-utils lftp links
lynx m4 mailutils memstat multitail mysql-client newbiedoc nfs4-acl-tools ntp ntpdate
numactl openipmi openssh-blacklist openssl-blacklist openssh-blacklist-extra
openssl-blacklist-extra openssl p7zip perl-doc perl-tk pkgsync psutils pv
python-docutils python-openssl python-setuptools python-setupdocs python-tk rubygems screen tmux
sharutils shtool strace subversion subversion-tools sudo sysstat tcsh trend wget whois
libdbd-csv-perl libdbd-mysql-perl libdbi-perl libdbd-pg-perl
libdbd-sqlite3-perl libwww-perl python-gtk2 python-glade2 python-sqlite python-ldap
python-libxml2 autofs5 ruby-dev xinetd  
cvs mercurial mercurial-git )

rh_5_plist = []
#rh_5_plist = %w( python python-devel perl perl-devel perl-Tk ruby ruby-devel ruby-rdoc ruby-ri ruby-irb 
#gcc-gfortran gcc-c++ gcc-objc aspell aspell-en tcl tcl-devel tclx tclx-devel tk tk-devel tix expect expectk 
#git-all subversion vim emacs ctags nano psacct acl bzip2 cadaver cpio curl dialog enscript file 
#fortune-mod gdb gnupg gnuplot graphviz graphviz-devel graphviz-gd indent ksh openldap openldap-devel
#lftp elinks lynx m4 mailx mysql mysql-devel ncftp ntp OpenIPMI screen sudo sysstat tcsh wget xinetd 
#cvs mercurial tmux )

case node[:platform]
when "ubuntu"
  ubuntu_lucid_plist.each do |pkg|
    package pkg
  end
when "redhat", "centos" 
  rh_5_plist.each do |pkg|
    package pkg
  end
end

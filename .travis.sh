#!/bin/bash

# Copyright (C) 2015-2016  Unreal Arena
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Travis CI support script


################################################################################
# Setup
################################################################################

# Arguments parsing
if [ $# -ne 1 ]; then
	echo "Usage: ${0} <STEP>"
	exit 1
fi


################################################################################
# Routines
################################################################################

# before_install
before_install() {
	sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
	sudo apt-get -qq update
}

# install
install() {
	sudo apt-get -qq install gcc-4.7\
	                         g++-4.7\
	                         libc6\
	                         libglib2.0-0\
	                         libjpeg-turbo8\
	                         libpcre3\
	                         libpng12-0\
	                         libxml2\
	                         zip\
	                         zlib1g
	sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.7 100\
	                         --slave   /usr/bin/g++ g++ /usr/bin/g++-4.7
	git clone https://github.com/xonotic/netradient.git
	cd netradient
	make -j8 BUILD=native DEPENDENCIES_CHECK=off binaries-q3map2
}

# before_script
before_script() {
	mkdir -p "${HOMEPATH}"
	ln -s "$(pwd)/maps/${MAP}" "${HOMEPATH}/pkg"
}

# script
script() {
	cd "maps/${MAP}"
	q3map2 -threads 8 -fs_homebase .unrealarena -fs_game pkg -meta\
	                                                         -custinfoparms\
	                                                         -keeplights\
	                                                         "maps/${MAP}.map"
	q3map2 -threads 8 -fs_homebase .unrealarena -fs_game pkg -vis\
	                                                         -saveprt\
	                                                         "maps/${MAP}.map"
	q3map2 -threads 8 -fs_homebase .unrealarena -fs_game pkg -light\
	                                                         -faster\
	                                                         "maps/${MAP}.map"
	zip -r9 "../../map-${MAP}_${MAPVERSION}.pk3" . -x "maps/${MAP}.srf" "maps/${MAP}.prt"
}

# before_deploy
before_deploy() {
	if [ "${MAPVERSION}" == "${TAGMAPVERSION}" ]; then
		curl -LsO "https://github.com/unrealarena/unrealarena-maps/releases/download/${TAG}/map-${MAP}.pre.zip"
	else
		zip -9 "map-${MAP}.pre.zip" "map-${MAP}_${MAPVERSION}.pk3"
	fi
}


################################################################################
# Main
################################################################################

# Arguments check
if ! `declare -f "${1}" > /dev/null`; then
	echo "Error: unknown step \"${1}\""
	exit 1
fi

# Enable exit on error & display of executing commands
set -ex

# Run <STEP>
${1}

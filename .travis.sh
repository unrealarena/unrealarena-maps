#!/bin/bash

# Travis CI support script


# Arguments parsing
if [ $# -ne 1 ]; then
	echo "Usage: ${0} <STEP>"
	exit 1
fi


# Routines ---------------------------------------------------------------------

# before_install
before_install() {
	sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
	sudo apt-get -qq update
}

# install
install() {
	sudo apt-get -qq install gcc-4.7 g++-4.7 libc6 libglib2.0-0 libjpeg-turbo8 libpcre3 libpng12-0 libxml2 zip zlib1g
	sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.7 100 --slave /usr/bin/g++ g++ /usr/bin/g++-4.7
	git clone https://github.com/xonotic/netradient.git
	cd netradient
	make -j8 BUILD=native DEPENDENCIES_CHECK=off binaries-q3map2
}

# before_script
before_script() {
	mkdir -p "${HOMEPATH}"
	if [ "${CMNVERSION}" == "${TAGCMNVERSION}" ]; then
		wget -q "https://github.com/unrealarena/unrealarena-maps/releases/download/${TAG}/maps-common.pre.zip"
		unzip "maps-common.pre.zip" -d "${HOMEPATH}"
	else
		cd data
		zip -r9 "${HOMEPATH}/maps-common_${CMNVERSION}.pk3" .
	fi
}

# script
script() {
	if [ "${MAPVERSION}" == "${TAGMAPVERSION}" ]; then
		wget -q "https://github.com/unrealarena/unrealarena-maps/releases/download/${TAG}/map-${MAP}.pre.zip"
	else
		cd "maps/${MAP}"
		q3map2 -threads 8 -fs_homebase .unrealarena -fs_game pkg -meta -custinfoparms -keeplights "maps/${MAP}.map"
		q3map2 -threads 8 -fs_homebase .unrealarena -fs_game pkg -vis -saveprt "maps/${MAP}.map"
		q3map2 -threads 8 -fs_homebase .unrealarena -fs_game pkg -light -faster "maps/${MAP}.map"
		find -type f | fgrep -v -e "maps/${MAP}.srf" \
		                        -e "maps/${MAP}.prt" | zip -9 "${HOMEPATH}/map-${MAP}_${MAPVERSION}.pk3" -@
	fi
}

# before_deploy
before_deploy() {
	if [ ! -f "maps-common.pre.zip" ]; then
		mv "${HOMEPATH}/maps-common_${CMNVERSION}.pk3" .
		zip -9 "maps-common.pre.zip" "maps-common_${CMNVERSION}.pk3"
	fi
	if [ ! -f "map-${MAP}.pre.zip" ]; then
		mv "${HOMEPATH}/map-${MAP}_${MAPVERSION}.pk3" .
		zip -9 "map-${MAP}.pre.zip" "map-${MAP}_${MAPVERSION}.pk3"
	fi
}


# Main -------------------------------------------------------------------------

# Arguments check
if ! `declare -f "${1}" > /dev/null`; then
	echo "Error: unknown step \"${1}\""
	exit 1
fi

# Enable exit on error & display of executing commands
set -ex

# Run <STEP>
${1}

#! /bin/bash
efile="/opt/tinyos-2.1.2/tinyos.sh"
edir="/opt/tinyos-2.1.2"
srcfile="~/.bashrc"

echo "Removing brltty package. It conflicts with TinyOS..."
sudo apt-get autoremove brltty
echo "Intalling build-essentials..."
sudo apt-get install build-essential
echo "Updating sources..."
cd /etc/apt/sources.list.d

# Uncomment the following iff tinyos distro for latest ubuntu release is available
# sudo bash -c "echo deb http://tinyos.stanford.edu/tinyos/dists/ubuntu `lsb_release -cs` main > tinyos.list"
# Else resorting to natty release
sudo bash -c "echo deb http://tinyos.stanford.edu/tinyos/dists/ubuntu natty main > tinyos.list"

echo "Sources updated."
echo "Updating system..."
sudo apt-get update
echo "Installing TinyOS 2.1.2..."
sudo apt-get install tinyos-2.1.2

if [ -d "$edir" ]
then
	if [ -f "$efile" ]
	then
		echo "$efile is installed. Skipping setup script creation..."
	else
		echo "creating $efile as setup script for tinyos..."
		echo "Writing to file..."
		sudo bash -c "echo '# Here we setup the environment variables needed by the tinyos make system' > $efile"
		sudo bash -c "echo 'echo "'Setting up TinyOS on path $TOSROOT'" '>>$efile"
		sudo bash -c "echo 'export TOSROOT="'"'$edir'"'"' >> $efile"
		sudo bash -c "echo 'export TOSDIR="'"$TOSROOT/tos"'"' >> $efile"
		sudo bash -c "echo '"'export CLASSPATH=$CLASSPATH:$TOSROOT/support/sdk/java:.:$TOSROOT/support/sdk/java/tinyos.jar'"' >> $efile"
		sudo bash -c "echo '"'export MAKERULES="$TOSROOT/support/make/Makerules"'"' >> $efile"
		sudo bash -c "echo '"'export PYTHONPATH=$PYTHONPATH:$TOSROOT/support/sdk/python'"' >> $efile"
		echo "$efile written."
	fi

	echo "Appending the tinyos environment variable script to $srcfile ..."
	sudo bash -c "echo -e '\n' >> $srcfile"
	sudo bash -c "echo '# Sourcing the tinyos environment variable script' >> $srcfile"
	sudo bash -c "echo 'source $efile' >> $srcfile"
	source $efile
	echo -e "\n\n"
	echo "Installation complete. Enjoy:-)"
	echo -e "\n\n"
	echo "Checking tinyos..."
	tos-check-env
	java -version
else
	echo "Installation failed!"
fi


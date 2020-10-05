#!/bin/bash
FID=unixawx
HOST=$(hostname)
OS="Solaris 11"
DIR="/etc/ssh/keys"
DIR_ANS="/var/ansible"
ARTIFACTORY_URL=""
LOCAL_KEY="authorized_keys2"

# Function to check if user exists
function VERIFY_USER {
if id ${FID} &>/dev/null; then
    echo "user $FID found on $HOST"
else
    echo "user $FID not found on $HOST"
    exit 1
fi
}

# Verify the operating system type
function VERIFY_OS {
if grep -q $OS /etc/release; then
    echo "OS type: $OS"
else
    echo "The OS is not $OS"
    exit 1
fi
}

# Create OPENSSH FID directory
function CREATE_DIR_SSH {
if [ -d $DIR/$FID ]
then
    echo "Directory $DIR/$FID already exists"
else
    echo "Creating Directory $DIR/$FID"
    mkdir -p $DIR/$FID && chmod 111 $DIR/$FID
fi
}

# Create ansible directory for playbook execution
function CREATE_DIR_ANSIBLE {
if [ -d $DIR_ANS ]
then
    echo "Directory $DIR_ANS already exists"
else
    echo "Creating directory $DIR_ANS"
    mkdir -p $DIR_ANS && chmod 755 $DIR_ANS && chown $FID:root $DIR_ANS
fi
}

# Download and copy keys if not present
function DOWNLOAD_KEYS {
if [ -f $DIR/$FID/$LOCAL_KEY ]
then
    echo "$LOCAL_KEY exist and not downloading"
else
    echo "Downloading $LOCAL_KEY"
    wget --no-check-certificate -O $DIR/$FID/$LOCAL_KEY $URL/$REMOTE_KEY; chmod 644 $DIR/$FID/$LOCAL_KEY
fi
}

# Verify checksum and copy if key changed
function VERIFY_CHECKSUM {
wget --no-check-certificate -P /tmp $URL/$REMOTE_KEY
SUM_LOCAL="$(sum $DIR/$FID/$LOCAL_KEY | awk '{print $1}')"
SUM_REMOTE="$(sum /tmp/$REMOTE_KEY | awk '{print $1}')"

if [ "$SUM_LOCAL" = "$SUM_REMOTE" ];
then
    echo "Checksum matched and not copying keys"
else
    echo "Checksum changed, copying the new key"
    cp /tmp/$REMOTE_KEY $DIR/$FID/$LOCAL_KEY && rm /tmp/$REMOTE_KEY
fi
}

# Create sudoers file for unixawx
function SUDOERS_FILE {
if [ -f /etc/sudoers.d/$FID ]
then
    echo "/etc/sudoers.d/$FID already exists"
else
    echo "Creating file /etc/sudoers.d/$FID"
    echo "$FID          ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/$FID && chmod 440 /etc/sudoers.d/$FID
fi
}

PS3='Please enter your choice: '
options=("dev" "uat" "prod" )
select opt in "${options[@]}"
do
    case $opt in
        "dev")
            REMOTE_KEY="id_rsa_$FID_$opt.pub"
            echo "Preparing to generate $opt environment keys for $FID user on $HOST"
            VERIFY_USER;VERIFY_OS;CREATE_DIR_SSH;CREATE_DIR_ANSIBLE;DOWNLOAD_KEYS;VERIFY_CHECKSUM;SUDOERS_FILE
            break
            ;;
        "uat")
            REMOTE_KEY="id_rsa_$FID_$opt.pub"
            echo "Preparing to generate $opt environment keys for $FID user on $HOST"
            VERIFY_USER;VERIFY_OS;CREATE_DIR_SSH;CREATE_DIR_ANSIBLE;DOWNLOAD_KEYS;VERIFY_CHECKSUM;SUDOERS_FILE
            break
            ;;
        "prod")
            REMOTE_KEY="id_rsa_$FID_$opt.pub"
            echo "Preparing to generate $opt environment keys for $FID user on $HOST "
            VERIFY_USER;VERIFY_OS;CREATE_DIR_SSH;CREATE_DIR_ANSIBLE;DOWNLOAD_KEYS;VERIFY_CHECKSUM;SUDOERS_FILE
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

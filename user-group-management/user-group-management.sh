#!/bin/bash

#This script allows the user to manage users and groups
#It will provide them with options to create, modify 
#Or delete Users or Groups

#This script requires root privilages
if [[ "${UID}" -ne 0 ]]
then 
	echo "Use sudo ${0} or run as root"
	exit 1
fi

#Function responsible for adding a new user
create_user()
{
	read -p "Enter Username: " USER_NAME
	read -p "Enter Fullname: " REAL_NAME

	#autogenerates password
	PASSWORD=$(date +%s| sha256sum | head -c12)
	echo "${PASSWORD}"
	
	#Add USER
	useradd -c "${REAL_NAME}" "${USER_NAME}"

	#Checks to see if last command was successful

	if [[ ${?} -ne 0 ]]
	then
		echo "The user could not be created"
		return
	fi

	#Set Password

	echo "$USER_NAME:$PASSWORD" | sudo chpasswd

	#Check to see if last command was successful

	if [[ ${?} -ne 0 ]]
	then
		echo "The password could not be set"
		return
	fi

	echo "USER_NAME: ${USER_NAME}"
	echo "Fullname: ${REAL_NAME}"
	echo "Password: ${PASSWORD}"
	echo
}

#this function allows the User to modify attributes of other users

modify_user()
{
#Checks to see if user exists before editing user
	read -p "Enter the Username of the user you would like to modify: " USER_NAME
	if ! id "$USER_NAME" &>/dev/null; then
		echo "${USER_NAME} does not exist"
		return
	fi

#Display current information on user

	echo "1. Current attributes for user ${USER_NAME}:"
	echo "2. User ID (UID): $(id -u ${USER_NAME})"
	echo "3. Group ID (GID): $(id -g ${USER_NAME})"
	echo "4. Home Directory: $(getent passwd $USER_NAME | cut -d: -f6)"

	read -p "Enter which attribute you would like to modify: " ATTRIBUTE_CHOICE
	
	case "$ATTRIBUTE_CHOICE" in
	
	1) #modify username
		read -p "Enter new username for ${USER_NAME}: " NEW_USER_NAME
		usermod -l ${NEW_USER_NAME} ${USER_NAME}
		if [[ ${?} -ne 0 ]]
			then
				echo "The username could not be changed to ${NEW_USER_NAME}"
				return
			else
				echo "${USER_NAME}'s new username is now ${NEW_USER_NAME}"
			fi
		;;
	
	2) #change UID
		read -p "Enter the new user ID for ${USER_NAME}: " NEW_UID
		usermod -u "${NEW_UID}" "${USER_NAME}"
		if [[ ${?} -ne 0 ]]
			then
				echo "The UID could not be changed to ${NEW_UID}"
				return
			else
				echo "${USER_NAME}'s new UID is now ${NEW_UID}"
			fi
			;;
			
	3) #Change group ID
		read -p "Enter the new Group ID for ${USER_NAME}: " NEW_GID
		usermod -g ${NEW_GID} ${USER_NAME}
		;;
		
	4)
		read -p "Enter new home directory for ${USER_NAME}: " NEW_USER_DIR
		usermod -d "${NEW_USER_DIR}" "${USER_NAME}" 
		if [[ ${?} -ne 0 ]]
			then
				echo "The home directory could not be changed to ${}"
				return
			else
				echo "${USER_NAME}'s new UID is now ${NEW_UID}"
			fi
		;;
	
	*) echo "Invalid choice, no changes made"
	
	esac
	echo
}

#Creates group
create_group()
{

	read -p "Enter in Group ID (GID) that you would like to create: " GID
	read -p "Enter a name for this Group: " GROUP_NAME
	if getent group "$GID" &>/dev/null; then
		echo "This group already exists"
		return
	fi

	groupadd -g "$GID" "$GROUP_NAME"
	
	if [[ ${?} -ne 0 ]]
		then
			echo "The GID:"$GID" could not be created"
			return
		else
			echo ""$GID" is now a Group number named "$GROUP_NAME""
	fi
	echo
}

delete_group()
{

	read -p "Enter the name of the group that you want to delete: " GROUP_NAME
	
	if getent group "$GROUP_NAME" &>/dev/null; then
		groupdel "$GROUP_NAME"
		
		if [[ ${?} -eq 0 ]]
			then
				echo ""$GROUP_NAME" deleted successfully"
			else
				echo ""$GROUP_NAME" could not be deleted"
				return
			fi
	else
		echo ""$GROUP_NAME" does not exist"
		return	
	fi
	echo
}


#main menu displayed to User

while true; do

	echo "1. Create User"
	echo "2. Modify User"
	echo "3. Create Group"
	echo "4. Delete Group"
	echo "5. Exit"
	read -p "Enter in your choice: " choice
	echo
	
  case "$choice" in 
    1) create_user ;;
    2) modify_user ;;
    3) create_group ;;
    4) delete_group ;;
    5) exit 0 ;;
    *) echo "Invalid choice, pick again" ;;
  esac
done
done

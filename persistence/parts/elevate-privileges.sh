
# with root
# add user to sudo group
usermod -a -G sudo <username>


fuTITLE "trying to add user $USER to sudo group"

usermod -a -G sudo <username> 2>/dev/null



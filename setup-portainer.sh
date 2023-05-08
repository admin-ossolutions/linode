#!/bin/bash

# Update and upgrade the system
sudo apt-get update
sudo apt-get upgrade -y

# Prompt for company name and set hostname
read -p "What is the server name? " servername
sudo hostnamectl set-hostname "$servername"

# Get username and password for new user
read -p "Enter username for new user: " username
while true; do
    read -s -p "Enter password for new user: " password1
    echo
    read -s -p "Confirm password for new user: " password2
    echo
    if [ "$password1" = "$password2" ]; then
        password="$password1"
        break
    else
        echo "Passwords do not match. Please try again."
    fi
done

# Create new user, add to sudo group, and set home directory
sudo useradd -m -s /bin/bash -G sudo $username
echo "$username:$password" | sudo chpasswd
sudo mkdir -p /home/$username
sudo chown $username:$username /home/$username

# Move /opt/scripts to the user's home directory and set ownership
echo "Moving /opt/scripts folder to user's home directory and setting ownership..."
sudo cp -R /opt/scripts /home/$username/
sudo chown -R $username:$username /home/$username/scripts

# Make all .sh files inside the scripts folder executable
echo "Making all .sh files inside the scripts folder executable..."
find /home/$username/scripts -type f -name "*.sh" -exec chmod +x {} \;

# Install Docker and Docker Compose
echo "Installing Docker and Docker Compose..."
curl -sSL https://get.docker.com/ | sh
sudo usermod -aG docker $username
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Portainer
echo "Installing Portainer..."
sudo docker volume create portainer_data
sudo docker run -d -p 8000:8000 -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce

# Output cool thing showing installation is finished
echo "
   _____ ____  __  __ _____  _      ______ _______ ______ 
  / ____/ __ \|  \/  |  __ \| |    |  ____|__   __|  ____|
 | |   | |  | | \  / | |__) | |    | |__     | |  | |__   
 | |   | |  | | |\/| |  ___/| |    |  __|    | |  |  __|  
 | |___| |__| | |  | | |    | |____| |____   | |  | |____ 
  \_____\____/|_|  |_|_|    |______|______|  |_|  |______|

Installation is complete! Enjoy using Docker, Docker Compose, and Portainer.
"

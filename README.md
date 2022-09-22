# horcrux-disco-mon
Log scrapper for [Strangelove Labs Horcrux MPC signer](https://github.com/strangelove-ventures/horcrux) for Cosmos SDK chains that echoes log content to a Discord webhook

Tested on Ubuntu 22.04

![Horcrux Disco Mon](https://user-images.githubusercontent.com/286206/191844002-9cf37114-8280-4411-9e6b-717fceb5b98b.jpg)

# Installing on each signer
This script and service assumes that the horcrux signer is running under a user called `horcrux` with a home directory `/home/horcrux` with the script located here: `/home/horcrux/horcrux-disco-mon.sh`

### Make executable:

`sudo chmod a+x horcrux-disco-mon.sh`

### Change the top portion of the script with your sentry IP:port information (order matters):

`sentries=( "10.0.0.1:1234" "10.0.0.2:1234" )`

### Change the sentry labels (use the same order as above):

`sentryLabels=( "sentry1" "sentry2" )`

### Label each signer:

`whoami="signer1"`

### Give each signer an emoji:

`whoamiEmoji="1️⃣"`

### Create a Discord Webhook in your channel and paste the webhook url into the script:

`url="https://discord.com/api/webhooks/1021204268902010900/GgXg8k4tqI3mwZP6ka0bgHx6t32jBkqY7-8oG7hH6EterU8mb-hilqtZkXURMWc3WbJU"`

### Move service file to systemd directory:

`sudo mv horcrux-disco-mon.service /etc/systemd/system/horcrux-disco-mon.service`

### Reload systemd and enable and start

`sudo systemctl daemon-reload && sudo systemctl enable horcrux-disco-mon && sudo systemctl start horcrux-disco-mon`

#!/bin/bash

sentries=( "10.0.0.1:1234" "10.0.0.2:1234" )
sentryLabels=( "sentry1" "sentry2" )
whoami="signer1"
whoamiEmoji="1️⃣"

declare -a sentriesCooldown
length=${#sentries[@]}
count=50

publishDiscord () {
  url="https://discord.com/api/webhooks/..."

  # POST request to Discord Webhook with the domain name and the HTTP status code
  curl -H "Content-Type: application/json" -X POST -d '{"content":"'"${1}"'"}'  $url

}

announceChanges () {
  case "$1" in
    "start") 
      mesg="$whoamiEmoji: 🚀 $whoami has started"
      publishDiscord "$mesg"
      echo $mesg ;;
    "stop") 
      mesg="$whoamiEmoji: 🛑 $whoami has stopped"
      publishDiscord "$mesg"
      echo $mesg ;;
    "king") 
      if [ $leaderCount -ge 1 ]; then
        echo "Already leader" > /dev/null 2>&1
      else
        mesg="$whoamiEmoji: 👑 I am the raft leader"
        publishDiscord "$mesg"
        echo $mesg
      fi
      leaderCount=$count ;;
    "notKing") 
      if [ $notLeaderCount -ge 1 ]; then
        echo "Already not leader" > /dev/null 2>&1
      else
        mesg="$whoamiEmoji: ⛓ I am not the raft leader"
        publishDiscord "$mesg"
        echo $mesg
      fi
      notLeaderCount=$count ;;
    "sentry") 
      for (( i=0; i<${length}; i++ ));
      do
        if [[ ${sentries[$i]} = $2 ]]; then
          if [ ${sentriesCooldown[$i]} -ge 1 ]; then
            echo "Already signing for" "$2" > /dev/null 2>&1
          else
            s="${sentryLabels[$i]}"
            mesg="$whoamiEmoji: ✍🏼 Signing for $s ($2)"
            publishDiscord "$mesg"
            echo $mesg
          fi
          sentriesCooldown[$i]=$count
        fi
      done ;;
  esac
}

## Cooldown Counters
leaderCount=0
notLeaderCount=0
for (( i=0; i<${length}; i++ ));
do
  sentriesCooldown[$i]=0
done

stdbuf -oL journalctl -u horcrux -f -o cat | 
  while IFS= read -r line
  do
    test "$(echo $line | grep -cim1 'I am not')" -eq 1 && announceChanges notKing || echo "" > /dev/null 2>&1
    test "$(echo $line | grep -cim1 'I am the')" -eq 1 && announceChanges king || echo "" > /dev/null 2>&1
    test "$(echo $line | grep -cim1 'Starting CosignerRaftStore service')" -eq 1 && announceChanges start || echo "" > /dev/null 2>&1
    test "$(echo $line | grep -cim1 'Stopping CosignerRaftStore service')" -eq 1 && announceChanges stop || echo "" > /dev/null 2>&1
    test "$(echo $line | grep -cim1 'node=tcp://')" -eq 1 && announceChanges sentry "$(echo $line | grep -Po 'node=tcp://\s*\K\S*')" || echo "" > /dev/null 2>&1
    ((leaderCount--))
    ((notLeaderCount--))
    for (( i=0; i<${length}; i++ ));
    do
      ((sentriesCooldown[$i]--))
    done
  done

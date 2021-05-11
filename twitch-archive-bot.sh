#!/usr/bin/env bash
CHANNEL="fieldmouse"
DOWNLOAD_DIR="/mnt/videos/fieldmouse"

# DO NOT EDIT BELOW THIS LINE
INSTALL_PATH="/opt/twitch-archive-bot"
CRONCMD="$INSTALL_PATH/twitch-archive-bot.sh -d"

# Loop through arguments and process them
for arg in "$@"
do
    case $arg in
        -s|--stats)
            ID=$(curl -s https://decapi.me/twitch/id/$CHANNEL)
            ACCOUNTAGE=$(curl -s https://decapi.me/twitch/accountage/$CHANNEL)
            TOTAL_VIEWS=$(curl -s https://decapi.me/twitch/total_views/$CHANNEL)
            FOLLOWCOUNT=$(curl -s https://decapi.me/twitch/followcount/$CHANNEL)
            # SUBCOUNT=$(curl -s https://decapi.me/twitch/subcount/$CHANNEL)

            echo "Channel Name:   $CHANNEL"
            echo "Channel ID:     $ID"
            echo "Account Age:    $ACCOUNTAGE"
            echo "Total Views:    $TOTAL_VIEWS"
            echo "Follower Count: $FOLLOWCOUNT"
            # echo "Sub Count:      $SUBCOUNT"
            ;;

        -l|--list)
            VOD_JSON=$(curl -H "Accept: application/json" -s https://decapi.me/twitch/videos/$CHANNEL/?limit=100)
            echo $VOD_JSON | jq .[] | grep 'https://www.twitch.tv/videos/' | cut -d ":" -f2- | rev | cut -c2- | rev
            ;;

        -cji|--cronjob_install)
            cronjob="0 4 * * * $CRONCMD"
            ( crontab -l | grep -v -F "$CRONCMD" || : ; echo "$cronjob" ) | crontab -
            ;;
        
        -cjr|--cronjob_remove)
            cronjob="0 4 * * * $CRONCMD"
            ( crontab -l | grep -v -F "$CRONCMD" ) | crontab -
            ;;

        -d|--download)
            cd $DOWNLOAD_DIR
            for i in $(seq 0 100)
              do
                VOD_JSON=`curl -H "Accept: application/json" -s https://decapi.me/twitch/videos/$CHANNEL/?offset=$i | jq '. | .videos'`
                if [ "$VOD_JSON" = "[]" ]
                  then
                    echo "No Video Found at Offset $i"
                    sleep 1
                  else
                    TITLE=$(echo $VOD_JSON | jq '.[0].title' | cut -c2- | rev | cut -c2- | rev | sed -e 's/[]\/$*.^[]/\\&/g')
                    DATE=$(echo $VOD_JSON | jq '.[0].published_at' | cut -c2- | rev | cut -c12- | rev)
                    URL=$(echo $VOD_JSON | jq '.[0].url' | cut -c2- | rev | cut -c2- | rev)
                    echo "youtube-dl $URL -o \"$TITLE: $DATE\"" | bash
                fi
            done
            ;;

        *)
            echo "usage: twitch-archive-bot.sh"
            echo ""
            echo "    -s, --stats                   Lists stats on the configured channel"
            echo "    -d, --download                Downloads all videos available on a channels 'CHANNEL/videos?filter=archives' to the configured path"
            echo "    -l, --list                    Lists all urls available on a channels 'CHANNEL/videos?filter=archives'"
            echo "    -cji, --cronjob_install       INSTALL a cronjob to download all available videos each day"
            echo "    -cjr, --cronjob_remove        REMOVE the cronjob to download all available videos each day"
            echo ""
            ;;
    esac
  done


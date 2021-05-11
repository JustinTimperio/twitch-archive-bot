# Twitch-Archive-Bot
Twitch-Archive-Bot is a simple bash script designed to sync a Twitch channels archived broadcasts every day at 4am.

### PreRequisites
1. A working bash enviroment and git (WSL, Linux or Mac)
2. A working install of [youtube-dl](https://ytdl-org.github.io/youtube-dl/index.html)

### Install the Archive Bot 
1. Download the script `git clone https://github.com/JustinTimperio/twitch-archive-bot.git`
2. Configure the `Channel` and `Download Path` in `twitch-archive-bot.sh`
3. Run `./twitch-archive-bot.sh --cronjob_install` to setup the background job
4. Run `./twitch-archive-bot.sh --download` to start syncing all the current vidoes

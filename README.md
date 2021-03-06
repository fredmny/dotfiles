# Fred's Dotfiles
These are the configuration files for my Arch Linux installation

## Screenshot
![Screenshot 01](./.screenshots/screenshot_01.png)
![Screenshot 02](./.screenshots/screenshot_02.png)
![Screenshot 03](./.screenshots/screenshot_03.png)

## Used Applications
- **Window Manager:** Qtile 
- **Shell:** zsh (+oh\_my\_zsh)
- **File Manager:** Ranger (with ueberzug to visualize images)
- **Audio Player:** Spotify - controlled through spotify-tui
- **System Monitoring Dashboard:** gtop

## Colors
I am using *pywal* to control the colors of my terminal (main functionality of pywal) as well as of my window manager. 

To change the colors of the window manager I wrote a short *Python* script, that loads the pywal cached color scheme into a list, which is then used in my Qtile configuration file. If you are interested you can find the script [here](https://github.com/fredmny/dotfiles/blob/master/.config/qtile/pywal_colors.py). 

## Wallpaper
The wallpapers for the screenshots are in the wallpaper folder. I got them from a collection from [Luke Smith](https://lukesmith.xyz/), that I downloaded some years ago. 

## How I manage my Dotfiles Repository
I manage my dotfiles with a bare git repository and would engourage you to do the same. Just check following links (I recommend watching the video from Derek Taylor/DistroTube for better understanding):
- [Original Article](https://www.atlassian.com/git/tutorials/dotfiles)
- [More in-depth explanation](https://www.ackama.com/blog/posts/the-best-way-to-store-your-dotfiles-a-bare-git-repository-explained)
- [Video from DT](https://www.youtube.com/watch?v=tBoLDpTWVOM)

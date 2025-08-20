# Spotify Multi-Account Switcher & SpotX Installer for macOS

A collection of bash scripts to manage multiple Spotify accounts and install SpotX modifications on macOS.

## Features

- **Multi-Account Switcher**: Seamlessly switch between multiple Spotify accounts without re-entering credentials
- **SpotX Integration**: Install SpotX modifications with ad blocking, developer mode, and experimental features
- **Profile Management**: Keep separate profiles for each account with preserved login tokens and preferences
- **Cache Management**: Automatic cleanup of volatile caches during account switches

## Tested Environment

- **MacBook Pro** 16-inch, 2023
- **Chip** Apple M2 Max
- **Memory** 96 GB
- **macOS** Sequoia 15.6

## Scripts Included

### 1. Multi-Account Switcher (`spotify-account-switcher.sh`)

Manages separate Spotify profile folders and provides one-command switching between accounts.

**What it does:**
- Keeps a snapshot of your Spotify support folder per account
- One command to switch: kills Spotify, swaps profile, clears caches, launches
- No passwords stored—uses Spotify's saved login tokens

### 2. SpotX Installer (`spotx-sharmanhall.sh`)

Custom SpotX installer that downloads and applies modifications to Spotify.

**Features:**
- Installs specific Spotify version (1.2.68.528.g50f97d42)
- Applies SpotX modifications (ad blocking, dev mode, experimental features)
- Creates automatic backups
- Removes podcasts and blocks updates

## Quick Start

### Setting Up Multi-Account Switching

1. **Make the script executable:**
   ```bash
   chmod +x spotify-account-switcher.sh
   ```

2. **Set up your first account:**
   - Log into Spotify with Account A
   - Quit Spotify completely
   - Save the profile:
     ```bash
     ./spotify-account-switcher.sh init work
     ```

3. **Set up additional accounts:**
   - Log into Spotify with Account B
   - Quit Spotify completely
   - Save the profile:
     ```bash
     ./spotify-account-switcher.sh init personal
     ```

4. **Switch between accounts:**
   ```bash
   # Switch to work account
   ./spotify-account-switcher.sh switch work
   
   # Switch to personal account
   ./spotify-account-switcher.sh switch personal
   
   # List all profiles
   ./spotify-account-switcher.sh list
   ```

### Installing SpotX

1. **Make the script executable:**
   ```bash
   chmod +x spotx-sharmanhall.sh
   ```

2. **Run the installer:**
   ```bash
   ./spotx-sharmanhall.sh
   ```

This will:
- Kill any running Spotify processes
- Create a backup of your current Spotify.app
- Download and install Spotify version 1.2.68.528.g50f97d42
- Apply SpotX modifications
- Launch the modified Spotify

## Usage Commands

### Multi-Account Switcher Commands

```bash
./spotify-account-switcher.sh list                    # List all saved profiles
./spotify-account-switcher.sh init <profile>          # Save current state as profile
./spotify-account-switcher.sh switch <profile>        # Switch to profile and launch
./spotify-account-switcher.sh remove <profile>        # Delete a profile
./spotify-account-switcher.sh open-profiles           # Open profiles folder in Finder
```

### Optional: Create Launcher Scripts

For easier access, create individual launcher scripts:

```bash
echo './spotify-account-switcher.sh switch work' > Spotify-Work.command
echo './spotify-account-switcher.sh switch personal' > Spotify-Personal.command
chmod +x Spotify-*.command
```

Double-click from Finder or add to Dock for one-click switching.

## How It Works

### Multi-Account Switcher

The switcher maintains separate copies of your Spotify application support folder (`~/Library/Application Support/Spotify`) for each account. When switching:

1. **Kills** any running Spotify processes
2. **Swaps** the profile folder using rsync (fast, preserves permissions)
3. **Clears** volatile caches (GPU cache, browser cache, etc.)
4. **Launches** Spotify with the selected profile

### SpotX Integration

The SpotX installer uses the [SpotX-Bash](https://github.com/SpotX-Official/SpotX-Bash) project to apply modifications:

- **Blocks ads** and telemetry
- **Enables developer mode** and experimental features  
- **Removes podcasts** from home screen
- **Blocks automatic updates**
- **Preserves functionality** while enhancing experience

## File Structure

```
spotify-tools/
├── README.md
├── spotify-account-switcher.sh    # Main switcher script
└── spotx-sharmanhall.sh          # SpotX installer script
```

## Troubleshooting

### Common Issues

**"Spotify support folder not found"**
- Launch Spotify once, log in, then quit and retry the `init` command

**UI crashes after switching**
- Uncomment the `--disable-gpu` line in the switcher script

**SpotX installation fails**
- Ensure you have an active internet connection
- Try running the script with `/bin/bash` instead of your default shell

### Cache Locations

The switcher clears these cache directories on each switch:
- `~/Library/Caches/com.spotify.client`
- `~/Library/Application Support/Spotify/Code Cache`
- `~/Library/Application Support/Spotify/GPUCache`
- `~/Library/Application Support/Spotify/ShaderCache`
- Browser and storage caches

## Credits

- **Multi-Account Switcher**: Original work by [@sharmanhall](https://github.com/tyhallcsu)
- **SpotX**: Based on [SpotX-Bash](https://github.com/SpotX-Official/SpotX-Bash) by the SpotX team

## License

MIT License - feel free to modify and distribute as needed.

## Contributing

Pull requests and issues welcome! Please test on your system before submitting changes.

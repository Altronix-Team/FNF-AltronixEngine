# Building Friday Night Funkin': Altronix Engine

**Also note**: you should be familiar with the commandline. If not, read this [quick guide by ninjamuffin](https://ninjamuffin99.newgrounds.com/news/post/1090480).

**Also also note**: To build for *Windows*, you need to be on *Windows*. To build for *Linux*, you need to be on *Linux*. Same goes for macOS. You can build for html5/browsers on any platform.

## Dependencies
  1. [Install Haxe 4.2.5](https://haxe.org/download/). This is the latest version at the time of writing.
 	- 4.1.5 was originally recommended because "4.2.0 is broken and is not working with gits properly..." This was actually referring to compatibility issues with OpenFL, Lime, and HaxeFlixel, which are important libraries the game relies on.
 	- [ninjamuffin99 himself](https://github.com/HaxeFoundation/haxe/issues/10443#issuecomment-948958011) confirmed that these issues are long since resolved, and the latest version of Haxe is stable for development of FNF and its mods.
 2. After installing Haxe, [Install HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/).
 3. Install `git`.
	 - Windows: install from the [git-scm](https://git-scm.com/downloads) website.
	 - Linux: install the `git` package: `sudo apt install git` (ubuntu), `sudo pacman -S git` (arch), etc... (you probably already have it)
 4. Install and set up the necessary libraries:
	 - `haxelib install lime`
	 - `haxelib install openfl`
	 - `haxelib install flixel`
	 - `haxelib install flixel-tools`
	 - `haxelib install flixel-ui`
	 - `haxelib git hscript https://github.com/HaxeFoundation/hscript`
	 - `haxelib install flixel-addons`
	 - `haxelib run lime setup`
	 - `haxelib run lime setup flixel`
	 - `haxelib run flixel-tools setup`
	 - `haxelib install polymod`
	 - `haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc`
	 - `haxelib install haxe-strings 7.0.2`
	 - `haxelib install hscript-ex 0.0.0`
	 - `haxelib git hxCodec https://github.com/polybiusproxy/hxCodec main`
	 - `haxelib install yaml`
	 - `haxelib git SScript https://github.com/AltronMaxX/SScript`
	 - `haxelib git firetongue https://github.com/larsiusprime/firetongue dev`
	 - `haxelib install thx.semver`
	 - `openfl install away3d`
	      - Note: for Linux, you need to install the `g++-multilib` and `gcc-multilib` packages respectively. (use apt to install them.)

### Windows-only dependencies (only for building *to* Windows. Building html5 on Windows does not require this)
If you are planning to build for Windows, you also need to install **Visual Studio 2019**. While installing it, *don't click on any of the options to install workloads*. Instead, go to the **individual components** tab and choose the following:

-   MSVC v142 - VS 2019 C++ x64/x86 build tools
-   Windows SDK (10.0.17763.0)

This will install about 4 GB of crap, but is necessary to build for Windows.

### macOS-only dependencies (these are required for building on macOS at all, including html5.)
If you are running macOS, you'll need to install Xcode. You can download it from the macOS App Store or from the [Xcode website](https://developer.apple.com/xcode/).

If you get an error telling you that you need a newer macOS version, you need to download an older version of Xcode from the [More Software Downloads](https://developer.apple.com/download/more/) section of the Apple Developer website. (You can check which version of Xcode you need for your macOS version on [Wikipedia's comparison table (in the `min macOS to run` column)](https://en.wikipedia.org/wiki/Xcode#Version_comparison_table).)

## Cloning the repository
Since you already installed `git` in a previous step, we'll use it to clone the repository.
1. `cd` to where you want to store the source code (i.e. `C:\Users\username\Desktop` or `~/Desktop`)
2. `git clone https://github.com/AltronMaxX/FNF-AltronixEngine.git`
3. `cd` into the source code: `cd Altronix-Engine`
4. (optional) If you want to build a specific version of Altronix Engine, you can use `git checkout` to switch to it (i.e. `git checkout 1.0-AE`)
- You should **not** do this if you are planning to contribute, as you should always be developing on the latest version.

## Building
Finally, we are ready to build.

- Run `lime build <target>`, replacing `<target>` with the platform you want to build to (`windows`, `mac`, `linux`, `html5`) (i.e. `lime build windows`)
- The build will be in `Altronix-Engine/export/release/<target>/bin`, with `<target>` being the target you built to in the previous step. (i.e. `Altronix-Engine/export/release/windows/bin`)
- Incase you added the -debug flag the files will be inside `Altronix-Engine/export/debug/<target>/bin`
- Only the `bin` folder is necessary to run the game. The other ones in `export/release/<target>` are not.

## Troubleshooting
Check the **Troubleshooting documentation** if you have problems with these instructions.

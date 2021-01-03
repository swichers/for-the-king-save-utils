# For The King Save Scripts

These scripts help to back up, unpack, and re-pack For The King saves.

These scripts were created using WSL and are untested on an actual Linux setup.

## Installation

* Install jq
* Install gzip and gunzip (you may have this already)
* Install iconv (you may have this already)
* Clone this repository.

## Usage

**saves-process.sh**: Copy all available saves from the destination folder into
a backup folder and then unpack all backups into pure json.

```sh
./saves-process.sh -d /mnt/d/ftk-backups/ -- '/mnt/c/Users/example/AppData/LocalLow/IronOak Games/FTK/save/'
```

**saves-copy.sh**: Copy all available saves from the destination folder into a
backup folder. Backups are renamed to include a timestamp of when the save was last modified.

```sh
./saves-copy.sh -d /mnt/d/ftk-backups/backups -- '/mnt/c/Users/example/AppData/LocalLow/IronOak Games/FTK/save/'
```

**save-copy.sh**: Copy an individual save into a backup folder.

```sh
./save-copy.sh -d /mnt/d/ftk-backups/backups -- '/mnt/c/Users/example/AppData/LocalLow/IronOak Games/FTK/save/example_save.run'
```

**save-unpack.sh**: Unpack a FTK savefile into JSON that can be parsed by JQ.

```sh
./save-unpack.sh -d /mnt/d/ftk-backups/unpack -- '/mnt/d/ftk-backups/backups/example_save.0221-01-02T00:55-08:00.run'
```

**save-repack.sh**: Repack a FTK JSON file into a savefile that can be loaded in game.

```sh
./save-repack.sh -d /mnt/d/ftk-backups/repack -- '/mnt/d/ftk-backups/unpack/example_save.0221-01-02T00:55-08:00.json'
```

## Save file format

You do not need these scripts but they do make the process of editing saves
much easier.

`.run` files are gzip compressed json files encoded in UTF-16LE. The gzip
compression does not include filenames and timestamps, so only has the 10
byte header and 8 byte footer.

`gzip -1 --no-name $FN` is enough to recompress a save file.

## Item codes

This is a list of possible item codes. This list includes codes that are
non-functional and may cause your game to not load or your inventory to be
empty.

If you break your save restore a backup or undo the changes you made.

[ITEM-CODES.md](ITEM-CODES.md)
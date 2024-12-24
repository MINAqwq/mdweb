# mdweb

markdown to static website

## requirements

- bash
- md2html

```sh
pacman -Sy --needed bash md4c
```

## usage

Place your markdown files and other resource files like images in the `src` directory.
> Don't create a `index.md`, the script will create one.

Copy `scripts/config.bash.example` and rename it to `scripts/config.bash`.

Edit the constants in `scripts/config.bash`.

Run:
```sh
bash scripts/build.bash out
```

To create a zstd compressed GNU tar ball, run

```
bash scripts/release.bash out
```

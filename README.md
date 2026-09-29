# HomeDrive test media

Freely licensed media for HomeDrive's automated tests: HDR10, HLG and Dolby Vision video, lossless
and surround audio codecs, many subtitle tracks, rotated phone video, broken files, and photos with
GPS, HEIC, AVIF, RAW and 50+ megapixel panoramas.

The files are published as release assets, not committed. `SHA256SUMS` in each release lists them.
Licences and credits are in [ATTRIBUTION.md](ATTRIBUTION.md).

## Rebuild

Needs ffmpeg 7.1 or newer (with the `dovi_rpu` filter and the TrueHD, DTS, E-AC-3, Opus, x265 and
MPEG-2 encoders), libheif's `heif-enc`, curl and shasum.

```shell
./build.sh
gh release create media-v1 dist/* --title "Test media v1" --notes-file ATTRIBUTION.md
```

Sources are downloaded once into `.sources/`; outputs go to `dist/`.

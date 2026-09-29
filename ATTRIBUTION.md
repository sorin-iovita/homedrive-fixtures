# Attribution and licences

Test media for HomeDrive's automated tests. Every file here is freely licensed; derived files
(trimmed, remuxed, re-encoded) keep the licence of their source. `build.sh` records exactly how each
file was made.

## CC BY-SA 4.0: Jellyfin test videos

Courtesy of Gnattu / Jellyfin, https://repo.jellyfin.org/test-videos/, licensed under
[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Derived files are shared under the same licence.

- `video-dv-p81-hdr10-4k60.mp4`: Test Jellyfin 4K DV P8.1
- `video-dv-p5-1080p60.mp4`: Test Jellyfin 1080p DV P5
- `video-dv-p84-hlg-1080p60.mp4`: Test Jellyfin 1080p DV P8.4
- `video-hdr10-4k-100mbps.mp4`: Test Jellyfin 4K HEVC HDR10 100M
- `video-hdr10-4k60-10s.mkv`: first 10 s of the 4K DV P8.1 file with the Dolby Vision RPU removed
- `video-hlg-1080p60-10s.mkv`: first 10 s of the 1080p DV P8.4 file with the Dolby Vision RPU removed

## CC BY 3.0: Sintel

© copyright Blender Foundation, www.sintel.org, licensed under
[CC BY 3.0](https://creativecommons.org/licenses/by/3.0/) (https://durian.blender.org/sharing/).

- `video-sintel-multitrack-30s.mkv`: 30 s of Sintel.2010.1080p.mkv with its subtitles, plus the music and effects track tagged as a second language for testing
- `video-audio-*-10s.mkv`: 10 s of Sintel with the audio re-encoded to TrueHD, DTS, E-AC-3, FLAC 7.1, Opus 7.1, or the original AC-3
- `video-subtitles-srt-ass-10s.mkv`: 10 s of Sintel with the English subtitles as SRT and ASS
- `video-subtitles-srt-ass-10s.ro.srt`: the Romanian Sintel subtitles, shifted to match the 10 s clip

## CC BY: Matroska test suite

https://github.com/ietf-wg-cellar/matroska-test-files, licensed under Creative Commons Attribution as
stated in that repository's readme, based on Elephants Dream and Big Buck Bunny.

- `video-matroska-test5-multilang.mkv`: test5.mkv
- `video-matroska-test7-junk-elements.mkv`: test7.mkv

## BSD 3-Clause: Chromium test data

© The Chromium Authors, https://github.com/chromium/chromium, commit
e0f704daa316a959feb165460602f4ed982e718f, `media/test/data`, under the
[BSD 3-Clause licence](https://github.com/chromium/chromium/blob/main/LICENSE).

- `video-chromium-*`, `broken-corrupted-after-init.webm`, `broken-no-streams.webm`, `broken-ten-bytes.mp4`

## Apache 2.0 or MIT: GoPro GPMF parser

The GPMF telemetry track in `video-action-cam-4k60-hevc-gpmf.mp4` comes from `samples/hero8.mp4` in
https://github.com/gopro/gpmf-parser (Apache 2.0 or MIT). The picture and sound are generated.

## MIT: EXIF orientation examples and libheif

- `photo-orientation-*.jpg`: https://github.com/recurser/exif-orientation-examples (MIT)
- `photo-libheif-example.avif`: https://github.com/strukturag/libheif, `examples/example.avif` (MIT)

## CC0: Wikimedia Commons and raw.pixls.us

No attribution required; sources recorded for reference.

- `photo-quiabo-brazil.jpg`: https://commons.wikimedia.org/wiki/File:Quiabo.jpg
- `photo-quiabo-brazil.heic`, `photo-quiabo-brazil.avif`: converted from Quiabo.jpg with libheif
- `photo-smolensk-russia.jpg`: https://commons.wikimedia.org/wiki/File:20190220_111536_February_2019_in_Smolensk.jpg
- `photo-guangzhou-china.jpg`: https://commons.wikimedia.org/wiki/File:Bank_of_Guangzhou_Tower_1.jpg
- `photo-perth-australia.jpg`: https://commons.wikimedia.org/wiki/File:Central_Park,_November_2017.jpg
- `photo-south-dakota-usa.jpg`: https://commons.wikimedia.org/wiki/File:Golden_Glow_Canyon.jpg
- `photo-panorama-58mp.jpg`: https://commons.wikimedia.org/wiki/File:360%C2%B0_Panoramic_view_of_Santa_Rosa_de_la_Eminencia_Castle.jpg
- `photo-120mp.jpg`: https://commons.wikimedia.org/wiki/File:2017_Aston_Martin_Vanquish_Zagato_Volante_Auto_1.jpg
- `photo-iphone-xs.dng`: https://raw.pixls.us (Apple iPhone XS, CC0)

## Generated

Made by `build.sh` with ffmpeg from synthetic test patterns; no third-party content.

- `video-interlaced-576i.mpg`, `video-vfr.mp4`, `broken-truncated-no-moov.mp4`, `broken-truncated-mdat.mp4`, `broken-empty.mkv`

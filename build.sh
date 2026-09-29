#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")" && pwd)
SRC=${SRC:-$ROOT/.sources}
OUT=${OUT:-$ROOT/dist}
UA="homedrive-fixtures-build/1.0 (+https://github.com/sorin-iovita/homedrive-fixtures)"
CHROMIUM=https://raw.githubusercontent.com/chromium/chromium/e0f704daa316a959feb165460602f4ed982e718f/media/test/data
JELLYFIN=https://repo.jellyfin.org/test-videos
COMMONS=https://upload.wikimedia.org/wikipedia/commons
MATROSKA=https://raw.githubusercontent.com/ietf-wg-cellar/matroska-test-files/master/test_files
ORIENT=https://raw.githubusercontent.com/recurser/exif-orientation-examples/master

mkdir -p "$SRC" "$OUT"

need() {
  for tool in "$@"; do
    command -v "$tool" >/dev/null || { echo "missing tool: $tool" >&2; exit 1; }
  done
}
need curl ffmpeg ffprobe heif-enc shasum
ffmpeg -hide_banner -bsfs | grep -qx dovi_rpu || { echo "ffmpeg lacks the dovi_rpu bitstream filter (needs 7.1 or newer)" >&2; exit 1; }
for enc in truehd dca eac3 libopus flac libx265 mpeg2video ass; do
  ffmpeg -hide_banner -encoders | grep -q " $enc " || { echo "ffmpeg lacks the $enc encoder" >&2; exit 1; }
done

fetch() {
  local name=$1 url=$2
  [ -s "$SRC/$name" ] && return
  echo "fetch $name"
  local attempt
  for attempt in 1 2 3 4 5 6; do
    if curl -fsSL -C - --speed-limit 10000 --speed-time 30 -A "$UA" -o "$SRC/$name.part" "$url"; then
      mv "$SRC/$name.part" "$SRC/$name"
      return
    fi
    echo "retry $name ($attempt)"
    sleep 5
  done
  echo "could not download $name" >&2
  exit 1
}

ff() {
  ffmpeg -hide_banner -loglevel error -y "$@"
}

fetch jf-4k-dv-p81.mp4 "$JELLYFIN/HDR/Dolby%20Vision/Test%20Jellyfin%204K%20DV%20P8.1.mp4"
fetch jf-1080p-dv-p5.mp4 "$JELLYFIN/HDR/Dolby%20Vision/Test%20Jellyfin%201080p%20DV%20P5.mp4"
fetch jf-1080p-dv-p84.mp4 "$JELLYFIN/HDR/Dolby%20Vision/Test%20Jellyfin%201080p%20DV%20P8.4.mp4"
fetch jf-4k-hdr10-100m.mp4 "$JELLYFIN/HDR/HDR10/HEVC/Test%20Jellyfin%204K%20HEVC%20HDR10%20100M.mp4"
fetch sintel-1080p.mkv https://download.blender.org/durian/movies/Sintel.2010.1080p.mkv
fetch sintel-me.flac "https://download.blender.org/durian/movies/sintel-m%2Be-st.flac"
fetch sintel-ro.srt https://download.blender.org/durian/subs/sintel_ro.srt
fetch mkv-test5.mkv "$MATROSKA/test5.mkv"
fetch mkv-test7.mkv "$MATROSKA/test7.mkv"
fetch gopro-hero8.mp4 https://github.com/gopro/gpmf-parser/raw/main/samples/hero8.mp4
for f in 90rotation.mp4 bear_rotate_90.mp4 four-colors-rot-90.mp4 bear-320x180-hi10p.mp4 bear-av1.mp4 bear-av1.webm \
  bear-320x240-vp9_profile2.webm bear-vp9-odd-dimensions.webm bear-640x360-non_square_pixel-with_pasp.mp4 \
  bear-320x240_corrupted_after_init_segment.webm no_streams.webm ten_byte_file; do
  fetch "chromium-$f" "$CHROMIUM/$f"
done
fetch photo-quiabo-brazil.jpg "$COMMONS/5/54/Quiabo.jpg"
fetch photo-smolensk-russia.jpg "$COMMONS/b/b3/20190220_111536_February_2019_in_Smolensk.jpg"
fetch photo-guangzhou-china.jpg "$COMMONS/4/4c/Bank_of_Guangzhou_Tower_1.jpg"
fetch photo-perth-australia.jpg "$COMMONS/5/5f/Central_Park%2C_November_2017.jpg"
fetch photo-south-dakota-usa.jpg "$COMMONS/0/0e/Golden_Glow_Canyon.jpg"
fetch photo-panorama-58mp.jpg "$COMMONS/2/27/360%C2%B0_Panoramic_view_of_Santa_Rosa_de_la_Eminencia_Castle.jpg"
fetch photo-120mp.jpg "$COMMONS/2/2f/2017_Aston_Martin_Vanquish_Zagato_Volante_Auto_1.jpg"
fetch photo-iphone-xs.dng "https://raw.pixls.us/getfile.php/3372/nice/Apple%20-%20iPhone%20XS%20-%2016bit%20(4:3).dng"
fetch photo-libheif-example.avif https://raw.githubusercontent.com/strukturag/libheif/master/examples/example.avif
for n in 1 2 3 4 5 6 7 8; do
  fetch "orient-landscape-$n.jpg" "$ORIENT/Landscape_$n.jpg"
  fetch "orient-portrait-$n.jpg" "$ORIENT/Portrait_$n.jpg"
done

echo "build video"
cp "$SRC/jf-4k-dv-p81.mp4" "$OUT/video-dv-p81-hdr10-4k60.mp4"
cp "$SRC/jf-1080p-dv-p5.mp4" "$OUT/video-dv-p5-1080p60.mp4"
cp "$SRC/jf-1080p-dv-p84.mp4" "$OUT/video-dv-p84-hlg-1080p60.mp4"
cp "$SRC/jf-4k-hdr10-100m.mp4" "$OUT/video-hdr10-4k-100mbps.mp4"
ff -i "$SRC/jf-4k-dv-p81.mp4" -t 10 -map 0:v -c copy -bsf:v dovi_rpu=strip=1 "$OUT/video-hdr10-4k60-10s.mkv"
ff -i "$SRC/jf-1080p-dv-p84.mp4" -t 10 -map 0:v -c copy -bsf:v dovi_rpu=strip=1 "$OUT/video-hlg-1080p60-10s.mkv"

cat > "$SRC/sintel-chapters.txt" <<'EOF'
;FFMETADATA1
[CHAPTER]
TIMEBASE=1/1000
START=0
END=15000
title=Snow
[CHAPTER]
TIMEBASE=1/1000
START=15000
END=30000
title=Flight
EOF
ff -ss 90 -t 30 -i "$SRC/sintel-1080p.mkv" -ss 90 -t 30 -i "$SRC/sintel-me.flac" -i "$SRC/sintel-chapters.txt" \
  -map 0:v -map 0:a -map 1:a -map 0:s -map_chapters 2 -map_metadata 0 \
  -c:v copy -c:a:0 copy -c:a:1 flac -c:s copy \
  -metadata:s:a:1 language=ron -metadata:s:a:1 title="Music and effects (test dub)" \
  "$OUT/video-sintel-multitrack-30s.mkv"

ff -ss 105 -t 10 -i "$SRC/sintel-1080p.mkv" -map 0:v -map 0:a -c copy "$SRC/sintel-10s.mkv"
audio() {
  local name=$1
  shift
  ff -i "$SRC/sintel-10s.mkv" -map 0:v -map 0:a -c:v copy "$@" -metadata:s:a:0 language=eng -metadata:s:a:0 title= "$OUT/video-audio-$name-10s.mkv"
}
audio truehd-51 -c:a truehd -strict -2 -af "aformat=channel_layouts=5.1(side)"
audio dts-51 -c:a dca -strict -2 -af "aformat=channel_layouts=5.1(side)"
audio eac3-51 -c:a eac3 -af "aformat=channel_layouts=5.1(side)"
audio flac-71 -c:a flac -af "aformat=channel_layouts=7.1"
audio opus-71 -c:a libopus -mapping_family 1 -af "aformat=channel_layouts=7.1"
audio ac3-51 -c:a copy

ff -i "$SRC/sintel-1080p.mkv" -map 0:s:m:language:eng -c:s srt "$SRC/sintel-en.srt"
ff -i "$SRC/sintel-en.srt" "$SRC/sintel-en.ass"
ff -i "$SRC/sintel-10s.mkv" -itsoffset -105 -i "$SRC/sintel-en.srt" -itsoffset -105 -i "$SRC/sintel-en.ass" -map 0:v -map 0:a -map 1:s -map 2:s \
  -c:v copy -c:a copy -c:s:0 srt -c:s:1 ass -metadata:s:s:0 language=eng -metadata:s:s:1 language=eng -metadata:s:s:1 title=Styled \
  "$OUT/video-subtitles-srt-ass-10s.mkv"
ff -itsoffset -105 -i "$SRC/sintel-ro.srt" -c:s srt "$OUT/video-subtitles-srt-ass-10s.ro.srt"

cp "$SRC/mkv-test5.mkv" "$OUT/video-matroska-test5-multilang.mkv"
cp "$SRC/mkv-test7.mkv" "$OUT/video-matroska-test7-junk-elements.mkv"
for f in 90rotation.mp4 bear_rotate_90.mp4 four-colors-rot-90.mp4 bear-320x180-hi10p.mp4 bear-av1.mp4 bear-av1.webm \
  bear-320x240-vp9_profile2.webm bear-vp9-odd-dimensions.webm bear-640x360-non_square_pixel-with_pasp.mp4; do
  cp "$SRC/chromium-$f" "$OUT/video-chromium-$f"
done
cp "$SRC/chromium-bear-320x240_corrupted_after_init_segment.webm" "$OUT/broken-corrupted-after-init.webm"
cp "$SRC/chromium-no_streams.webm" "$OUT/broken-no-streams.webm"
cp "$SRC/chromium-ten_byte_file" "$OUT/broken-ten-bytes.mp4"
: > "$OUT/broken-empty.mkv"

ff -f lavfi -i testsrc2=size=3840x2160:rate=60 -f lavfi -i sine=frequency=440:sample_rate=48000 -i "$SRC/gopro-hero8.mp4" -t 3 \
  -map 0:v -map 1:a -map 2:d:1 -c:v libx265 -preset ultrafast -pix_fmt yuv420p10le -tag:v hvc1 -c:a aac -c:d copy -tag:d gpmd \
  "$OUT/video-action-cam-4k60-hevc-gpmf.mp4"
ff -f lavfi -i "testsrc2=size=720x576:rate=50,interlace=scan=tff,setfield=tff" -f lavfi -i sine=frequency=330:sample_rate=48000 -t 5 \
  -c:v mpeg2video -b:v 6M -flags +ilme+ildct -aspect 16:9 -c:a mp2 -f dvd "$OUT/video-interlaced-576i.mpg"
ff -f lavfi -i testsrc2=size=1280x720:rate=60 -t 4 -vf "select='if(lt(t,2),not(mod(n,2)),1)'" -fps_mode vfr -c:v libx264 "$OUT/video-vfr.mp4"
ff -f lavfi -i testsrc2=size=1280x720:rate=30 -f lavfi -i sine=frequency=500:sample_rate=48000 -t 10 -c:v libx264 -c:a aac "$SRC/whole.mp4"
head -c "$(( $(wc -c < "$SRC/whole.mp4") / 2 ))" "$SRC/whole.mp4" > "$OUT/broken-truncated-no-moov.mp4"
ff -i "$SRC/whole.mp4" -c copy -movflags +faststart "$SRC/whole-fast.mp4"
head -c "$(( $(wc -c < "$SRC/whole-fast.mp4") * 6 / 10 ))" "$SRC/whole-fast.mp4" > "$OUT/broken-truncated-mdat.mp4"

echo "build photos"
for f in quiabo-brazil smolensk-russia guangzhou-china perth-australia south-dakota-usa panorama-58mp 120mp; do
  cp "$SRC/photo-$f.jpg" "$OUT/photo-$f.jpg"
done
cp "$SRC/photo-iphone-xs.dng" "$OUT/photo-iphone-xs.dng"
cp "$SRC/photo-libheif-example.avif" "$OUT/photo-libheif-example.avif"
heif-enc -q 60 -o "$OUT/photo-quiabo-brazil.heic" "$SRC/photo-quiabo-brazil.jpg" >/dev/null
heif-enc --avif -q 60 -o "$OUT/photo-quiabo-brazil.avif" "$SRC/photo-quiabo-brazil.jpg" >/dev/null
for n in 1 2 3 4 5 6 7 8; do
  cp "$SRC/orient-landscape-$n.jpg" "$OUT/photo-orientation-landscape-$n.jpg"
  cp "$SRC/orient-portrait-$n.jpg" "$OUT/photo-orientation-portrait-$n.jpg"
done

cp "$ROOT/ATTRIBUTION.md" "$OUT/ATTRIBUTION.md"
(cd "$OUT" && shasum -a 256 -- * | grep -v ' SHA256SUMS$' > SHA256SUMS)
du -sh "$OUT"
echo "done: $(wc -l < "$OUT/SHA256SUMS") files in $OUT"

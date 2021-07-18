String getSongDuration(Duration? songDuration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");

  String twoDigitSeconds = twoDigits(songDuration!.inSeconds.remainder(60));
  return "${songDuration.inMinutes}:$twoDigitSeconds";
}

import 'package:audio_service/audio_service.dart';
import 'package:sputofy_2/models/song_model.dart';

/// Update queue with given [songs] adding [playlistID] as album of [mediaItem].
///
/// If [songPath] is passed once queue is updated skip to that item.
///
/// If [playlistTitle] is passed notification shows [playlistTitle].
Future<void> loadQueue(int playlistID, List<Song> songs,
    {String? songPath, String? playlistTitle}) async {
  if (songs.isEmpty) return;
  List<MediaItem> mediaItems = [];
  for (Song song in songs) {
    mediaItems.add(
      song
          .toMediaItem(
              playlistTitle: playlistTitle != null ? playlistTitle : null)
          .copyWith(album: '$playlistID'),
    );
  }
  await AudioService.updateQueue(mediaItems).then(
    (value) => {
      if (songPath != null)
        {
          AudioService.skipToQueueItem(songPath).then(
            (value) async => await AudioService.play(),
          )
        }
    },
  );
}

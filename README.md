# Offline LoFi Girl

An offline, single page LoFi experience with a seasonal video background and auto built music playlists. Fully local. No external CDNs.

![Screenshot](https://i.ibb.co/Bn6qDqW/Capture.png)

## Features

- Background video with seasonal themes
- Shuffled audio playlists built from your local folders
- Keyboard controls with saved volume and last track
- Optional offline app shell (PWA) for instant loads

## Folder layout

```text
project-root/
  index.html
  resources/
    Videos/
      Loop.mp4
      Halloween.mp4
      Xmas.mp4
      April_Fools.mp4
    Music/
      Normal/
      Halloween/
      Xmas/
      AprilFools/
    playlists.generated.js   ← created by the script
```

## Prereqs

- Modern browser with HTML5 audio and video
- Windows with PowerShell to build playlists
- Your own MP3 or M4A files in the folders above

## Build the playlists

From the project root run:

```powershell
.\nBuild-Playlists.ps1
```

This scans `resources/Music/*` and writes `resources/playlists.generated.js`:

```js
window.PLAYLISTS = {
  loop: [...],
  halloween: [...],
  xmas: [...],
  aprilfools: [...]
}
```

Re run the script any time you add or remove tracks.

## Run

1. Open `index.html` in your browser
2. Click Play to satisfy autoplay rules
3. Enjoy

## Season selection

The page picks a background by date. Override with a query parameter:

- `?bg=loop`
- `?bg=halloween`
- `?bg=xmas`
- `?bg=aprilfools`

Example: `index.html?bg=halloween`

## Controls

- **Space** play or pause  
- **N** next track  
- **P** previous track  
- **Up or Down** volume up or down  
- **M** mute toggle  
- Volume and last track position are saved locally

## Tips

- Filenames with spaces or non ASCII are fine. The builder URL encodes paths
- Keep videos H.264 MP4 for widest support
- To avoid a black flash before video paints, add a `poster` image to the `<video>`

## Troubleshooting

**No music plays**  
- Ensure `resources/playlists.generated.js` exists  
- Confirm paths in that file point to actual files under `resources`

**Video not loading**  
- Verify the video file exists and matches the expected name  
- Try another MP4 or re encode with a common preset

**Playlist missing songs**  
- Re run `Build-Playlists.ps1` after adding files  
- Confirm files are inside the expected subfolders

## Optional offline app shell

Add a small service worker and manifest to cache the UI shell for instant offline loads. This does not cache your music library by default.

- `manifest.webmanifest` with name, colors, and icons  
- `sw.js` that pre caches `index.html` and `resources/playlists.generated.js`

## License

Personal use. Replace with your preferred license if you plan to distribute.

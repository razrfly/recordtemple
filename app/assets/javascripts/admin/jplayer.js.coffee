jQuery ->
  playlist_items = $('#jp_container_1 .jp-playlist').data('playlist-items')
  new jPlayerPlaylist({
    jPlayer: '#jquery_jplayer_1'
    cssSelectorAncestor: '#jp_container_1'
  }, playlist_items,
    # swfPath: '../dist/jplayer'
    supplied: 'mp3'
    wmode: 'window'
    useStateClassSkin: true
    autoBlur: false
    smoothPlayBar: true
    keyEnabled: true
  )

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["audio", "playButton", "pauseButton", "progress", "currentTime", "duration", "track", "previewMessage"]
  static values = {
    authenticated: { type: Boolean, default: false },
    previewDuration: { type: Number, default: 30 }
  }

  connect() {
    this.currentTrackIndex = null
    this.urlCache = new Map()
  }

  async play(event) {
    const trackIndex = parseInt(event.currentTarget.dataset.trackIndex)

    if (this.currentTrackIndex === trackIndex && this.audioTarget.src) {
      // Resume current track
      this.audioTarget.play()
      this.updateTrackUI(trackIndex, true)
      return
    }

    // Stop current track if playing a different one
    if (this.currentTrackIndex !== null) {
      this.stopCurrentTrack()
    }

    this.currentTrackIndex = trackIndex
    this.updateTrackUI(trackIndex, true)

    // Get the audio URL
    const signedId = event.currentTarget.dataset.songSignedId
    let audioUrl = this.urlCache.get(signedId)

    if (!audioUrl) {
      try {
        audioUrl = await this.fetchStreamUrl(signedId)
        this.urlCache.set(signedId, audioUrl)
      } catch (error) {
        console.error("Failed to load audio:", error)
        this.updateTrackUI(trackIndex, false)
        return
      }
    }

    this.audioTarget.src = audioUrl
    this.audioTarget.play()
  }

  async fetchStreamUrl(signedId) {
    const response = await fetch(`/songs/stream_url/${signedId}`)
    if (!response.ok) {
      throw new Error("Failed to fetch stream URL")
    }
    const data = await response.json()
    return data.url
  }

  pause() {
    this.audioTarget.pause()
    if (this.currentTrackIndex !== null) {
      this.updateTrackUI(this.currentTrackIndex, false)
    }
  }

  stopCurrentTrack() {
    this.audioTarget.pause()
    this.audioTarget.currentTime = 0
    if (this.currentTrackIndex !== null) {
      this.updateTrackUI(this.currentTrackIndex, false)
      const track = this.trackTargets[this.currentTrackIndex]
      if (track) {
        const progress = track.querySelector('[data-audio-player-target="progress"]')
        if (progress) progress.style.width = '0%'
        // Hide preview message when stopping
        this.hidePreviewMessage(track)
      }
    }
  }

  updateTrackUI(index, playing) {
    this.trackTargets.forEach((track, i) => {
      const playBtn = track.querySelector('[data-audio-player-target="playButton"]')
      const pauseBtn = track.querySelector('[data-audio-player-target="pauseButton"]')

      if (i === index && playing) {
        playBtn?.classList.add('hidden')
        playBtn?.classList.remove('flex')
        pauseBtn?.classList.remove('hidden')
        pauseBtn?.classList.add('flex')
        track.classList.add('bg-olive-100')
      } else {
        playBtn?.classList.remove('hidden')
        playBtn?.classList.add('flex')
        pauseBtn?.classList.add('hidden')
        pauseBtn?.classList.remove('flex')
        track.classList.remove('bg-olive-100')
        // Hide preview message for non-active tracks
        this.hidePreviewMessage(track)
      }
    })
  }

  timeUpdate() {
    if (this.currentTrackIndex === null) return

    const track = this.trackTargets[this.currentTrackIndex]
    if (!track) return

    const currentTime = this.audioTarget.currentTime
    const duration = this.audioTarget.duration

    // Check if anonymous user has reached preview limit
    if (!this.authenticatedValue && currentTime >= this.previewDurationValue) {
      this.audioTarget.pause()
      this.audioTarget.currentTime = this.previewDurationValue
      this.showPreviewEndMessage(track)
      this.updateTrackUI(this.currentTrackIndex, false)
      return
    }

    const progress = track.querySelector('[data-audio-player-target="progress"]')
    const currentTimeEl = track.querySelector('[data-audio-player-target="currentTime"]')

    // For anonymous users, show progress relative to preview duration
    const effectiveDuration = this.authenticatedValue ? duration : Math.min(duration, this.previewDurationValue)
    const percent = (currentTime / effectiveDuration) * 100
    if (progress) progress.style.width = `${Math.min(percent, 100)}%`
    if (currentTimeEl) currentTimeEl.textContent = this.formatTime(currentTime)
  }

  loadedMetadata() {
    if (this.currentTrackIndex === null) return

    const track = this.trackTargets[this.currentTrackIndex]
    if (!track) return

    const durationEl = track.querySelector('[data-audio-player-target="duration"]')
    if (durationEl) {
      // For anonymous users, show preview duration or track duration (whichever is shorter)
      const actualDuration = this.audioTarget.duration
      const displayDuration = this.authenticatedValue
        ? actualDuration
        : Math.min(actualDuration, this.previewDurationValue)
      durationEl.textContent = this.formatTime(displayDuration)
    }
  }

  ended() {
    if (this.currentTrackIndex !== null) {
      this.updateTrackUI(this.currentTrackIndex, false)

      // Auto-advance to next track
      if (this.currentTrackIndex < this.trackTargets.length - 1) {
        const nextTrack = this.trackTargets[this.currentTrackIndex + 1]
        const playBtn = nextTrack?.querySelector('[data-audio-player-target="playButton"]')
        if (playBtn) playBtn.click()
      } else {
        this.currentTrackIndex = null
      }
    }
  }

  seek(event) {
    const track = event.currentTarget.closest('[data-audio-player-target="track"]')
    if (!track) return

    const progressBar = track.querySelector('.progress-bar')
    if (!progressBar) return

    const rect = progressBar.getBoundingClientRect()
    const percent = (event.clientX - rect.left) / rect.width

    // For anonymous users, limit seeking within preview duration
    const maxDuration = this.authenticatedValue
      ? this.audioTarget.duration
      : Math.min(this.audioTarget.duration, this.previewDurationValue)

    this.audioTarget.currentTime = percent * maxDuration
  }

  showPreviewEndMessage(track) {
    let messageEl = track.querySelector('[data-audio-player-target="previewMessage"]')

    if (!messageEl) {
      // Create the message element if it doesn't exist
      messageEl = document.createElement('div')
      messageEl.setAttribute('data-audio-player-target', 'previewMessage')
      messageEl.className = 'mt-2 text-sm text-olive-600 flex items-center gap-2'
      messageEl.innerHTML = `
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
        </svg>
        <span>Preview ended. <a href="/users/sign_in" class="text-olive-800 underline hover:text-olive-950">Sign in</a> to listen to full tracks.</span>
      `
      track.appendChild(messageEl)
    }

    messageEl.classList.remove('hidden')
  }

  hidePreviewMessage(track) {
    const messageEl = track.querySelector('[data-audio-player-target="previewMessage"]')
    if (messageEl) {
      messageEl.classList.add('hidden')
    }
  }

  formatTime(seconds) {
    if (isNaN(seconds)) return '0:00'
    const mins = Math.floor(seconds / 60)
    const secs = Math.floor(seconds % 60)
    return `${mins}:${secs.toString().padStart(2, '0')}`
  }
}

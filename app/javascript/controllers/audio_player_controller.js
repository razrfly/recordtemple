import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["audio", "playButton", "pauseButton", "progress", "currentTime", "duration", "track"]

  connect() {
    this.currentTrackIndex = null
  }

  play(event) {
    const trackIndex = parseInt(event.currentTarget.dataset.trackIndex)

    if (this.currentTrackIndex === trackIndex) {
      // Resume current track
      this.audioTarget.play()
    } else {
      // Play new track
      if (this.currentTrackIndex !== null) {
        this.stopCurrentTrack()
      }

      this.currentTrackIndex = trackIndex
      const audioUrl = event.currentTarget.dataset.audioUrl
      this.audioTarget.src = audioUrl
      this.audioTarget.play()
    }

    this.updateTrackUI(trackIndex, true)
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
      }
    }
  }

  updateTrackUI(index, playing) {
    this.trackTargets.forEach((track, i) => {
      const playBtn = track.querySelector('[data-audio-player-target="playButton"]')
      const pauseBtn = track.querySelector('[data-audio-player-target="pauseButton"]')

      if (i === index && playing) {
        playBtn?.classList.add('hidden')
        pauseBtn?.classList.remove('hidden')
        track.classList.add('bg-olive-100')
      } else {
        playBtn?.classList.remove('hidden')
        pauseBtn?.classList.add('hidden')
        track.classList.remove('bg-olive-100')
      }
    })
  }

  timeUpdate() {
    if (this.currentTrackIndex === null) return

    const track = this.trackTargets[this.currentTrackIndex]
    if (!track) return

    const progress = track.querySelector('[data-audio-player-target="progress"]')
    const currentTimeEl = track.querySelector('[data-audio-player-target="currentTime"]')

    const percent = (this.audioTarget.currentTime / this.audioTarget.duration) * 100
    if (progress) progress.style.width = `${percent}%`
    if (currentTimeEl) currentTimeEl.textContent = this.formatTime(this.audioTarget.currentTime)
  }

  loadedMetadata() {
    if (this.currentTrackIndex === null) return

    const track = this.trackTargets[this.currentTrackIndex]
    if (!track) return

    const durationEl = track.querySelector('[data-audio-player-target="duration"]')
    if (durationEl) durationEl.textContent = this.formatTime(this.audioTarget.duration)
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
    this.audioTarget.currentTime = percent * this.audioTarget.duration
  }

  formatTime(seconds) {
    if (isNaN(seconds)) return '0:00'
    const mins = Math.floor(seconds / 60)
    const secs = Math.floor(seconds % 60)
    return `${mins}:${secs.toString().padStart(2, '0')}`
  }
}

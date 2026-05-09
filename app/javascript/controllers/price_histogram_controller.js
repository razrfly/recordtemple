import { Controller } from "@hotwired/stimulus"

// Dual-handle range slider over a histogram of price buckets.
// Boundaries: array of N price thresholds. Buckets: 0..N-1 representing the
// half-open intervals [boundaries[i], boundaries[i+1]). Bucket N-1 is the
// overflow bucket [boundaries[N-1], +∞). Slider positions are 0..N inclusive,
// where position N means "no upper bound".
export default class extends Controller {
  static targets = ["bar", "lowHandle", "highHandle", "track", "rangeLabel", "minInput", "maxInput", "selection"]
  static values = {
    boundaries: Array,
    counts: Array
  }

  connect() {
    this.maxPosition = this.boundariesValue.length // e.g. 24 → positions 0..24
    this.dragging = null

    const minVal = parseFloat(this.minInputTarget.value)
    const maxVal = parseFloat(this.maxInputTarget.value)
    this.lowPos = Number.isFinite(minVal) && minVal > 0 ? this.snapToBoundary(minVal) : 0
    this.highPos = Number.isFinite(maxVal) && maxVal > 0 ? this.snapToBoundary(maxVal) : this.maxPosition

    this.boundPointerMove = this.onPointerMove.bind(this)
    this.boundPointerUp = this.onPointerUp.bind(this)
    this.boundLowKeydown = (event) => this.onHandleKeydown(event, "low")
    this.boundHighKeydown = (event) => this.onHandleKeydown(event, "high")
    this.lowHandleTarget.addEventListener("keydown", this.boundLowKeydown)
    this.highHandleTarget.addEventListener("keydown", this.boundHighKeydown)

    this.render()
  }

  disconnect() {
    document.removeEventListener("pointermove", this.boundPointerMove)
    document.removeEventListener("pointerup", this.boundPointerUp)
    this.lowHandleTarget.removeEventListener("keydown", this.boundLowKeydown)
    this.highHandleTarget.removeEventListener("keydown", this.boundHighKeydown)
  }

  startDragLow(event) {
    event.preventDefault()
    this.dragging = "low"
    this.attachDocListeners()
  }

  startDragHigh(event) {
    event.preventDefault()
    this.dragging = "high"
    this.attachDocListeners()
  }

  onPointerMove(event) {
    if (!this.dragging) return
    const rect = this.trackTarget.getBoundingClientRect()
    const ratio = Math.max(0, Math.min(1, (event.clientX - rect.left) / rect.width))
    const pos = Math.round(ratio * this.maxPosition)
    if (this.dragging === "low") {
      this.lowPos = Math.min(pos, this.highPos - 1)
      if (this.lowPos < 0) this.lowPos = 0
    } else {
      this.highPos = Math.max(pos, this.lowPos + 1)
      if (this.highPos > this.maxPosition) this.highPos = this.maxPosition
    }
    this.render()
  }

  onPointerUp() {
    if (!this.dragging) return
    this.dragging = null
    document.removeEventListener("pointermove", this.boundPointerMove)
    document.removeEventListener("pointerup", this.boundPointerUp)
    this.commit()
  }

  reset(event) {
    event?.preventDefault()
    this.lowPos = 0
    this.highPos = this.maxPosition
    this.render()
    this.commit()
  }

  attachDocListeners() {
    document.addEventListener("pointermove", this.boundPointerMove)
    document.addEventListener("pointerup", this.boundPointerUp)
  }

  onHandleKeydown(event, handle) {
    if (!["ArrowLeft", "ArrowRight", "Home", "End"].includes(event.key)) return

    event.preventDefault()

    const step = event.key === "ArrowLeft" ? -1 : event.key === "ArrowRight" ? 1 : 0
    if (handle === "low") {
      if (event.key === "Home") {
        this.lowPos = 0
      } else if (event.key === "End") {
        this.lowPos = this.highPos - 1
      } else {
        this.lowPos = Math.max(0, Math.min(this.highPos - 1, this.lowPos + step))
      }
    } else if (event.key === "Home") {
      this.highPos = this.lowPos + 1
    } else if (event.key === "End") {
      this.highPos = this.maxPosition
    } else {
      this.highPos = Math.min(this.maxPosition, Math.max(this.lowPos + 1, this.highPos + step))
    }

    this.render()
    this.commit()
  }

  render() {
    const lowPct = (this.lowPos / this.maxPosition) * 100
    const highPct = (this.highPos / this.maxPosition) * 100
    this.lowHandleTarget.style.left = `${lowPct}%`
    this.highHandleTarget.style.left = `${highPct}%`

    if (this.hasSelectionTarget) {
      this.selectionTarget.style.left = `${lowPct}%`
      this.selectionTarget.style.width = `${highPct - lowPct}%`
    }

    this.barTargets.forEach((bar, i) => {
      const active = i >= this.lowPos && i < this.highPos
      bar.dataset.active = active ? "true" : "false"
    })

    this.rangeLabelTarget.textContent = this.formatRange()
    this.updateHandleAria()
  }

  commit() {
    const minVal = this.lowPos === 0 ? "" : String(this.boundariesValue[this.lowPos])
    const maxVal = this.highPos === this.maxPosition ? "" : String(this.boundariesValue[this.highPos])
    if (this.minInputTarget.value === minVal && this.maxInputTarget.value === maxVal) return
    this.minInputTarget.value = minVal
    this.maxInputTarget.value = maxVal
    const form = this.element.closest("form")
    if (form) form.requestSubmit()
  }

  snapToBoundary(price) {
    let idx = 0
    for (let i = 0; i < this.boundariesValue.length; i++) {
      if (price >= this.boundariesValue[i]) idx = i
    }
    return idx
  }

  formatPrice(v) {
    if (v >= 1000) {
      const k = v / 1000
      return Number.isInteger(k) ? `$${k}k` : `$${k.toFixed(1)}k`
    }
    return `$${v}`
  }

  formatRange() {
    if (this.lowPos === 0 && this.highPos === this.maxPosition) return "Any price"
    const lo = this.boundariesValue[this.lowPos]
    if (this.highPos === this.maxPosition) return `${this.formatPrice(lo)}+`
    const hi = this.boundariesValue[this.highPos]
    if (this.lowPos === 0) return `Up to ${this.formatPrice(hi)}`
    return `${this.formatPrice(lo)} – ${this.formatPrice(hi)}`
  }

  updateHandleAria() {
    const lowValue = this.boundariesValue[this.lowPos] || 0
    const highValue = this.highPos === this.maxPosition ? this.boundariesValue[this.boundariesValue.length - 1] : this.boundariesValue[this.highPos]
    this.lowHandleTarget.setAttribute("aria-valuenow", String(lowValue))
    this.lowHandleTarget.setAttribute("aria-valuetext", this.lowPos === 0 ? "No minimum price" : `Minimum ${this.formatPrice(lowValue)}`)
    this.highHandleTarget.setAttribute("aria-valuenow", String(highValue))
    this.highHandleTarget.setAttribute("aria-valuetext", this.highPos === this.maxPosition ? "No maximum price" : `Maximum ${this.formatPrice(highValue)}`)
  }
}

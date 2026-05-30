import { Controller } from "@hotwired/stimulus"

// Dual-handle range slider over a histogram of price buckets.
//
// The visible Min/Max number inputs hold the EXACT filter values (number or
// null) — they are the source of truth. The slider handles are purely visual:
// their positions (0..N) are derived by snapping a value to the nearest bucket
// boundary. Typing gives any exact value; dragging snaps to a bucket boundary.
//
// Boundaries: array of N price thresholds. Buckets: 0..N-1 representing the
// half-open intervals [boundaries[i], boundaries[i+1]). Bucket N-1 is the
// overflow bucket [boundaries[N-1], +∞). Slider positions are 0..N inclusive,
// where position 0 means "no minimum" and position N means "no maximum".
export default class extends Controller {
  static targets = ["bar", "lowHandle", "highHandle", "track", "rangeLabel", "minInput", "maxInput", "selection"]
  static values = {
    boundaries: Array,
    counts: Array
  }

  connect() {
    this.maxPosition = this.boundariesValue.length // e.g. 24 → positions 0..24
    this.dragging = null

    this.minValue = this.parseInputValue(this.minInputTarget.value)
    this.maxValue = this.parseInputValue(this.maxInputTarget.value)
    this.syncPositionsFromValues()
    this.lastSig = this.signature()

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
      this.minValue = this.lowPos === 0 ? null : this.boundariesValue[this.lowPos]
    } else {
      this.highPos = Math.max(pos, this.lowPos + 1)
      if (this.highPos > this.maxPosition) this.highPos = this.maxPosition
      this.maxValue = this.highPos === this.maxPosition ? null : this.boundariesValue[this.highPos]
    }
    this.writeInputs()
    this.render()
  }

  onPointerUp() {
    if (!this.dragging) return
    this.dragging = null
    document.removeEventListener("pointermove", this.boundPointerMove)
    document.removeEventListener("pointerup", this.boundPointerUp)
    this.commitAndSubmit()
  }

  // Typed entry: the field is authoritative for the exact value. We re-snap the
  // matching handle for visual feedback but never overwrite the typed value with
  // the snapped boundary.
  onMinInput() {
    this.minValue = this.parseInputValue(this.minInputTarget.value)
    // Never let the range invert: a min above the max pushes the max up to match.
    if (this.minValue !== null && this.maxValue !== null && this.minValue > this.maxValue) {
      this.maxValue = this.minValue
    }
    this.syncPositionsFromValues()
    this.commitAndSubmit()
  }

  onMaxInput() {
    this.maxValue = this.parseInputValue(this.maxInputTarget.value)
    // Never let the range invert: a max below the min pulls the min down to match.
    if (this.maxValue !== null && this.minValue !== null && this.maxValue < this.minValue) {
      this.minValue = this.maxValue
    }
    this.syncPositionsFromValues()
    this.commitAndSubmit()
  }

  // Enter commits immediately; preventDefault stops a duplicate native form submit.
  onInputKeydown(event) {
    if (event.key !== "Enter") return
    event.preventDefault()
    if (event.target === this.minInputTarget) this.onMinInput()
    else if (event.target === this.maxInputTarget) this.onMaxInput()
  }

  reset(event) {
    event?.preventDefault()
    this.minValue = null
    this.maxValue = null
    this.lowPos = 0
    this.highPos = this.maxPosition
    this.commitAndSubmit()
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
      this.minValue = this.lowPos === 0 ? null : this.boundariesValue[this.lowPos]
    } else {
      if (event.key === "Home") {
        this.highPos = this.lowPos + 1
      } else if (event.key === "End") {
        this.highPos = this.maxPosition
      } else {
        this.highPos = Math.min(this.maxPosition, Math.max(this.lowPos + 1, this.highPos + step))
      }
      this.maxValue = this.highPos === this.maxPosition ? null : this.boundariesValue[this.highPos]
    }

    this.commitAndSubmit()
  }

  render() {
    // Handles sit at the exact interpolated position of the typed value (not just
    // the nearest bucket edge), so a $120 floor lands between the $100 and $150 bars.
    const lowPct = (this.positionForValue(this.minValue, 0) / this.maxPosition) * 100
    const highPct = (this.positionForValue(this.maxValue, this.maxPosition) / this.maxPosition) * 100
    this.lowHandleTarget.style.left = `${lowPct}%`
    this.highHandleTarget.style.left = `${highPct}%`

    if (this.hasSelectionTarget) {
      this.selectionTarget.style.left = `${lowPct}%`
      this.selectionTarget.style.width = `${Math.max(0, highPct - lowPct)}%`
    }

    // A bucket [b[i], b[i+1]) is active when it overlaps the selected [min, max] range.
    const lo = this.minValue === null ? -Infinity : this.minValue
    const hi = this.maxValue === null ? Infinity : this.maxValue
    this.barTargets.forEach((bar, i) => {
      const bucketLow = this.boundariesValue[i]
      const bucketHigh = i + 1 < this.boundariesValue.length ? this.boundariesValue[i + 1] : Infinity
      const active = bucketHigh > lo && bucketLow < hi
      bar.dataset.active = active ? "true" : "false"
    })

    this.rangeLabelTarget.textContent = this.formatRange()
    this.updateHandleAria()
  }

  // Write the current exact values back to the inputs, re-render, and submit the
  // form — but only if the submitted values actually changed (mirrors the old
  // commit() early-return so a no-op drag/blur doesn't trigger a redundant fetch).
  commitAndSubmit() {
    this.writeInputs()
    this.render()
    const sig = this.signature()
    if (sig === this.lastSig) return
    this.lastSig = sig
    const form = this.element.closest("form")
    if (form) form.requestSubmit()
  }

  writeInputs() {
    const minStr = this.minValue === null ? "" : String(this.minValue)
    const maxStr = this.maxValue === null ? "" : String(this.maxValue)
    if (this.minInputTarget.value !== minStr) this.minInputTarget.value = minStr
    if (this.maxInputTarget.value !== maxStr) this.maxInputTarget.value = maxStr
  }

  signature() {
    return `${this.minInputTarget.value}|${this.maxInputTarget.value}`
  }

  // Derive visual handle positions from the exact values. Positions are only a
  // visual approximation (nearest bucket); they never feed back into the values.
  syncPositionsFromValues() {
    this.lowPos = this.minValue ? this.snapToBoundary(this.minValue) : 0
    this.highPos = this.maxValue ? this.snapToBoundary(this.maxValue) : this.maxPosition
    // Keep the handles from crossing visually without altering the stored values.
    if (this.lowPos >= this.highPos) this.lowPos = Math.max(0, this.highPos - 1)
  }

  parseInputValue(raw) {
    const v = parseFloat(raw)
    return Number.isFinite(v) && v > 0 ? Math.round(v) : null
  }

  snapToBoundary(price) {
    let idx = 0
    for (let i = 0; i < this.boundariesValue.length; i++) {
      if (price >= this.boundariesValue[i]) idx = i
    }
    return idx
  }

  // Map an exact price to a fractional slider position (0..maxPosition) along the
  // equal-width bucket scale, so off-boundary values render at their true spot.
  // Returns `fallback` when the value is null (the unbounded end of the range).
  positionForValue(value, fallback) {
    if (value === null || value === undefined) return fallback
    const b = this.boundariesValue
    if (value <= b[0]) return 0
    for (let i = 0; i < b.length - 1; i++) {
      if (value < b[i + 1]) return i + (value - b[i]) / (b[i + 1] - b[i])
    }
    return this.maxPosition // value is in the overflow bucket (no upper bound)
  }

  formatPrice(v) {
    if (v >= 1000) {
      const k = v / 1000
      return Number.isInteger(k) ? `$${k}k` : `$${k.toFixed(1)}k`
    }
    return `$${v}`
  }

  formatRange() {
    if (this.minValue === null && this.maxValue === null) return "Any price"
    if (this.maxValue === null) return `${this.formatPrice(this.minValue)}+`
    if (this.minValue === null) return `Up to ${this.formatPrice(this.maxValue)}`
    return `${this.formatPrice(this.minValue)} – ${this.formatPrice(this.maxValue)}`
  }

  updateHandleAria() {
    const boundsMin = this.boundariesValue[0] || 0
    const boundsMax = this.boundariesValue[this.boundariesValue.length - 1]
    const lowNow = this.minValue === null ? boundsMin : this.minValue
    const highNow = this.maxValue === null ? boundsMax : this.maxValue

    this.lowHandleTarget.setAttribute("aria-valuemin", String(boundsMin))
    this.lowHandleTarget.setAttribute("aria-valuemax", String(highNow))
    this.lowHandleTarget.setAttribute("aria-valuenow", String(lowNow))
    this.lowHandleTarget.setAttribute("aria-valuetext", this.minValue === null ? "No minimum price" : `Minimum ${this.formatPrice(this.minValue)}`)
    this.highHandleTarget.setAttribute("aria-valuemin", String(lowNow))
    this.highHandleTarget.setAttribute("aria-valuemax", String(boundsMax))
    this.highHandleTarget.setAttribute("aria-valuenow", String(highNow))
    this.highHandleTarget.setAttribute("aria-valuetext", this.maxValue === null ? "No maximum price" : `Maximum ${this.formatPrice(this.maxValue)}`)
  }
}

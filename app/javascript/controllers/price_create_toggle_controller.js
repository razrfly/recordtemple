import { Controller } from "@hotwired/stimulus"

// Inline price-guide-entry create panel.
// Sits next to a form-autocomplete that searches /api/prices.
// On submit, POSTs the new Price to /api/prices and either:
//   (a) writes the new id/name into the record form's price selector, or
//   (b) when linkUrl is set, POSTs the id to the price-review link endpoint
//       and follows the redirect.
export default class extends Controller {
  static targets = [
    "panel", "trigger", "errors",
    "artistIdInput", "labelIdInput", "formatIdInput",
    "artistName", "labelName", "formatName",
    "yearbegin", "yearend", "priceLow", "priceHigh",
    "detail", "footnote", "mediaType",
    "submitButton"
  ]

  static values = {
    url: { type: String, default: "/api/prices" },
    artistSource: String,
    labelSource: String,
    formatSource: String,
    artistNameSource: String,
    labelNameSource: String,
    formatNameSource: String,
    priceIdHidden: String,
    priceLabel: String,
    linkUrl: String
  }

  open(event) {
    event?.preventDefault()
    this.clearErrors()
    this.prefill(this.artistSourceValue, this.artistIdInputTarget, this.hasArtistSourceValue)
    this.prefill(this.labelSourceValue, this.labelIdInputTarget, this.hasLabelSourceValue)
    this.prefill(this.formatSourceValue, this.formatIdInputTarget, this.hasFormatSourceValue)
    this.prefillName(this.artistNameSourceValue, this.hasArtistNameTarget && this.artistNameTarget, this.hasArtistNameSourceValue)
    this.prefillName(this.labelNameSourceValue, this.hasLabelNameTarget && this.labelNameTarget, this.hasLabelNameSourceValue)
    this.prefillName(this.formatNameSourceValue, this.hasFormatNameTarget && this.formatNameTarget, this.hasFormatNameSourceValue, "select")
    this.panelTarget.hidden = false
    if (this.hasTriggerTarget) this.triggerTarget.hidden = true
  }

  close(event) {
    event?.preventDefault()
    this.panelTarget.hidden = true
    if (this.hasTriggerTarget) this.triggerTarget.hidden = false
  }

  prefill(selector, target, present) {
    if (!present) return
    const src = document.querySelector(selector)
    if (src && src.value) target.value = src.value
  }

  prefillName(selector, target, present, kind) {
    if (!present || !target) return
    const src = document.querySelector(selector)
    if (!src) return
    const text = kind === "select"
      ? (src.options?.[src.selectedIndex]?.text || "")
      : src.value
    if (text) target.textContent = text
  }

  async submit(event) {
    event?.preventDefault()
    this.clearErrors()
    this.submitButtonTarget.disabled = true

    const payload = {
      price: {
        artist_id: this.artistIdInputTarget.value,
        label_id: this.labelIdInputTarget.value,
        record_format_id: this.formatIdInputTarget.value,
        yearbegin: this.yearbeginTarget.value,
        yearend: this.yearendTarget.value,
        price_low: this.priceLowTarget.value,
        price_high: this.priceHighTarget.value,
        detail: this.detailTarget.value,
        footnote: this.footnoteTarget.value,
        media_type: this.mediaTypeTarget.value
      }
    }

    try {
      const csrf = document.querySelector('meta[name="csrf-token"]')?.content

      const res = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": csrf
        },
        body: JSON.stringify(payload)
      })

      if (!res.ok) {
        const data = await res.json().catch(() => ({}))
        this.showErrors(data.errors || ["Failed to create. Please try again."])
        return
      }

      const item = await res.json()

      if (this.hasLinkUrlValue) {
        await this.linkAndRedirect(item.id, csrf)
        return
      }

      this.populateSelector(item)
      this.close()
    } catch (err) {
      console.error("Price create failed:", err)
      this.showErrors(["Network error. Please try again."])
    } finally {
      this.submitButtonTarget.disabled = false
    }
  }

  populateSelector(item) {
    if (this.hasPriceIdHiddenValue) {
      const hidden = document.querySelector(this.priceIdHiddenValue)
      if (hidden) hidden.value = item.id
    }
    if (this.hasPriceLabelValue) {
      const label = document.querySelector(this.priceLabelValue)
      if (label) label.value = item.name
    }
  }

  async linkAndRedirect(priceId, csrf) {
    const body = new URLSearchParams({ price_id: priceId })
    const res = await fetch(this.linkUrlValue, {
      method: "POST",
      headers: {
        "Accept": "text/html",
        "X-CSRF-Token": csrf
      },
      body
    })
    if (!res.ok) {
      const data = await res.json().catch(() => ({}))
      this.showErrors(data.errors || ["Failed to link price. Please try again."])
      return
    }
    if (res.redirected) {
      window.location = res.url
    } else {
      window.location.reload()
    }
  }

  clearErrors() {
    this.errorsTarget.hidden = true
    this.errorsTarget.innerHTML = ""
  }

  showErrors(messages) {
    this.errorsTarget.innerHTML = messages.map(m => {
      const div = document.createElement("div")
      div.textContent = m
      return `<li>${div.innerHTML}</li>`
    }).join("")
    this.errorsTarget.hidden = false
  }
}
